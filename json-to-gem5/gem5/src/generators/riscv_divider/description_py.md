# riscv_divider.py 配置说明

## SimObject 参数
本模块无参数。

## 使用方式
riscv_divider 作为 riscv_core 的子模块使用。riscv_core 中通过 Param.RiscvDivider 引用该模块：
```python
from m5.params import *
from m5.SimObject import SimObject

class RiscvCore(SimObject):
    divider = Param.RiscvDivider("RISC-V divider unit")
```

## 父模块调用接口
父模块在每个时钟周期按以下顺序交互：
1. 通过 set* 函数设置输入端口值
2. 调用 process() 处理一个周期
3. 通过 get* 函数读取输出端口值

当 writeback_valid_o 为 true 时，writeback_value_o 包含有效的计算结果。
