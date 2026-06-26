#ifndef __GENERATORS_RISCV_DIVIDER_HH__
#define __GENERATORS_RISCV_DIVIDER_HH__

#include <cstdint>

#include "params/RiscvDivider.hh"
#include "sim/sim_object.hh"

namespace gem5 {

class RiscvDivider : public SimObject
{
  private:
    /* Input port registers */
    bool opcode_valid_i_reg;
    bool opcode_invalid_i_reg;
    uint32_t opcode_opcode_i_reg;
    uint32_t opcode_pc_i_reg;
    uint8_t opcode_rd_idx_i_reg;
    uint8_t opcode_ra_idx_i_reg;
    uint8_t opcode_rb_idx_i_reg;
    uint32_t opcode_ra_operand_i_reg;
    uint32_t opcode_rb_operand_i_reg;

    /* Output port registers */
    bool writeback_valid_o_val;
    uint32_t writeback_value_o_val;

    /* Internal state for multi-cycle division */
    enum State { IDLE = 0, COMPUTE = 1, DONE = 2 };
    State state;

    /* Division state registers */
    int counter;
    uint32_t dividend;
    uint32_t divisor;
    uint32_t remainder;
    bool a_neg;
    bool b_neg;
    bool is_signed;
    bool is_rem;

  public:
    RiscvDivider(const RiscvDividerParams &p);

    /* Input port set functions */
    void setOpcodeValidI(bool val);
    void setOpcodeInvalidI(bool val);
    void setOpcodeOpcodeI(uint32_t val);
    void setOpcodePcI(uint32_t val);
    void setOpcodeRdIdxI(uint8_t val);
    void setOpcodeRaIdxI(uint8_t val);
    void setOpcodeRbIdxI(uint8_t val);
    void setOpcodeRaOperandI(uint32_t val);
    void setOpcodeRbOperandI(uint32_t val);

    /* Output port get functions */
    bool getWritebackValidO();
    uint32_t getWritebackValueO();

    /**
     * Process function.
     * Called by parent module (riscv_core) each cycle.
     * Implements multi-cycle restoring division algorithm.
     */
    void process();
};

} // namespace gem5

#endif // __GENERATORS_RISCV_DIVIDER_HH__
