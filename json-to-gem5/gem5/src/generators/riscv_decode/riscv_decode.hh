/*
 * Copyright (c) 2024 The gem5 project
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

/**
 * @file
 * RISC-V Decode Stage - Sequential Submodule
 *
 * Pipeline register stage between Fetch and Issue. Holds fetched instruction,
 * PC, and fault information. Instantiates riscv_decoder combinational module
 * for instruction type decoding. Supports optional extra decode pipeline stage
 * controlled by EXTRA_DECODE_STAGE parameter.
 *
 * Usage:
 *   1. Call setXxx() functions to set input values
 *   2. Call process() to advance pipeline and compute combinational logic
 *   3. Call getXxx() functions to read output values
 */

#ifndef __GENERATORS_RISCV_DECODE_RISCV_DECODE_HH__
#define __GENERATORS_RISCV_DECODE_RISCV_DECODE_HH__

#include <cstdint>

#include "generators/riscv_decoder/riscv_decoder.hh"

namespace gem5 {

class RiscvDecode
{
  private:
    // -- Input ports --
    uint32_t fetch_in_valid_i_reg;
    uint32_t fetch_in_instr_i_reg;
    uint32_t fetch_in_pc_i_reg;
    uint32_t fetch_in_fault_fetch_i_reg;
    uint32_t fetch_in_fault_page_i_reg;
    uint32_t fetch_out_accept_i_reg;
    uint32_t squash_decode_i_reg;

    // -- Output ports --
    uint32_t fetch_in_accept_o_val;
    uint32_t fetch_out_valid_o_val;
    uint32_t fetch_out_instr_o_val;
    uint32_t fetch_out_pc_o_val;
    uint32_t fetch_out_fault_fetch_o_val;
    uint32_t fetch_out_fault_page_o_val;
    uint32_t fetch_out_instr_exec_o_val;
    uint32_t fetch_out_instr_lsu_o_val;
    uint32_t fetch_out_instr_branch_o_val;
    uint32_t fetch_out_instr_mul_o_val;
    uint32_t fetch_out_instr_div_o_val;
    uint32_t fetch_out_instr_csr_o_val;
    uint32_t fetch_out_instr_rd_valid_o_val;
    uint32_t fetch_out_instr_invalid_o_val;

    // -- State registers (main pipeline stage) --
    uint32_t decode_valid_reg;
    uint32_t decode_instr_reg;
    uint32_t decode_pc_reg;
    uint32_t decode_fault_fetch_reg;
    uint32_t decode_fault_page_reg;

    // -- State registers (extra pipeline stage, used when extra_decode_stage != 0) --
    uint32_t decode_extra_valid_reg;
    uint32_t decode_extra_instr_reg;
    uint32_t decode_extra_pc_reg;
    uint32_t decode_extra_fault_fetch_reg;
    uint32_t decode_extra_fault_page_reg;
    uint32_t decode_extra_exec_reg;
    uint32_t decode_extra_lsu_reg;
    uint32_t decode_extra_branch_reg;
    uint32_t decode_extra_mul_reg;
    uint32_t decode_extra_div_reg;
    uint32_t decode_extra_csr_reg;
    uint32_t decode_extra_rd_valid_reg;
    uint32_t decode_extra_invalid_reg;

    // -- Parameters --
    uint32_t extra_decode_stage;

    // -- Submodule reference (non-owning pointer) --
    RiscvDecoder* u_dec;

  public:
    RiscvDecode(uint32_t extra_decode_stage_val, RiscvDecoder* decoder);

    // ---- Input set functions ----
    void setFetchInValidI(uint32_t val);
    void setFetchInInstrI(uint32_t val);
    void setFetchInPcI(uint32_t val);
    void setFetchInFaultFetchI(uint32_t val);
    void setFetchInFaultPageI(uint32_t val);
    void setFetchOutAcceptI(uint32_t val);
    void setSquashDecodeI(uint32_t val);

    // ---- Output get functions ----
    uint32_t getFetchInAcceptO();
    uint32_t getFetchOutValidO();
    uint32_t getFetchOutInstrO();
    uint32_t getFetchOutPcO();
    uint32_t getFetchOutFaultFetchO();
    uint32_t getFetchOutFaultPageO();
    uint32_t getFetchOutInstrExecO();
    uint32_t getFetchOutInstrLsuO();
    uint32_t getFetchOutInstrBranchO();
    uint32_t getFetchOutInstrMulO();
    uint32_t getFetchOutInstrDivO();
    uint32_t getFetchOutInstrCsrO();
    uint32_t getFetchOutInstrRdValidO();
    uint32_t getFetchOutInstrInvalidO();

    /**
     * Pipeline stage logic. Called each cycle by the parent module.
     * Advances the pipeline: decodes current instruction, handles squash,
     * shifts pipeline registers, and computes outputs.
     */
    void process();
};

} // namespace gem5

#endif // __GENERATORS_RISCV_DECODE_RISCV_DECODE_HH__
