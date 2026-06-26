# riscv_decode (RISC-V Decode Stage)

## 模块功能概述
RISC-V 流水线译码级模块，位于 Fetch 和 Issue 之间。负责缓存来自 Fetch 阶段的指令、PC 和故障信息，并根据参数 EXTRA_DECODE_STAGE 决定是否插入额外的译码流水级。内部实例化 riscv_decoder 组合逻辑模块，完成指令类型的解码。当流水线冲刷信号 squash_decode_i 有效时，清除译码级内容。

## 逻辑类型
时序逻辑（子模块）

## 端口列表

### 输入信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| fetch_in_valid_i | 1 | input | 取指输入有效标志 |
| fetch_in_instr_i | 31:0 | input | 取指输入指令 |
| fetch_in_pc_i | 31:0 | input | 取指输入 PC |
| fetch_in_fault_fetch_i | 1 | input | 取指输入取指故障 |
| fetch_in_fault_page_i | 1 | input | 取指输入页故障 |
| fetch_out_accept_i | 1 | input | 下游接受标志（Issue 单元反馈） |
| squash_decode_i | 1 | input | 译码级冲刷信号 |

### 输出信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| fetch_in_accept_o | 1 | output | 上游接受标志（反馈给 Fetch） |
| fetch_out_valid_o | 1 | output | 译码输出有效标志 |
| fetch_out_instr_o | 31:0 | output | 译码输出指令 |
| fetch_out_pc_o | 31:0 | output | 译码输出 PC |
| fetch_out_fault_fetch_o | 1 | output | 译码输出取指故障 |
| fetch_out_fault_page_o | 1 | output | 译码输出页故障 |
| fetch_out_instr_exec_o | 1 | output | 指令类型：执行单元 |
| fetch_out_instr_lsu_o | 1 | output | 指令类型：访存单元 |
| fetch_out_instr_branch_o | 1 | output | 指令类型：分支单元 |
| fetch_out_instr_mul_o | 1 | output | 指令类型：乘法单元 |
| fetch_out_instr_div_o | 1 | output | 指令类型：除法单元 |
| fetch_out_instr_csr_o | 1 | output | 指令类型：CSR 单元 |
| fetch_out_instr_rd_valid_o | 1 | output | 指令有目标寄存器写 |
| fetch_out_instr_invalid_o | 1 | output | 非法指令标志 |

## 参数列表
| 参数名 | 类型 | 默认值 | 描述 |
|--------|------|--------|------|
| EXTRA_DECODE_STAGE | uint32_t | 0 | 额外译码流水级：0=直通模式，1=插入额外译码级 |

## 内部信号说明

### 状态寄存器（主译码级）
| 信号名 | 位宽 | 描述 |
|--------|------|------|
| decode_valid_reg | 1 | 主级有效标志 |
| decode_instr_reg | 32 | 主级指令 |
| decode_pc_reg | 32 | 主级 PC |
| decode_fault_fetch_reg | 1 | 主级取指故障 |
| decode_fault_page_reg | 1 | 主级页故障 |

### 状态寄存器（额外译码级，仅 EXTRA_DECODE_STAGE=1 时使用）
| 信号名 | 位宽 | 描述 |
|--------|------|------|
| decode_extra_valid_reg | 1 | 额外级有效标志 |
| decode_extra_instr_reg | 32 | 额外级指令 |
| decode_extra_pc_reg | 32 | 额外级 PC |
| decode_extra_fault_fetch_reg | 1 | 额外级取指故障 |
| decode_extra_fault_page_reg | 1 | 额外级页故障 |
| decode_extra_exec_reg | 1 | 额外级执行单元标志 |
| decode_extra_lsu_reg | 1 | 额外级访存单元标志 |
| decode_extra_branch_reg | 1 | 额外级分支单元标志 |
| decode_extra_mul_reg | 1 | 额外级乘法单元标志 |
| decode_extra_div_reg | 1 | 额外级除法单元标志 |
| decode_extra_csr_reg | 1 | 额外级 CSR 单元标志 |
| decode_extra_rd_valid_reg | 1 | 额外级写目标寄存器标志 |
| decode_extra_invalid_reg | 1 | 额外级非法指令标志 |

## 子模块

### u_dec (riscv_decoder)
组合逻辑指令解码器，根据指令 opcode 解码指令类型。通过 set/get/process 接口调用。
