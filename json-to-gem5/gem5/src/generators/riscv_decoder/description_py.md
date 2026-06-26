# RiscvDecoder Python 配置脚本说明

## 模块类型
组合逻辑子模块（非 SimObject 顶层模块）

## 参数说明
本模块无 Python 可配置参数，所有输入通过 C++ set 函数传递：
- valid_i: 指令有效标志
- fetch_fault_i: 取指错误标志
- enable_muldiv_i: 乘除法扩展使能
- opcode_i: 32 位 RISC-V 指令操作码

## 使用方式
该模块不作为独立 SimObject 实例化，而是由 riscv_decode 模块在 C++ 端
直接包含头文件并实例化，通过 set/get/process 接口调用。
