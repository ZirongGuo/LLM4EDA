import m5
from m5.objects import *

root = Root(full_system=False)

root.regfile = RiscvRegfile()
root.dut = RiscvIssue(regfile=root.regfile)
root.tester = RiscvIssueTestGenerator(
    dut=root.dut,
    clock_period=100
)

m5.instantiate()
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")
