## 创建一个简单的cache

本章我们会在上一章的基础上添加cache相关的逻辑。

### MySimpleCache SimObject

按照惯例，我们首先还是创建一个SimObject的Python文件 `src/tutorials/MySimpleCache.py`并在 `src/tutorials/SConscript`中进行注册。

```python
# @file: src/tutorials/MySimpleCache.py
from m5.params import *
from m5.proxy import *
# MemObject已弃用，内存对象在CLockedObject中
# from MemObject import MemObject
from m5.objects.ClockedObject import ClockedObject

class MySimpleCache(ClockedObject):
    type = 'MySimpleCache'
    cxx_header = "tutorials/part2/my_simple_cache.hh"
    cxx_class = "gem5::MySimpleCache"

    # 端口参数，没有默认值
    # 其中VectorPort可以理解为常规端口数组，包含多个端口，通过PortID类型变量来索引
    cpu_side = VectorResponsePort("CPU side port, receives requests")
    mem_side = RequestPort("Memory side port, sends requests")
    # 缓存延迟
    latency = Param.Cycles(1, "Cycles taken on a hit or to resolve a miss")
    # 缓存大小
    size = Param.MemorySize('16kB', "The size of the cache")
    # 缓存所属的系统，用于从系统对象获取缓存块大小
    # 为了引用系统对象，这里使用一个特殊的代理参数Parent.any，当在配置文件中被实例化时，
    # 代理参数会在该实例的所有父对象中寻找System类型的SimObject
    system = Param.System(Parent.any, "The system this cache is part of")
```

### 实现MySimpleCache

`MySimpleCache`的大部分代码都跟 `MySimpleMemobj`相同，以下是构造函数和内存对象的一些关键函数的改动。

首先，我们需要在构造函数中动态地创建CPU侧的端口并初始化新增的一些参数。然后，需要改写一下 `getPort`函数，CPU侧的端口需要根据索引返回相应对象。

`CPUSidePort`和 `MemSidePort`的逻辑与 `MySimpleMemobj`中几乎一样，但 `handleRequest`需要增加一个请求端口id的参数用于传递响应到对应的端口，以及加入模拟访存延迟的逻辑。

最后就是实现Timing模式访问cache的逻辑 `accessTiming`。

### cache功能逻辑

为了实现cache访问逻辑，还需要添加存储cache内容的容器并实现两个主要功能函数：`accessFunctional`和 `insert`。

关于cache内容的存储，最简单的方式是使用map（哈希表），键值分别是地址和数据指针。因此，我们向 `MySimpleCache`添加一个 `unordered_map`成员变量。

接下来是 `accessFuntional()`，为了访问cache，我们首先需要检查哈希表中是否有与packet中地址匹配的入口，如果没有找到对应的地址则直接返回false，表明数据不在cache中，缓存缺失。否则对packet的请求类型进行分类处理：如果是写请求，则更新cache中的数据，是读请求则用cache中的数据更新packet中的数据。

最后就是实现 `insert()`函数，该函数每次收到内存侧的响应时都会被调用，将数据插入cache。第一步是检查cache是否满了，如果满了则需要进行替换，在替换时还需要将数据写入下一层存储器。

> 注意：作者由于漏改 `MySimpleCache::handleFunctional()`找了好久的bug，调查后发现，即使是timing模式运行，gem5也会调用 `MySimpleCache::CPUSidePort::recvFunctional()`，通常是用于以下三个用途：①仿真开始前加载二进制文件；②执行系统调用时读写内存；③调试和使用检查点时读写内存。而这里就是因为 `printf()`触发系统调用后需要读取从rodata拷贝到写缓冲的“Hello World!”，如果不对 `handleFunctional()`进行修改，系统调用就会去内存中读取，而拷贝完之后数据还存在于cache中，暂未写回内存，因此就会导致没有输出。
>
> 因此，除了二进制文件的加载外，系统调用的缓存命中/缺失也不会被统计，如果需要统计这两类情况下的数据，需要使用Full System模式。

```cpp
// @file: src/tutorials/part2/my_simple_cache.hh
#ifndef __TUTORIALS_MY_SIMPLE_CACHE_HH__
#define __TUTORIALS_MY_SIMPLE_CACHE_HH__

// NEW 随机数头文件
#include "base/random.hh"
#include "mem/port.hh"
#include "params/MySimpleCache.hh"
// NEW 内存对象所在头文件
#include "sim/clocked_object.hh"

namespace gem5 {

// NEW cache由于涉及延迟等属性，改为继承ClockedObject
class MySimpleCache : public ClockedObject {
private:
    // 定义CPU侧响应端口类
    class CPUSidePort : public ResponsePort {
    private:
        // NEW 保存端口在向量端口中的索引
        int id;
        MySimpleCache *owner;
        bool needRetry;
        PacketPtr blockedPacket;
    public:
        // NEW 增加索引参数
        CPUSidePort(const std::string &name, int id, MySimpleCache *owner) :
            ResponsePort(name), id(id), owner(owner),
            needRetry(false), blockedPacket(nullptr) {}
        ...
    };
    ...
    // NEW 定义AccessEvent类
    class AccessEvent : public Event
    {
    private:
        MySimpleCache *cache;
        PacketPtr pkt;
    public:
        AccessEvent(MySimpleCache *cache, PacketPtr pkt) :
            Event(Default_Pri, AutoDelete), cache(cache), pkt(pkt)
        { }
        void process() override {
            cache->accessTiming(pkt);
        }
    };
  
    // NEW 命名端口改为向量端口
    // CPUSidePort instPort;
    // CPUSidePort dataPort;
    std::vector<CPUSidePort> cpuPorts;
    MemSidePort memPort;
    // NEW 添加cache数据的存储空间
    std::unordered_map<Addr, uint8_t*> cacheStore;
    // NEW 全局随机数生成器（单例模式）
    Random::RandomPtr random_mt = Random::genRandom();
    // NEW 添加新的缓存参数
    // 读取缓存的延迟
    const Cycles latency;
    // 缓存块大小
    const Addr blockSize;
    // 缓存容量
    const unsigned capacity;
    // 是否阻塞在等待响应
    bool blocked;
    // 正在处理的packet
    PacketPtr outstandingPacket;
    // 正在处理的端口号
    int waitingPortId;

    // NEW 添加端口id参数，并引入访存延迟
    // 处理来自CPU的请求，空闲能处理则返回true，否则false
    bool handleRequest(PacketPtr pkt, int port_id);
    // NEW 将内存响应数据插入cache，并根据原请求地址和大小返回响应数据
    // 处理来自内存的响应，空闲能处理则返回true，否则false
    bool handelResponse(PacketPtr pkt);
    // NEW 发送响应包给CPU侧
    void sendResponse(PacketPtr pkt);
    // functional模式处理packet，请求到响应一条调用链完成，无需处理响应部分
    void handleFunctional(PacketPtr pkt);
    // NEW timing模式处理packet，由事件回调函数调用
    void accessTiming(PacketPtr pkt);
    // NEW functional模式处理packet，实际更新缓存的函数，缓存命中返回true，否则返回false
    bool accessFunctional(PacketPtr pkt);
    // NEW 更新cache数据
    void insert(PacketPtr pkt);
    ...
};

} // namespace gem5

#endif // __TUTORIALS_MY_SIMPLE_CACHE_HH__
```

```cpp
// @file: src/tutorials/part2/my_simple_cache.cc
#include "tutorials/part2/my_simple_cache.hh"
#include "debug/MySimpleCache.hh"
// NEW 获取system参数所需的头文件
#include "sim/system.hh"

namespace gem5{

// NEW 将CPU侧端口改成动态初始化，更新初始化列表
MySimpleCache::MySimpleCache(const MySimpleCacheParams &params) :
    // SimObject(params),
    ClockedObject(params),
    latency(params.latency),
    blockSize(params.system->cacheLineSize()),
    capacity(params.size / blockSize),
    // instPort(params.name + ".inst_port", this),
    // dataPort(params.name + ".data_port", this),
    memPort(params.name + ".mem_side", this),
    blocked(false), outstandingPacket(nullptr), waitingPortId(-1) {
    // 根据配置脚本中连接的端口数初始化端口数组
    for (int i = 0; i < params.port_cpu_side_connection_count; ++i) {
        cpuPorts.emplace_back(name() + csprintf(".cpu_side[%d]", i), i, this);
    }
}

// NEW CPU侧端口改为向量索引方式
Port &MySimpleCache::getPort(const std::string &if_name, PortID idx) {
    // panic_if(idx != InvalidPortID, "This object doesn't support vector ports");
    // 根据请求的端口名字返回相应对象，if_name即Python中声明的端口参数名
    if (if_name == "mem_side") {
        panic_if(idx != InvalidPortID,
            "Mem side of simple cache is not a vector port");
        return memPort;
    }
    // else if (if_name == "inst_port") {
    //     return instPort;
    // }
    // else if (if_name == "data_port") {
    //     return dataPort;
    // }
    else if (if_name == "cpu_side" && idx < cpuPorts.size()) {
        return cpuPorts[idx];
    }
    else {
        // 传递给父类
        return SimObject::getPort(if_name, idx);
    }
}

bool MySimpleCache::handleRequest(PacketPtr pkt, int port_id) {
    if (blocked) {
        return false;
    }
    DPRINTF(MySimpleCache, "Got request for addr %#x\n", pkt->getAddr());
    blocked = true;
    // NEW 记录当前正在处理的端口
    waitingPortId = port_id;
    // memPort.sendPacket(pkt);
    // NEW 添加延迟
    // AccessEvent：由于需要传递packet参数，所以不能使用EventWrapper
    // clockEdge()函数返回n个周期后的tick数
    schedule(new AccessEvent(this, pkt), clockEdge(latency));
    // 实际上用EventWrapper也行，匿名函数捕获packet即可
    // schedule(new EventFunctionWrapper([this, pkt]{ accessTiming(pkt); },
    //                                     name() + ".accessEvent", true),
    //         clockEdge(latency));
    return true;
}

bool MySimpleCache::handelResponse(PacketPtr pkt) {
    assert(blocked);
    DPRINTF(MySimpleCache, "Got response for addr %#x\n", pkt->getAddr());
    // NEW 将内存响应数据插入cache
    insert(pkt);
    // NEW 取出与cache块不对齐的原始请求
    if (outstandingPacket != nullptr) {
        // 完成原始请求的操作（对于与cache块对齐的请求，其操作在内存侧就已完成）
        accessFunctional(outstandingPacket);
        // 转换成响应packet
        outstandingPacket->makeResponse();
        // 释放accessTiming中创建的临时packet，重置outstandingPacket
        delete pkt;
        pkt = outstandingPacket;
        outstandingPacket = nullptr;
    }

    // NEW 以下逻辑封装到sendResponse中
    sendResponse(pkt);
    // blocked = false;
    // // 根据请求类型分发到对应端口
    // if (pkt->req->isInstFetch()) {
    //     instPort.sendPacket(pkt);
    // }
    // else {
    //     dataPort.sendPacket(pkt);
    // }
    // // 此时可以继续处理其他请求，告知CPU
    // instPort.trySendRetry();
    // dataPort.trySendRetry();

    return true;
}

// NEW sendResponse函数与MySimpleMemobj中的handleResponse类似，但使用waitingPortId来发送给正确的端口
void MySimpleCache::sendResponse(PacketPtr pkt) {
    int port_id = waitingPortId;
    // 解锁缓存，重置waitingPortId
    blocked = false;
    waitingPortId = -1;
    // 根据port_id向对应端口发送packet
    cpuPorts[port_id].sendPacket(pkt);
    // 此时该port已完成响应，其他port可以重试
    for (auto &port : cpuPorts) {
        port.trySendRetry();
    }
}

void MySimpleCache::handleFunctional(PacketPtr pkt) {
    // NEW 如果缓存中有数据，直接使用缓存中的数据
    if (accessFunctional(pkt)) {
        pkt->makeResponse();
    }
    else {
        memPort.sendFunctional(pkt);
    }
}

// NEW timing模式处理packet，由事件回调函数调用
void MySimpleCache::accessTiming(PacketPtr pkt) {
    bool hit = accessFunctional(pkt);
    if (hit) {
        // 将请求packet转换为响应packet
        pkt->makeResponse();
        sendResponse(pkt);
    }
    else {
        // 获取请求的地址、块地址和大小
        Addr addr = pkt->getAddr();
        Addr block_addr = pkt->getBlockAddr(blockSize);
        unsigned size = pkt->getSize();
        // 如果请求地址与块地址对齐且大小与块大小一致，则直接转发到下游存储
        if (addr == block_addr && size == blockSize) {
            DPRINTF(MySimpleCache, "forwarding packet\n");
            memPort.sendPacket(pkt);
        }
        // 否则需要新建一个请求以读入整个cacheline的数据
        else {
            DPRINTF(MySimpleCache, "Upgrading packet to block size\n");
            panic_if(addr + size - block_addr > blockSize,
                    "Cannot handle accesses that span multiple cache lines");
            assert(pkt->needsResponse());
            // 不管是读还是写都会将整个cacheline读入，在cache中进行操作
            MemCmd cmd;
            if (pkt->isWrite() || pkt->isRead()) {
                cmd = MemCmd::ReadReq;
            }
            else {
                panic("Unknown packet type in upgrade size");
            }
            // 新建packet并分配数据空间
            PacketPtr new_pkt = new Packet(pkt->req, cmd, blockSize);
            new_pkt->allocate();
            // 保存请求packet
            outstandingPacket = pkt;
            // 向内存侧发送packet
            memPort.sendPacket(new_pkt);
        }
    }
}

// NEW functional模式处理packet，实际更新缓存的函数，缓存命中返回true，否则返回false
bool MySimpleCache::accessFunctional(PacketPtr pkt) {
    // 获取块地址
    Addr block_addr = pkt->getBlockAddr(blockSize);
    // 查找cache中是否有该块地址的数据（是否命中），命中则执行packet的操作并返回true，否则直接返回false
    auto it = cacheStore.find(block_addr);
    if (it != cacheStore.end()) {
        if (pkt->isWrite()) {
            pkt->writeDataToBlock(it->second, blockSize);
        }
        else if (pkt->isRead()) {
            pkt->setDataFromBlock(it->second, blockSize);
        }
        else {
            panic("Unknown packet type!");
        }
        return true;
    }
    return false;
}

// NEW 更新cache数据
void MySimpleCache::insert(PacketPtr pkt) {
    // 当缓存已满，进行替换
    if (cacheStore.size() >= capacity) {
        // 随机选择替换的块
        int bucket, bucket_size;
        do {
            bucket = random_mt->random(0, (int)cacheStore.bucket_count() - 1);
        } while ( (bucket_size = cacheStore.bucket_size(bucket)) == 0 );
        auto block = std::next(cacheStore.begin(bucket),
                                random_mt->random(0, bucket_size - 1));
        // 写回将被替换的块
        RequestPtr req = std::make_shared<Request>(block->first, blockSize, 0, 0);
        PacketPtr new_pkt = new Packet(req, MemCmd::WritebackDirty, blockSize);
        new_pkt->dataDynamic(block->second);    // 指针指向的地址后续会被释放
        memPort.sendPacket(new_pkt);
        DPRINTF(MySimpleCache, "Writing packet back %s\n", pkt->print());
        // 删除被替换的块
        cacheStore.erase(block->first);
    }
    // 插入新cache条目
    uint8_t *data = new uint8_t[blockSize];
    cacheStore[pkt->getAddr()] = data;
    // 写入cache数据
    pkt->writeDataToBlock(data, blockSize);
}
...
void MySimpleCache::sendRangeChange() {
    // NEW 改成vector port
    for (auto &port : cpuPorts) {
        port.sendRangeChange();
    }
    // instPort.sendRangeChange();
    // dataPort.sendRangeChange();
}
...
bool MySimpleCache::CPUSidePort::recvTimingReq(PacketPtr pkt) {
    // NEW 检查是否还有未发送的packet或需要重试的请求
    if (blockedPacket || needRetry) {
        DPRINTF(MySimpleCache, "Request blocked\n");
        needRetry = true;
        return false;
    }
    // NEW handleRequest新增port_id参数，传入CPUSidePort::id
    if (!owner->handleRequest(pkt, id)) {
        needRetry = true;
        return false;
    }
    else {
        return true;
    }
}
void MySimpleCache::CPUSidePort::recvRespRetry() {
    assert(blockedPacket != nullptr);
    PacketPtr pkt = blockedPacket;
    blockedPacket = nullptr;

    sendPacket(pkt);
    // NEW 此时能够再次处理请求，发送重试信号
    trySendRetry();
}
...
} // namespace gem5
```

### 创建配置文件

最后一步就是创建一个Python配置脚本来使用我们实现的cache。同样也可以在上一章的基础上进行修改，唯一的不同是需要设置cache的大小，以及将原来的命名端口改成向量端口。

编译并运行即可看到正常输出“Hello World！”，同时如果将cache调大，系统性能应该会提升（退出时间更早）。

```python
# @file: configs/tutorials/part2/simple_cache.py
import m5
from m5.objects import *

system = System()
system.clk_domain = SrcClockDomain()
system.clk_domain.clock = '1GHz'
system.clk_domain.voltage_domain = VoltageDomain()
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('512MB')]

system.cpu = X86TimingSimpleCPU()

# system.memobj = MySimpleMemobj()

# NEW 实例化MySimpleCache，并连接到cpu的icache、dcache，membus的cpu_side_ports
system.cache = MySimpleCache(size='1kB')

# system.cpu.icache_port = system.memobj.inst_port
# system.cpu.dcache_port = system.memobj.data_port
system.cpu.icache_port = system.cache.cpu_side
system.cpu.dcache_port = system.cache.cpu_side

system.membus = SystemXBar()

# system.memobj.mem_side = system.membus.cpu_side_ports
system.cache.mem_side = system.membus.cpu_side_ports

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

### 给cache添加统计数据

了解系统的整体执行时间是一个重要的度量指标。然而，你可能也想包括其他的统计数据例如cache命中率和缺失率。为此，我们需要给 `MySimpleCache`添加一些统计信息。

首先，我们需要在类中声明这些统计数据，它们属于 `Stats`命名空间，这里我们添加了四个统计数据——缓存命中数、缺失数，缺失延迟以及命中率。

然后，我们需要重写 `regStats()`函数来注册这些统计数据。这里我们采用父对象 `MySimpleCache`加统计数据名的层级命名方式来注册统计数据并添加相应描述。

对于直方图（histogram）统计数据，还需要指定有多少个统计区域；对于公式（formula）统计数据，只需要写出对应的表达式即可。

最后就是在相应代码区域对这些统计数据进行更新：对于缓存命中与缺失数，我们需要在 `accessTiming()`中根据是否命中分别自增 `hits`和 `misses`，另外对于缓存缺失，我们还要记录当前的时间点以测量缺失延迟。当获取到相应时，我们需要添加测量出的延迟添加到直方图中。

```cpp
// @file: src/tutorials/part2/my_simple_cache.hh
...
class MySimpleCache : public ClockedObject {
private:
    ...
    // NEW 记录发生缓存缺失的时刻
    Tick missTime;
    ...
protected:
    // NEW 缓存统计数据
    struct SimpuleCacheStats : public statistics::Group {
        SimpuleCacheStats(statistics::Group *parent);
        statistics::Scalar hits;
        statistics::Scalar misses;
        statistics::Histogram missLatency;
        statistics::Formula hitRatio;
    } stats;
    ...
};
...


// @file: src/tutorials/part2/my_simple_cache.cc
...
bool MySimpleCache::handelResponse(PacketPtr pkt) {
    assert(blocked);
    DPRINTF(MySimpleCache, "Got response for addr %#x\n", pkt->getAddr());
    insert(pkt);
    // NEW 记录缺失代价
    stats.missLatency.sample(curTick() - missTime);
    if (outstandingPacket != nullptr) {
        accessFunctional(outstandingPacket);
        outstandingPacket->makeResponse();
        delete pkt;
        pkt = outstandingPacket;
        outstandingPacket = nullptr;
    }

    sendResponse(pkt);
    return true;
}
...
void MySimpleCache::accessTiming(PacketPtr pkt) {
    bool hit = accessFunctional(pkt);
    if (hit) {
        // NEW 记录命中次数
        stats.hits++;
        pkt->makeResponse();
        sendResponse(pkt);
    }
    else {
        // NEW 记录缺失次数和缺失时刻
        stats.misses++;
        missTime = curTick();
        // 获取请求的地址、块地址和大小
        Addr addr = pkt->getAddr();
        Addr block_addr = pkt->getBlockAddr(blockSize);
        unsigned size = pkt->getSize();
        // 如果请求地址与块地址对齐且大小与块大小一致，则直接转发到下游存储
        if (addr == block_addr && size == blockSize) {
            DPRINTF(MySimpleCache, "forwarding packet\n");
            memPort.sendPacket(pkt);
        }
        // 否则需要新建一个请求以读入整个cacheline的数据
        else {
            DPRINTF(MySimpleCache, "Upgrading packet to block size\n");
            panic_if(addr + size - block_addr > blockSize,
                    "Cannot handle accesses that span multiple cache lines");
            assert(pkt->needsResponse());
            // 不管是读还是写都会将整个cacheline读入，在cache中进行操作
            MemCmd cmd;
            if (pkt->isWrite() || pkt->isRead()) {
                cmd = MemCmd::ReadReq;
            }
            else {
                panic("Unknown packet type in upgrade size");
            }
            // 新建packet并分配数据空间
            PacketPtr new_pkt = new Packet(pkt->req, cmd, blockSize);
            new_pkt->allocate();
            // 保存请求packet
            outstandingPacket = pkt;
            // 向内存侧发送packet
            memPort.sendPacket(new_pkt);
        }
    }
}
...
// NEW 注册相关统计数据并初始化
MySimpleCache::SimpuleCacheStats::SimpuleCacheStats(statistics::Group *parent)
    : statistics::Group(parent),
    ADD_STAT(hits, statistics::units::Count::get(), "Number of hits"),
    ADD_STAT(misses, statistics::units::Count::get(), "Number of misses"),
    ADD_STAT(missLatency, statistics::units::Tick::get(), "Ticks for misses to cache"),
    ADD_STAT(hitRatio, statistics::units::Ratio::get(), "The ratio of hits to the total accesses to the cache", hits / (hits + misses))
{
    missLatency.init(16);   // 直方图桶数
}
```

此时当我们再运行配置脚本时，我们就可以在 `m5out/stats.txt`中查看运行的统计数据。对于1KB大小的cache，应该有91%的命中率，平均缺失延迟是49782周期（50ns）。提高cache容量后，我们应该能看到命中率稍微变高。
