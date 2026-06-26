## ARM DVFS建模

跟大多数现代CPU一样，ARM CPU也支持DVFS（动态电压频率缩放）。可以在gem5中对其进行建模，例如监控由此产生的功耗。DVFS的建模是使用电压域和时钟域这两个时钟对象组件实现的。这一章会详细介绍这两个不同的组件，并展示把它们添加到已有模拟的不同方式。

### 电压域（VD）

电压域决定了CPU可以使用的电压值。如果运行一个gem5全系统模拟时没有指定VD，将会使用默认电压值1.0V。这是为了避免强制用户考虑电压，即使他们对此并不感兴趣。

电压域可以被构造成一个值或一个列表，使用 `voltage` kwarg传递给 `VoltageDomain`的构造函数。如果指定了一个电压和多个频率，那么这个电压将应用到时钟域中的所有频率。如果指定了一个电压列表，那么电压的数量必须与时钟域中的频率数量一致，且必须按照降序排列。就像真实硬件一样，一个电压域会应用到整个处理器插槽。也就是说如果你想给不同的处理器（例如大小核配置）应用不同的电压域，必须要保证大小集群（簇）在不同的插槽中（检查与簇关联的 `socket_id`值）。

有两种方式给现有的CPU/模拟添加电压域，一个更灵活而另一个更直接。第一个方法是给 `configs/example/arm/fs_bigLITTLE.py`添加命令行标志，第二种方法是添加自定义类。

1. 给模拟添加电压域最灵活的方式是使用命令行标志。在 `addOptions`函数中添加这个标志，还可以写上一些帮助信息。下面的示例支持单个电压和多个电压，通过 `--big-cpu-voltage <val1>V [<val2>V [<val3>V [...]]]`指定电压域的电压值：

```python
def addOptions(parser):
    [...]
    # nargs="+"，保证至少需要一个参数
    parser.add_argument("--big-cpu-voltage", nargs="+", default="1.0V",
                        help="Big CPU voltage(s).")
    return parser

[...]

def build(options):
    [...]
    # big cluster
    if options.big_cpus > 0:
        # 通过options.big_cpu_voltage获取指定的电压域
        system.bigCluster = big_model(system, options.big_cpus,
                                      options.big_cpu_clock,
                                      options.big_cpu_voltage)
    [...]

```

2. 另一个不太灵活的方式是创建 `CpuCluster`的子类。就像现有的 `BigCluster`和 `LittleCluster`，这些类会扩展 `CpuCluster`类。在子类的构造函数中，除了指定CPU类型，我们还需要定义一个电压域的列表并使用 `cpu_voltage` kwarg传递给超类构造函数。下面的示例演示了如何给 `BigCluster`添加电压，最后可以通过 `--cpu-type vd-timing`指定使用我们定义的带电压域的CPU：

```python
class VDBigCluster(devices.CpuCluster):
    def __init__(self, system, num_cpus, cpu_clock=None, cpu_voltage=None):
        # use the same CPU as the stock BigCluster
        abstract_cpu = ObjectList.cpu_list.get("O3_ARM_v7a_3")
        # voltage value(s)，降序
        my_voltages = [ '1.0V', '0.75V', '0.51V']

        super(VDBigCluster, self).__init__(
            cpu_voltage=my_voltages,
            system=system,
            num_cpus=num_cpus,
            cpu_type=abstract_cpu,
            l1i_type=devices.L1I,
            l1d_type=devices.L1D,
            wcache_type=devices.WalkCache,
            l2_type=devices.L2
        )

# 将自定义的CPU类添加到cpu_types字典中
cpu_types = {
    [...]
    "vd-timing" : (VDBigCluster, VDLittleCluster)
}

```

### 时钟域（CD）

电压域需要与时钟域结合使用。就像前面说的，如果没有指定自定义电压值，那么所有时钟域都将使用默认值1.0V。

与电压域只有单一类型相比，时钟域有三种不同的类型（定义于 `src/sim/clock_domain.hh`）：

* `ClockDomain`：给绑定在同一个时钟域下的一组时钟对象提供时钟。时钟域依次按电压域分组，支持源时钟域和派生时钟域两种类型的层次结构
* `SrcClockDomain`：连接到可调时钟源的时钟域。它维护了一个时钟周期并提供设置和获取时钟的方法、以及提供给处理程序进行管理的时钟域配置参数。包括对应不同性能级别的一系列频率值、一个域ID以及当前的性能级别。注意，软件要求的性能级别对应着时钟域可以运行的其中一个频点。
* `DerivedClockDomain`：连接到一个父时钟域的派生时钟域，父时钟域可以是一个 `SrcClockDomain`或 `DerivedClockDomain`。它维护了一个时钟分频器并提供获取时钟的方法。

### 给现有模拟添加时钟域

这里的样例使用与电压域样例中相同的文件，`configs/example/arm/fs_bigLITTLE.py`和 `configs/example/arm/devices.py`。

像电压域一样，时钟域也可以是一个单独的值或是一系列值的列表。如果给出了一个时钟的列表，需要遵循与电压域中的列表相同的规则，如时钟域的值数量需要与电压域对应，时钟速度需要降序排列。提供的这两个文件支持给时钟指定一个单独的值（通过 `--{big, little}-cpu-clock`标志），但不能是一个列表。为了支持多个值的时钟域，扩展/修改这个给定标志的行为是最简单和灵活的方式，但通过添加子类也是可行的。

1. 为了给现有的 `--{big,little}-cpu-clock`标志添加多值支持，需要定位到 `configs/example/arm/fs_bigLITTLE.py`中的 `addOptions`函数。在各种各样的 `parser.add_argument`调用中，找到添加CPU时钟标志的那两个并把kwarg从 `type=str`改成 `nargs="+"`。修改之后，可以像电压域一样通过 `--{big,little}-cpu-clock <val1>GHz [<val2>MHz [<val3>MHz [...]]]`来指定多个频率。由于这里是修改已有的标志，标志的值已经连接到了 `build`函数中对应的构造函数和kwargs，因此 `build`函数中没有需要修改的地方。

```python
def addOptions(parser):
    [...]
    parser.add_argument("--big-cpu-clock", nargs="+", default="2GHz",
                        help="Big CPU clock frequency.")
    parser.add_argument("--little-cpu-clock", nargs="+", default="1GHz",
                        help="Little CPU clock frequency.")
    [...]
```

2. 对于在子类中添加时钟域，流程与添加电压域子类非常相似。不同点在于电压域子类中通过 `cpu_voltage` kwarg指定电压，这里我们通过超类构造函数中的 `cpu_clock` kwarg来指定时钟值。它可以与电压域样例结合来同时指定簇的电压域和时钟域。但就像使用这种方式添加电压域一样，我们需要为每一类CPU定义一个类并记录在 `cpu-types`字典中。这种方法也有同样的限制且没有基于标志的方法那么灵活。

```python
class CDBigCluster(devices.CpuCluster):
    def __init__(self, system, num_cpus, cpu_clock=None, cpu_voltage=None):
        # use the same CPU as the stock BigCluster
        abstract_cpu = ObjectList.cpu_list.get("O3_ARM_v7a_3")
        # clock value(s)
        my_freqs = [ '1510MHz', '1000MHz', '667MHz']

        super(VDBigCluster, self).__init__(
            cpu_clock=my_freqs,
            system=system,
            num_cpus=num_cpus,
            cpu_type=abstract_cpu,
            l1i_type=devices.L1I,
            l1d_type=devices.L1D,
            wcache_type=devices.WalkCache,
            l2_type=devices.L2
        )
```

### 确保时钟域有有效的域ID

不管使用前面的哪种方法，都还需要一些额外的修改。这涉及到 `configs/example/arm/devices.py`。

在这个文件中定位到 `CpuClusters`类并找到实例化 `SrcClockDomain`的位置。就像前面提到的 `SrcClockDomain`的定义，它有一个域ID。如果没有设置这个值，就像这个配置中提供的例子一样，那么会使用默认ID `-1`。将代码改成下述形式可以确保设置了域ID：

```python
[...]
self.clk_domain = SrcClockDomain(clock=cpu_clock,
                                 voltage_domain=self.voltage_domain,
                                 domain_id=system.numCpuClusters())
[...]
```

这里使用的是 `system.numCpuClusters()`，因为这个时钟域应用到整个簇，例如0代表第一个簇、1代表第二个簇，以此类推。

如果不设置域ID，当你尝试支持DVFS的模拟时，会因为一些内部检查获取到了默认域ID而得到如下报错：

```plaintext
fatal: fatal condition domain_id == SrcClockDomain::emptyDomainID occurred:
DVFS: Controlled domain system.bigCluster.clk_domain needs to have a properly
assigned ID.
```

### DVFS处理函数

如果你指定了电压域和时钟域并尝试运行模拟，大概率会运行起来，但你可能会注意到如下警告：

```plaintext
warn: Existing EnergyCtrl, but no enabled DVFSHandler found.
```

电压域和时钟域都已经添加了，但没有 `DVFSHandler`，系统无法与之交互来调节这些值。修复这个的最简单方式是 `configs/example/arm/fs_bigLITTLE.py`中添加另一个命令行标志。

就像电压域和时钟域中一样，定位到 `addOptions`函数并添加如下代码：

```python
def addOptions(parser):
    [...]
    parser.add_argument("--dvfs", action="store_true",
                        help="Enable the DVFS Handler.")
    return parser
```

然后定位到 `build`函数并添加如下代码：

```python
def build(options):
    [...]
    if options.dvfs:
        system.dvfs_handler.domains = [system.bigCluster.clk_domain,
                                       system.littleCluster.clk_domain]
        system.dvfs_handler.enable = options.dvfs

    return root
```

万事俱备之后，你就可以使用 `--dvfs`标志运行一个支持DVFS的模拟了，根据需要还可以同时指定大簇和小簇的电压、频率工作点。

