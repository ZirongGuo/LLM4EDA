from m5.params import *
from m5.SimObject import SimObject


class RiscvDecoder(SimObject):
    type = 'RiscvDecoder'
    cxx_header = "generators/riscv_decoder/riscv_decoder.hh"
    cxx_class = "gem5::RiscvDecoder"

    # Combinational submodule: no parameters needed.
    # Inputs are set via C++ set functions; outputs read via get functions.
    # Used as a submodule by riscv_decode via direct C++ instantiation.
