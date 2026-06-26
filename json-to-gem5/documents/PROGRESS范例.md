# RISC-V 处理器 gem5 转换项目进度

## 项目概述

将 `files/riscv/` 目录下的 RISC-V 处理器（tinyriscv）Verilog 模块转换为 gem5 兼容代码。

**源文件**：`files/riscv/` 下 13 个 Verilog 模块文件
**目标**：gem5 SimObject 模块 + 测试验证

## 模块规格描述文件

已生成在 `input/` 目录下：
- input/riscv/riscv.txt（顶层）
- input/pc_reg/pc_reg.txt
- input/if_id/if_id.txt
- input/id/id.txt
- input/id_ex/id_ex.txt
- input/ex/ex.txt
- input/regs/regs.txt
- input/csr_reg/csr_reg.txt
- input/div/div.txt
- input/ctrl/ctrl.txt
- input/clint/clint.txt
- input/rib/rib.txt

## gem5 代码生成进度

### 已完成模块（构建通过）

| 模块 | 类型 | 路径 | 状态 |
|------|------|------|------|
| pc_reg | 时序逻辑 | gem5/src/generators/pc_reg/ | ✅ 构建通过 |
| if_id | 时序逻辑 | gem5/src/generators/if_id/ | ✅ 构建通过 |
| id | 组合逻辑 | gem5/src/generators/id/ | ✅ 构建通过 |
| id_ex | 时序逻辑 | gem5/src/generators/id_ex/ | ✅ 构建通过 |
| ex | 组合逻辑 | gem5/src/generators/ex/ | ✅ 构建通过 |
| regs | 时序+组合 | gem5/src/generators/regs/ | ✅ 构建通过 |
| csr_reg | 时序+组合 | gem5/src/generators/csr_reg/ | ✅ 构建通过 |
| div | 时序逻辑 | gem5/src/generators/div/ | ✅ 构建通过 |
| ctrl | 组合逻辑 | gem5/src/generators/ctrl/ | ✅ 构建通过 |
| clint | 时序逻辑 | gem5/src/generators/clint/ | ✅ 构建通过 |
| rib | 组合逻辑 | gem5/src/generators/rib/ | ✅ 构建通过 |
| riscv | 顶层模块 | gem5/src/generators/riscv/ | ✅ 构建通过 |

### 测试进度（Part 4）

按自底向上顺序测试：

| 模块 | 测试向量 | 测试模块 | 测试结果 | 完成时间 |
|------|----------|----------|----------|----------|
| pc_reg | ✅ 23个 | ✅ | ✅ 全部通过 (24/24) | 2026-05-03 |
| if_id | ✅ 14个 | ✅ | ✅ 全部通过 (14/14) | 2026-05-03 |
| id | ✅ | ✅ | ✅ 全部通过 (6/6) | 2026-05-03 |
| id_ex | ✅ 22个 | ✅ | ✅ 全部通过 (22/22) | 2026-05-03 |
| ex | ✅ 41个 | ✅ | ✅ 全部通过 (41/41) | 2026-05-03 |
| regs | ✅ 23个 | ✅ | 🔄 测试中 (测试19/21读不到数据，需修复时序) | 2026-05-03 |
| csr_reg | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |
| div | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |
| ctrl | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |
| clint | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |
| rib | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |
| riscv (顶层) | ⏳ 待生成 | ⏳ 待生成 | ⏳ 待测试 | - |

## 当前任务

正在进行：id 模块测试（样例点生成 → 测试模块生成 → 构建 → 运行测试）

## 注意事项

- 构建命令：`cd gem5 && scons build/X86/gem5.opt -j10`
- 测试运行：`cd /home/diving/Documents/opencode-runoob-test && ./gem5/build/X86/gem5.opt --debug-flags=<Module>TestGenerator configs/<module>_test/<module>_test.py`
- debug flag 需要在 SConscript 中声明
- LSP 错误（找不到 m5.params 等）是 IDE 问题，不影响构建
