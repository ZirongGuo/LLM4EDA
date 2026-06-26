/*
 * Copyright (c) 2024 The gem5 project
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

/**
 * @file
 * RISC-V Instruction Decoder - Combinational Submodule
 *
 * Decodes a 32-bit RISC-V instruction and classifies it into
 * the appropriate execution unit category.
 *
 * Inputs:  valid_i, fetch_fault_i, enable_muldiv_i, opcode_i
 * Outputs: invalid_o, exec_o, lsu_o, branch_o, mul_o, div_o, csr_o, rd_valid_o
 *
 * Usage:
 *   1. Call setXxx() functions to set input values
 *   2. Call process() to compute combinational logic
 *   3. Call getXxx() functions to read output values
 */

#ifndef __GENERATORS_RISCV_DECODER_RISCV_DECODER_HH__
#define __GENERATORS_RISCV_DECODER_RISCV_DECODER_HH__

#include <cstdint>

namespace gem5 {

class RiscvDecoder
{
  private:
    // -- Input ports --
    uint32_t valid_i_reg;
    uint32_t fetch_fault_i_reg;
    uint32_t enable_muldiv_i_reg;
    uint32_t opcode_i_reg;

    // -- Output ports --
    uint32_t invalid_o_val;
    uint32_t exec_o_val;
    uint32_t lsu_o_val;
    uint32_t branch_o_val;
    uint32_t mul_o_val;
    uint32_t div_o_val;
    uint32_t csr_o_val;
    uint32_t rd_valid_o_val;

  public:
    RiscvDecoder();

    // ---- Input set functions ----
    void setValidI(uint32_t val);
    void setFetchFaultI(uint32_t val);
    void setEnableMuldivI(uint32_t val);
    void setOpcodeI(uint32_t val);

    // ---- Output get functions ----
    uint32_t getInvalidO();
    uint32_t getExecO();
    uint32_t getLsuO();
    uint32_t getBranchO();
    uint32_t getMulO();
    uint32_t getDivO();
    uint32_t getCsrO();
    uint32_t getRdValidO();

    /**
     * Combinational decode logic.
     * Reads input registers, computes outputs, writes output registers.
     * Must be called after all inputs are set and before outputs are read.
     */
    void process();
};

} // namespace gem5

#endif // __GENERATORS_RISCV_DECODER_RISCV_DECODER_HH__
