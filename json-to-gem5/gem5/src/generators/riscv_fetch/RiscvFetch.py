from m5.params import *
from m5.SimObject import SimObject

class RiscvFetch(SimObject):
    type = 'RiscvFetch'
    cxx_header = "generators/riscv_fetch/riscv_fetch.hh"
    cxx_class = "gem5::RiscvFetch"
