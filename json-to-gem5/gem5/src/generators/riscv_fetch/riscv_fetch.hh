#ifndef __GENERATORS_RISCV_FETCH_HH__
#define __GENERATORS_RISCV_FETCH_HH__

#include "params/RiscvFetch.hh"
#include "sim/sim_object.hh"

namespace gem5 {

class RiscvFetch : public SimObject
{
  private:
    // Input port registers
    uint32_t fetch_accept_i_reg;
    uint32_t icache_accept_i_reg;
    uint32_t icache_valid_i_reg;
    uint32_t icache_error_i_reg;
    uint32_t icache_inst_i_reg;
    uint32_t icache_page_fault_i_reg;
    uint32_t fetch_invalidate_i_reg;
    uint32_t branch_request_i_reg;
    uint32_t branch_pc_i_reg;
    uint32_t branch_priv_i_reg;

    // Output port registers
    uint32_t fetch_valid_o_reg;
    uint32_t fetch_instr_o_reg;
    uint32_t fetch_pc_o_reg;
    uint32_t fetch_fault_fetch_o_reg;
    uint32_t fetch_fault_page_o_reg;
    uint32_t icache_rd_o_reg;
    uint32_t icache_flush_o_reg;
    uint32_t icache_invalidate_o_reg;
    uint32_t icache_pc_o_reg;
    uint32_t icache_priv_o_reg;
    uint32_t squash_decode_o_reg;

    // Internal state registers
    uint32_t pc_reg;
    uint32_t priv_reg;
    bool req_sent;
    bool wait_data;
    bool pending_ready;
    uint32_t pending_instr_reg;
    uint32_t pending_pc_val;
    uint32_t pending_fault_fetch_val;
    uint32_t pending_fault_page_val;
    uint32_t sent_pc_reg;

  public:
    RiscvFetch(const RiscvFetchParams &p);

    // Set functions for input ports
    void setFetchAcceptI(uint32_t val);
    void setIcacheAcceptI(uint32_t val);
    void setIcacheValidI(uint32_t val);
    void setIcacheErrorI(uint32_t val);
    void setIcacheInstI(uint32_t val);
    void setIcachePageFaultI(uint32_t val);
    void setFetchInvalidateI(uint32_t val);
    void setBranchRequestI(uint32_t val);
    void setBranchPcI(uint32_t val);
    void setBranchPrivI(uint32_t val);

    // Get functions for output ports
    uint32_t getFetchValidO();
    uint32_t getFetchInstrO();
    uint32_t getFetchPcO();
    uint32_t getFetchFaultFetchO();
    uint32_t getFetchFaultPageO();
    uint32_t getIcacheRdO();
    uint32_t getIcacheFlushO();
    uint32_t getIcacheInvalidateO();
    uint32_t getIcachePcO();
    uint32_t getIcachePrivO();
    uint32_t getSquashDecodeO();

    // Process function - called by parent module each cycle
    void process();
};

} // namespace gem5

#endif // __GENERATORS_RISCV_FETCH_HH__
