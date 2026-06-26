## 模块名称
riscv_fetch (RISC-V Fetch Unit)

## 逻辑类型
时序逻辑（子模块）

注意：作为子模块，其 process() 调用由顶层模块（riscv_core）每个周期触发。
不需要 clk 输入端口和时钟边沿检测逻辑。

## 功能概述
riscv_fetch 是 RISC-V 处理器的取指单元，负责从指令缓存（ICache/MMU）中读取指令，管理程序计数器（PC），处理分支跳转和流水线冲刷。它接收分支请求并更新 PC，向译码阶段提供指令数据。

## 端口定义

### 输入信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| fetch_accept_i | 1 | input | 译码阶段接受取指输出 |
| icache_accept_i | 1 | input | 指令缓存接受请求 |
| icache_valid_i | 1 | input | 指令缓存数据有效 |
| icache_error_i | 1 | input | 指令缓存错误 |
| icache_inst_i | 31:0 | input | 指令缓存返回指令 |
| icache_page_fault_i | 1 | input | 指令页错误 |
| fetch_invalidate_i | 1 | input | 取指无效化（IFENCE） |
| branch_request_i | 1 | input | 分支请求 |
| branch_pc_i | 31:0 | input | 分支目标 PC |
| branch_priv_i | 1:0 | input | 分支目标特权级 |

### 输出信号
| 端口名 | 位宽 | 方向 | 描述 |
|--------|------|------|------|
| fetch_valid_o | 1 | output | 取指数据有效 |
| fetch_instr_o | 31:0 | output | 取到的指令 |
| fetch_pc_o | 31:0 | output | 指令 PC |
| fetch_fault_fetch_o | 1 | output | 取指错误标志 |
| fetch_fault_page_o | 1 | output | 页错误标志 |
| icache_rd_o | 1 | output | 指令缓存读请求 |
| icache_flush_o | 1 | output | 指令缓存冲刷 |
| icache_invalidate_o | 1 | output | 指令缓存无效化 |
| icache_pc_o | 31:0 | output | 发送到缓存的 PC |
| icache_priv_o | 1:0 | output | 取指特权级 |
| squash_decode_o | 1 | output | 冲刷译码阶段 |

## 功能说明

### 1. 程序计数器管理
- 维护内部 PC 寄存器（顺序递增或分支跳转）
- PC 默认每次递增 4 字节（32 位指令）
- 分支请求时根据目标地址更新 PC

### 2. 指令缓存接口
- 通过 icache_rd_o 向缓存发出读请求
- 通过 icache_accept_i 接收缓存请求接受信号
- 接收 icache_valid_i 和 icache_inst_i 获取指令数据
- 处理缓存错误（icache_error_i）和页错误（icache_page_fault_i）

### 3. 分支处理
- 接收来自执行单元的分支请求（branch_request_i）
- 根据分支目标 PC（branch_pc_i）更新取指地址
- 输出 squash_decode_o 信号冲刷译码阶段的错误指令

### 4. 无效化处理
- 接收 fetch_invalidate_i（来自 IFENCE/SFENCE 指令）
- 冲刷指令缓存并重新取指

### 5. 内部状态机
- 使用三个内部状态标志管理取指流程：
  - req_sent: 请求已发送，等待 icache 接受
  - wait_data: 请求已被接受，等待数据有效
  - pending_ready: 有指令待输出给译码阶段
- 每个周期 process() 被调用一次，按优先级顺序处理
