/*
 * Copyright (c) 2024 The gem5 project
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "generators/riscv_decode/riscv_decode.hh"

namespace gem5 {

RiscvDecode::RiscvDecode(uint32_t extra_decode_stage_val, RiscvDecoder* decoder)
    : fetch_in_valid_i_reg(0),
      fetch_in_instr_i_reg(0),
      fetch_in_pc_i_reg(0),
      fetch_in_fault_fetch_i_reg(0),
      fetch_in_fault_page_i_reg(0),
      fetch_out_accept_i_reg(0),
      squash_decode_i_reg(0),
      fetch_in_accept_o_val(0),
      fetch_out_valid_o_val(0),
      fetch_out_instr_o_val(0),
      fetch_out_pc_o_val(0),
      fetch_out_fault_fetch_o_val(0),
      fetch_out_fault_page_o_val(0),
      fetch_out_instr_exec_o_val(0),
      fetch_out_instr_lsu_o_val(0),
      fetch_out_instr_branch_o_val(0),
      fetch_out_instr_mul_o_val(0),
      fetch_out_instr_div_o_val(0),
      fetch_out_instr_csr_o_val(0),
      fetch_out_instr_rd_valid_o_val(0),
      fetch_out_instr_invalid_o_val(0),
      decode_valid_reg(0),
      decode_instr_reg(0),
      decode_pc_reg(0),
      decode_fault_fetch_reg(0),
      decode_fault_page_reg(0),
      decode_extra_valid_reg(0),
      decode_extra_instr_reg(0),
      decode_extra_pc_reg(0),
      decode_extra_fault_fetch_reg(0),
      decode_extra_fault_page_reg(0),
      decode_extra_exec_reg(0),
      decode_extra_lsu_reg(0),
      decode_extra_branch_reg(0),
      decode_extra_mul_reg(0),
      decode_extra_div_reg(0),
      decode_extra_csr_reg(0),
      decode_extra_rd_valid_reg(0),
      decode_extra_invalid_reg(0),
      extra_decode_stage(extra_decode_stage_val),
      u_dec(decoder)
{
}

// ---- Input set functions ----

void
RiscvDecode::setFetchInValidI(uint32_t val)
{
    fetch_in_valid_i_reg = val;
}

void
RiscvDecode::setFetchInInstrI(uint32_t val)
{
    fetch_in_instr_i_reg = val;
}

void
RiscvDecode::setFetchInPcI(uint32_t val)
{
    fetch_in_pc_i_reg = val;
}

void
RiscvDecode::setFetchInFaultFetchI(uint32_t val)
{
    fetch_in_fault_fetch_i_reg = val;
}

void
RiscvDecode::setFetchInFaultPageI(uint32_t val)
{
    fetch_in_fault_page_i_reg = val;
}

void
RiscvDecode::setFetchOutAcceptI(uint32_t val)
{
    fetch_out_accept_i_reg = val;
}

void
RiscvDecode::setSquashDecodeI(uint32_t val)
{
    squash_decode_i_reg = val;
}

// ---- Output get functions ----

uint32_t
RiscvDecode::getFetchInAcceptO()
{
    return fetch_in_accept_o_val;
}

uint32_t
RiscvDecode::getFetchOutValidO()
{
    return fetch_out_valid_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrO()
{
    return fetch_out_instr_o_val;
}

uint32_t
RiscvDecode::getFetchOutPcO()
{
    return fetch_out_pc_o_val;
}

uint32_t
RiscvDecode::getFetchOutFaultFetchO()
{
    return fetch_out_fault_fetch_o_val;
}

uint32_t
RiscvDecode::getFetchOutFaultPageO()
{
    return fetch_out_fault_page_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrExecO()
{
    return fetch_out_instr_exec_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrLsuO()
{
    return fetch_out_instr_lsu_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrBranchO()
{
    return fetch_out_instr_branch_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrMulO()
{
    return fetch_out_instr_mul_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrDivO()
{
    return fetch_out_instr_div_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrCsrO()
{
    return fetch_out_instr_csr_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrRdValidO()
{
    return fetch_out_instr_rd_valid_o_val;
}

uint32_t
RiscvDecode::getFetchOutInstrInvalidO()
{
    return fetch_out_instr_invalid_o_val;
}

// ---- Pipeline stage logic ----

void
RiscvDecode::process()
{
    // 1. Run decoder on the current main decode stage values.
    //    Combine fetch fault and page fault into a single fault signal
    //    for the decoder.
    uint32_t decode_fault = decode_fault_fetch_reg | decode_fault_page_reg;
    u_dec->setValidI(decode_valid_reg);
    u_dec->setFetchFaultI(decode_fault);
    u_dec->setEnableMuldivI(1);
    u_dec->setOpcodeI(decode_instr_reg);
    u_dec->process();

    // 2. Determine instruction value: clear instruction on fault.
    uint32_t fault = decode_fault_fetch_reg | decode_fault_page_reg;
    uint32_t instr_val;
    if (fault != 0) {
        instr_val = 0;
    } else {
        instr_val = decode_instr_reg;
    }

    // 3. Handle squash and pipeline advance.
    if (squash_decode_i_reg != 0) {
        // Clear main pipeline stage
        decode_valid_reg = 0;
        if (extra_decode_stage != 0) {
            // Clear extra pipeline stage as well
            decode_extra_valid_reg = 0;
        }
    } else if (fetch_out_accept_i_reg != 0) {
        // Advance pipeline: shift main stage to extra stage if configured
        if (extra_decode_stage != 0) {
            decode_extra_valid_reg = decode_valid_reg;
            decode_extra_instr_reg = instr_val;
            decode_extra_pc_reg = decode_pc_reg;
            decode_extra_fault_fetch_reg = decode_fault_fetch_reg;
            decode_extra_fault_page_reg = decode_fault_page_reg;
            decode_extra_exec_reg = u_dec->getExecO();
            decode_extra_lsu_reg = u_dec->getLsuO();
            decode_extra_branch_reg = u_dec->getBranchO();
            decode_extra_mul_reg = u_dec->getMulO();
            decode_extra_div_reg = u_dec->getDivO();
            decode_extra_csr_reg = u_dec->getCsrO();
            decode_extra_rd_valid_reg = u_dec->getRdValidO();
            decode_extra_invalid_reg = u_dec->getInvalidO();
        }

        // Load new data into main pipeline stage from inputs
        decode_valid_reg = fetch_in_valid_i_reg;
        decode_instr_reg = fetch_in_instr_i_reg;
        decode_pc_reg = fetch_in_pc_i_reg;
        decode_fault_fetch_reg = fetch_in_fault_fetch_i_reg;
        decode_fault_page_reg = fetch_in_fault_page_i_reg;
    }

    // 4. Set output values based on pipeline stage configuration.
    if (extra_decode_stage != 0) {
        // Output from extra pipeline stage (one cycle delayed)
        fetch_out_valid_o_val = decode_extra_valid_reg;
        fetch_out_instr_o_val = decode_extra_instr_reg;
        fetch_out_pc_o_val = decode_extra_pc_reg;
        fetch_out_fault_fetch_o_val = decode_extra_fault_fetch_reg;
        fetch_out_fault_page_o_val = decode_extra_fault_page_reg;
        fetch_out_instr_exec_o_val = decode_extra_exec_reg;
        fetch_out_instr_lsu_o_val = decode_extra_lsu_reg;
        fetch_out_instr_branch_o_val = decode_extra_branch_reg;
        fetch_out_instr_mul_o_val = decode_extra_mul_reg;
        fetch_out_instr_div_o_val = decode_extra_div_reg;
        fetch_out_instr_csr_o_val = decode_extra_csr_reg;
        fetch_out_instr_rd_valid_o_val = decode_extra_rd_valid_reg;
        fetch_out_instr_invalid_o_val = decode_extra_invalid_reg;
    } else {
        // Passthrough mode: output directly from main stage through decoder
        fetch_out_valid_o_val = decode_valid_reg;
        fetch_out_instr_o_val = instr_val;
        fetch_out_pc_o_val = decode_pc_reg;
        fetch_out_fault_fetch_o_val = decode_fault_fetch_reg;
        fetch_out_fault_page_o_val = decode_fault_page_reg;
        fetch_out_instr_exec_o_val = u_dec->getExecO();
        fetch_out_instr_lsu_o_val = u_dec->getLsuO();
        fetch_out_instr_branch_o_val = u_dec->getBranchO();
        fetch_out_instr_mul_o_val = u_dec->getMulO();
        fetch_out_instr_div_o_val = u_dec->getDivO();
        fetch_out_instr_csr_o_val = u_dec->getCsrO();
        fetch_out_instr_rd_valid_o_val = u_dec->getRdValidO();
        fetch_out_instr_invalid_o_val = u_dec->getInvalidO();
    }

    // 5. Backpressure: forward downstream accept signal to fetch stage.
    fetch_in_accept_o_val = fetch_out_accept_i_reg;
}

} // namespace gem5
