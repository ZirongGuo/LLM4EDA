#include "generators/riscv_divider/riscv_divider.hh"

#include <cstdint>
#include <climits>

namespace gem5 {

RiscvDivider::RiscvDivider(const RiscvDividerParams &params)
    : SimObject(params),
      opcode_valid_i_reg(false),
      opcode_invalid_i_reg(false),
      opcode_opcode_i_reg(0),
      opcode_pc_i_reg(0),
      opcode_rd_idx_i_reg(0),
      opcode_ra_idx_i_reg(0),
      opcode_rb_idx_i_reg(0),
      opcode_ra_operand_i_reg(0),
      opcode_rb_operand_i_reg(0),
      writeback_valid_o_val(false),
      writeback_value_o_val(0),
      state(IDLE),
      counter(0),
      dividend(0),
      divisor(0),
      remainder(0),
      a_neg(false),
      b_neg(false),
      is_signed(false),
      is_rem(false)
{
}

void
RiscvDivider::setOpcodeValidI(bool val)
{
    opcode_valid_i_reg = val;
}

void
RiscvDivider::setOpcodeInvalidI(bool val)
{
    opcode_invalid_i_reg = val;
}

void
RiscvDivider::setOpcodeOpcodeI(uint32_t val)
{
    opcode_opcode_i_reg = val;
}

void
RiscvDivider::setOpcodePcI(uint32_t val)
{
    opcode_pc_i_reg = val;
}

void
RiscvDivider::setOpcodeRdIdxI(uint8_t val)
{
    opcode_rd_idx_i_reg = val;
}

void
RiscvDivider::setOpcodeRaIdxI(uint8_t val)
{
    opcode_ra_idx_i_reg = val;
}

void
RiscvDivider::setOpcodeRbIdxI(uint8_t val)
{
    opcode_rb_idx_i_reg = val;
}

void
RiscvDivider::setOpcodeRaOperandI(uint32_t val)
{
    opcode_ra_operand_i_reg = val;
}

void
RiscvDivider::setOpcodeRbOperandI(uint32_t val)
{
    opcode_rb_operand_i_reg = val;
}

bool
RiscvDivider::getWritebackValidO()
{
    return writeback_valid_o_val;
}

uint32_t
RiscvDivider::getWritebackValueO()
{
    return writeback_value_o_val;
}

void
RiscvDivider::process()
{
    if (state == IDLE) {
        /* Clear valid flag from previous cycle */
        writeback_valid_o_val = false;

        if (opcode_valid_i_reg && !opcode_invalid_i_reg) {
            /* Decode operation from funct3 field (bits 14:12) */
            uint8_t funct3 = (opcode_opcode_i_reg >> 12) & 0x7;

            if (funct3 == 0x0) {
                /* DIV: signed quotient */
                is_signed = true;
                is_rem = false;
            } else if (funct3 == 0x5) {
                /* DIVU: unsigned quotient */
                is_signed = false;
                is_rem = false;
            } else if (funct3 == 0x6) {
                /* REM: signed remainder */
                is_signed = true;
                is_rem = true;
            } else if (funct3 == 0x7) {
                /* REMU: unsigned remainder */
                is_signed = false;
                is_rem = true;
            } else {
                /* Invalid funct3 - stay in IDLE */
                return;
            }

            uint32_t a = opcode_ra_operand_i_reg;
            uint32_t b = opcode_rb_operand_i_reg;

            /* Special case: division by zero */
            if (b == 0) {
                if (is_rem) {
                    writeback_value_o_val = a;
                } else {
                    writeback_value_o_val = 0xFFFFFFFF;
                }
                writeback_valid_o_val = true;
                return;
            }

            /* Special case: signed overflow (INT32_MIN / -1) */
            if (is_signed) {
                int32_t sa = static_cast<int32_t>(a);
                int32_t sb = static_cast<int32_t>(b);
                if (sa == INT32_MIN && sb == -1) {
                    if (is_rem) {
                        writeback_value_o_val = 0;
                    } else {
                        writeback_value_o_val =
                            static_cast<uint32_t>(INT32_MIN);
                    }
                    writeback_valid_o_val = true;
                    return;
                }
            }

            /* Prepare operands for unsigned restoring division */
            a_neg = false;
            b_neg = false;

            if (is_signed) {
                int32_t sa = static_cast<int32_t>(a);
                int32_t sb = static_cast<int32_t>(b);
                if (sa < 0) {
                    a_neg = true;
                    dividend = static_cast<uint32_t>(-sa);
                } else {
                    dividend = a;
                }
                if (sb < 0) {
                    b_neg = true;
                    divisor = static_cast<uint32_t>(-sb);
                } else {
                    divisor = b;
                }
            } else {
                dividend = a;
                divisor = b;
            }

            remainder = 0;
            counter = 32;
            state = COMPUTE;
        }
    } else if (state == COMPUTE) {
        /* One iteration of restoring division algorithm */
        uint32_t msb = (dividend >> 31) & 1;
        remainder = (remainder << 1) | msb;
        dividend = dividend << 1;

        if (remainder >= divisor) {
            remainder = remainder - divisor;
            dividend = dividend | 1;
        }

        counter--;
        if (counter == 0) {
            state = DONE;
        }
    } else if (state == DONE) {
        uint32_t quotient = dividend;
        uint32_t rem = remainder;

        /* Apply sign adjustments for signed operations */
        if (is_signed) {
            /* Negate quotient if dividend and divisor have opposite signs */
            if (a_neg != b_neg) {
                quotient = static_cast<uint32_t>(
                    -static_cast<int32_t>(quotient));
            }
            /* Remainder has same sign as dividend */
            if (a_neg) {
                rem = static_cast<uint32_t>(
                    -static_cast<int32_t>(rem));
            }
        }

        if (is_rem) {
            writeback_value_o_val = rem;
        } else {
            writeback_value_o_val = quotient;
        }
        writeback_valid_o_val = true;
        state = IDLE;
    }
}

} // namespace gem5
