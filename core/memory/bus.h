#pragma once
#include <memory/dma.h>
#include <devices/cdrom_drive.hpp>
#include <devices/timer.h>
#include <devices/controller.h>
#include <tools/debugger.hpp>
#include <cpu/cache.h>
#include <video/gpu_core.h>
#include <devices/timer.h>

enum class ExceptionType {
	Interrupt = 0x0,
	ReadError = 0x4,
	WriteError = 0x5,
	BusError = 0x6,
	Syscall = 0x8,
	Break = 0x9,
	IllegalInstr = 0xA,
	CoprocessorError = 0xB,
	Overflow = 0xC
};

struct PSEXELoadInfo {
	uint pc;
	uint r28;
	uint r29;
	uint r30;
};

/* Forward declarations. */
class CPU;
class SPU;
class Renderer;
class Expansion2;

struct GLFWwindow;

/**
 * @brief
 * A system bus is a set of electronic cables that connects a computer's main
 * components (CPU, memory, and I/O devices), allowing data to be transferred between them.
 *
 * The system bus is made up of three types of buses:
 * 1. Data bus: Carries the data being transferred
 * 2. Address bus: Determines the location of the data
 * 3. Control bus: Manages the timing and direction of data flow
 */
class Bus
{
public:
	Bus(const std::string& bios_path);
	~Bus() = default;

    /**
     * @brief
     * Read the memory at address
     *
     * @param addr                                          The address to be read
     */
	template <typename T = uint>
	T read(uint addr);

	template <typename T = uint>
	void write(uint addr, T data);

	/**
	 * @brief
	 * Ticking of ``Bus``
	 */
	void tick();
	void irq(Interrupt interrupt) const;
	
	/**
	 * Get the physical memory address from the virtual one.
	 *
	 * Mask a CPU address to remove the region bits.
	 */
	uint physical_addr(uint addr);
	
	bool loadEXE(std::string test, PSEXELoadInfo& info);
	static void key_callback(GLFWwindow* window, int key, int scancode,
												 int action, int mods);

public:
	/* Peripherals. */
	std::unique_ptr<Timer> timers[3];
	std::unique_ptr<DMAController> dma;
	std::unique_ptr<ControllerManager> controller;
	std::unique_ptr<CDManager> cddrive;

	/* Components. */
	std::unique_ptr<Renderer> renderer;
	std::unique_ptr<GPU> gpu;
	std::shared_ptr<CPU> cpu;
	std::shared_ptr<SPU> spu;
	std::shared_ptr<Expansion2> exp2;

	/* Debugging. */
	std::unique_ptr<DEBugger> debugger;
	bool debug_enable = false;

	/* Memory regions. */
	uint spu_delay = 0;
	ubyte registers[4 * 1024] = {};
	ubyte ram[2048 * 1024] = {};
	ubyte scratchpad[1024] = {};
    
    /**
     * @brief
     * Buffer for PS1 BIOS (firmware) file loading
     *
     * @note
     * The size is in bytes, 512 kilo bytes (ubyte is one unsigned byte)
     */
	ubyte bios[512 * 1024] = {};
	ubyte ex1[512 * 1024] = {};
	
	/**
	 * Mask repeated memory regions.
	 *
	 * Mask array used to strip the region bits of the address . The
	 * mask is selected using the 3 MSBs of the address so each entry
	 * effectively matches 512kB of the address space . KSEG2 i s not
	 * touched since it doesn’t share anything with the other regions
	 */
	const uint region_mask[8] = {
		// KUSEG: 2048MB
		0xffffffff, 0xffffffff, 0xffffffff, 0xffffffff,
		// KSEG0: 512MB
		0x7fffffff,
		// KSEG1: 512MB
		0x1fffffff,
		// KSEG2: 1024MB
		0xffffffff, 0xffffffff,
	};

	/* Memory ranges. */
	const Range RAM = Range(0x00000000, 2 * 1024 * 1024LL);
	const Range BIOS = Range(0x1fc00000, 512 * 1024LL);
	const Range TIMERS = Range(0x1f801100, 0x30);
	const Range RAM_SIZE = Range(0x1f801060, 4);
	const Range SPU_RANGE = Range(0x1f801c00, 640);
	const Range EXPANSION_2 = Range(0x1f802000, 66);
	const Range EXPANSION_1 = Range(0x1f000000, 512 * 1024);
	const Range CACHE_CONTROL = Range(0xfffe0130, 4);
	const Range SYS_CONTROL = Range(0x1f801000, 36);
	const Range CDROM = Range(0x1f801800, 0x4);
	const Range PAD_MEMCARD = Range(0x1f801040, 15);
	const Range DMA_RANGE = Range(0x1f801080, 0x80LL);
	const Range SCRATCHPAD = Range(0x1f800000, 1024LL);
};
