# Verilog/SystemVerilog 双向转换 JSON 规范

**版本**：1.0.0  
**核心原则**：本规范定义的 JSON 格式，必须能够**无损地**反向生成与原始代码功能等价的 Verilog/SystemVerilog 代码（忽略空格、注释和格式差异）。所有语法元素和表达式细节均需显式存储。

---

## 1. 设计原则（强调完备性）

1. **语义完备性**：保留所有语法信息（参数、端口类型、阻塞/非阻塞、生成块、函数/任务等），不允许模糊或省略。
2. **表达式结构化**：所有表达式（RHS 值、条件）必须存储为**递归 AST 对象**，而不是字符串。这保证了反向生成时无需猜测操作符优先级或结合性。
3. **无歧义常量**：所有数字常量以**字符串**形式存储，保留进制和位宽（如 `"32'hDEAD"`）。
4. **显式类型**：`data_type`（如 `wire`、`reg`、`logic`）和 `signed` 属性必须明确。
5. **可扩展性与前向兼容**：通过版本号管理，解析器须忽略未知字段。

---

## 2. 顶层结构

```json
{
  "version": "string (required)",
  "metadata": { ... },
  "includes": ["string"],      // `include 文件路径列表
  "defines": [ ... ],          // `define 宏定义
  "packages": [ ... ],         // 预留 SystemVerilog package 支持
  "modules": [ ... ],
  "design_hierarchy": { ... }  // 可选，便于快速导航
}
```

---

## 3. 表达式（Expression）AST 规范（核心）

**所有 `rhs`、`condition`、`value` 等字段，必须使用以下对象之一表示：**

### 3.1 信号引用（Ref）
```json
{ "ref": "signal_name" }
```
表示一个标识符（变量、端口、参数）。

### 3.2 字面量（Literal）
```json
{ "literal": "32'hDEAD_BEEF" }
```
所有常量值必须为字符串，保留位宽和进制。

### 3.3 位/向量选择（Select）
```json
{
  "type": "select",
  "source": { "ref": "data_bus" },
  "range": { "msb": 7, "lsb": 0 }   // 包含 msb 和 lsb
}
```
或单比特选择：
```json
{
  "type": "bit_select",
  "source": { "ref": "data_bus" },
  "index": { "literal": "5" }
}
```

### 3.4 一元运算（Unary）
```json
{
  "op": "! | ~ | - | & | ~& | | | ~| | ^ | ~^",
  "operand": { ... }   // 子表达式
}
```

### 3.5 二元运算（Binary）
```json
{
  "op": "+ | - | * | / | % | & | | | ^ | ^~ | ~^ | && | || | == | != | === | !== | < | <= | > | >= | << | >> | <<< | >>>",
  "left": { ... },
  "right": { ... }
}
```

### 3.6 条件运算（Ternary）
```json
{
  "type": "cond",
  "condition": { ... },
  "true_expr": { ... },
  "false_expr": { ... }
}
```

### 3.7 拼接（Concat）
```json
{
  "type": "concat",
  "parts": [ { ... }, { ... } ]   // 数组，按顺序拼接
}
```

### 3.8 复制（Replication）
```json
{
  "type": "replicate",
  "times": { "literal": "8" },
  "value": { "ref": "signal" }
}
```

### 3.9 函数调用（Call）
```json
{
  "type": "call",
  "function": "my_func",
  "arguments": [ { ... }, { ... } ]
}
```

---

## 4. 语句（Statement）规范

### 4.1 赋值语句（Assignment）
```json
{
  "type": "assignment",
  "lhs": { ... },         // 必须是 Ref 或 Select
  "rhs": { ... },         // 任何表达式 AST
  "blocking": true | false, // true: =, false: <=
  "delay": { "value": "10", "type": "unit" } // 可选, 如 #10
}
```

### 4.2 If 语句
```json
{
  "type": "if",
  "condition": { ... },
  "then": [ { ... } ],    // 语句列表
  "else": [ { ... } ]     // 可选
}
```

### 4.3 Case 语句
```json
{
  "type": "case",
  "expression": { ... },
  "items": [
    { "value": { "literal": "2'b00" }, "body": [ ... ] },
    { "value": { "literal": "2'b01" }, "body": [ ... ] }
  ],
  "default": [ ... ]      // 可选
}
```
支持 `casex` / `casez`，通过 `case_type` 字段指定（`"x"` 或 `"z"`）。

### 4.4 循环语句（For/While/Repeat/Forever）
```json
{
  "type": "for",
  "init": { "type": "assignment", ... },
  "condition": { ... },
  "step": { "type": "assignment", ... },
  "body": [ ... ]
}
```

### 4.5 Return 语句（用于函数）
```json
{
  "type": "return",
  "value": { ... }       // 表达式 AST
}
```

---

## 5. 模块（Module）对象详细字段

### 5.1 参数（Parameter）
```json
{
  "name": "string",
  "type": "parameter | localparam",
  "data_type": "int | logic | ... (optional)",
  "value": "string",
  "description": "string (optional)"
}
```
> **值必须为字符串**，如 `"32"` 或 `"XLEN * 2"`。

### 5.2 端口（Port）
```json
{
  "name": "string",
  "direction": "input | output | inout",
  "data_type": "wire | reg | logic | integer | ...",  // 显式类型
  "width": "integer",
  "signed": "boolean (default false)",
  "range_msb": "integer (optional)",  // 若不为 [width-1:0]
  "range_lsb": "integer (optional)"
}
```

### 5.3 信号（Signal）
```json
{
  "name": "string",
  "type": "wire | reg | logic | integer | ...",
  "width": "integer",
  "signed": "boolean",
  "dimensions": [ {"msb": 7, "lsb": 0} ], // 支持多维数组
  "initial_value": "string (optional)"
}
```

### 5.4 实例化（Instance）
```json
{
  "name": "string",
  "module": "string",
  "parameter_mapping": { "PARAM_NAME": { ... } },  // 值必须是 AST 或引用
  "port_connections": [
    { "port": "port_name", "connection": { ... } }  // 连接必须是 AST 表达式
  ]
}
```

### 5.5 Always 块
```json
{
  "id": "string (unique)",
  "type": "always | always_comb | always_ff | always_latch",
  "sensitivity": [
    { "type": "posedge | negedge | level", "signal": "clk" }
  ],
  "body": [ ... ]   // 语句列表
}
```

### 5.6 Generate 块
```json
{
  "type": "generate_if | generate_for | generate_case",
  "condition": { ... },   // 或 init/condition/step for generate_for
  "body": [ ... ]         // 可以包含实例、assign、always 等
}
```

### 5.7 函数（Function）
```json
{
  "name": "string",
  "return_type": "string",
  "inputs": [ {"name": "a", "type": "logic"} ],
  "body": [ ... ]   // 语句列表，必须包含 return
}
```

### 5.8 任务（Task）
```json
{
  "name": "string",
  "inputs": [ ... ],
  "outputs": [ ... ],
  "body": [ ... ]
}
```

---

## 6. 反向生成（JSON → Verilog）规则

1. **顶层顺序**：`includes` → `defines` → `module` 声明。
2. **模块声明**：使用 ANSI-C 风格，`module module_name #(parameters) (ports);`。
3. **类型显式**：所有 `reg`/`wire`/`logic` 声明必须包含位宽和 signed 属性。
4. **生成代码**：严格依据 AST 表达式递归生成，运算符两端添加空格以保证可读性（如 `a + b`）。
5. **缩进和格式**：采用 2 空格缩进，语句块用 `begin`/`end` 包裹（除非单行）。
6. **块/非块**：严格依据 `blocking` 字段输出 `=` 或 `<=`。

---

## 7. 完备性检查清单

| Verilog 元素 | 是否显式存储 | 反向生成保障 |
| :--- | :--- | :--- |
| 端口数据类型（wire/reg/logic） | ✅ `data_type` | 生成 `input wire`, `output reg` 等 |
| 有符号修饰 | ✅ `signed` | 生成 `signed` 关键字 |
| 阻塞/非阻塞赋值 | ✅ `blocking` | 生成 `=` 或 `<=` |
| 位宽和进制 | ✅ `literal` 字符串 | 直接还原 |
| 延迟控制（#10） | ✅ `delay` | 生成 `#10` |
| 表达式优先级 | ✅ AST 树 | 括号自动添加 |
| 函数/任务 | ✅ 独立部分 | 生成完整 `function`/`task` |
| Generate 块 | ✅ `generates` | 生成 `generate`...`endgenerate` |
| 宏定义 | ✅ `defines` | 生成 ` `define` 语句 |
| Include | ✅ `includes` | 生成 ` `include` 语句 |

---

## 8. 示例：最小单元的反向生成

### 输入 JSON（片段）
```json
{
  "type": "assignment",
  "lhs": { "ref": "count" },
  "rhs": { "op": "+", "left": { "ref": "count" }, "right": { "literal": "1'b1" } },
  "blocking": false
}
```

### 生成的 Verilog
```verilog
count <= count + 1'b1;
```

---

## 9. 版本历史

| 版本 | 日期 | 变更说明 |
| :--- | :--- | :--- |
| 1.0.0 | 2026-06-25 | 初始版本，强调双向转换完备性 |