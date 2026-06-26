import m5
from m5.objects import *

root = Root(full_system=False)

# Instantiate leaf sub-modules
root.csr_regfile = RiscvCsrRegfile()
root.regfile = RiscvRegfile()
root.xilinx_2r1w = RiscvXilinx2r1w()
root.alu = RiscvAlu()

# Instantiate intermediate sub-modules
root.fetch = RiscvFetch()
root.issue = RiscvIssue(regfile=root.regfile, xilinx_2r1w=root.xilinx_2r1w)
root.exec = RiscvExec(alu=root.alu)
root.lsu = RiscvLsu(fifo_depth=4)
root.csr = RiscvCsr(csrfile=root.csr_regfile)
root.mul = RiscvMultiplier()
root.div = RiscvDivider()
root.mmu = RiscvMmu()

# Instantiate top-level core
root.dut = RiscvCore(
    fetch=root.fetch,
    issue=root.issue,
    exec=root.exec,
    lsu=root.lsu,
    csr=root.csr,
    mul=root.mul,
    div=root.div,
    mmu=root.mmu
)

root.tester = RiscvCoreTestGenerator(dut=root.dut, clock_period=100)

m5.instantiate()
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")
