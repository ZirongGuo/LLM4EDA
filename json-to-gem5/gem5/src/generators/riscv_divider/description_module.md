# riscv_divider 模块功能描述

## 模块功能概述
riscv_divider 是 RISC-V 处理器的除法单元，负责执行 DIV/DIVU/REM/REMU 除法/取余指令。除法操作需要多个时钟周期完成（32 周期），模块内部维护计算状态，完成后输出有效标志和结果。作为子模块，其 process() 由顶层模块 riscv_core 每个周期调用。

## 端口列表及说明

### 输入信号
| 端口名 | 类型 | 描述 |
|--------|------|------|
| opcode_valid_i | bool | 操作码有效标志 |
| opcode_invalid_i | bool | 操作码非法标志 |
| opcode_opcode_i | uint32_t | 指令操作码（含 funct3 字段） |
| opcode_pc_i | uint32_t | 指令 PC |
| opcode_rd_idx_i | uint8_t | 目标寄存器索引 |
| opcode_ra_idx_i | uint8_t | 源寄存器 A 索引 |
| opcode_rb_idx_i | uint8_t | 源寄存器 B 索引 |
| opcode_ra_operand_i | uint32_t | 被除数 |
| opcode_rb_operand_i | uint32_t | 除数 |

### 输出信号
| 端口名 | 类型 | 描述 |
|--------|------|------|
| writeback_valid_o | bool | 写回有效标志 |
| writeback_value_o | uint32_t | 除法/取余结果 |

## 参数列表及说明
无参数。

## 内部信号说明
| 内部信号 | 类型 | 描述 |
|---------|------|------|
| state | State (枚举) | 状态机状态：IDLE/COMPUTE/DONE |
| counter | int | 除法迭代计数器，初始 32，递减至 0 |
| dividend | uint32_t | 被除数绝对值（运算过程中保存商） |
| divisor | uint32_t | 除数绝对值 |
| remainder | uint32_t | 部分余数 |
| a_neg | bool | 被除数是否为负数（有符号运算） |
| b_neg | bool | 除数是否为负数（有符号运算） |
| is_signed | bool | 是否为有符号运算 |
| is_rem | bool | 是否为取余运算 |
