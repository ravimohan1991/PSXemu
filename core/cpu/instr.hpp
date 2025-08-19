#pragma once
#include <memory/range.h>

/**
 * @brief
 * Data structure for the instruction obtained from reading.
 * An instruction 0x3c080013 gets decoded to
 * +---------------
 * | lui $8 , 0x13
 * +---------------
 * meaning load 0x13 (or 19 in decimal) in 16 high bits of register 8.
 *
 * @note 0x3c080013 is the first instruction encountered on PS reset, from BIOS.
 */
struct Instr
{
    /**
     * @brief
     * The actual instruction obtained from reading
     */
    uint value;
    
    /**
     * @brief
     * Returns the bits [31:26] of instruction which is an operation (opcode)
     * for instance LUI (load upper immediate).
     */
    uint opcode() { return value >> 26; }

    //I-Type
    /**
     * @brief
     *
     */
    uint rs() { return (value >> 21) & 0x1F; }//Register Source
    
    /**
     * @brief
     * Returns register target (rt) index in bits [20:16]. For instance register 8.
     */
    uint rt() { return(value >> 16) & 0x1F; }
    
    /**
     * @brief
     * Returns the immediate value residing in bits [15:0]. For instance 19 or 0x13.
     */
    uint imm() { return value & 0xFFFF; } //Immediate value

	/**
	 * @brief
	 * Immediate value sign extended
	 */
	uint imm_s() { return(uint)(int16_t)imm(); }

    //R-Type
    uint rd() { return(value >> 11) & 0x1F; }
    uint sa() { return(value >> 6) & 0x1F; } //Shift Amount
    uint function() { return value & 0x3F; }  //Function

    //J-Type                                       
    uint addr() { return value & 0x3FFFFFF; } //Target Address

    //id / Cop
    uint id() { return opcode() & 0x3; } //This is used mainly for coprocesor opcode id but its also used on opcodes that trigger exception
};
