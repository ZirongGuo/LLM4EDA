## Python 配置脚本参数说明

### RiscvExec 参数

RiscvExec 模块需要引用一个 riscv_alu 子模块实例：

```python
alu = Param.RiscvAlu("RISC-V ALU unit")
```

### 父模块使用方式

在父模块中通过 Param.RiscvExec 引用：
```python
exec_unit = Param.RiscvExec("RISC-V execution unit")
```

在 C++ 中通过 params 获取引用：
```cpp
RiscvExec &exec_unit = *params.exec_unit;
```

每个周期调用流程：
```cpp
// 设置输入
exec_unit.setOpcodeValid(valid);
exec_unit.setOpcodeOpcode(instr);
exec_unit.setOpcodePc(pc);
exec_unit.setOpcodeInvalid(invalid);
exec_unit.setOpcodeRdIdx(rd_idx);
exec_unit.setOpcodeRaIdx(rs1_idx);
exec_unit.setOpcodeRbIdx(rs2_idx);
exec_unit.setOpcodeRaOperand(rs1_val);
exec_unit.setOpcodeRbOperand(rs2_val);
exec_unit.setHold(hold);

// 执行
exec_unit.process();

// 读取输出
uint32_t result = exec_unit.getWritebackValue();
uint8_t branch_req = exec_unit.getBranchRequest();
```

### 子模块 riscv_alu 配置

riscv_alu 在 Python 配置中作为子模块注入：
```python
alu = RiscvAlu()
exec_unit = RiscvExec(alu=alu)
```

或通过 Root 层级设置：
```python
root.alu = RiscvAlu()
root.exec_unit = RiscvExec(alu=root.alu)
```
