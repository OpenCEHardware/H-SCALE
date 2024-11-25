#ifndef HOSTED_MAGIC_IO_HPP
#define HOSTED_MAGIC_IO_HPP

#include <cstdint>

#include "simulation.hpp"

class magic_io_agent : public memory_mapped
{
	public:
		inline magic_io_agent(simulation &sim, unsigned base)
		: memory_mapped{sim, base, 2 * sizeof(std::uint64_t)}
		{}

		inline virtual bool read_relative(unsigned address, unsigned &data)
		{
			return false;
		}

		virtual bool write_relative(unsigned address, unsigned data);

		inline void mute() noexcept
		{
			this->muted_ = true;
		}

	private:
		bool muted_ = false;
};

#endif
