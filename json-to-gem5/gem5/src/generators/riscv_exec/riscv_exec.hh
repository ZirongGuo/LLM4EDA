#ifndef __GENERATORS_RISCV_EXEC_HH__
#define __GENERATORS_RISCV_EXEC_HH__

#include <cstdint>

#include "generators/riscv_alu/riscv_alu.hh"
#include "params/RiscvExec.hh"
#include "sim/sim_object.hh"

namespace gem5 {

class RiscvExec : public SimObject
{
  private:
    // Input port registers
    uint8_t opcode_valid_i_reg;
    uint32_t opcode_opcode_i_reg;
    uint32_t opcode_pc_i_reg;
    uint8_t opcode_invalid_i_reg;
    uint8_t opcode_rd_idx_i_reg;
    uint8_t opcode_ra_idx_i_reg;
    uint8_t opcode_rb_idx_i_reg;
    uint32_t opcode_ra_operand_i_reg;
    uint32_t opcode_rb_operand_i_reg;
    uint8_t hold_i_reg;

    // Output port values
    uint8_t branch_request_o_val;
    uint8_t branch_is_taken_o_val;
    uint8_t branch_is_not_taken_o_val;
    uint8_t branch_source_o_val;
    uint8_t branch_is_call_o_val;
    uint8_t branch_is_ret_o_val;
    uint8_t branch_is_jmp_o_val;
    uint32_t branch_pc_o_val;
    uint8_t branch_d_request_o_val;
    uint32_t branch_d_pc_o_val;
    uint8_t branch_d_priv_o_val;
    uint32_t writeback_value_o_val;

    // Submodule reference
    RiscvAlu &alu;

    // ALU operation codes (matching riscv_alu internal constants)
    static constexpr uint8_t ALU_NONE = 0x0;
    static constexpr uint8_t ALU_SHIFTL = 0x1;
    static constexpr uint8_t ALU_SHIFTR = 0x2;
    static constexpr uint8_t ALU_SHIFTR_ARITH = 0x3;
    static constexpr uint8_t ALU_ADD = 0x4;
    static constexpr uint8_t ALU_SUB = 0x6;
    static constexpr uint8_t ALU_AND = 0x7;
    static constexpr uint8_t ALU_OR = 0x8;
    static constexpr uint8_t ALU_XOR = 0x9;
    static constexpr uint8_t ALU_LESS_THAN = 0xA;
    static constexpr uint8_t ALU_LESS_THAN_SIGNED = 0xB;

    // Branch source type
    static constexpr uint8_t BRANCH_COND = 0;
    static constexpr uint8_t BRANCH_JAL = 1;
    static constexpr uint8_t BRANCH_JALR = 2;
    static constexpr uint8_t BRANCH_TRAP = 3;

  public:
    RiscvExec(const RiscvExecParams &p);

    // Set functions for input ports
    void setOpcodeValid(uint8_t val);
    void setOpcodeOpcode(uint32_t val);
    void setOpcodePc(uint32_t val);
    void setOpcodeInvalid(uint8_t val);
    void setOpcodeRdIdx(uint8_t val);
    void setOpcodeRaIdx(uint8_t val);
    void setOpcodeRbIdx(uint8_t val);
    void setOpcodeRaOperand(uint32_t val);
    void setOpcodeRbOperand(uint32_t val);
    void setHold(uint8_t val);

    // Get functions for output ports
    uint8_t getBranchRequest();
    uint8_t getBranchIsTaken();
    uint8_t getBranchIsNotTaken();
    uint8_t getBranchSource();
    uint8_t getBranchIsCall();
    uint8_t getBranchIsRet();
    uint8_t getBranchIsJmp();
    uint32_t getBranchPc();
    uint8_t getBranchDRequest();
    uint32_t getBranchDPc();
    uint8_t getBranchDPriv();
    uint32_t getWritebackValue();

    // Process function - sequential logic, called by parent module each cycle
    void process();
};

} // namespace gem5

#endif // __GENERATORS_RISCV_EXEC_HH__
