## ARM功耗建模

在gem5模拟中建模、监控能量和功率的使用是可能的。为了实现这一点，需要使用gem5在 `MathExprPowerModel`中记录的各种统计数据，通过数学等式建模功率的使用。这一章会详细介绍功率建模所需的各个组件，并演示如何将它们添加到已有的ARM模拟中。

本章会利用 `configs/example/arm`目录中提供的 `fs_power.py`配置文件，同时也会提供一些指令来扩展这个脚本和其他脚本。

注意，功率模型只能应用于详尽建模的timing CPU。

关于功率建模是如何融入到gem5中以及它们与模拟器的哪些部分进行交互，可以在2017年ARM研究峰会上[Sascha Bischoff的报告](https://youtu.be/3gWyUWHxVj4)中找到答案。

### 动态功率状态

功率模型由两个函数组成，它们描述了在不同功率状态下如何计算功耗，这些功率状态分别是（定义于 `src/sim/PowerState.py`）：

* UNDEFINED：默认值，无效状态，没有可用的功耗状态派生信息。
* ON：逻辑块正在活跃运行，根据其处理量消耗相应动态和泄露能量（动态功耗和静态功耗）。
* CLK_GATED：使用时钟门控节省动态能量（动态功耗），电源供给依然在，会消耗泄露能量（静态功耗）。
* SRAM_RETENTION：逻辑块中SRAM被拉入保留状态以进一步节省泄露能量（静态功耗）。
* OFF：通过电源门控关闭电源，不消耗任何能量。

除了 `UNDEFINED`外，每个状态都有一个对应的功率模型，通过 `PowerModel`类的 `pm`字段指定，它是一个包含四个功率模型的列表，顺序如下：

1. ON
2. CLK_GATED
3. SRAM_RETENTION
4. OFF

需要注意的是，虽然这里有4个不同的入口，但它们不必是不同的功率模型。`fs_power.py`中给 `ON`状态使用了一个功率模型，其他状态则使用的是相同的功率模型。

### 功率使用类型

gem5模拟器建模了2种功率使用：

* **静态**：跟活跃度无关的功率

* **动态**：由于各种活动造成的功率

一个功率模型必须包含对这两个功率类型进行建模的等式（但如果功率模型不需要考虑静态功率或无关紧要，可以直接把等式设为 `st = "0"`）。

### MathExprPowerModels类

`fs_power.py`中提供的功率模型继承自 `MathExprPowerModel`类。`MathExprPowerModels`用字符串表示的数学表达式来决定如何计算系统所使用的功率，它们通常是一些统计数据和自动变量（如温度）的组合，例如（节选自 `fs_power.py`）：

```python
# @file: configs\example\arm\fs_power.py
...
class CpuPowerOn(MathExprPowerModel):
    def __init__(self, cpu_path, **kwargs):
        super(CpuPowerOn, self).__init__(**kwargs)
        # 每个IPC消耗电流2A，每次缓存缺失消耗3pA，通过P=U*I计算功率
        self.dyn = "voltage * (2 * {}.ipc + 3 * 0.000000001 * " \
                   "{}.dcache.overall_misses / sim_seconds)".format(cpu_path, cpu_path)
        self.st = "4 * temp"
...
def main():
    ...
    # Wire up some example power models to the CPUs
    for cpu in root.system.descendants():
        if not isinstance(cpu, m5.objects.BaseCPU):
            continue

        cpu.power_state.default_state = "ON"
        cpu.power_model = CpuPowerModel(cpu.path())

    # Example power model for the L2 Cache of the bigCluster
    for l2 in root.system.bigCluster.l2.descendants():
        if not isinstance(l2, m5.objects.Cache):
            continue

        l2.power_state.default_state = "ON"
        l2.power_model = L2PowerModel(l2.path())
    ...
...

```

可以看到，自动变量（如 `voltage`和 `temp`）不需要路径，而模块相关的统计数据（如CPU的 `ipc`）则需要对应模块的路径。继续往下，在 `main`函数中，可以看到CPU对象有一个 `path()`函数，它会返回组件在系统中的路径（如 `system.bigCluster.cpus0`）。`path`函数是由 `SimObject`提供的，所以可以被系统中任意派生自它的对象使用，例如 `cpu.path()`下面几行的L2 cache对象。

### 扩展已有的模拟

`fs_power.py`脚本通过导入 `fs_bigLITTLE.py`并修改变量值来扩展已有的 `fs_bigLITTLE.py`脚本。除此之外，上面的代码还使用了一些循环来迭代 `SimObject`的后代（该SimObject中声明的所有SimObject对象），给它们添加功率模型。所以为了给一个已有的模拟扩展功率模型，定义一个辅助函数是有帮助的：

```python
def _apply_pm(simobj, power_model, so_class=None):
    for desc in simobj.descendants():
        if so_class is not None and not isinstance(desc, so_class):
            continue

        desc.power_state.default_state = "ON"
        desc.power_model = power_model(desc.path())

# 使用这个辅助函数后，上面代码中的两个循环可以简化为如下两行函数调用
def main():
    ...
    # Wire up some example power models to the CPUs
    _apply_pm(root.system, CpuPowerModel, m5.objects.BaseCPU)
    # Example power model for the L2 Cache of the bigCluster
    _apply_pm(root.system.bigCluster.l2, L2PowerModel, m5.objects.Cache)

```

上面的函数输入参数为一个SimObject、一个功率模型以及一个可选的类参数，通过这个可选参数指定该SimObject的后代中需要应用功率模型的实例，如果没有指定，则功率模型会应用到所有后代上。

不管是否使用辅助函数，接下来需要定义一些功耗模型。按照 `fs_power.py`中的如下模式即可：

1. 为感兴趣的每个功率状态定义一个类。这些类需要继承自 `MathExprPowerModel`且包含一个 `dyn`和 `st`字段，每个字段都包含一个用字符串的功率计算公式；类的构造函数需要传入等式中所需的路径以及一系列传递给超类构造函数的kwargs。
2. 定义一个类来存放上一步定义的功率模型。这个类需要继承自 `PowerModel`且只有一个 `pm`字段，由这个字段来保存4类功率模型组成的列表，其顺序需要严格按照 `["ON"状态的功率模型, "CLK_GATED"状态的功率模型, "SRAM_RETENTION"状态的功率模型, "OFF"状态的功率模型]`的顺序；类的构造函数需要传入每个功率模型所需的路径以及一系列传递给超类构造函数的kwargs。
3. 有了上面提供的辅助函数和定义的类，就可以修改 `build`函数来实现功率模型的扩展，还可以在 `addOptions`函数中添加一个命令行标志来切换是否使用功率模型。

示例如下：

```python
class CpuPowerOn(MathExprPowerModel):
    def __init__(self, cpu_path, **kwargs):
        super(CpuPowerOn, self).__init__(**kwargs)
        self.dyn = "voltage * 2 * {}.ipc".format(cpu_path)
        self.st = "4 * temp"


class CpuPowerClkGated(MathExprPowerModel):
    def __init__(self, cpu_path, **kwargs):
        super(CpuPowerOn, self).__init__(**kwargs)
        self.dyn = "voltage / sim_seconds"
        self.st = "4 * temp"


class CpuPowerOff(MathExprPowerModel):
    dyn = "0"
    st = "0"


class CpuPowerModel(PowerModel):
    def __init__(self, cpu_path, **kwargs):
        super(CpuPowerModel, self).__init__(**kwargs)
        self.pm = [
            CpuPowerOn(cpu_path),       # ON
            CpuPowerClkGated(cpu_path), # CLK_GATED
            CpuPowerOff(),              # SRAM_RETENTION
            CpuPowerOff(),              # OFF
        ]

[...]

def addOptions(parser):
    [...]
    parser.add_argument("--power-models", action="store_true",
                        help="Add power models to the simulated system. "
                             "Requires using the 'timing' CPU."
    return parser


def build(options):
    root = Root(full_system=True)
    [...]
    if options.power_models:
        if options.cpu_type != "timing":
            m5.fatal("The power models require the 'timing' CPUs.")

        _apply_pm(root.system.bigCluster.cpus, CpuPowerModel
                  so_class=m5.objects.BaseCpu)
        _apply_pm(root.system.littleCluster.cpus, CpuPowerModel)

    return root

[...]

```

### 统计数据名

统计数据的名字通常与 `m5out/stats.txt`中记录的相同，但也有几个例外：

* CPU时钟在 `stats.txt`中记为 `clk_domain.clock`，但在功率模型中需要使用 `clock_period`而不是 `clock`。

### 统计频率

默认情况下，gem5导出模拟统计数据的周期是一个模拟秒。这可以通过 `m5.stats.periodicStatDump`函数进行控制，输入参数是以模拟ticks为单位（而不是秒）的期望导出频率。幸运的是 `m5.ticks`提供了一个 `fromSeconds`函数以便转换。

统计频率对功率分析结果的影响可以总结为以下两点，采样频率越高：

* 功率曲线细节越多；但会导致 `stats.txt`数据量显著增大，占用更多存储空间
* 更多数据点以捕捉DVFS变化（提高时间精度）

因此需要权衡输出大小和保真度，控制统计频率是有意义的。

在 `fs_power.py`脚本中，它是这样实现的：

```python
[...]

def addOptions(parser):
    [...]
    parser.add_argument("--stat-freq", type=float, default=1.0,
                        help="Frequency (in seconds) to dump stats to the "
                             "'stats.txt' file. Supports scientific notation, "
                             "e.g. '1.0E-3' for milliseconds.")
    return parser

[...]

def main():
    [...]
    m5.stats.periodicStatDump(m5.ticks.fromSeconds(options.stat_freq))
    bL.run()

[...]

```

在调用模拟时通过 `--stat-freq <val>`选项就可以指定导出统计数据的频率。

### 常见问题

使用 `fs_power.py`时gem5崩溃：

* `fatal: statistic '' (160) was not properly initialized by a regStats() function`

* `fatal: Failed to evaluate power expressions: [...]`

出现这些报错是因为gem5的统计框架最近重构了，获取最新的gem5源码并重新构建应该能修复问题。如果不想拉取最新源码，需要打上以下两组补丁，通过在下面链接中点击Download获取各自的指令进行分支切换和应用补丁：

1. [https://gem5-review.googlesource.com/c/public/gem5/+/26643](https://gem5-review.googlesource.com/c/public/gem5/+/26643)
2. [https://gem5-review.googlesource.com/c/public/gem5/+/26785](https://gem5-review.googlesource.com/c/public/gem5/+/26785)
