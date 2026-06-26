## 事件触发编程

gem5是一个事件触发的模拟器。本章我们将继续在上一章的 `MyHelloObject`基础上进行扩展，探讨如何创建和规划事件。

### 创建一个简单的事件回调函数

在gem5的事件触发模型中，每个事件都有一个回调函数用来处理这个事件。通常而言，它应该是一个继承自C++ Event的类，但gem5提供了一个封装函数来创建简单的事件。

在 `MyHelloObject`的头文件中，我们只需要声明一个新函数，这个函数必须没有参数和返回值，每次事件触发时都会执行这个函数。然后我们还需要在类中添加一个Event实例，这里我们使用gem5提供的 `EventFunctionWrapper`，它可以执行任何函数。最后，我们还需要添加一个 `startup()`函数，后续再进行详细说明。修改后的 `MyHelloObject`如下：

```cpp
class MyHelloObject : public SimObject {
private:
	// 声明事件的回调函数
	void processEvent();
	// 实例化一个事件对象
	EventFunctionWrapper event;
public:
	// 所有SimObject子类的构造函数都接收一个参数对象，这个参数对象基于该类所对应的Python类，在构建时自动创建
	MyHelloObject(const MyHelloObjectParams &p);
	// 以重写形式声明启动函数
	void startup() override;
};
```

接下来，我们需要对构造函数进行一定修改，在初始化列表中完成event的构造。`EventFunctionWrapper`需要两个参数，回调函数对象（`std::function<void(void)>`）以及名字，名字通常是绑定这个事件的SimObject的名字。修改如下：

```cpp
// 实现构造函数，把参数传给SimObject基类并完成event的构造
MyHelloObject::MyHelloObject(const MyHelloObjectParams &params) :
	SimObject(params), event([this]{processEvent();}, name()) {
	DPRINTF(MyHelloExample, "Created the hello object\n");
}

// 实现回调函数
void MyHelloObject::processEvent() {
	DPRINTF(MyHelloExample, "Hello world! Processing the event!\n");
}
```

### 事件调度

最后，我们需要调度事件何时执行。通过使用C++的 `schedule`函数在未来某个时间点调度一些事件实例。

我们需要在 `startup()`函数中初始化事件的调度，这个函数允许调度一些内部事件，函数本身直到模拟开始时才会执行。完成以下 `startup()`函数的实现后，重新编译gem5并运行 `run_hello.py`配置脚本即可看到相应输出。运行：`build/X86/gem5.opt --debug-flags=MyHelloExample configs/tutorials/part2/run_hello.py`。

```cpp
void MyHelloObject::startup() {
	// 调度event在第100个tick时执行
	// 还可以基于curTick()设置偏移量，但startup固定在tick为0时执行，因此没有作用以及必要
	schedule(event, 100);
}
```

### 尝试更多事件调度

我们甚至还可以在一个事件处理动作当中调度新的事件。例如，我们将给 `MyHelloObject`添加一个延迟参数和时长参数，下一章中我们还会将这些参数对Python配置文件开放。修改后的类以及对应的函数实现如下，重新编译并运行后可以发现触发了10次event。

```cpp
// @file: src/tutorials/part2/my_hello_object.hh
// 声明MyHelloObject类，继承自SimObject
class MyHelloObject : public SimObject {
private:
	// 声明事件的回调函数
	void processEvent();
	// 实例化一个事件对象
	EventFunctionWrapper event;
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
// 实现构造函数，把参数传给SimObject基类并完成event的构造
MyHelloObject::MyHelloObject(const MyHelloObjectParams &params) :
	SimObject(params), event([this]{processEvent();}, name()),
	latency(100), timesLeft(10) {
	// gem5实际开发中绝对不能使用cout，而是使用调试标志（debug flags，将在下一章中引入）
	// std::cout << "Hello World! From a SimObject!" << std::endl;
	// 使用DPRINTF宏替换std::cout，第一个参数表示与HelloExample标志绑定，后续参数为输出信息，用法与printf一致
	// 该宏函数定义在src/base/trace.hh:209，可用grep -r -n -w "#define DPRINTF" src/base/查找
	DPRINTF(MyHelloExample, "Created the hello object\n");
}

void MyHelloObject::startup() {
	// 调度event在第100个tick时执行
	// 还可以基于curTick()设置偏移量，但startup固定在tick为0时执行，因此没有作用以及必要
	schedule(event, latency);
}

// 实现回调函数
void MyHelloObject::processEvent() {
	--timesLeft;
	DPRINTF(MyHelloExample, "Hello world! Processing the event! %d left\n", timesLeft);
	// 当持续次数没减至0时，继续触发event直至完成
	if (timesLeft <= 0) {
		DPRINTF(MyHelloExample, "Done firing!\n");
	}
	else {
		schedule(event, curTick() + latency);
	}
}
```

