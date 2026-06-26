from m5.params import *
from m5.SimObject import SimObject


class RiscvDivider(SimObject):
    type = 'RiscvDivider'
    cxx_header = "generators/riscv_divider/riscv_divider.hh"
    cxx_class = "gem5::RiscvDivider"
