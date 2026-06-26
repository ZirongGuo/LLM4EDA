#include "generators/riscv_exec/riscv_exec.hh"

namespace gem5 {

RiscvExec::RiscvExec(const RiscvExecParams &p)
    : SimObject(p),
      opcode_valid_i_reg(0),
      opcode_opcode_i_reg(0),
      opcode_pc_i_reg(0),
      opcode_invalid_i_reg(0),
      opcode_rd_idx_i_reg(0),
      opcode_ra_idx_i_reg(0),
      opcode_rb_idx_i_reg(0),
      opcode_ra_operand_i_reg(0),
      opcode_rb_operand_i_reg(0),
      hold_i_reg(0),
      branch_request_o_val(0),
      branch_is_taken_o_val(0),
      branch_is_not_taken_o_val(0),
      branch_source_o_val(0),
      branch_is_call_o_val(0),
      branch_is_ret_o_val(0),
      branch_is_jmp_o_val(0),
      branch_pc_o_val(0),
      branch_d_request_o_val(0),
      branch_d_pc_o_val(0),
      branch_d_priv_o_val(0),
      writeback_value_o_val(0),
      alu(*p.alu)
{
}

void
RiscvExec::setOpcodeValid(uint8_t val)
{
    opcode_valid_i_reg = val;
}

void
RiscvExec::setOpcodeOpcode(uint32_t val)
{
    opcode_opcode_i_reg = val;
}

void
RiscvExec::setOpcodePc(uint32_t val)
{
    opcode_pc_i_reg = val;
}

void
RiscvExec::setOpcodeInvalid(uint8_t val)
{
    opcode_invalid_i_reg = val;
}

void
RiscvExec::setOpcodeRdIdx(uint8_t val)
{
    opcode_rd_idx_i_reg = val;
}

void
RiscvExec::setOpcodeRaIdx(uint8_t val)
{
    opcode_ra_idx_i_reg = val;
}

void
RiscvExec::setOpcodeRbIdx(uint8_t val)
{
    opcode_rb_idx_i_reg = val;
}

void
RiscvExec::setOpcodeRaOperand(uint32_t val)
{
    opcode_ra_operand_i_reg = val;
}

void
RiscvExec::setOpcodeRbOperand(uint32_t val)
{
    opcode_rb_operand_i_reg = val;
}

void
RiscvExec::setHold(uint8_t val)
{
    hold_i_reg = val;
}

uint8_t
RiscvExec::getBranchRequest()
{
    return branch_request_o_val;
}

uint8_t
RiscvExec::getBranchIsTaken()
{
    return branch_is_taken_o_val;
}

uint8_t
RiscvExec::getBranchIsNotTaken()
{
    return branch_is_not_taken_o_val;
}

uint8_t
RiscvExec::getBranchSource()
{
    return branch_source_o_val;
}

uint8_t
RiscvExec::getBranchIsCall()
{
    return branch_is_call_o_val;
}

uint8_t
RiscvExec::getBranchIsRet()
{
    return branch_is_ret_o_val;
}

uint8_t
RiscvExec::getBranchIsJmp()
{
    return branch_is_jmp_o_val;
}

uint32_t
RiscvExec::getBranchPc()
{
    return branch_pc_o_val;
}

uint8_t
RiscvExec::getBranchDRequest()
{
    return branch_d_request_o_val;
}

uint32_t
RiscvExec::getBranchDPc()
{
    return branch_d_pc_o_val;
}

uint8_t
RiscvExec::getBranchDPriv()
{
    return branch_d_priv_o_val;
}

uint32_t
RiscvExec::getWritebackValue()
{
    return writeback_value_o_val;
}

void
RiscvExec::process()
{
    // If hold is asserted, stall pipeline - do not update outputs
    if (hold_i_reg) {
        return;
    }

    // Default output values
    branch_request_o_val = 0;
    branch_is_taken_o_val = 0;
    branch_is_not_taken_o_val = 0;
    branch_source_o_val = 0;
    branch_is_call_o_val = 0;
    branch_is_ret_o_val = 0;
    branch_is_jmp_o_val = 0;
    branch_pc_o_val = 0;
    branch_d_request_o_val = 0;
    branch_d_pc_o_val = 0;
    branch_d_priv_o_val = 0;
    writeback_value_o_val = 0;

    // If no valid instruction, done
    if (!opcode_valid_i_reg) {
        return;
    }

    uint32_t instr = opcode_opcode_i_reg;
    uint32_t pc = opcode_pc_i_reg;
    uint8_t rd_idx = opcode_rd_idx_i_reg;
    uint8_t rs1_idx = opcode_ra_idx_i_reg;
    uint32_t rs1_val = opcode_ra_operand_i_reg;
    uint32_t rs2_val = opcode_rb_operand_i_reg;
    uint8_t invalid = opcode_invalid_i_reg;

    // Decode instruction fields
    uint8_t opcode = instr & 0x7F;
    uint8_t funct3 = (instr >> 12) & 0x7;
    uint8_t funct7 = (instr >> 25) & 0x7F;

    // ---- Immediate Generation ----

    // I-type: sign_extend(instr[31:20])
    uint32_t imm_i_raw = (instr >> 20) & 0xFFF;
    uint32_t imm_i;
    if ((imm_i_raw >> 11) & 1) {
        imm_i = imm_i_raw | 0xFFFFF000;
    } else {
        imm_i = imm_i_raw;
    }

    // S-type: sign_extend({instr[31:25], instr[11:7]})
    uint32_t imm_s_raw = ((instr >> 25) & 0x7F) << 5;
    imm_s_raw = imm_s_raw | ((instr >> 7) & 0x1F);
    uint32_t imm_s;
    if ((imm_s_raw >> 11) & 1) {
        imm_s = imm_s_raw | 0xFFFFF000;
    } else {
        imm_s = imm_s_raw;
    }

    // B-type: sign_extend({instr[31], instr[7], instr[30:25], instr[11:8], 0})
    uint32_t imm_b_raw = 0;
    if ((instr >> 31) & 1) {
        imm_b_raw = imm_b_raw | (1 << 12);
    }
    if ((instr >> 7) & 1) {
        imm_b_raw = imm_b_raw | (1 << 11);
    }
    imm_b_raw = imm_b_raw | (((instr >> 25) & 0x3F) << 5);
    imm_b_raw = imm_b_raw | (((instr >> 8) & 0xF) << 1);
    uint32_t imm_b;
    if ((imm_b_raw >> 12) & 1) {
        imm_b = imm_b_raw | 0xFFFFE000;
    } else {
        imm_b = imm_b_raw;
    }

    // U-type: {instr[31:12], 12'b0}
    uint32_t imm_u = instr & 0xFFFFF000;

    // J-type: sign_extend({instr[31], instr[19:12], instr[20], instr[30:21], 0})
    uint32_t imm_j_raw = 0;
    if ((instr >> 31) & 1) {
        imm_j_raw = imm_j_raw | (1 << 20);
    }
    imm_j_raw = imm_j_raw | (((instr >> 12) & 0xFF) << 12);
    if ((instr >> 20) & 1) {
        imm_j_raw = imm_j_raw | (1 << 11);
    }
    imm_j_raw = imm_j_raw | (((instr >> 21) & 0x3FF) << 1);
    uint32_t imm_j;
    if ((imm_j_raw >> 20) & 1) {
        imm_j = imm_j_raw | 0xFFE00000;
    } else {
        imm_j = imm_j_raw;
    }

    // ---- Instruction Execution ----

    // Check for illegal instruction
    if (invalid) {
        branch_request_o_val = 1;
        branch_source_o_val = BRANCH_TRAP;
        branch_d_request_o_val = 1;
        branch_d_pc_o_val = 0;
        branch_d_priv_o_val = 3;
        return;
    }

    if (opcode == 0x37) {
        // LUI: Load Upper Immediate
        writeback_value_o_val = imm_u;
    } else if (opcode == 0x17) {
        // AUIPC: Add Upper Immediate to PC
        writeback_value_o_val = pc + imm_u;
    } else if (opcode == 0x6F) {
        // JAL: Jump and Link
        uint32_t target = pc + imm_j;
        branch_request_o_val = 1;
        branch_is_jmp_o_val = 1;
        branch_source_o_val = BRANCH_JAL;
        branch_pc_o_val = target;
        writeback_value_o_val = pc + 4;
        if (rd_idx != 0) {
            branch_is_call_o_val = 1;
        }
    } else if (opcode == 0x67) {
        // JALR: Jump and Link Register
        uint32_t target = (rs1_val + imm_i) & 0xFFFFFFFEu;
        branch_request_o_val = 1;
        branch_is_jmp_o_val = 1;
        branch_source_o_val = BRANCH_JALR;
        branch_pc_o_val = target;
        writeback_value_o_val = pc + 4;
        if (rd_idx != 0) {
            branch_is_call_o_val = 1;
        }
        if (rs1_idx == 1 || rs1_idx == 5) {
            branch_is_ret_o_val = 1;
        }
    } else if (opcode == 0x63) {
        // Branch instructions (B-type)
        bool branch_taken = false;

        if (funct3 == 0) {
            // BEQ
            branch_taken = (rs1_val == rs2_val);
        } else if (funct3 == 1) {
            // BNE
            branch_taken = (rs1_val != rs2_val);
        } else if (funct3 == 4) {
            // BLT
            branch_taken = (static_cast<int32_t>(rs1_val) <
                           static_cast<int32_t>(rs2_val));
        } else if (funct3 == 5) {
            // BGE
            branch_taken = (static_cast<int32_t>(rs1_val) >=
                           static_cast<int32_t>(rs2_val));
        } else if (funct3 == 6) {
            // BLTU
            branch_taken = (rs1_val < rs2_val);
        } else if (funct3 == 7) {
            // BGEU
            branch_taken = (rs1_val >= rs2_val);
        }

        branch_request_o_val = 1;
        branch_source_o_val = BRANCH_COND;
        branch_pc_o_val = pc + imm_b;
        if (branch_taken) {
            branch_is_taken_o_val = 1;
        } else {
            branch_is_not_taken_o_val = 1;
        }
    } else if (opcode == 0x03) {
        // Load instructions: compute address using ALU (rs1 + imm_i)
        alu.setAluA(rs1_val);
        alu.setAluB(imm_i);
        alu.setAluOp(ALU_ADD);
        alu.process();
        writeback_value_o_val = alu.getAluP();
    } else if (opcode == 0x23) {
        // Store instructions: compute address using ALU (rs1 + imm_s)
        alu.setAluA(rs1_val);
        alu.setAluB(imm_s);
        alu.setAluOp(ALU_ADD);
        alu.process();
        writeback_value_o_val = alu.getAluP();
    } else if (opcode == 0x13) {
        // ALU Immediate instructions (I-type)
        uint8_t alu_op = ALU_NONE;
        uint32_t alu_b = imm_i;

        if (funct3 == 0) {
            // ADDI
            alu_op = ALU_ADD;
        } else if (funct3 == 2) {
            // SLTI
            alu_op = ALU_LESS_THAN_SIGNED;
        } else if (funct3 == 3) {
            // SLTIU
            alu_op = ALU_LESS_THAN;
        } else if (funct3 == 4) {
            // XORI
            alu_op = ALU_XOR;
        } else if (funct3 == 6) {
            // ORI
            alu_op = ALU_OR;
        } else if (funct3 == 7) {
            // ANDI
            alu_op = ALU_AND;
        } else if (funct3 == 1) {
            // SLLI: shift left by immediate[24:20]
            alu_op = ALU_SHIFTL;
            alu_b = (instr >> 20) & 0x1F;
        } else if (funct3 == 5) {
            // SRLI/SRAI: shift right by immediate[24:20]
            alu_b = (instr >> 20) & 0x1F;
            if ((funct7 >> 6) & 1) {
                // SRAI: arithmetic right shift
                alu_op = ALU_SHIFTR_ARITH;
            } else {
                // SRLI: logical right shift
                alu_op = ALU_SHIFTR;
            }
        }

        alu.setAluA(rs1_val);
        alu.setAluB(alu_b);
        alu.setAluOp(alu_op);
        alu.process();
        writeback_value_o_val = alu.getAluP();
    } else if (opcode == 0x33) {
        // ALU Register instructions (R-type)
        uint8_t alu_op = ALU_NONE;

        if (funct3 == 0) {
            // ADD/SUB
            if ((funct7 >> 6) & 1) {
                // SUB
                alu_op = ALU_SUB;
            } else {
                // ADD
                alu_op = ALU_ADD;
            }
        } else if (funct3 == 1) {
            // SLL
            alu_op = ALU_SHIFTL;
        } else if (funct3 == 2) {
            // SLT
            alu_op = ALU_LESS_THAN_SIGNED;
        } else if (funct3 == 3) {
            // SLTU
            alu_op = ALU_LESS_THAN;
        } else if (funct3 == 4) {
            // XOR
            alu_op = ALU_XOR;
        } else if (funct3 == 5) {
            // SRL/SRA
            if ((funct7 >> 6) & 1) {
                // SRA
                alu_op = ALU_SHIFTR_ARITH;
            } else {
                // SRL
                alu_op = ALU_SHIFTR;
            }
        } else if (funct3 == 6) {
            // OR
            alu_op = ALU_OR;
        } else if (funct3 == 7) {
            // AND
            alu_op = ALU_AND;
        }

        alu.setAluA(rs1_val);
        alu.setAluB(rs2_val);
        alu.setAluOp(alu_op);
        alu.process();
        writeback_value_o_val = alu.getAluP();
    } else if (opcode == 0x73) {
        // System instructions (ECALL, EBREAK)
        uint32_t sys_imm = (instr >> 20) & 0xFFF;

        if ((funct3 & 0x7) == 0) {
            if (sys_imm == 0) {
                // ECALL: environment call
                branch_request_o_val = 1;
                branch_source_o_val = BRANCH_TRAP;
                branch_d_request_o_val = 1;
                branch_d_pc_o_val = 0;
                branch_d_priv_o_val = 3;
            } else if (sys_imm == 1) {
                // EBREAK: breakpoint
                branch_request_o_val = 1;
                branch_source_o_val = BRANCH_TRAP;
                branch_d_request_o_val = 1;
                branch_d_pc_o_val = 0;
                branch_d_priv_o_val = 3;
            }
        }
    } else if (opcode == 0x0F) {
        // FENCE: no execution changes needed
        writeback_value_o_val = 0;
    }
}

} // namespace gem5
