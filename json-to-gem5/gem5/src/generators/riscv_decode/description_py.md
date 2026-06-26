# RiscvDecode Python 配置脚本说明

## 模块类型
时序逻辑子模块

## 参数说明

### extra_decode_stage
- **类型**: Param.UInt8
- **默认值**: 0
- **描述**: 额外译码流水级控制
  - 0: 直通模式，跳过额外译码级（单级流水线）
  - 1: 插入一个额外的译码流水级（两级流水线）

### decoder
- **类型**: Param.RiscvDecoder
- **默认值**: Parent.any
- **描述**: RISC-V 指令解码器子模块引用。该子模块为组合逻辑模块，由 riscv_decode 在 C++ 端通过 set/get/process 接口直接调用。

## 使用方式
该模块不直接作为独立 SimObject 实例化于 Python 脚本，而是由顶层流水线模块在 C++ 端实例化并使用。Python 配置负责传入 EXTRA_DECODE_STAGE 参数和解码器子模块引用。
