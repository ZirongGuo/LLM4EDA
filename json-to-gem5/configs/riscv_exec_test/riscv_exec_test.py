import m5
from m5.objects import *

root = Root(full_system=False)

root.alu = RiscvAlu()
root.dut = RiscvExec(alu=root.alu)
root.tester = RiscvExecTestGenerator(
    dut=root.dut,
    clock_period=100
)

m5.instantiate()
exit_event = m5.simulate()
print(f"Exiting @ tick {m5.curTick()} because {exit_event.getCause()}")
