import m5
from m5.objects import *

# Create system
system = System()
system.clk_domain = SrcClockDomain(clock='1GHz', voltage_domain=VoltageDomain())
system.mem_mode = 'timing'
system.mem_ranges = [AddrRange('512MB')]

# Create DUT
dut = RiscvMultiplier()

# Create test generator
tester = RiscvMultiplierTestGenerator()
tester.dut = dut

# Connect
system.dut = dut
system.tester = tester

# Root
root = Root(full_system=False, system=system)
m5.instantiate()

# Run
exit_event = m5.simulate()
print(f'Exit: {exit_event.getCause()}')
