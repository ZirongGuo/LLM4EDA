#include "generators/riscv_fetch/riscv_fetch.hh"

#include "base/trace.hh"
#include "debug/RiscvFetch.hh"

namespace gem5 {

RiscvFetch::RiscvFetch(const RiscvFetchParams &p)
    : SimObject(p),
      fetch_accept_i_reg(0),
      icache_accept_i_reg(0),
      icache_valid_i_reg(0),
      icache_error_i_reg(0),
      icache_inst_i_reg(0),
      icache_page_fault_i_reg(0),
      fetch_invalidate_i_reg(0),
      branch_request_i_reg(0),
      branch_pc_i_reg(0),
      branch_priv_i_reg(0),
      fetch_valid_o_reg(0),
      fetch_instr_o_reg(0),
      fetch_pc_o_reg(0),
      fetch_fault_fetch_o_reg(0),
      fetch_fault_page_o_reg(0),
      icache_rd_o_reg(0),
      icache_flush_o_reg(0),
      icache_invalidate_o_reg(0),
      icache_pc_o_reg(0),
      icache_priv_o_reg(0),
      squash_decode_o_reg(0),
      pc_reg(0x80000000),
      priv_reg(3),
      req_sent(false),
      wait_data(false),
      pending_ready(false),
      pending_instr_reg(0),
      pending_pc_val(0),
      pending_fault_fetch_val(0),
      pending_fault_page_val(0),
      sent_pc_reg(0)
{
}

void
RiscvFetch::setFetchAcceptI(uint32_t val)
{
    fetch_accept_i_reg = val;
}

void
RiscvFetch::setIcacheAcceptI(uint32_t val)
{
    icache_accept_i_reg = val;
}

void
RiscvFetch::setIcacheValidI(uint32_t val)
{
    icache_valid_i_reg = val;
}

void
RiscvFetch::setIcacheErrorI(uint32_t val)
{
    icache_error_i_reg = val;
}

void
RiscvFetch::setIcacheInstI(uint32_t val)
{
    icache_inst_i_reg = val;
}

void
RiscvFetch::setIcachePageFaultI(uint32_t val)
{
    icache_page_fault_i_reg = val;
}

void
RiscvFetch::setFetchInvalidateI(uint32_t val)
{
    fetch_invalidate_i_reg = val;
}

void
RiscvFetch::setBranchRequestI(uint32_t val)
{
    branch_request_i_reg = val;
}

void
RiscvFetch::setBranchPcI(uint32_t val)
{
    branch_pc_i_reg = val;
}

void
RiscvFetch::setBranchPrivI(uint32_t val)
{
    branch_priv_i_reg = val;
}

uint32_t
RiscvFetch::getFetchValidO()
{
    return fetch_valid_o_reg;
}

uint32_t
RiscvFetch::getFetchInstrO()
{
    return fetch_instr_o_reg;
}

uint32_t
RiscvFetch::getFetchPcO()
{
    return fetch_pc_o_reg;
}

uint32_t
RiscvFetch::getFetchFaultFetchO()
{
    return fetch_fault_fetch_o_reg;
}

uint32_t
RiscvFetch::getFetchFaultPageO()
{
    return fetch_fault_page_o_reg;
}

uint32_t
RiscvFetch::getIcacheRdO()
{
    return icache_rd_o_reg;
}

uint32_t
RiscvFetch::getIcacheFlushO()
{
    return icache_flush_o_reg;
}

uint32_t
RiscvFetch::getIcacheInvalidateO()
{
    return icache_invalidate_o_reg;
}

uint32_t
RiscvFetch::getIcachePcO()
{
    return icache_pc_o_reg;
}

uint32_t
RiscvFetch::getIcachePrivO()
{
    return icache_priv_o_reg;
}

uint32_t
RiscvFetch::getSquashDecodeO()
{
    return squash_decode_o_reg;
}

void
RiscvFetch::process()
{
    // Step 0: Reset all output registers to default 0
    fetch_valid_o_reg = 0;
    fetch_instr_o_reg = 0;
    fetch_pc_o_reg = 0;
    fetch_fault_fetch_o_reg = 0;
    fetch_fault_page_o_reg = 0;
    icache_rd_o_reg = 0;
    icache_flush_o_reg = 0;
    icache_invalidate_o_reg = 0;
    icache_pc_o_reg = 0;
    icache_priv_o_reg = 0;
    squash_decode_o_reg = 0;

    // Step 1: Handle invalidate (IFENCE / SFENCE) - highest priority
    if (fetch_invalidate_i_reg) {
        icache_flush_o_reg = 1;
        icache_invalidate_o_reg = 1;
        req_sent = false;
        wait_data = false;
        pending_ready = false;
        DPRINTF(RiscvFetch, "Invalidate: flushing icache\n");
    }

    // Step 2: Handle branch request
    if (branch_request_i_reg) {
        pc_reg = branch_pc_i_reg;
        priv_reg = branch_priv_i_reg;
        req_sent = false;
        wait_data = false;
        pending_ready = false;
        squash_decode_o_reg = 1;
        DPRINTF(RiscvFetch, "Branch: pc=0x%08x priv=%u\n", pc_reg, priv_reg);
    }

    // Step 3: Handle icache response (valid data from cache)
    if (wait_data && icache_valid_i_reg) {
        wait_data = false;
        pending_ready = true;
        pending_instr_reg = icache_inst_i_reg;
        pending_pc_val = sent_pc_reg;
        pending_fault_fetch_val = icache_error_i_reg;
        pending_fault_page_val = icache_page_fault_i_reg;
    }

    // Step 4: Output pending instruction to decode stage
    if (pending_ready) {
        fetch_valid_o_reg = 1;
        fetch_pc_o_reg = pending_pc_val;
        fetch_fault_fetch_o_reg = pending_fault_fetch_val;
        fetch_fault_page_o_reg = pending_fault_page_val;
        if (!pending_fault_fetch_val && !pending_fault_page_val) {
            fetch_instr_o_reg = pending_instr_reg;
        }

        // Step 5: Check if decode accepts the instruction
        if (fetch_accept_i_reg) {
            if (!pending_fault_fetch_val && !pending_fault_page_val) {
                // Normal instruction: advance PC by 4
                pc_reg = pending_pc_val + 4;
            }
            // On fault: PC stays (exception handler redirects via branch)
            pending_ready = false;
        }
    }

    // Step 6: Send new icache request if not already waiting and no pending
    if (!req_sent && !wait_data && !pending_ready) {
        icache_rd_o_reg = 1;
        icache_pc_o_reg = pc_reg;
        icache_priv_o_reg = priv_reg;
        sent_pc_reg = pc_reg;
        req_sent = true;
    }

    // Step 7: Check if icache accepts the request (same cycle handshake)
    if (req_sent && icache_accept_i_reg) {
        req_sent = false;
        wait_data = true;
    }
}

} // namespace gem5
