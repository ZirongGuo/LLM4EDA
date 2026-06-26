## 创建内存系统中的SimObject

本章我们会创建一个位于CPU和内存总线之间的简单内存对象，并在下一章中给它添加一些逻辑，变成一个非常简单的阻塞单处理器cache。

### gem5请求、响应端口

在深入了解内存对象的实现之前，我们应该先理解gem5请求、响应端口的接口。

gem5端口实现了三种内存系统模式：timing、atomic和functional。其中最重要的是timing，它是唯一一个能产生正确模拟结果的模式，其他模式只在特定情形下使用。

atomic模式常用于快进（fastforward）到感兴趣的部分和预热模拟器，只有用于快进或模拟器预热时才需要实现内存对象的原子访问。该模式假设内存系统中没有事件产生，而是通过一个固定的调用链来执行访存请求。

functional模式叫做debugging模式更好，主要用于从主机读数据到模拟器内存，同时在SE模式使用非常频繁。例如，functional模式用于加载 `process.cmd`中的二进制文件到被模拟系统的内存。functional访问应该返回读取时的最新数据，包括正在写入的数据。

### 数据包（Packet）

在gem5中，端口间通过 `Packet`传输信息，所有端口的接口函数都接受一个 `Packet`指针作为参数，并且由于这个指针太常用了，gem5为它定义了一个 `PacketPtr`类。

`Packet`来源于m5的经典cache，用于跟踪缓存一致性。因此许多packet相关的代码都是针对经典cache的缓存一致性写的。但在gem5中，packet用于所有内存对象间的通信，不管是否直接与一致性相关（例如DRAM控制器和CPU模型之间）。

一个 `Packet`由 `MemReq`、`MemCmd`以及数据组成。

`MemReq`存放原始的请求信息如请求者、地址以及请求类型（读写等）。

`MemCmd`是packet当前执行的命令，会动态变化（例如请求命令完成后变为响应）。最常见的 `MemCmd`是 `ReadReq`（读请求）、`ReadResp`（读响应）、`WriteReq`（写请求）和 `WriteResq`（写响应），除此之外还有cache的写回请求（`WritebackDirty`、`WritebackClean`）和其他命令类型。

对于请求的数据或指向该数据的指针，创建packet时还可以指定数据是动态（显式分配和释放）还是静态（由packet对象分配和释放）。

### 端口接口

gem5中有两种端口：请求端口和响应端口，在实现一个内存对象时，至少需要实现其中一种端口，创建一个新类时需要继承 `RequestPort`或者 `ResponsePort`。

请求和响应端口之间的交互通过 `sendTimingReq`、`recvTimingReq`、`sendTimingResp`和 `recvTimingResp`等函数来实现。完整函数列表可参考 `src/mem/port.hh`，这些函数都接收一个 `PacketPtr`类型的参数。

请求者通过 `sendTimingReq`发送一个请求packet，然后轮到响应者的 `recvTimingReq`被调用，将前者的 `PacketPtr`变量作为唯一参数，然后返回一个 `bool`类型的变量，`true`表明响应方接受了packet，`false`代表响应方暂时不能接收请求，需要将来某一时刻重发。

* 如果请求者和响应者都空闲，则 `recvTimingReq`返回 `true`，然后请求者和响应者分别继续执行，直到响应者完成请求并调用 `sendTimingResp`，接着调用请求方的 `recvTimingResp`并返回 `true`，至此，一个请求的交互就完成了。
* 如果响应者当前正忙，则 `recvTimingReq`返回 `false`，此时请求者需要等待响应者空闲并调用 `recvReqRetry`，然后才能重新调用 `sendTimingReq`发送请求，后续步骤与情形一一致。
* 类似的，如果响应者发送响应时请求者正忙，则请求者的 `recvTimingResp`返回 `false`，响应者等待，直到请求者调用 `sendRespRetry`，后续步骤也与情形一一致。

### 内存对象简单示例

本节我们会构建一个简单的内存对象。最初，它的功能只是简单的传递CPU端的请求到内存端（内存总线），拥有一个内存端的请求端口及两个CPU端的响应端口。在下一章中我们将给它添加逻辑，把它变成一个cache。

#### 声明SimObject

就像之前创建 `MyHelloObject`一样，第一步是在 `src/tutorials/part2`目录下创建一个SimObject的Python文件 `MySimpleMemobj.py`，定义一个 `MySimpleMemobj`对象，然后在之前的SConscript文件中进行注册。

```python
# @file: src/tutorials/part2/MySimpleMemobj.py
from m5.params import *
from m5.proxy import *
from m5.SimObject import SimObject

class MySimpleMemobj(SimObject):
    type = 'MySimpleMemobj'
    cxx_header = "tutorials/part2/my_simple_memobj.hh"
    cxx_class = "gem5::MySimpleMemobj"

    # 端口相关参数，没有默认值
    inst_port = ResponsePort("CPU side port, receives instruction requests")
    data_port = ResponsePort("CPU side port, receives data requests")
    mem_side = RequestPort("Memory side port, sends requests")
```

#### 定义MySimpleMemobj类

首先是在 `src/tutorials/part2`下创建一个头文件 `my_simple_memobj.hh`并定义 `MySimpleMemobj`。

然后需要定义CPU端和内存端两种端口的类，由于其他对象绝对不会使用这些类，所以直接在 `MySimpleMemobj`类内声明这些类。

```cpp
// @file: src/tutorials/part2/my_simple_memobj.hh
#ifndef __TUTORIALS_MY_SIMPLE_MEMOBJ_HH__
#define __TUTORIALS_MY_SIMPLE_MEMOBJ_HH__

#include "mem/port.hh"
#include "params/MySimpleMemobj.hh"
#include "sim/sim_object.hh"

namespace gem5 {

class MySimpleMemobj : public SimObject {
private:
    // 定义CPU侧响应端口类
    class CPUSidePort : public ResponsePort {
    private:
        // 所有者变量，用于调用所有者的函数
        MySimpleMemobj *owner;
        // 是否需要重试
        bool needRetry;
        // 存放需要重发的packet
        PacketPtr blockedPacket;
    public:
        CPUSidePort(const std::string &name, MySimpleMemobj *owner) :
            ResponsePort(name), owner(owner) {}
        // 发送响应packet，sendTimingResp的外层封装
        void sendPacket(PacketPtr pkt);
        // 获取属于该memobj的地址区间
        AddrRangeList getAddrRanges() const override;
        // 尝试重发请求，sendRetryReq的外层封装
        void trySendRetry();
    protected:
        /* ResponsePort中定义的四个纯虚函数 */
        /* 三种模式各自的接收请求函数 */
        // 请求接收函数，atomic模式的请求和响应通过一条调用链完成，无需处理响应部分
        Tick recvAtomic(PacketPtr pkt) override { panic("recvAtomic unimpl."); }
        // 请求接收函数，functional模式的请求和响应通过一条调用链完成，无需处理响应部分
        void recvFunctional(PacketPtr pkt) override;
        // 请求接收函数
        bool recvTimingReq(PacketPtr pkt) override;
        // 收到重发响应信号的回调函数，请求方调用sendRespRetry时触发
        void recvRespRetry() override;
    };

    // 定义内存侧请求端口类
    class MemSidePort : public RequestPort {
    private:
        MySimpleMemobj *owner;
        // 存放需要重发的packet
        PacketPtr blockedPacket;
    public:
        MemSidePort(const std::string &name, MySimpleMemobj *owner) :
            RequestPort(name), owner(owner) {}
        // 发送请求packet，sendTimingReq的外层封装
        void sendPacket(PacketPtr pkt);
    protected:
        /* RequestPort只有三个纯虚函数需要重写 */
        // 响应接收函数
        bool recvTimingResp(PacketPtr pkt) override;
        // 收到重发请求信号的回调函数，响应方调用sendReqRetry时触发
        void recvReqRetry() override;
        // 收到地址区间的回调函数，响应方调用sendRangeChange时触发
        void recvRangeChange() override;
    };
  
    CPUSidePort instPort;
    CPUSidePort dataPort;
    MemSidePort memPort;
    // 是否阻塞在等待响应
    bool blocked;

    // 处理来自CPU的请求，空闲能处理则返回true，否则false
    bool handleRequest(PacketPtr pkt);
    // 处理来自内存的响应，空闲能处理则返回true，否则false
    bool handelResponse(PacketPtr pkt);
    // functional模式处理packet，请求到响应一条调用链完成，无需处理响应部分
    void handleFunctional(PacketPtr pkt);
    // 获取属于该memobj的地址区间
    AddrRangeList getAddrRanges() const;
    // 向CPU侧发送所属的内存区间
    void sendRangeChange();
public:
    MySimpleMemobj(const MySimpleMemobjParams &params);
    // 根据请求的端口名字返回相应对象
    Port &getPort(const std::string &if_name, PortID idx = InvalidPortID) override;
};

} // namespace gem5

#endif // __TUTORIALS_MY_SIMPLE_MEMOBJ_HH__
```

#### 实现构造函数以及请求、响应端口函数

```cpp
// @file: src/tutorials/part2/my_simple_memobj.cc
#include "tutorials/part2/my_simple_memobj.hh"
#include "debug/MySimpleMemobj.hh"

namespace gem5{

MySimpleMemobj::MySimpleMemobj(const MySimpleMemobjParams &params) :
    SimObject(params),
    instPort(params.name + ".inst_port", this),
    dataPort(params.name + ".data_port", this),
    memPort(params.name + ".mem_side", this),
    blocked(false) {}

Port &MySimpleMemobj::getPort(const std::string &if_name, PortID idx) {
    panic_if(idx != InvalidPortID, "This object doesn't support vector ports");
    // 根据请求的端口名字返回相应对象，if_name即Python中声明的端口参数名
    if (if_name == "mem_side") {
        return memPort;
    }
    else if (if_name == "inst_port") {
        return instPort;
    }
    else if (if_name == "data_port") {
        return dataPort;
    }
    else {
        // 传递给超类
        return SimObject::getPort(if_name, idx);
    }
}

bool MySimpleMemobj::handleRequest(PacketPtr pkt) {
    if (blocked) {
        return false;
    }
    DPRINTF(MySimpleMemobj, "Got request for addr %#x\n", pkt->getAddr());
    blocked = true;
    memPort.sendPacket(pkt);
    return true;
}

bool MySimpleMemobj::handelResponse(PacketPtr pkt) {
    assert(blocked);
    DPRINTF(MySimpleMemobj, "Got response for addr %#x\n", pkt->getAddr());
    blocked = false;
    // 根据请求类型分发到对应端口
    if (pkt->req->isInstFetch()) {
        instPort.sendPacket(pkt);
    }
    else {
        dataPort.sendPacket(pkt);
    }
    // 此时可以继续处理其他请求，告知CPU
    instPort.trySendRetry();
    dataPort.trySendRetry();

    return true;
}

void MySimpleMemobj::handleFunctional(PacketPtr pkt) {
    memPort.sendFunctional(pkt);
}

AddrRangeList MySimpleMemobj::getAddrRanges() const {
    DPRINTF(MySimpleMemobj, "Sending new ranges\n");
    return memPort.getAddrRanges();
}

void MySimpleMemobj::sendRangeChange() {
    instPort.sendRangeChange();
    dataPort.sendRangeChange();
}

/* CPUSidePort相关函数 */

void MySimpleMemobj::CPUSidePort::sendPacket(PacketPtr pkt) {
    panic_if(blockedPacket != nullptr, "Should never try to send if blocked!");
    if (!sendTimingResp(pkt)) {
        blockedPacket = pkt;
    }
}
AddrRangeList MySimpleMemobj::CPUSidePort::getAddrRanges() const {
    return owner->getAddrRanges();
}
void MySimpleMemobj::CPUSidePort::trySendRetry() {
    if (needRetry && blockedPacket == nullptr) {
        needRetry = false;
        DPRINTF(MySimpleMemobj, "Sending retry req for %d\n", id);
        sendRetryReq();
    }
}
void MySimpleMemobj::CPUSidePort::recvFunctional(PacketPtr pkt) {
    return owner->handleFunctional(pkt);
}
bool MySimpleMemobj::CPUSidePort::recvTimingReq(PacketPtr pkt) {
    if (!owner->handleRequest(pkt)) {
        needRetry = true;
        return false;
    }
    else {
        return true;
    }
}
void MySimpleMemobj::CPUSidePort::recvRespRetry() {
    assert(blockedPacket != nullptr);
    PacketPtr pkt = blockedPacket;
    blockedPacket = nullptr;

    sendPacket(pkt);
}

/* MemSidePort相关函数 */

void MySimpleMemobj::MemSidePort::sendPacket(PacketPtr pkt) {
    panic_if(blockedPacket != nullptr, "Should never try to send if blocked!");
    if (!sendTimingReq(pkt)) {
        blockedPacket = pkt;
    }
}
bool MySimpleMemobj::MemSidePort::recvTimingResp(PacketPtr pkt) {
    return owner->handelResponse(pkt);
}
void MySimpleMemobj::MemSidePort::recvReqRetry() {
    assert(blockedPacket != nullptr);
    // 读取阻塞的packet
    PacketPtr pkt = blockedPacket;
    blockedPacket = nullptr;
    sendPacket(pkt);
}
void MySimpleMemobj::MemSidePort::recvRangeChange() {
    owner->sendRangeChange();
}

} // namespace gem5
```

#### 创建配置文件

这里的配置文件从入门时的简单配置文件改造而来，但在CPU和内存总线之间插入了我们自己设计的 `MySimpleMemobj`。

编写完配置文件即可通过 `build/X86/gem5.opt --debug-flags=MySimpleMemobj configs/tutorials/part2/simple_memobj.py`模拟带有我们设计的 `MySimpleMemobj`对象的系统。

此外，还可以将配置文件中的CPU改成乱序模型 `X86O3CPU`，此时会看到与原配置不同的地址流，因为乱序CPU可能同时有多个访存请求，同时由于我们的 `MySimpleMemobj`是阻塞的，所以处理器会有许多的停顿。

```python
# @file: configs/tutorials/part2/simple_memobj.py
import m5
from m5.objects import *

system = System()
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '1GHz'
system.clk_domain.voltage_domain = VoltageDomain()
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('512MB')]

system.cpu = X86TimingSimpleCPU()

system.memobj = MySimpleMemobj()

system.cpu.icache_port = system.memobj.inst_port
system.cpu.dcache_port = system.memobj.data_port

system.membus = SystemXBar()

system.memobj.mem_side = system.membus.cpu_side_ports

system.cpu.createInterruptController()
system.cpu.interrupts[0].pio = system.membus.mem_side_ports
system.cpu.interrupts[0].int_requestor = system.membus.cpu_side_ports
system.cpu.interrupts[0].int_responder = system.membus.mem_side_ports

system.mem_ctrl = MemCtrl()
system.mem_ctrl.dram = DDR3_1600_8x8()
system.mem_ctrl.dram.range = system.mem_ranges[0]
system.mem_ctrl.port = system.membus.mem_side_ports

system.system_port = system.membus.cpu_side_ports

binary = 'tests/test-progs/hello/bin/x86/linux/hello'
system.workload = SEWorkload.init_compatible(binary)
process = Process()
process.cmd = [binary]
system.cpu.workload = process
system.cpu.createThreads()

root = Root(full_system = False, system = system)
m5.instantiate()

print("Beginning simulation!")
exit_event = m5.simulate()
print("Exiting @ tick {} because {}".format(m5.curTick(), exit_event.getCause()))
```
