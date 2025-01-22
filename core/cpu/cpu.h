/**
 * @file cpu.h
 */
#pragma once
#include <memory/bus.h>
#include <cpu/gte.h>
#include <cpu/instr.hpp>
#include <cpu/cop0.h>
#include <fstream>

struct MEM
{
    uint reg = 0;
    uint value = 0;
};

typedef std::function<void()> CPUfunc;

/* Memory Ranges. */
const Range KSEG = Range(0x00000000, 2048 * 1024 * 1024LL);
const Range KSEG0 = Range(0x80000000, 512 * 1024 * 1024LL);
const Range KSEG1 = Range(0xA0000000, 512 * 1024 * 1024LL);
const Range KSEG2 = Range(0xC0000000, 1024 * 1024 * 1024LL);
const Range INTERRUPT = Range(0x1f801070, 8);

/**
 * @brief
 * A class implemeting the MIPS R3000A CPU having von-Neumann
 * architecture. The addresses are 32 bits of memory locations including
 * the peripherals. For perspective, PS5 uses properitery (hehe) variation
 * of Zen 2 microarchitecture (https://en.wikipedia.org/wiki/Zen_2).
 *
 * @note There are 67 opcodes in playstation's MIPS CPU and
 * they are defined in this class
 */
class CPU
{
public:
    /**
     * @brief
     * Does the following:
     * 1. Initializes PS bus,
     * 2. coprocessor (Cop0) Processor Revision Identifier,
     * 3. opcode registration, and
     * 4. reset (CPU::reset()) or clean slate :D
     *
     * @param bus                               The ``Bus`` object created using BIOS
     */
    CPU(Bus* bus);
    
    /**
     * @brief
     * A destructor which closes logfile atm
     */
    ~CPU();

    /**
     * @brief
     * CPU functionality. See ``/core/Bus/tick``, ``/core/CPU/fetch``.
     *
     * @note
     * A typical CPU execution cycle (tick?) goes roughly like this:
     * 1. Fetch the instruction located at address PC,
     * 2. Increment the PC to point to the next instruction,
     * 3. Execute the instruction,
     * 4. Repeat
     */
    void tick();

    /**
     * @brief
     * Basically restart the system in a clean and deterministic
     * state. The docs say that reset value of PC is 0xbfc00000 which
     * translates to the begining of PS1 Bios in memory map
     */
    void reset();
    
    /**
     * @brief
     * Fetches the instruction by reading the ``pc`` address and does the appropriate increment.
     * See ``/core/CPU/tick``.
     *
     * @note
     * The read instruction is stored in ``instr``
     * @note
     * A typical CPU execution cycle (tick?) goes roughly like this:
     * 1. Fetch the instruction located at address PC,
     * 2. Increment the PC to point to the next instruction,
     * 3. Execute the instruction,
     * 4. Repeat
     */
    void fetch();
    
    /**
     * @brief
     * No clue.
     * Seems like ``next_pc`` component of program counter is assigned ``/core/Instr/imm_s`` shifted by 2^2
     * @code{.cpp}
     * instr.imm_s() << 2
     * @endcode
     *
     * @note
     * A branch, jump or transfer is an instruction in a computer program that can cause a computer to begin executing a
     * different instruction sequence and thus deviate from its default behavior of executing instructions in order. Branch (or
     * branching, branched) may also refer to the act of switching execution to a different instruction sequence as a result of
     * executing a branch instruction. Branch instructions are used to implement control flow in program loops and
     * conditionals (i.e., executing a particular sequence of instructions only if certain conditions are satisfied).
     */
    void branch();
    
    /**
     * @brief
     * Registration of opcodes by creating a lookup table with key-value
     * pair with key being some address in bios ? (to be made clear later) and value is address of op function
     *
     * @see
     * ``lookup``
     *
     */
    void register_opcodes();
    
    /**
     * @brief
     * Handle requested interrupts. See ``/core/Bus/tick``.
     *
     * @note
     * Interrupts are a signal coming from the peripherals to the CPU to notify it
     * that a certain event occurred (a timer reached its target value, a button was
     * pressed on the controller etc. . . ). This way the CPU doesn’t have to waste time
     * polling the status of the various peripherals, it can just wait for the interrupt notification.
     */
    void handle_interrupts();
    
    /**
     * 
     */
    void handle_load_delay();
    void force_test();

    void break_on_next_tick();

    void exception(ExceptionType cause, uint cop = 0);
    void set_reg(uint regN, uint value);
    void load(uint regN, uint value);

    /* Bus communication. */
    template <typename T = uint>
    T read(uint addr);
    
    template <typename T = uint>
    void write(uint addr, T data);

    /**
     * @brief
     * Means interrupt request
     */
    uint read_irq(uint address);
    void write_irq(uint address, uint value);
    void trigger(Interrupt interrupt);

    /* Opcodes. */
    void op_special(); void op_cop2(); void op_cop0();
    void op_lwc2(); void op_swc2(); void op_mfc2(); void op_mtc2();
    void op_cfc2(); void op_ctc2();

    /* Read/Write instructions. */
    void op_lhu(); void op_lh(); void op_lbu(); void op_sw();
    void op_swr(); void op_swl(); void op_lwr(); void op_lwl();
    void op_lui(); void op_sb(); void op_lw(); void op_lb();
    void op_sh();

    /* Bitwise manipulation instructions. */
    void op_and(); void op_andi(); void op_xor(); void op_xori();
    void op_nor(); void op_or(); void op_ori();

    /* Jump and branch instructions. */
    void op_bcond(); void op_jalr(); void op_blez(); void op_bgtz(); 
    void op_j(); void op_beq(); void op_jr(); void op_jal();
    void op_bne();

    /* Arithmetic instructions. */
    void op_add(); void op_addi(); void op_addu(); void op_addiu(); 
    void op_sub(); void op_subu(); void op_mult(); void op_multu();
    void op_div(); void op_divu();
  
    /* Bit shift-rotation instructions. */
    void op_srl(); void op_srlv(); void op_sra(); void op_srav();
    void op_sll(); void op_sllv(); void op_slt(); void op_slti();
    void op_sltu(); void op_sltiu();

    /* HI/LO instructions. */
    void op_mthi(); void op_mtlo(); void op_mfhi(); void op_mflo();

    /* Exception instructions. */
    void op_break(); void op_syscall(); void op_rfe();
    
    /* Coprocessor instructions. */
    void op_mfc0(); void op_mtc0();                      

public:
    Bus* bus;

    /* Registers. */
    
    /**
     * @brief
     * Program counter register
     *
     * @note We are using unsigned 32bit because PS1 uses 32bit addresses
     */
    uint pc;
    
    /**
     * @brief
     * Cache for current value (address) of program counter
     */
    uint current_pc;
    
    /**
     * @brief
     * Cache for address of next instruction of program counter (``pc``).
     */
    uint next_pc;
    uint i_stat, i_mask;
    uint registers[32] = {};
    uint hi, lo;

    /* Flow control. */
    bool is_branch, is_delay_slot;
    bool took_branch;
    bool in_delay_slot_took_branch;
    
    /* Debugging. */
    bool should_break = false;
    bool should_log = false;
    bool exe = false;
    
    /**
     * @brief
     * File for logging the current status
     */
    std::ofstream log_file;
    int cycle_int = 20000;
    bool flip = true;

    uint exception_addr[2] = { 0x80000080, 0xBFC00180 };
    
    /* I-Cache. */
    CacheLine instr_cache[256] = {};
    CacheControl cache_control = {};

    /* Coprocessors. */
    Cop0 cop0;
    GTE gte;

    MEM write_back, memory_load;
    MEM delayed_memory_load;

    /**
     * @brief
     * Current instruction
     */
    Instr instr;

    /* Opcode lookup table. */
    std::unordered_map<uint, CPUfunc> lookup, special;
};

template<typename T>
inline T CPU::read(uint addr)
{
    KR_CORE_INFO("Attempting to read virtual address {0:x} using bus", addr);
    
    /* Read from main RAM or IO. */
    return bus->read<T>(addr);
}

template<typename T>
inline void CPU::write(uint addr, T data)
{
    /* Write to main RAM or IO. */
    bus->write<T>(addr, data);
}
