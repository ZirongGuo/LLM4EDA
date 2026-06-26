## Python 配置脚本参数说明

### RiscvFetch 参数

RiscvFetch 模块不需要额外的 Python 可配置参数。
模块的行为完全由输入端口驱动，通过 set 函数设置输入值，process() 函数在每个周期被调用。

### 父模块使用方式

在父模块（如 riscv_core）中通过 Param.RiscvFetch 引用：
```python
fetch = Param.RiscvFetch("RISC-V fetch unit")
```

在 C++ 中通过 params 获取引用：
```cpp
RiscvFetch &fetch = *params.fetch;
```

每个周期调用流程：
```cpp
fetch.setFetchAcceptI(accept);
fetch.setIcacheAcceptI(icache_accept);
fetch.setIcacheValidI(icache_valid);
fetch.setIcacheErrorI(icache_error);
fetch.setIcacheInstI(icache_inst);
fetch.setIcachePageFaultI(icache_page_fault);
fetch.setFetchInvalidateI(invalidate);
fetch.setBranchRequestI(branch_req);
fetch.setBranchPcI(branch_pc);
fetch.setBranchPrivI(branch_priv);
fetch.process();

// Read outputs after process()
uint32_t valid = fetch.getFetchValidO();
uint32_t instr = fetch.getFetchInstrO();
uint32_t pc = fetch.getFetchPcO();
// ...
```
