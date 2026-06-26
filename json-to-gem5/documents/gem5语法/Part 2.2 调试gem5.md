## 调试gem5

gem5通过debug flags提供printf输出形式的踪迹和调试。这些标志允许每个模块都声明调试输出语句，而选择性地激活部分调试输出。

这可以通过运行gem5时修改命令行来实现，例如执行 `build/X86/gem5.opt --debug-flags=DRAM configs/tutorials/part1/SimpleCPU/simple.py | head -n 50`来打开DRAM的调试输出（由于使用了管道将输出提供给head命令，运行完后会有一个报错，可以忽略，感兴趣的读者可以自行搜索相关信息）；执行 `build/X86/gem5.opt --debug-flags=Exec configs/tutorials/part1/SimpleCPU/simple.py | head -n 50`来打开CPU执行相关的调试信息。

事实上，`Exec`标志是一系列标志的集合，可以通过 `build/X86/gem5.opt --debug-help`查看相关信息。

### 添加新的调试标志

上一节中，我们使用的是 `std::cout`进行输出，尽管在gem5中能够使用普通的C/C++ IO方式，但非常不建议这样做。因此，在本节中我们将使用gem5的调试设施来代替它。

为了创建一个新的调试标志，需要在 `SConscript`文件中注册。添加下面这行代码到 `src/tutorials/SConscript`中，这样就声明了一个叫“HelloExample”的调试标志。

然后，在 `my_hello_object.cc`中，我们需要导入自动生成的两个相关头文件，这样就可以使用头文件中的相关（宏）函数代替 `std::cout`。

```cpp
// @file: src/tutorials/SConscript
# 注册调试标志
DebugFlag("MyHelloExample")

// @file: src/tutorials/my_hello_object.cc
// 添加调试相关头文件，MyHelloExample.hh在构建时自动生成
#include "base/trace.hh"
#include "debug/MyHelloExample.hh"
...
// std::cout << "Hello World! From a SimObject!" << std::endl;
// 使用DPRINTF宏替换std::cout，第一个参数表示与HelloExample标志绑定，后续参数为输出信息，用法与printf一致
// 该宏函数定义在src/base/trace.hh:209，可用grep -r -n -w "#define DPRINTF" src/base/查找
DPRINTF(MyHelloExample, "Created the hello object\n");
```

完成修改后，执行 `scons build/X86/gem5.opt`重新编译gem5，再执行 `build/X86/gem5.opt --debug-flags=MyHelloExample configs/tutorials/part2/run_hello.py`即可看到修改后的新输出。

`DPRINTF`每次调用默认都会输出三个信息到 `stdout`标准输出流，依次是当前的时钟周期数（tick）、调用DPRINTF的SimObject变量名和传递给DPRINTF的调试信息字符串。另外，还可以通过 `--debug-file`参数指定输出到任意文件，文件使用相对于gem5输出目录 `m5out/`的相对路径。

### 其他调试函数

`DPRINTF`是gem5中最常用的调试函数，但gem5还提供了一系列其他函数，在一些特殊情况下很有用，可参阅[gem5: base/trace.hh File Reference](https://doxygen.gem5.org/release/current/base_2trace_8hh.html)。

这些函数只有在运行以“opt”或“debug”模式编译的可执行文件时才会激活，即“gem5.opt”或“gem5.debug”。
