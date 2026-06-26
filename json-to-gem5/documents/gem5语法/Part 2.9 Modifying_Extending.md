# 官方教程中的BUGs

> 由于开始记录的时间点较晚，较早的章节中会有部分遗漏的bug。

## Modifying/Extending

### Creating a simple cache object

1. 注册SimObject的Python文件中，使用了已弃用的 `MemObject`，现已改用 `ClockedObject`。
2. `base/random.hh`中的Random已弃用无参默认构造函数，因此无法再使用点运算符，应改用箭头运算符。
3. `RequestPtr`是智能指针，`RequestPtr req = new Request(block->first, blockSize, 0, 0);`应改为 `RequestPtr req = std::make_shared<Request>(block->first, blockSize, 0, 0);`。
4. `Stats`命名空间已变更为 `statistics`，使用方式也有所改动。
