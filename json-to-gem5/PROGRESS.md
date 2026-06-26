# RISC-V Core gem5 转换项目进度

## 项目概述

将 RISC-V Core Verilog 模块转换为 gem5 兼容代码。

**源文件**：`input/design_riscv.json`（19 个模块）
**目标**：gem5 SimObject 模块 + 测试验证

## 模块规格描述文件

已生成在 `input/` 目录下（18个模块）：
- input/riscv_alu/riscv_alu.txt
- input/riscv_core/riscv_core.txt
- input/riscv_csr/riscv_csr.txt
- input/riscv_csr_regfile/riscv_csr_regfile.txt
- input/riscv_decode/riscv_decode.txt
- input/riscv_decoder/riscv_decoder.txt
- input/riscv_defs/riscv_defs.txt（常量定义，不生成SimObject）
- input/riscv_divider/riscv_divider.txt
- input/riscv_exec/riscv_exec.txt
- input/riscv_fetch/riscv_fetch.txt
- input/riscv_issue/riscv_issue.txt
- input/riscv_lsu/riscv_lsu.txt
- input/riscv_mmu/riscv_mmu.txt
- input/riscv_multiplier/riscv_multiplier.txt
- input/riscv_pipe_ctrl/riscv_pipe_ctrl.txt
- input/riscv_regfile/riscv_regfile.txt
- input/riscv_trace_sim/riscv_trace_sim.txt
- input/riscv_xilinx_2r1w/riscv_xilinx_2r1w.txt

## gem5 代码生成进度

### 已完成模块

| 模块 | 类型 | 路径 | 状态 |
|------|------|------|------|
| riscv_alu | 组合逻辑 | gem5/src/generators/riscv_alu/ | ✅ 代码已生成 |
| riscv_csr_regfile | 时序逻辑 | gem5/src/generators/riscv_csr_regfile/ | ✅ 代码已生成 |
| riscv_decoder | 组合逻辑 | gem5/src/generators/riscv_decoder/ | ✅ 代码已生成 |
| riscv_divider | 时序逻辑 | gem5/src/generators/riscv_divider/ | ✅ 代码已生成 |
| riscv_fetch | 时序逻辑 | gem5/src/generators/riscv_fetch/ | ✅ 代码已生成 |
| riscv_lsu | 时序逻辑 | gem5/src/generators/riscv_lsu/ | ✅ 代码已生成 |
| riscv_multiplier | 时序逻辑 | gem5/src/generators/riscv_multiplier/ | ✅ 代码已生成 |
| riscv_pipe_ctrl | 组合逻辑 | gem5/src/generators/riscv_pipe_ctrl/ | ✅ 代码已生成 |
| riscv_regfile | 时序逻辑 | gem5/src/generators/riscv_regfile/ | ✅ 代码已生成 |
| riscv_trace_sim | 组合逻辑 | gem5/src/generators/riscv_trace_sim/ | ✅ 代码已生成 |
| riscv_xilinx_2r1w | 时序逻辑 | gem5/src/generators/riscv_xilinx_2r1w/ | ✅ 代码已生成 |
| riscv_csr | 时序逻辑 | gem5/src/generators/riscv_csr/ | ✅ 代码已生成 |
| riscv_decode | 时序逻辑 | gem5/src/generators/riscv_decode/ | ✅ 代码已生成 |
| riscv_exec | 时序逻辑 | gem5/src/generators/riscv_exec/ | ✅ 代码已生成 |
| riscv_issue | 时序逻辑 | gem5/src/generators/riscv_issue/ | ✅ 代码已生成 |

| riscv_csr | 时序逻辑 | gem5/src/generators/riscv_csr/ | ✅ 代码已生成 |
| riscv_decode | 时序逻辑 | gem5/src/generators/riscv_decode/ | ✅ 代码已生成 |
| riscv_exec | 时序逻辑 | gem5/src/generators/riscv_exec/ | ✅ 代码已生成 |
| riscv_issue | 时序逻辑 | gem5/src/generators/riscv_issue/ | ✅ 代码已生成 |
| riscv_mmu | 时序逻辑 | gem5/src/generators/riscv_mmu/ | ✅ 代码已生成 |
| riscv_core | 时序逻辑（顶层） | gem5/src/generators/riscv_core/ | ✅ 代码已生成 |

## 测试进度

| 模块 | 测试向量 | 测试模块 | 测试结果 | 完成时间 |
|------|----------|----------|----------|----------|
| - | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |

## 当前状态

- Part 1 & 2: ✅ 已完成（模块规格 + 代码生成）
- Part 3: ⚠️ 部分完成（.o 文件编译通过，二进制未链接）
- Part 4: ✅ 测试代码生成完成，⏳ 等待用户端构建后运行测试

## 当前任务

### Part 3 - scons 构建
- 所有 1910 个 `.o` 文件编译通过，SimObject 参数文件生成成功
- `gem5.opt` 二进制在当前环境未链接（构建系统问题），需在用户端执行：
  ```
  cd /root/verilog-to-gem5-main/gem5 && scons build/X86/gem5.opt -j10
  ```

### Part 4 - 测试（已完成代码生成，待运行）
- **15 个模块** 全部完成测试向量生成（SampleGenerator）和测试模块生成（TestGenerator）
- 测试模块位于 `gem5/src/generators/*_test/`
- 测试配置位于 `configs/*_test/`
- 需在用户端构建二进制后运行测试

### 测试模块列表（自底向上）

| # | 模块 | 类型 | 测试向量 | SConscript |
|---|------|------|---------|------------|
| 1 | riscv_alu | combinational | 32 | ✅ |
| 2 | riscv_csr_regfile | sequential | 25 | ✅ |
| 3 | riscv_xilinx_2r1w | sequential | 13 | ✅ |
| 4 | riscv_divider | sequential | 18 | ✅ |
| 5 | riscv_multiplier | sequential | 15 | ✅ |
| 6 | riscv_regfile | sequential | 14 | ✅ |
| 7 | riscv_trace_sim | combinational | 7 | ✅ |
| 8 | riscv_pipe_ctrl | combinational | 15 | ✅ |
| 9 | riscv_fetch | sequential | 15 | ✅ |
| 10 | riscv_issue | sequential | 22 | ✅ |
| 11 | riscv_exec | sequential | 25 | ✅ |
| 12 | riscv_lsu | sequential | 20 | ✅ |
| 13 | riscv_csr | sequential | 18 | ✅ |
| 14 | riscv_mmu | sequential | 20 | ✅ |
| 15 | riscv_core（顶层） | sequential | 18 | ✅ |

**总计：277 个测试向量**

### 运行测试命令
用户端构建成功后，运行测试：
```
cd /root/verilog-to-gem5-main/gem5
build/X86/gem5.opt ../../configs/riscv_alu_test/riscv_alu_test.py
build/X86/gem5.opt ../../configs/riscv_core_test/riscv_core_test.py
...
```
