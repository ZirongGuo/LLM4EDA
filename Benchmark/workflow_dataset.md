## 数据集预处理工作流

### 1. 目录结构约定（单 Benchmark 为例）

```
benchmark/
└── <benchmark_name>/
    ├── original/          # 原始 .v / .sv 文件（来自数据集）
    ├── filtered/          # （临时目录）存放通过筛选的文件
    ├── src/               # 最终有效的源代码（Design）
    ├── tb/                # 最终有效的测试代码（Testbench）
    ├── json/              # 由源代码生成的 JSON 中间表示
    ├── restored/          # 由 JSON 恢复出的 Verilog 代码
    └── scripts/           # 核心脚本（每个 benchmark 独立维护）
        ├── parse_to_json.py
        ├── generate_from_json.py
        ├── check_json_spec.py
        └── check_output.py   # 根据此 benchmark 的 TB 规范定制生成
```

### 2. 输入
- 原始 Verilog/SystemVerilog 文件集合（位于 `original/`），可能来自公开数据集或用户提供。

### 3. 文件分类与差异化过滤（Classification & Differentiated Filtering）
本阶段对 Design 文件和 TB 文件实施**不同的质量准入标准**，而不是“一刀切”地全部检查。

对 `original/` 中的**每一个文件**，按以下流程处理：

#### 步骤 3.1：语义预分类（Heuristic Pre-classification）
通过启发式规则识别文件类型：
- **测试代码（Testbench）**：满足以下任意特征即判定为 TB。
  - 顶层模块无输入端口（或仅有测试接口）。
  - 包含仿真控制系统任务（如 `$display`、`$dumpfile`、`$dumpvars`、`$finish`、`$stop`、`$monitor`）。
  - 包含显式延迟控制（`#<delay>`）或时钟生成逻辑（`forever #5 clk = ~clk;`）。
- **源代码（Design）**：不满足上述 TB 特征，且包含 `module ... endmodule` 定义的 RTL 或门级网表。

#### 步骤 3.2：差异化过滤执行
根据分类结果，执行不同的准入策略：

- **对于源代码（Design）文件**（质量严控）：
  - 执行 `iverilog -c` 独立语法检查（不包含外部库依赖）。
  - **判定规则**：
    - 编译通过（Exit Code 0）→ 复制到 `filtered/` 目录，保留原名，标记为 `type: design`。
    - 编译失败（Exit Code ≠ 0）→ **直接丢弃该文件**（不进入 `filtered/`），记录丢弃日志（`discard_design.log`），说明语法不兼容。
  - *目的*：确保进入下游迭代的设计代码 **100% 符合 iverilog 标准语法**，从源头保证核心逻辑质量。

- **对于测试代码（Testbench）文件**（自动放行）：
  - **无条件通过**，不执行任何 `iverilog` 语法检查。
  - 直接复制到 `filtered/` 目录，保留原名，标记为 `type: testbench`。
  - *理由*：TB 天生包含大量仿真专用语法（系统任务、延迟、随机函数等），强制严格检查会导致大量有效 TB 被误删，且 TB 的功能正确性将在后续 `check_output.py` 的联合仿真中实际验证，无需在此阶段过度约束。

> **输出**：`filtered/` 目录中既包含严格筛选的 Design 文件，也包含自动放行的 TB 文件。

### 4. 文件归档与二次分类（Archive & Re-classification）
将 `filtered/` 中的文件按类型分别移入最终目录：
- 标记为 `design` 的文件 → 移至 `src/` 目录。
- 标记为 `testbench` 的文件 → 移至 `tb/` 目录。

### 5. 配对与二次质量清理（Pairing & Cleanup）
本阶段依据 **“源文件优先”** 原则进行配对，并清理因 Design 丢弃而产生的“孤儿 TB”文件。

- **配对核心逻辑**：
  1. 遍历 `src/` 目录中的所有源代码文件。
  2. 对每个 `src/<design>.v`，在 `tb/` 目录中查找对应的测试文件。
     - 匹配优先级：`tb/<design>_tb.v` > `tb/tb_<design>.v` > `tb/<design>.v`。
  3. **若找到匹配的 TB 文件**：构成有效配对，保留双方。
  4. **若未找到匹配的 TB 文件**：使用 **LLM** 自动生成一个对应的测试代码文件，存入 `tb/` 目录（命名遵循上述优先级规则）。

- **孤儿文件清理（关键步骤）**：
  - 完成上述配对后，检查 `tb/` 目录：
    - 若某个 TB 文件未能与 `src/` 中任何源代码配对（即其对应的 Design 文件在步骤 3.2 中已被丢弃），则 **直接删除该 TB 文件**。
  - 检查 `src/` 目录：
    - 理论上所有源文件都应保留（除非没有 TB 且 LLM 生成失败，此情况极少数，若发生则记录警告并移除该源文件）。

- **生成配对清单**：
  - 在 benchmark 根目录下生成 `pairing.json` 文件，仅记录成功配对的测试点，内容示例：
    ```json
    {
      "alu": { "src": "src/alu.v", "tb": "tb/alu_tb.v" },
      "counter": { "src": "src/counter.v", "tb": "tb/counter_tb.v" }
    }
    ```

### 6. 生成定制化的测试验证脚本（Generate check_output.py）
由于不同数据集的 TB 文件在波形转储命名、打印格式、仿真结束条件、顶层测试模块名等方面各不相同，通用的比较器无法适配所有情况。因此，本步骤将**依据当前 benchmark 的具体 TB 规范，生成专属的 `check_output.py`**。

- **输入**：`tb/` 目录下所有已配对的 `.v` 测试文件，以及对应的 `pairing.json`。
- **执行方式**：将上述 TB 文件内容 + 配对清单，作为上下文提供给 LLM，要求其编写 `scripts/check_output.py`。
- **LLM 生成脚本时需要提取的信息（Prompt 指导）**：
  1. **顶层测试模块名**（通常为 `tb` 或 `<design>_tb`），用于编译时的顶层指定。
  2. **仿真结束条件**（如 `$finish` 后的仿真时间，或监测到的结束标志）。
  3. **波形转储命令**（如 `$dumpfile("dump.vcd")`、`$dumpvars`），用于确定是否需要检查 VCD 生成。
  4. **标准输出/错误打印**（如 `$display`、`$monitor` 的内容格式），用于决定比较基于文本还是波形。
- **生成的 `check_output.py` 必须包含的功能**：
  - 接受命令行参数：`--src`（原始设计）、`--tb`（测试平台）、`--restored`（恢复设计）。
  - 使用 `iverilog` + `vvp` 分别编译运行 `(src + tb)` 和 `(restored + tb)`。
  - 捕获两份运行的标准输出、标准错误，以及（可选）VCD 文件的哈希值。
  - 进行严格比较（逐行文本比对 + 波形关键信号采样比对），若完全一致返回退出码 0，否则返回非 0 并打印差异详情。
- **输出**：`scripts/check_output.py` 脚本，并赋予可执行权限。

> **最终预处理输出**：干净的 `src/`、`tb/` 目录，精确的 `pairing.json`，以及针对本 benchmark 特化的 `scripts/check_output.py`。所有未通过质量门控的 Design 文件及其对应的孤儿 TB 均已被清除。