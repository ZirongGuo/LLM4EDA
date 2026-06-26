## 为SimObject添加参数和更多事件

gem5的Python接口的一个强大功能就是通过Python向C++对象传递参数。本章我们将探索SimObject的一些参数并使用它们来构建上一章的 `MyHelloObject`。

### 简单的参数

首先，我们来添加延迟和触发事件次数的参数。为此，我们需要修改注册SimObject的Python文件（`src/tutorials/part2/MyHelloObject.py`），简单地添加一个 `Param`类型变量赋值语句即可完成参数的设置。

在修改后的代码中，`time_to_wait`是一个“Latency”参数，`number_of_fires`是一个整数参数。

```python
# 定义一个MyHelloObject类，继承自SimObject
class MyHelloObject(SimObject):
	# 指定类型，gem5底层类型的注册和查找都依赖该字段
	# type可以和类名不一样，但通常情况下需与被封装的C++类名保持一致（公约），只有少数特殊情况下可以和类名不一样
	type = 'MyHelloObject'
	# 指定对应的C++头文件路径和C++类名，因为都在src/目录，所以使用的是相对路径
	# 同时，头文件名字约定使用类名的蛇形命名形式，即全小写、下划线分隔
	cxx_header = "tutorials/part2/my_hello_object.hh"
	cxx_class = "gem5::MyHelloObject"

	# 添加参数，其中触发次数还指定了默认值为1
	time_to_wait = Param.Latency("Time before firing the event")
	number_of_fires = Param.Int(1, "Number of times to fire the event before "
					"goodbye")
```

完成Python类的修改后，需要再修改C++类的构造函数，将Python中设置的参数传递给C++对象，这里，我们还给类添加了一个 `myName`成员变量（仅用于示范，实际工程中直接使用SimObject的 `name()`函数即可）。

> 注：此处官方教程中对于event的初始化采用的是 `event(*this)`，实测无法通过编译。需要按照后面 `MyGoodbyeObject`的形式定义event才能使用这种初始化形式，但这种形式已被弃用，不建议使用。

```cpp
// @file: src/tutorials/part2/my_hello_object.hh
// 声明MyHelloObject类，继承自SimObject
class MyHelloObject : public SimObject {
private:
	// 声明事件的回调函数
	void processEvent();
	// 实例化一个事件对象
	EventFunctionWrapper event;
	// NEW 定义名字变量
	const std::string myName;
	// 定义触发延迟以及持续时间
	const Tick latency;
	int timesLeft;
public:
	// 所有SimObject子类的构造函数都接收一个参数对象，这个参数对象基于该类所对应的Python类，在构建时自动创建
	MyHelloObject(const MyHelloObjectParams &p);
	// 以重写形式声明启动函数
	void startup() override;
};


// @file: src/tutorials/part2/my_hello_object.cc
// 实现构造函数，把参数传给SimObject基类并完成event的构造以及latency等参数的初始化
MyHelloObject::MyHelloObject(const MyHelloObjectParams &params) :
	SimObject(params),
	event([this]{processEvent();}, name()),
	myName(params.name),
	latency(params.time_to_wait),
	timesLeft(params.number_of_fires) {
	// 使用DPRINTF宏替换std::cout，第一个参数表示与HelloExample标志绑定，后续参数为输出信息，用法与printf一致
	// 该宏函数定义在src/base/trace.hh:209，可用grep -r -n -w "#define DPRINTF" src/base/查找
	DPRINTF(MyHelloExample, "Created the hello object\n");
}
```

完成上述修改并重新编译后，运行 `build/X86/gem5.opt --debug-flags=MyHelloExample configs/tutorials/part2/run_hello.py`，可以发现执行报错了，这是因为我们并没有给 `time_to_wait`参数设置默认值，在 `run_hello.py`中实例化 `MyHelloObject`时指定该参数的值即可：

```python
# root.hello = MyHelloObject(time_to_wait = '2us')
# 或者实例化后再直接修改成员变量
root.hello = MyHelloObject()
root.hello.time_to_wait = '2us'
```

### 将其他SimObject作为参数

为了演示如何将其他SimObject作为参数，我们将创建一个新的SimObject `MyGoodbyeObject`，这个对象功能很简单，向其他SimObject发送“Goodbye”。为了更接近物理器件，`MyGoodbyeObject`会有一个固定带宽的buffer来写消息。

首先，需要在SConscript中注册新的SimObject。

```python
# 导入上层环境和变量，包括编译器、编译参数和路径等信息
Import('*')

# 声明SimObject以及对应的Python文件和cc文件
SimObject('MyHelloObject.py', sim_objects=['MyHelloObject', 'MyGoodbyeObject'])
Source('my_hello_object.cc')
Source('my_goodbye_object.cc')
# 注册调试标志
DebugFlag("MyHelloExample")
```

然后是在 `MyHelloObject.py`中定义 `MyGoodbyeObject`类：

```python
class MyGoodbyeObject(SimObject):
	type = 'MyGoodbyeObject'
	cxx_header = "tutorials/part2/my_goodbye_object.hh"
	cxx_class = "gem5::MyGoodbyeObject"

	buffer_size = Param.MemorySize('1kB', "Size of buffer to fill with goodbye")
	write_bandwidth = Param.MemoryBandwidth('100MB/s', "Bandwidth to fill the buffer")
```

按照惯例，接下来就是MyGoodbyeObject的头文件以及实现文件。

> 注：官方教程中忘记使用gem5命名空间，部分代码细节也有瑕疵，建议参考本代码。

```cpp
// @file: src/tutorials/part2/my_goodbye_object.hh
#ifndef __TUTORIALS_MY_GOODBYE_OBJECT_HH__
#define __TUTORIALS_MY_GOODBYE_OBJECT_HH__

#include <string>

#include "params/MyGoodbyeObject.hh"
#include "sim/sim_object.hh"

namespace gem5 {

class MyGoodbyeObject : public SimObject {
private:
	void processEvent();
	// 填充buffer，填充满buffer后退出仿真
	void fillBuffer();
	// 在定义event的同时指定回调函数，已弃用，不建议使用
	EventWrapper<MyGoodbyeObject, &MyGoodbyeObject::processEvent> event;

	// 带宽，bytes/tick
	float bandwidth;
	// buffer大小
	int bufferSize;
	// 字符类型buffer
	char *buffer;
	// 将要放入buffer中的信息
	std::string message;
	// 已使用的buffer大小
	int bufferUsed;

public:
	MyGoodbyeObject(const MyGoodbyeObjectParams &p);
	~MyGoodbyeObject();
	// 由外部模块调用，启动事件向buffer填充goodbye信息
	void sayGoodbye(std::string name);
};

} // namespace gem5

#endif // __TUTORIALS_MY_GOODBYE_OBJECT_HH__


// @file: src/tutorials/part2/my_goodbye_object.cc
#include "tutorials/part2/my_goodbye_object.hh"

#include "base/trace.hh"
#include "debug/MyHelloExample.hh"
#include "sim/sim_exit.hh"

namespace gem5 {

MyGoodbyeObject::MyGoodbyeObject(const MyGoodbyeObjectParams &params) :
	SimObject(params),
	event(*this),
	bandwidth(params.write_bandwidth),
	bufferSize(params.buffer_size),
	buffer(nullptr),
	bufferUsed(0) {
	buffer = new char[bufferSize];
	DPRINTF(MyHelloExample, "Created the goodbye object\n");
}

MyGoodbyeObject::~MyGoodbyeObject() {
	delete[] buffer;
}

void MyGoodbyeObject::processEvent() {
	DPRINTF(MyHelloExample, "Processing the event!\n");
	fillBuffer();
}

void MyGoodbyeObject::sayGoodbye(std::string other_name) {
	DPRINTF(MyHelloExample, "Saying goodbye to %s\n", other_name);
	message = "Goodbye " + other_name + "!! ";
	fillBuffer();
}

void MyGoodbyeObject::fillBuffer() {
	assert(message.length() > 0);

	int bytes_copied = 0;
	// 拷贝message到buffer
	for (auto it = message.begin(); it < message.end() && bufferUsed < bufferSize - 1; ++it, ++bufferUsed, ++bytes_copied) {
		buffer[bufferUsed] = *it;
	}
	// 若buffer还未填满，则规划下一次填充
	if (bufferUsed < bufferSize - 1) {
		DPRINTF(MyHelloExample, "Scheduling another fillBuffer in %d ticks\n", bandwidth * bytes_copied);
		schedule(event, curTick() + bandwidth * bytes_copied);
	}
	// 填满后，退出仿真
	else {
		DPRINTF(MyHelloExample, "Goodbye done copying!\n");
		// 退出仿真
		// 第一个参数是返回给exit_event.getCause()的退出信息
		// 第二个参数是退出码
		// 第三个参数是退出时间（tick）
		exitSimLoop(buffer, 0, curTick() + bandwidth * bytes_copied);
	}
}

} // namespace gem5
```

### 将MyGoodbyeObject作为参数添加到MyHelloObject

首先像添加Latency参数一样在 `MyHelloObject.py`中添加 `Param.MyGoodbyeObject`参数：

```python
# 定义一个MyHelloObject类，继承自SimObject
class MyHelloObject(SimObject):
	# 指定类型，gem5底层类型的注册和查找都依赖该字段
	# type可以和类名不一样，但通常情况下需与被封装的C++类名保持一致（公约），只有少数特殊情况下可以和类名不一样
	type = 'MyHelloObject'
	# 指定对应的C++头文件路径和C++类名，因为都在src/目录，所以使用的是相对路径
	# 同时，头文件名字约定使用类名的蛇形命名形式，即全小写、下划线分隔
	cxx_header = "tutorials/part2/my_hello_object.hh"
	cxx_class = "gem5::MyHelloObject"

	# 添加参数，其中触发次数还指定了默认值为1
	time_to_wait = Param.Latency("Time before firing the event")
	number_of_fires = Param.Int(1, "Number of times to fire the event before "
					"goodbye")
	# NEW 新的SimObject参数
	goodbye_object = Param.MyGoodbyeObject("A goodbye object")
```

然后是在 `my_hello_object.hh`中添加对 `MyGoodbyeObject`的引用，以及在 `my_hello_object.cc`中初始化 `MyGoodbyeObject`并调用相关接口：

```cpp
// @file: src/tutorials/part2/my_hello_object.hh
...
// NEW 导入MyGoodbyeObject头文件
#include "tutorials/part2/my_goodbye_object.hh"
...
class MyHelloObject : public SimObject {
private:
	...
	// NEW 定义MyGoodbyeObject指针
	MyGoodbyeObject *goodbye;
	...
public:
	...
};


// @file: src/tutorials/part2/my_hello_object.cc
...
MyHelloObject::MyHelloObject(MyHelloObjectParams &params) :
	SimObject(params),
	event([this]{processEvent();}, name()),
	// NEW 初始化MyGoodbyeObject
	goodbye(params.goodbye_object),
	myName(params.name),
	latency(params.time_to_wait),
	timesLeft(params.number_of_fires) {
	DPRINTF(MyHelloExample, "Created the hello object\n");
	// NEW 确保goodbye正确初始化而不是野指针
	panic_if(!goodbye, "MyHelloObject must have a non-null MyGoodbyeObject");
}
...
void MyHelloObject::processEvent() {
	--timesLeft;
	DPRINTF(MyHelloExample, "Hello world! Processing the event! %d left\n", timesLeft);
	// 当持续次数没减至0时，继续触发event直至完成
	if (timesLeft <= 0) {
		DPRINTF(MyHelloExample, "Done firing!\n");
		// NEW 调用MyGoodbyeObject的sayGoodbye函数，写满buffer后退出仿真
		goodbye->sayGoodbye(myName);
	}
	else {
		schedule(event, curTick() + latency);
	}
}
```

完成上述修改后就可以重新编译gem5了。

### 更新配置脚本

创建一个新的配置脚本 `configs/tutorials/part2/hello_goodbye.py`，实例化hello和goodbye对象，然后执行 `build/X86/gem5.opt --debug-flags=MyHelloExample configs/tutorials/part2/run_hello.py`运行新脚本，即可看到触发了多次fillBuffer，且最后的退出原因为Goodbye信息。

```python
import m5
from m5.objects import *

root = Root(full_system = False)

root.hello = MyHelloObject(time_to_wait = '2us', number_of_fires = 5)
root.hello.goodbye_object = MyGoodbyeObject(buffer_size = '100B')

m5.instantiate()

print("Beginning simulation!")
exit_event = m5.simulate()
print("Exiting @ tick %i because %s" % (m5.curTick(), exit_event.getCause()))
```
