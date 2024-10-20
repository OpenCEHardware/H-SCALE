#ifndef HOSTED_JTAG_UART_HPP
#define HOSTED_JTAG_UART_HPP

#include "simulation.hpp"

class jtag_uart_agent : public memory_mapped
{
	public:
		inline jtag_uart_agent(simulation &sim, unsigned base)
		: memory_mapped{sim, base, 2 * sizeof(unsigned)}
		{}

		~jtag_uart_agent() noexcept;

		virtual bool read_relative(unsigned address, unsigned &data) noexcept final override;
		virtual bool write_relative(unsigned address, unsigned data) noexcept final override;

		void takeover() noexcept;
		void release() noexcept;

	private:
		unsigned      countdown = 0;
		unsigned      rx_avail  = 0;
		unsigned      rx_next   = 0;
		bool          ctrl_re   = false;
		bool          ctrl_we   = false;
		bool          ctrl_ac   = true;
		bool          took_over = false;
		unsigned char rx[64];
};

#endif
