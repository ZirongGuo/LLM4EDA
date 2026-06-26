## 模块名称
riscv_exec (RISC-V Execution Unit)

## 逻辑类型
时序逻辑（子模块）

注意：作为子模块，其 process() 调用由顶层模块每个周期触发，代表一个时钟上升沿。不需要 clk 输入端口和时钟边沿检测逻辑。

## 功能概述
RISC-V 执行单元模块，负责执行算术逻辑运算、分支条件判断、立即数生成等操作。内部包含 riscv_alu 子模块完成 ALU 运算。模块根据指令类型计算执行结果、分支跳转目标和分支条件，并为分支预测器提供分支反馈信息。

## 端口定义

### 输入信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| opcode_valid_i | 1 | input | 操作码有效标志 |
| opcode_opcode_i | 31:0 | input | 指令操作码 |
| opcode_pc_i | 31:0 | input | 指令 PC 值 |
| opcode_invalid_i | 1 | input | 非法指令标志 |
| opcode_rd_idx_i | 4:0 | input | 目标寄存器索引 |
| opcode_ra_idx_i | 4:0 | input | 源操作数 A 寄存器索引 |
| opcode_rb_idx_i | 4:0 | input | 源操作数 B 寄存器索引 |
| opcode_ra_operand_i | 31:0 | input | 源操作数 A 值 |
| opcode_rb_operand_i | 31:0 | input | 源操作数 B 值 |
| hold_i | 1 | input | 流水线暂停标志 |

### 输出信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| branch_request_o | 1 | output | 分支请求标志 |
| branch_is_taken_o | 1 | output | 分支条件满足（已跳转） |
| branch_is_not_taken_o | 1 | output | 分支条件不满足（未跳转） |
| branch_source_o | 1:0 | output | 分支源类型 |
| branch_is_call_o | 1 | output | 函数调用标志 |
| branch_is_ret_o | 1 | output | 函数返回标志 |
| branch_is_jmp_o | 1 | output | 无条件跳转标志 |
| branch_pc_o | 31:0 | output | 分支目标 PC |
| branch_d_request_o | 1 | output | 分支延迟请求（异常/陷阱） |
| branch_d_pc_o | 31:0 | output | 分支延迟目标 PC |
| branch_d_priv_o | 1:0 | output | 分支延迟目标特权级 |
| writeback_value_o | 31:0 | output | 写回结果值 |

## 参数列表
无额外可配置参数。通过 Param.RiscvAlu 引用 riscv_alu 子模块。

### 子模块
| 子模块名 | 类型 | 描述 |
|---------|------|------|
| alu | riscv_alu | 组合逻辑 ALU 模块，执行算术逻辑运算 |

## 内部信号说明

### ALU 操作码常量
| 常量名 | 值 | 描述 |
|--------|-----|------|
| ALU_NONE | 0x0 | 直通 |
| ALU_SHIFTL | 0x1 | 逻辑左移 |
| ALU_SHIFTR | 0x2 | 逻辑右移 |
| ALU_SHIFTR_ARITH | 0x3 | 算术右移 |
| ALU_ADD | 0x4 | 加法 |
| ALU_SUB | 0x6 | 减法 |
| ALU_AND | 0x7 | 按位与 |
| ALU_OR | 0x8 | 按位或 |
| ALU_XOR | 0x9 | 按位异或 |
| ALU_LESS_THAN | 0xA | 无符号小于比较 |
| ALU_LESS_THAN_SIGNED | 0xB | 有符号小于比较 |

### 分支源类型编码
| 值 | 类型 | 描述 |
|----|------|------|
| 0 | COND_BRANCH | 条件分支（B 型） |
| 1 | JAL | JAL 跳转 |
| 2 | JALR | JALR 跳转 |
| 3 | TRAP | 异常/陷阱 |
