在工作开始前需要生成一个PROGRESS.md文件，格式参考documents/PROGRESS范例.md，初始不用写任何文本，而是在任务进行过程中渐进式写入

## part1.生成模块规格描述文件
```
将1.用户的需求以及2.提供的文件路径传达给@ModuleFrameworkBuilder,禁止传递二次加工的信息以及其他信息，让其生成待生成模块的模块规格描述文件

完成后更新进程文件
```
## part2.根据生成的模块规格描述文件，生成符合gem5语法规范的代码

```
1. 读取模块规格描述文件
   - 读取 part1生成的模块规格描述文件
   - 解析txt文件中的模块描述，每个模块对应一个SimObject,判断哪些是子模块，哪些是顶层模块
2. 创建子agent (Task工具)
   - 根据解析出的模块数量，同时启动对应数量的子agent
   - 优先处理子模块，从底至顶生成
   - 使用@CodeGenerator这一子代理
   - 传递参数：模块描述内容、模块名、输出目录、模块是否使用了子模块以及子模块代码的路径

3. 收集结果
   - 等待所有子agent完成
   - 汇总生成的文件列表
```

## part3.构建流程
```
1. 执行 scons 构建
   cd gem5 && scons build/X86/gem5.opt -j10

2. 错误处理
   - 如果编译失败，且原因是超时，则返回让用户手动编译
   - 如果编译失败且不是因为超时，提取错误信息
   - 不允许清理构建缓存
   - 将错误信息发送给对应的子agent进行修复
   - 重复直到编译成功
```

## part4.生成样例点与测试模块并进行功能验证（重要！）

### 1. 测试分类：组合逻辑 vs 时序逻辑

#### 组合逻辑模块测试特点
- 无需时钟周期，set函数调用后立即产生输出
- TestGenerator在startup()中直接同步运行所有测试，无需事件调度
- 测试用例在构造函数中定义，直接遍历执行

#### 时序逻辑模块测试特点
- 需要时钟周期驱动，状态转换需要多个周期
- TestGenerator需要通过事件调度( EventFunctionWrapper)在每个周期设置输入
- 需要等待机制(wait_cycles)确保状态稳定后再读取输出

### 2. 为什么需要TestGenerator(具体命名应为XXX_test）？

**问题**：时序逻辑模块需要在每个周期传入不同的输入值，但gem5的Python端无法直接调用C++的set方法。

**解决方案**：创建独立的TestGenerator(具体命名应为XXX_test）模块，在C++端通过事件调度调用DUT的set函数。

### 3. 输入传递机制

```
┌─────────────────┐    set函数     ┌─────────────────┐
│  TestGenerator  │ ─────────────▶ │      DUT        │
│  (事件调度器)    │   每个周期     │  (待测模块)     │
└─────────────────┘               └─────────────────┘
```

**TestGenerator工作流程**：
1. 在startup()中调度第一个事件
2. 每次事件触发时，调用DUT的set函数设置输入
3. 调度下一个周期的事件
4. 所有输入发送完毕后调用exitSimLoop退出

### 4. 具体工作流
```
要求
- 按模块生成，只有在当前模块生成样例点、测试模块并测试通过后才能进行下一个模块
- 按自底向上的顺序进行测试，先测试子模块，最后测试顶层模块，在子模块测试完成后，要检查顶层模块的代码，以确保顶层模块正确使用子模块以及正确发挥子模块功能
- 如果测试不通过需要分析原因：a.如果是样例点有问题则修改样例点；b.如果是模块功能能问题则不允许修改样例点，只允许修改模块功能，修改完成后对齐测试模块。然后重新测试，如此往复，直到测试通过
- 修改bug的过程中除了可以参考gem5的成功案例外，也可以参考以下文件
  `documents/gem5语法/Part 2.1创建一个简单的SimObject.md`
  `documents/gem5语法/Part 2.3 事件触发编程.md`
  `documents/gem5语法/Part 2.4 为SimObject添加参数和更多事件.md`
  `documents/测试模块模板.md`
- **进度维护（重要！）**：
  - 每次完成一个模块的测试后，必须更新 PROGRESS.md
  - 更新内容：模块名、测试向量数量、测试模块状态、测试结果（通过/失败）、完成时间
  - 进度文档路径：项目根目录/PROGRESS.md
  - 格式参考 PROGRESS.md 的表格格式
```


#### 4.1 样例点生成（使用@SampleGenerator代理）
```
1. 为@SampleGenerator提供需要生成样例点的模块的代码所在的目录，也就是gem5/src/generators/xxx/
2. SampleGenerator分析模块逻辑，生成：
   - 测试向量 → test_vectors.json
   - 测试点元信息 → testpoints.json
   - coverage_plan.json
```

#### 4.2 测试模块与配置文件生成（使用@TestGenerator代理）
```
1. 创建子agent，使用@TestGenerator
2. 为子agent传递的信息（除此之外不允许传递其他信息）：
   - 模块名
   - 主模块头文件路径
   - 测试向量路径：gem5/src/generators/xxx/test_vectors.json
3. TestGenerator最终会生成：
   - gem5/src/generators/xxx_test/XXXTestGenerator.py
   - gem5/src/generators/xxx_test/xxx_test_generator.hh
   - gem5/src/generators/xxx_test/xxx_test_generator.cc
   - gem5/src/generators/xxx_test/SConscript
   - configs/xxx_test/xxx_test.py
4. 禁止JSON读取，所有测试向量硬编码在.cc文件中
5. 参考documents/测试模块模板.md
```



### 4.3 关于测试配置文件的说明

**测试配置文件存放位置**：
```
configs/xxx/
├── xxx_test.py      # 测试配置脚本
└── test_output.txt  # 测试输出结果（运行后生成）
```

**xxx_test.py**：
```python
import m5
from m5.objects import *

root = Root(full_system=False)

root.dut = Spi(clock_divider=1)
root.tester = SpiTestGenerator(
    clock_period=100,
    dut=root.dut,
)

m5.instantiate()
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")
```

### 4.4 运行测试

```bash
# 构建
cd gem5 && scons build/X86/gem5.opt -j10

# 运行测试
./build/X86/gem5.opt --debug-flags=DUT,TestGenerator ../configs/xxx/test_xxx.py
```

### 4.5 更新进度文档（必须执行）

**每次模块测试通过后，立即更新 PROGRESS.md**：

```markdown
| 模块 | 测试向量 | 测试模块 | 测试结果 | 完成时间 |
|------|----------|----------|----------|----------|
| xxx  | ✅ N个   | ✅       | ✅ 全部通过 (N/N) | YYYY-MM-DD |
```

**重要**：
- 测试通过后立即更新，不要等到所有模块完成
- 如果测试失败，标记为 🔄 测试中 或 ❌ 失败
- 完成时间格式：YYYY-MM-DD
- 保持表格按自底向上顺序排列（先子模块，后顶层模块）


