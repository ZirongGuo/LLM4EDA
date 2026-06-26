from m5.params import *
from m5.SimObject import SimObject


class RiscvDecode(SimObject):
    type = 'RiscvDecode'
    cxx_header = "generators/riscv_decode/riscv_decode.hh"
    cxx_class = "gem5::RiscvDecode"

    # Extra decode pipeline stage: 0 = passthrough, 1 = extra decode stage
    extra_decode_stage = Param.UInt8(0, "Extra decode pipeline stage (0 or 1)")

    # RISC-V instruction decoder submodule (combinational)
    decoder = Param.RiscvDecoder(Parent.any, "RISC-V instruction decoder")
