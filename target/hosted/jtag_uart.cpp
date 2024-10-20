#include <ncursesw/ncurses.h>

#include "jtag_uart.hpp"
#include "simulation.hpp"

jtag_uart_agent::~jtag_uart_agent() noexcept
{
	this->release();
}

bool jtag_uart_agent::read_relative(unsigned address, unsigned &data) noexcept
{
	bool valid_read;
	bool ctrl_ri;
	bool ctrl_wi;
	bool ctrl_rrdy;

	unsigned char read;

	switch (address) {
		case 0x00:
			read = this->rx[this->rx_next];
			valid_read = this->rx_avail > 0;

			if (valid_read) {
				--this->rx_avail;

				this->rx_next = this->rx_next + 1;
				if (this->rx_next >= sizeof this->rx)
					this->rx_next = 0;
			}

			data
				= this->rx_avail << 16
				| valid_read     << 15
				| (read & 0xff)  << 0;

			break;

		case 0x04:
			ctrl_ri = this->ctrl_re && this->rx_avail > 0;

			// Siempre se puede escribir
			ctrl_wi = this->ctrl_we;

			// Este bit no existe pero U-Boot lo espera por alguna razón
			ctrl_rrdy = this->rx_avail > 0;

			data
				= this->ctrl_re << 0
				| this->ctrl_we << 1
				| ctrl_ri       << 8
				| ctrl_wi       << 9
				| this->ctrl_ac << 10
				| ctrl_rrdy     << 12
				| 63            << 16;

			break;

		default:
			return false;
	}

	return true;
}

bool jtag_uart_agent::write_relative(unsigned address, unsigned data) noexcept
{
	switch (address) {
		case 0x00:
			echochar(data & 0xff);

			this->ctrl_ac = 1;
			break;

		case 0x04:
			this->ctrl_re = !!(data & (1 << 0));
			this->ctrl_we = !!(data & (1 << 1));

			if (data & (1 << 10))
				this->ctrl_ac = 0;

			break;

		default:
			return false;
	}

	return true;
}

void jtag_uart_agent::takeover() noexcept
{
	if (!took_over) {
		assert(::initscr() != nullptr);
		assert(::noecho() != ERR);
		assert(::nodelay(stdscr, TRUE) != ERR);
		assert(::cbreak() != ERR);

		took_over = true;
	}
}

void jtag_uart_agent::release() noexcept
{
	if (took_over) {
		::endwin();
		putchar('\n');
	}
}
