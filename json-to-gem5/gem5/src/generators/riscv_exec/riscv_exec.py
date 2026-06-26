from m5.params import *
from m5.SimObject import SimObject


class RiscvExec(SimObject):
    type = 'RiscvExec'
    cxx_header = "generators/riscv_exec/riscv_exec.hh"
    cxx_class = "gem5::RiscvExec"

    alu = Param.RiscvAlu("RISC-V ALU unit")
