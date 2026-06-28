## 核心迭代工作流

### 1. 总体目标
通过迭代优化 `parse_to_json.py` 和 `generate_from_json.py`，使得对当前 benchmark 中的所有配对 `(src/*.v, tb/*.v)`，恢复出的 `restored/*.v` 能通过功能等价性检查，最终达到 **100% 通过率**。

### 2. 前置条件（Precondition）
- 已完成 `workflow_dataset.md` 定义的预处理流程。
- `src/`、`tb/`、`json/`、`restored/` 目录已就绪。
- `scripts/` 目录下必须存在以下文件（其中 `check_output.py` 由预处理阶段定制生成）：
  - `parse_to_json.py`
  - `generate_from_json.py`
  - `check_json_spec.py`
  - `check_output.py`（**注意**：该脚本的内容是根据当前数据集的 TB 风格特化的，非通用模板）

### 3. 配对解析与初始化（Testpoint Pairing Resolution）
核心迭代流程通过**显式解析配对清单**来确定测试点。

- **步骤 3.1**：在工作目录（`<benchmark_name>/`）下，查找 `pairing.json` 文件。
  - 若存在，直接加载该文件，获取设计名称到源文件和 TB 文件的映射。
- **步骤 3.2**：若 `pairing.json` 不存在（例如手动运行或清单丢失），则执行**隐式目录扫描**：
  - 扫描 `src/` 目录，获取所有 `.v` / `.sv` 文件。
  - 对每个 `src/<name>.v`，按以下优先级在 `tb/` 中查找配对文件：
    1. `tb/<name>_tb.v`
    2. `tb/tb_<name>.v`
    3. `tb/<name>.v`（同名）
  - 若找到唯一匹配，则组成一个测试点；若找不到匹配，则跳过该源文件并记录警告。
- **步骤 3.3**：生成测试点列表 `testpoints`，每个条目包含：
  ```python
  {
    "design": "alu",                # 设计标识名
    "src_path": "src/alu.v",        # 源代码路径
    "tb_path": "tb/alu_tb.v",       # 测试代码路径
    "json_path": "json/alu.json",   # 后续生成
    "restored_path": "restored/alu.v"
  }
  ```
- **步骤 3.4**：**容错检查**：遍历 `testpoints`，验证 `src_path` 和 `tb_path` 是否实际存在，同时验证 `scripts/check_output.py` 是否存在。
  - 若任何文件缺失，从 `testpoints` 中移除该测试点并记录错误日志，**继续执行剩余测试点**（不中断流程）。
- **步骤 3.5**：初始化统计计数器（总测试点数、当前通过数、失败详情列表），准备进入迭代。

### 4. 迭代框架（外层循环）

```
# 0. 初始化：解析配对清单，得到 testpoints
testpoints = resolve_pairings()   # 基于 pairing.json 或目录扫描，过滤掉缺失文件

while True:
    # 1. 解析与 JSON 生成
    for tp in testpoints:
        python scripts/parse_to_json.py tp.src_path -o tp.json_path
    
    # 2. JSON 格式规范检查
    for tp in testpoints:
        python scripts/check_json_spec.py tp.json_path
        # 若失败，在 tp 中标记 "spec_fail" 并记录错误
    
    # 3. Verilog 恢复（仅对通过格式检查的测试点）
    for tp in [tp for tp in testpoints if not tp.spec_fail]:
        python scripts/generate_from_json.py tp.json_path -o tp.restored_path
    
    # 4. 功能等价性检查（调用预处理阶段生成的特化脚本）
    for tp in [tp for tp in testpoints if not tp.spec_fail]:
        python scripts/check_output.py --src tp.src_path --tb tp.tb_path --restored tp.restored_path
        # 若失败，标记 tp.func_fail 并记录差异日志
    
    # 5. 汇总当前轮结果
    passed = count of tp with no spec_fail and no func_fail
    total = len(testpoints)
    记录通过率与所有失败详情
    
    # 6. 终止判断
    if passed == total:
        break  # 全部通过，迭代成功结束
    if 达到最大迭代次数（如50）:
        break  # 退出并保留失败项供人工分析
    
    # 7. LLM 反馈与脚本修改
    收集所有未通过测试点的失败日志（包括格式问题与功能差异）
    将失败日志 + 当前版本的 parse_to_json.py 和 generate_from_json.py 源码提交给 LLM
    LLM 仅可修改这两个脚本文件（不得修改 check_output.py、check_json_spec.py、源代码或 TB）
    应用修改后的脚本，进入下一轮迭代
```

### 5. 各阶段详细说明（与 check_output.py 的协作）

#### 阶段 4：功能等价性检查（调用 check_output.py）
- **脚本特性**：该脚本由预处理阶段根据本 benchmark 的 TB 文件专门生成，因此它“天然知道”：
  - 仿真需要运行多长时间（`$finish` 时刻）。
  - 标准输出中会出现哪些特定的 `$display` 格式。
  - 是否需要比对 VCD 波形中的特定信号组。
- **执行命令**：`python scripts/check_output.py --src <路径> --tb <路径> --restored <路径>`
- **输出约定**：脚本返回 0 表示通过，返回非 0 表示失败，并将差异详情打印到 stderr 或日志文件中，供后续 LLM 分析。
- **失败判定**：编译错误、仿真崩溃、文本输出不匹配、波形关键信号值不一致，均视为失败。

### 6. 迭代控制与 LLM 反馈

- **每轮迭代结束后**，汇总所有未通过项的失败原因：
  - 格式失败（阶段 2）→ 通常因 JSON 缺失关键信息，需改进 `parse_to_json.py` 的生成逻辑。
  - 功能差异（阶段 4）→ 可能因解析丢失语义或恢复时语法变换不当，需改进 `parse_to_json.py` 或 `generate_from_json.py`。
- **反馈内容**：
  - 失败统计（通过率）。
  - 每个失败点的详细错误日志（包括文件路径、具体差异）。
  - 当前版本的 `parse_to_json.py` 和 `generate_from_json.py` 完整源码。
- **LLM 修改约束**：
  - 仅允许修改 `scripts/parse_to_json.py` 和 `scripts/generate_from_json.py`。
  - 不得修改源代码、测试代码、检查脚本（含 `check_output.py`）或目录结构。
- **修改方向**：LLM 根据错误根因，提出针对性代码变更（如改进正则匹配、增加语法分支、修正信号连接规则等），人工审核后应用（或自动应用），进入下一轮。

### 7. 终止条件
- 所有测试配对标记为“通过” → 迭代成功结束。
- 达到预设最大迭代次数（如 50） → 记录未通过项，人工介入分析。

### 8. 输出产物
- `json/` 目录下最终通过的 JSON 文件（可存档）。
- `restored/` 目录下恢复的 Verilog 文件（用于验证或后续使用）。
- 每轮迭代的通过率统计和详细日志（便于追溯）。
- 最终优化后的 `parse_to_json.py` 和 `generate_from_json.py` 脚本。
