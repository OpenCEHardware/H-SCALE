#include <atomic>
#include <chrono>
#include <cinttypes>
#include <cstdint>
#include <cstdio>
#include <memory>

#include "Vtop.h"

#include "simulation.hpp"

namespace
{
	constexpr std::size_t AXI_MAX_PENDING = 3;
}

memory_mapped::memory_mapped(simulation &sim, unsigned base, unsigned len)
: sim{sim}, base{base}, len{len}
{
	unsigned start = base;
	unsigned end = base + len - 1;

	auto &mappings = sim.mappings;

	bool retry;
	do {
		retry = false;

		auto it = mappings.begin();
		while (it != mappings.end()) {
			if (end >= it->start && start <= it->end) {
				unsigned keep_lo = std::min(it->end + 1, std::max(it->start, start)) - it->start;
				unsigned keep_hi = it->end + 1 - std::max(it->start, std::min(it->end + 1, end + 1));

				if (keep_lo != 0 && keep_hi != 0) {
					simulation::mapping hi_half{it->end - keep_hi + 1, it->end, it->agent};

					it->end = it->start + keep_lo - 1;
					mappings.insert(++it, hi_half);

					retry = true;
					break;
				} else if (keep_lo != 0) {
					it->end = it->start + keep_lo - 1;
				} else if (keep_hi != 0) {
					it->start = it->end - keep_hi + 1;
				} else {
					mappings.erase(it);

					retry = true;
					break;
				}
			}

			++it;
		}
	} while (retry);

	auto it = mappings.begin();
	while (it != mappings.end()) {
		if (base < it->start)
			break;

		++it;
	}

	mappings.insert(it, simulation::mapping{base, end, this});
}

memory_mapped::memory_mapped(memory_mapped &&other)
: sim{other.sim}, base{other.base}, len{other.len}
{
	auto &mappings = this->sim.mappings;
	for (auto it = mappings.begin(); it != mappings.end(); ++it)
		if (it->agent == &other)
			it->agent = this;
}

memory_mapped::~memory_mapped()
{
	auto &mappings = this->sim.mappings;
	for (auto it = mappings.begin(); it != mappings.end(); ++it)
		if (it->agent == this) {
			mappings.erase(it);
			break;
		}
}

bool memory_mapped::write_relative_strobe(unsigned address, unsigned data, unsigned strobe)
{
	unsigned current;
	if (!this->read_relative(address, current))
		return false;

	unsigned mask = 0;

	if (strobe & 0b0001)
		mask |= 0x000000ff;

	if (strobe & 0b0010)
		mask |= 0x0000ff00;

	if (strobe & 0b0100)
		mask |= 0x00ff0000;

	if (strobe & 0b1000)
		mask |= 0xff000000;

	return this->write_relative(address, (data & mask) | (current & ~mask));
}

int simulation::run()
{
	if (!this->top) {
		this->top = std::make_unique<Vtop>();
		auto &top = *this->top;

#if VM_TRACE
		if (!this->trace_path.empty()) {
#if VM_TRACE_FST
			this->trace = std::make_unique<VerilatedFstC>();
#else
			this->trace = std::make_unique<VerilatedVcdC>();
#endif

			Verilated::traceEverOn(true);
			top.trace(&*this->trace, 0);
			this->trace->open(this->trace_path.c_str());

			this->trace_path.clear();
		}
#endif

		top.sys_bvalid = 0;
		top.sys_rvalid = 0;
		top.sys_wready = 0;
		top.sys_arready = 0;
		top.sys_awready = 0;

		top.clk = 0;
		top.rst_n = 0;

		this->run_cycles(2);

		top.rst_n = 1;
		this->top->eval();
	}

	constexpr unsigned HOT_LOOP_CYCLES = 8;

	auto start = std::chrono::steady_clock::now();

	do {
		do
			this->run_cycles(HOT_LOOP_CYCLES);
		while (!this->has_pending_io() && !this->halting());

		bool io_idle;
		do {
			do
				this->io_cycle();
			while (this->has_pending_io() && !this->halting());

			if (this->halting())
				break;

			io_idle = true;
			for (unsigned i = 0; i < HOT_LOOP_CYCLES; ++i) {
				this->run_cycles(1);

				if (this->has_pending_io()) {
					io_idle = false;
					break;
				}
			}
		} while (!io_idle);
	} while (!this->halting());

	auto end = std::chrono::steady_clock::now();

	if (this->timed_out_)
		std::fputs("Simulation timed out!\n", stderr);

	int exit_code = this->exit_code_;
	this->io_cycle();

	this->exit_code_ = 0;
	this->timed_out_ = false;
	this->halt_.store(false, std::memory_order_release);

	auto cycles = this->cycles();
	auto micros = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();

	float cycles_per_ms = cycles * 1000 / static_cast<float>(micros);
	if (micros == 0)
		cycles_per_ms = 0.0;

	std::fprintf(
		stderr,
		"Exited with status %u after %" PRIu64 " cycles in %.5fs (~%.1f cycles/ms)\n",
		exit_code, cycles, static_cast<float>(micros) / 1'000'000, cycles_per_ms
	);

	return exit_code;
}

bool simulation::has_pending_io()
{
	auto &top = *this->top;

	return top.sys_bvalid
	    || top.sys_rvalid
	    || top.sys_wready
	    || top.sys_wvalid
	    || top.sys_arready
	    || top.sys_arvalid
	    || top.sys_arready
	    || top.sys_awvalid;
}

void simulation::io_cycle()
{
	auto &top = *this->top;

	this->sys_r_queue.read_tx(
		top.sys_rready,
		top.sys_rvalid,
		top.sys_rid,
		top.sys_rdata,
		top.sys_rresp,
		top.sys_rlast
	);

	this->sys_w_queue.write_tx(
		top.sys_bready,
		top.sys_bvalid,
		top.sys_bid,
		top.sys_bresp
	);

	this->sys_r_queue.read_begin(top.sys_arready, top.sys_arvalid);
	this->sys_w_queue.write_begin(top.sys_awready, top.sys_awvalid, top.sys_wready, top.sys_wvalid);

	top.eval();

	this->sys_r_queue.addr_rx(
		top.sys_arready,
		top.sys_arvalid,
		top.sys_arid,
		top.sys_arlen,
		top.sys_arsize,
		top.sys_arburst,
		top.sys_araddr
	);

	this->sys_w_queue.addr_rx(
		top.sys_awready,
		top.sys_awvalid,
		top.sys_awid,
		top.sys_awlen,
		top.sys_awsize,
		top.sys_awburst,
		top.sys_awaddr
	);

	bool write_rx_ok = this->sys_w_queue.write_rx(
		top.sys_wready,
		top.sys_wvalid,
		top.sys_wdata,
		top.sys_wlast,
		top.sys_wstrb
	);

	this->sys_r_queue.read_end(top.sys_rready, top.sys_rvalid);
	this->sys_w_queue.write_end(top.sys_bready, top.sys_bvalid);

	auto callback = [this](unsigned address)
	{
		return this->resolve_address(address);
	};

	this->sys_r_queue.do_reads(callback);
	this->sys_w_queue.do_writes(callback);

	if (!write_rx_ok) [[unlikely]]
		top.eval();

	this->run_cycles(1);
}

void simulation::run_cycles(unsigned cycles)
{
	auto &top = *this->top;
	for (unsigned i = 0; i < cycles; ++i) {
#if VM_TRACE
		if (this->trace)
			trace->dump(this->time_);
#endif

		this->time_++;
		top.clk = 0;
		top.eval();

#if VM_TRACE
		if (this->trace)
			trace->dump(this->time_);
#endif

		this->time_++;
		top.clk = 1;
		top.eval();
	}
}

memory_mapped *simulation::resolve_address(unsigned address)
{
	for (auto &mapping : this->mappings)
	{
		if (address < mapping.start)
			return nullptr;
		else if (mapping.end >= address)
			return mapping.agent;
	}

	return nullptr;
}
