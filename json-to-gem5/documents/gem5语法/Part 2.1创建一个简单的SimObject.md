# Part 2. 修改、扩展gem5

这部分的官方示例代码位于 `src/learning_gem5/part2`和 `configs/learning_gem5/part2`，本仓库带中文注释的手写代码位于 `src/tutorials/part2`和 `configs/tutorials/part2`。

## 配置开发环境

修改任何开源项目的时候，遵守项目风格指南是很重要的。gem5的风格可以在[gem5: C/C++ Coding Style](https://www.gem5.org/documentation/general_docs/development/coding_style/)查阅。

同时，为了帮助用户遵守风格指南，gem5引入了一个脚本来自动检查git提交的代码，这个脚本在第一次构建gem5时会由SCons自动添加到 `.git/config`文件。当你实在想要提交一份没有遵守gem5风格指南的代码时（比如在gem5源码结构外的内容），可以使用git选项 `--no-verify`来跳过风格检查。

gem5风格的要点如下：

* 使用4个空格而不是Tab
* 对头文件进行排序
* 类名用大驼峰命名法（如MyClass），成员变量和函数使用小驼峰命名法（如myFunc），局部变量使用蛇形命名法（如local_var）
* 使用Doxygen风格对文件、类和成员进行归档

另外，在开发gem5时，请使用git的branch特征来单独跟踪自己的修改，方便将你的修改提交回gem5以及从gem5拉取别人的更改而不影响自己的修改。

## 创建一个简单的SimObject

> **注意**：gem5有一个叫 `SimpleObject`的SimObject，所以这里我们不能使用这个名字。

SimObject是封装好的C++对象，能够在Python配置脚本中访问。在gem5中，几乎所有对象都继承自基类SimObject，SimObject提供了gem5中各种各样的对象所需的主要接口。

SimObject有很多可以通过Python配置文件设置的参数。除了像整数、浮点数这样的简单参数，还可以有其他SimObject作为参数。这样就可以创建出像真实机器的复杂系统层次结构。

本章会通过创建一个简单的“HelloWorld”SimObject来介绍如何创建SimObject对象以及所需的样板代码。同时，还会写一个简单的Python配置脚本来实例化我们写的SimObject对象。

在后面的章节中，我们会继续在这个简单的SimObject上进行扩展，尝试引入调试支持、动态事件和对象参数。

> 在开始之前，就像前面说的，建议先创建一个新的git分支来保存自己的修改。如 `git checkout -b hello-simobject`。

### Step 1：为新的SimObject类创建一个Python类

每个SimObject都有一个对应的Python类，这个类描述了该SimObject能在Python配置文件中进行调整的参数。

这里我们只是设计一个简单的SimObject，无需任何参数，所以只在 `src/tutorials/part2`中创建一个文件 `MyHelloObject.py`，并声明一个新类，指定类名与对应的C++头文件路径以及C++类名即可。

```python
from m5.params import *
from m5.SimObject import SimObject

# 定义一个MyHelloObject类，继承自SimObject
class MyHelloObject(SimObject):
	# 指定类型，gem5底层类型的注册和查找都依赖该字段
	# type可以和类名不一样，但通常情况下需与被封装的C++类名保持一致（公约），只有少数特殊情况下可以和类名不一样
	type = 'MyHelloObject'
	# 指定对应的C++头文件路径和C++类名，因为都在src/目录，所以使用的是相对路径
	# 同时，头文件名字约定使用类名的蛇形命名形式，即全小写、下划线分隔
	cxx_header = "tutorials/part2/my_hello_object.hh"
	cxx_class = "gem5::MyHelloObject"
```

### Step 2：使用C++实现SimObject

在 `src/tutorials/part2`中创建 `my_hello_object.hh`头文件和 `my_hello_object.cc`实现文件。

代码风格方面，gem5中约定使用 `#ifndef/#endif`宏避免环形包含。然后，SimObject需要在gem5命名空间中进行声明。

虽然SimObject类声明了很多虚函数，但它们都不是纯虚函数，所以这里我们只需要简单地声明一个继承自SimObject的类以及它的构造函数即可。

```cpp
#ifndef __TUTORIALS_MY_HELLO_OBJECT_HH__
#define __TUTORIALS_MY_HELLO_OBJECT_HH__

// 构建时自动生成的头文件，路径位于build目录，如build/X86/下
#include "params/MyHelloObject.hh"
// src目录下的头文件，包含了SimObject的定义
#include "sim/sim_object.hh"

namespace gem5 {

// 声明MyHelloObject类，继承自SimObject
class MyHelloObject : public SimObject {
public:
	// 所有SimObject子类的构造函数都接收一个参数对象，这个参数对象基于该类所对应的Python类，在构建时自动创建
	MyHelloObject(const MyHelloObjectParams &p);
};

} // namespace gem5

#endif // __TUTORIALS_MY_HELLO_OBJECT_HH__
```

接下来，在 `.cc`文件中实现构造函数。

```cpp
#include "tutorials/part2/my_hello_object.hh"

#include <iostream>

namespace gem5 {

// 实现构造函数，这里只需要简单地把参数传给SimObject基类
MyHelloObject::MyHelloObject(const MyHelloObjectParams &params) : SimObject(params) {
	// gem5实际开发中绝对不能使用cout，而是使用调试标志（debug flags，将在下一章中引入）
	std::cout << "Hello World! From a SimObject!" << std::endl;
}

} // namespace gem5
```

### Step 3：注册SimObject和C++文件

为了编译C++文件和解析Python文件，我们需要通过某种途径将这些文件告诉构建系统。

gem5使用的是SCons构建系统，只需要在存放SimObject代码的目录下创建一个SConscript文件即可，如果目录下已经有这个文件了，则只需要在文件中添加相应声明。

这里，只需要在 `src/tutorials/part2`目录下创建一个SConscript文件并声明SimObject和对应的 `.cc`文件。

```python
# 导入上层环境和变量，包括编译器、编译参数和路径等信息
Import('*')

# 声明SimObject以及对应的Python文件和cc文件
SimObject('MyHelloObject.py', sim_objects=['MyHelloObject'])
Source('my_hello_object.cc')
```

### Step 4：重新构建gem5

为了编译和连接新文件，需要重新编译gem5。

```bash
scons build/X86/gem5.opt
```

### Step 5：创建配置文件来使用新SimObject

编译完成后，我们就只需要像Part1一样编写Python配置文件来实例化我们自己写的对象了。

在 `configs/tutorials/part2`目录下从创建一个配置文件 `run_hello.py`。由于我们的对象非常简单，所以不需要 `System`对象，但 `Root`对象对于任何gem5都是必要的。

```python
import m5
from m5.objects import *

root = Root(full_system = False)
root.hello = MyHelloObject()

m5.instantiate()

print("Beginning simulation!")
exit_event = m5.simulate()
print("Exiting @ tick {} because {}".format(m5.curTick(), exit_event.getCause()))
```

编写完配置文件之后，即可通过 `build/X86/gem5.opt configs/tutorials/part2/run_hello.py`运行gem5并看到MyHelloObject打印的“Hello World! From a SimObject!”输出了。

> **注意**：在后续章节中给SimObject添加了参数和事件之后，`run_hello.py`就不能正常使用了。
