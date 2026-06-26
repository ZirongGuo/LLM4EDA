# riscv_decoder (RISC-V Instruction Decoder)

## 模块功能概述
RISC-V 指令解码模块，接收 32 位指令操作码并解码出指令类型（执行、加载存储、分支、乘法、除法、CSR 等）以及寄存器索引是否有效。检查指令是否合法并分类到对应的执行单元。

## 逻辑类型
组合逻辑（子模块）

## 端口列表

### 输入信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| valid_i | 1 | input | 输入指令有效标志 |
| fetch_fault_i | 1 | input | 取指错误标志（有错误时强制输出无效） |
| enable_muldiv_i | 1 | input | 乘除法扩展使能 |
| opcode_i | 31:0 | input | 32 位 RISC-V 指令操作码 |

### 输出信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| invalid_o | 1 | output | 指令非法标志 |
| exec_o | 1 | output | ALU/执行指令标志 |
| lsu_o | 1 | output | 加载/存储指令标志 |
| branch_o | 1 | output | 分支指令标志 |
| mul_o | 1 | output | 乘法指令标志 |
| div_o | 1 | output | 除法指令标志 |
| csr_o | 1 | output | CSR 指令标志 |
| rd_valid_o | 1 | output | 目标寄存器有效标志 |

## 参数列表
无参数（组合逻辑子模块，所有输入通过 set 函数传递）。

## 内部信号说明
无内部状态寄存器（纯组合逻辑）。

## 使用方式
1. 调用 setValidI(), setFetchFaultI(), setEnableMuldivI(), setOpcodeI() 设置输入
2. 调用 process() 执行组合逻辑解码
3. 调用 getInvalidO(), getExecO(), getLsuO(), getBranchO(), getMulO(), getDivO(), getCsrO(), getRdValidO() 读取输出
