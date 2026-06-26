/*
 * Copyright (c) 2024 The gem5 project
 *
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "generators/riscv_decoder/riscv_decoder.hh"

namespace gem5 {

RiscvDecoder::RiscvDecoder()
    : valid_i_reg(0),
      fetch_fault_i_reg(0),
      enable_muldiv_i_reg(0),
      opcode_i_reg(0),
      invalid_o_val(0),
      exec_o_val(0),
      lsu_o_val(0),
      branch_o_val(0),
      mul_o_val(0),
      div_o_val(0),
      csr_o_val(0),
      rd_valid_o_val(0)
{
}

// ---- Input set functions ----

void
RiscvDecoder::setValidI(uint32_t val)
{
    valid_i_reg = val;
}

void
RiscvDecoder::setFetchFaultI(uint32_t val)
{
    fetch_fault_i_reg = val;
}

void
RiscvDecoder::setEnableMuldivI(uint32_t val)
{
    enable_muldiv_i_reg = val;
}

void
RiscvDecoder::setOpcodeI(uint32_t val)
{
    opcode_i_reg = val;
}

// ---- Output get functions ----

uint32_t
RiscvDecoder::getInvalidO()
{
    return invalid_o_val;
}

uint32_t
RiscvDecoder::getExecO()
{
    return exec_o_val;
}

uint32_t
RiscvDecoder::getLsuO()
{
    return lsu_o_val;
}

uint32_t
RiscvDecoder::getBranchO()
{
    return branch_o_val;
}

uint32_t
RiscvDecoder::getMulO()
{
    return mul_o_val;
}

uint32_t
RiscvDecoder::getDivO()
{
    return div_o_val;
}

uint32_t
RiscvDecoder::getCsrO()
{
    return csr_o_val;
}

uint32_t
RiscvDecoder::getRdValidO()
{
    return rd_valid_o_val;
}

// ---- Combinational decode logic ----

void
RiscvDecoder::process()
{
    // Default all outputs to 0
    invalid_o_val = 0;
    exec_o_val = 0;
    lsu_o_val = 0;
    branch_o_val = 0;
    mul_o_val = 0;
    div_o_val = 0;
    csr_o_val = 0;
    rd_valid_o_val = 0;

    // If input not valid or fetch fault occurred, all outputs stay 0
    if (valid_i_reg == 0 || fetch_fault_i_reg != 0) {
        return;
    }

    // Extract instruction fields using bitwise operations (no array indexing)
    uint32_t opcode = opcode_i_reg & 0x7F;            // bits [6:0]
    uint32_t funct3 = (opcode_i_reg >> 12) & 0x7;     // bits [14:12]
    uint32_t funct7 = (opcode_i_reg >> 25) & 0x7F;    // bits [31:25]

    // Decode based on primary opcode
    if (opcode == 0x33) {
        // R-type: OP (0x33 = 7'b0110011)
        if (funct7 == 0x00) {
            // Standard ALU: ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
            exec_o_val = 1;
            rd_valid_o_val = 1;
        } else if (funct7 == 0x20) {
            // Standard ALU with alt funct7: SUB, SRA
            exec_o_val = 1;
            rd_valid_o_val = 1;
        } else if (funct7 == 0x01) {
            // M-extension (requires enable_muldiv_i)
            if (enable_muldiv_i_reg != 0) {
                if ((funct3 & 0x4) == 0) {
                    // funct3 = 000, 001, 010, 011: MUL, MULH, MULHSU, MULHU
                    mul_o_val = 1;
                } else {
                    // funct3 = 100, 101, 110, 111: DIV, DIVU, REM, REMU
                    div_o_val = 1;
                }
                rd_valid_o_val = 1;
            }
            // When enable_muldiv_i == 0: no category matches → invalid
        }
        // Any other funct7 value: illegal R-type → invalid_o stays 1

    } else if (opcode == 0x13) {
        // I-type: OP-IMM (0x13 = 7'b0010011)
        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        exec_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x03) {
        // Load: LB, LH, LW, LBU, LHU (0x03 = 7'b0000011)
        lsu_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x23) {
        // Store: SB, SH, SW (0x23 = 7'b0100011)
        lsu_o_val = 1;
        // Stores do not write rd

    } else if (opcode == 0x63) {
        // Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU (0x63 = 7'b1100011)
        branch_o_val = 1;
        // Branches do not write rd

    } else if (opcode == 0x6F) {
        // JAL (0x6F = 7'b1101111)
        branch_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x67) {
        // JALR (0x67 = 7'b1100111)
        branch_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x37) {
        // LUI (0x37 = 7'b0110111)
        exec_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x17) {
        // AUIPC (0x17 = 7'b0010111)
        exec_o_val = 1;
        rd_valid_o_val = 1;

    } else if (opcode == 0x73) {
        // SYSTEM: (0x73 = 7'b1110011)
        // CSR access (CSRRW, CSRRS, CSRRC, CSRRWI, CSRRSI, CSRRCI)
        // and system instructions (ECALL, EBREAK, MRET, WFI, SFENCE.VMA)
        csr_o_val = 1;
        if (funct3 != 0) {
            // CSR access instructions write rd (old CSR value)
            rd_valid_o_val = 1;
        }
        // funct3 == 0: system instructions, no rd write

    } else if (opcode == 0x0F) {
        // FENCE, FENCE.I (0x0F = 7'b0001111)
        csr_o_val = 1;
        // FENCE does not write rd

    } else {
        // Unknown opcode: illegal instruction
        invalid_o_val = 1;
    }

    // Ensure mul_o and div_o are 0 when M-extension is disabled
    if (enable_muldiv_i_reg == 0) {
        mul_o_val = 0;
        div_o_val = 0;
    }
}

} // namespace gem5
