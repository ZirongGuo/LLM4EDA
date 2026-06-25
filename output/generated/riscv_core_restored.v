`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`include "riscv_defs.v"
`define HAS_SIM_CTRL `endif
`define ALU_NONE 4'b0000
`define ALU_SHIFTL 4'b0001
`define ALU_SHIFTR 4'b0010
`define ALU_SHIFTR_ARITH 4'b0011
`define ALU_ADD 4'b0100
`define ALU_SUB 4'b0110
`define ALU_AND 4'b0111
`define ALU_OR 4'b1000
`define ALU_XOR 4'b1001
`define ALU_LESS_THAN 4'b1010
`define ALU_LESS_THAN_SIGNED 4'b1011
`define INST_ANDI 32'h7013
`define INST_ANDI_MASK 32'h707f
`define INST_ADDI 32'h13
`define INST_ADDI_MASK 32'h707f
`define INST_SLTI 32'h2013
`define INST_SLTI_MASK 32'h707f
`define INST_SLTIU 32'h3013
`define INST_SLTIU_MASK 32'h707f
`define INST_ORI 32'h6013
`define INST_ORI_MASK 32'h707f
`define INST_XORI 32'h4013
`define INST_XORI_MASK 32'h707f
`define INST_SLLI 32'h1013
`define INST_SLLI_MASK 32'hfc00707f
`define INST_SRLI 32'h5013
`define INST_SRLI_MASK 32'hfc00707f
`define INST_SRAI 32'h40005013
`define INST_SRAI_MASK 32'hfc00707f
`define INST_LUI 32'h37
`define INST_LUI_MASK 32'h7f
`define INST_AUIPC 32'h17
`define INST_AUIPC_MASK 32'h7f
`define INST_ADD 32'h33
`define INST_ADD_MASK 32'hfe00707f
`define INST_SUB 32'h40000033
`define INST_SUB_MASK 32'hfe00707f
`define INST_SLT 32'h2033
`define INST_SLT_MASK 32'hfe00707f
`define INST_SLTU 32'h3033
`define INST_SLTU_MASK 32'hfe00707f
`define INST_XOR 32'h4033
`define INST_XOR_MASK 32'hfe00707f
`define INST_OR 32'h6033
`define INST_OR_MASK 32'hfe00707f
`define INST_AND 32'h7033
`define INST_AND_MASK 32'hfe00707f
`define INST_SLL 32'h1033
`define INST_SLL_MASK 32'hfe00707f
`define INST_SRL 32'h5033
`define INST_SRL_MASK 32'hfe00707f
`define INST_SRA 32'h40005033
`define INST_SRA_MASK 32'hfe00707f
`define INST_JAL 32'h6f
`define INST_JAL_MASK 32'h7f
`define INST_JALR 32'h67
`define INST_JALR_MASK 32'h707f
`define INST_BEQ 32'h63
`define INST_BEQ_MASK 32'h707f
`define INST_BNE 32'h1063
`define INST_BNE_MASK 32'h707f
`define INST_BLT 32'h4063
`define INST_BLT_MASK 32'h707f
`define INST_BGE 32'h5063
`define INST_BGE_MASK 32'h707f
`define INST_BLTU 32'h6063
`define INST_BLTU_MASK 32'h707f
`define INST_BGEU 32'h7063
`define INST_BGEU_MASK 32'h707f
`define INST_LB 32'h3
`define INST_LB_MASK 32'h707f
`define INST_LH 32'h1003
`define INST_LH_MASK 32'h707f
`define INST_LW 32'h2003
`define INST_LW_MASK 32'h707f
`define INST_LBU 32'h4003
`define INST_LBU_MASK 32'h707f
`define INST_LHU 32'h5003
`define INST_LHU_MASK 32'h707f
`define INST_LWU 32'h6003
`define INST_LWU_MASK 32'h707f
`define INST_SB 32'h23
`define INST_SB_MASK 32'h707f
`define INST_SH 32'h1023
`define INST_SH_MASK 32'h707f
`define INST_SW 32'h2023
`define INST_SW_MASK 32'h707f
`define INST_ECALL 32'h73
`define INST_ECALL_MASK 32'hffffffff
`define INST_EBREAK 32'h100073
`define INST_EBREAK_MASK 32'hffffffff
`define INST_ERET 32'h200073
`define INST_ERET_MASK 32'hcfffffff
`define INST_CSRRW 32'h1073
`define INST_CSRRW_MASK 32'h707f
`define INST_CSRRS 32'h2073
`define INST_CSRRS_MASK 32'h707f
`define INST_CSRRC 32'h3073
`define INST_CSRRC_MASK 32'h707f
`define INST_CSRRWI 32'h5073
`define INST_CSRRWI_MASK 32'h707f
`define INST_CSRRSI 32'h6073
`define INST_CSRRSI_MASK 32'h707f
`define INST_CSRRCI 32'h7073
`define INST_CSRRCI_MASK 32'h707f
`define INST_MUL 32'h2000033
`define INST_MUL_MASK 32'hfe00707f
`define INST_MULH 32'h2001033
`define INST_MULH_MASK 32'hfe00707f
`define INST_MULHSU 32'h2002033
`define INST_MULHSU_MASK 32'hfe00707f
`define INST_MULHU 32'h2003033
`define INST_MULHU_MASK 32'hfe00707f
`define INST_DIV 32'h2004033
`define INST_DIV_MASK 32'hfe00707f
`define INST_DIVU 32'h2005033
`define INST_DIVU_MASK 32'hfe00707f
`define INST_REM 32'h2006033
`define INST_REM_MASK 32'hfe00707f
`define INST_REMU 32'h2007033
`define INST_REMU_MASK 32'hfe00707f
`define INST_WFI 32'h10500073
`define INST_WFI_MASK 32'hffff8fff
`define INST_FENCE 32'hf
`define INST_FENCE_MASK 32'h707f
`define INST_SFENCE 32'h12000073
`define INST_SFENCE_MASK 32'hfe007fff
`define INST_IFENCE 32'h100f
`define INST_IFENCE_MASK 32'h707f
`define PRIV_USER 2'd0
`define PRIV_SUPER 2'd1
`define PRIV_MACHINE 2'd3
`define IRQ_S_SOFT 1
`define IRQ_M_SOFT 3
`define IRQ_S_TIMER 5
`define IRQ_M_TIMER 7
`define IRQ_S_EXT 9
`define IRQ_M_EXT 11
`define IRQ_MIN (`IRQ_S_SOFT)
`define IRQ_MAX (`IRQ_M_EXT + 1)
`define IRQ_MASK ((1 << `IRQ_M_EXT)   | (1 << `IRQ_S_EXT)   |                       (1 << `IRQ_M_TIMER) | (1 << `IRQ_S_TIMER) |                       (1 << `IRQ_M_SOFT)  | (1 << `IRQ_S_SOFT))
`define SR_IP_MSIP_R `IRQ_M_SOFT
`define SR_IP_MTIP_R `IRQ_M_TIMER
`define SR_IP_MEIP_R `IRQ_M_EXT
`define SR_IP_SSIP_R `IRQ_S_SOFT
`define SR_IP_STIP_R `IRQ_S_TIMER
`define SR_IP_SEIP_R `IRQ_S_EXT
`define CSR_DSCRATCH 12'h7b2
`define CSR_SIM_CTRL 12'h8b2
`define CSR_SIM_CTRL_MASK 32'hFFFFFFFF
`define CSR_SIM_CTRL_EXIT (0 << 24)
`define CSR_SIM_CTRL_PUTC (1 << 24)
`define CSR_MSTATUS 12'h300
`define CSR_MSTATUS_MASK 32'hFFFFFFFF
`define CSR_MISA 12'h301
`define CSR_MISA_MASK 32'hFFFFFFFF
`define MISA_RV32 32'h40000000
`define MISA_RVI 32'h00000100
`define MISA_RVE 32'h00000010
`define MISA_RVM 32'h00001000
`define MISA_RVA 32'h00000001
`define MISA_RVF 32'h00000020
`define MISA_RVD 32'h00000008
`define MISA_RVC 32'h00000004
`define MISA_RVS 32'h00040000
`define MISA_RVU 32'h00100000
`define CSR_MEDELEG 12'h302
`define CSR_MEDELEG_MASK 32'h0000FFFF
`define CSR_MIDELEG 12'h303
`define CSR_MIDELEG_MASK 32'h0000FFFF
`define CSR_MIE 12'h304
`define CSR_MIE_MASK `IRQ_MASK
`define CSR_MTVEC 12'h305
`define CSR_MTVEC_MASK 32'hFFFFFFFF
`define CSR_MSCRATCH 12'h340
`define CSR_MSCRATCH_MASK 32'hFFFFFFFF
`define CSR_MEPC 12'h341
`define CSR_MEPC_MASK 32'hFFFFFFFF
`define CSR_MCAUSE 12'h342
`define CSR_MCAUSE_MASK 32'h8000000F
`define CSR_MTVAL 12'h343
`define CSR_MTVAL_MASK 32'hFFFFFFFF
`define CSR_MIP 12'h344
`define CSR_MIP_MASK `IRQ_MASK
`define CSR_MCYCLE 12'hc00
`define CSR_MCYCLE_MASK 32'hFFFFFFFF
`define CSR_MTIME 12'hc01
`define CSR_MTIME_MASK 32'hFFFFFFFF
`define CSR_MTIMEH 12'hc81
`define CSR_MTIMEH_MASK 32'hFFFFFFFF
`define CSR_MHARTID 12'hF14
`define CSR_MHARTID_MASK 32'hFFFFFFFF
`define CSR_MTIMECMP 12'h7c0
`define CSR_MTIMECMP_MASK 32'hFFFFFFFF
`define CSR_SSTATUS 12'h100
`define CSR_SSTATUS_MASK `SR_SMODE_MASK
`define CSR_SIE 12'h104
`define CSR_SIE_MASK ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_STVEC 12'h105
`define CSR_STVEC_MASK 32'hFFFFFFFF
`define CSR_SSCRATCH 12'h140
`define CSR_SSCRATCH_MASK 32'hFFFFFFFF
`define CSR_SEPC 12'h141
`define CSR_SEPC_MASK 32'hFFFFFFFF
`define CSR_SCAUSE 12'h142
`define CSR_SCAUSE_MASK 32'h8000000F
`define CSR_STVAL 12'h143
`define CSR_STVAL_MASK 32'hFFFFFFFF
`define CSR_SIP 12'h144
`define CSR_SIP_MASK ((1 << `IRQ_S_EXT) | (1 << `IRQ_S_TIMER) | (1 << `IRQ_S_SOFT))
`define CSR_SATP 12'h180
`define CSR_SATP_MASK 32'hFFFFFFFF
`define CSR_DFLUSH 12'h3a0
`define CSR_DFLUSH_MASK 32'hFFFFFFFF
`define CSR_DWRITEBACK 12'h3a1
`define CSR_DWRITEBACK_MASK 32'hFFFFFFFF
`define CSR_DINVALIDATE 12'h3a2
`define CSR_DINVALIDATE_MASK 32'hFFFFFFFF
`define SR_UIE (1 << 0)
`define SR_UIE_R 0
`define SR_SIE (1 << 1)
`define SR_SIE_R 1
`define SR_MIE (1 << 3)
`define SR_MIE_R 3
`define SR_UPIE (1 << 4)
`define SR_UPIE_R 4
`define SR_SPIE (1 << 5)
`define SR_SPIE_R 5
`define SR_MPIE (1 << 7)
`define SR_MPIE_R 7
`define SR_SPP (1 << 8)
`define SR_SPP_R 8
`define SR_MPP_SHIFT 11
`define SR_MPP_MASK 2'h3
`define SR_MPP_R 12:11
`define SR_MPP_U `PRIV_USER
`define SR_MPP_S `PRIV_SUPER
`define SR_MPP_M `PRIV_MACHINE
`define SR_SUM_R 18
`define SR_SUM (1 << `SR_SUM_R)
`define SR_MPRV_R 17
`define SR_MPRV (1 << `SR_MPRV_R)
`define SR_MXR_R 19
`define SR_MXR (1 << `SR_MXR_R)
`define SR_SMODE_MASK (`SR_UIE | `SR_SIE | `SR_UPIE | `SR_SPIE | `SR_SPP | `SR_SUM)
`define SATP_PPN_R 19:0
`define SATP_ASID_R 30:22
`define SATP_MODE_R 31
`define MMU_LEVELS 2
`define MMU_PTIDXBITS 10
`define MMU_PTESIZE 4
`define MMU_PGSHIFT (`MMU_PTIDXBITS + 2)
`define MMU_PGSIZE (1 << `MMU_PGSHIFT)
`define MMU_VPN_BITS (`MMU_PTIDXBITS * `MMU_LEVELS)
`define MMU_PPN_BITS (32 - `MMU_PGSHIFT)
`define MMU_VA_BITS (`MMU_VPN_BITS + `MMU_PGSHIFT)
`define PAGE_PRESENT 0
`define PAGE_READ 1
`define PAGE_WRITE 2
`define PAGE_EXEC 3
`define PAGE_USER 4
`define PAGE_GLOBAL 5
`define PAGE_ACCESSED 6
`define PAGE_DIRTY 7
`define PAGE_SOFT 9:8
`define PAGE_FLAGS 10'h3FF
`define PAGE_PFN_SHIFT 10
`define PAGE_SIZE 4096
`define EXCEPTION_W 6
`define EXCEPTION_MISALIGNED_FETCH 6'h10
`define EXCEPTION_FAULT_FETCH 6'h11
`define EXCEPTION_ILLEGAL_INSTRUCTION 6'h12
`define EXCEPTION_BREAKPOINT 6'h13
`define EXCEPTION_MISALIGNED_LOAD 6'h14
`define EXCEPTION_FAULT_LOAD 6'h15
`define EXCEPTION_MISALIGNED_STORE 6'h16
`define EXCEPTION_FAULT_STORE 6'h17
`define EXCEPTION_ECALL 6'h18
`define EXCEPTION_ECALL_U 6'h18
`define EXCEPTION_ECALL_S 6'h19
`define EXCEPTION_ECALL_H 6'h1a
`define EXCEPTION_ECALL_M 6'h1b
`define EXCEPTION_PAGE_FAULT_INST 6'h1c
`define EXCEPTION_PAGE_FAULT_LOAD 6'h1d
`define EXCEPTION_PAGE_FAULT_STORE 6'h1f
`define EXCEPTION_EXCEPTION 6'h10
`define EXCEPTION_INTERRUPT 6'h20
`define EXCEPTION_ERET_U 6'h30
`define EXCEPTION_ERET_S 6'h31
`define EXCEPTION_ERET_H 6'h32
`define EXCEPTION_ERET_M 6'h33
`define EXCEPTION_FENCE 6'h34
`define EXCEPTION_TYPE_MASK 6'h30
`define EXCEPTION_SUBTYPE_R 3:0
`define MCAUSE_INT 31
`define MCAUSE_MISALIGNED_FETCH ((0 << `MCAUSE_INT) | 0)
`define MCAUSE_FAULT_FETCH ((0 << `MCAUSE_INT) | 1)
`define MCAUSE_ILLEGAL_INSTRUCTION ((0 << `MCAUSE_INT) | 2)
`define MCAUSE_BREAKPOINT ((0 << `MCAUSE_INT) | 3)
`define MCAUSE_MISALIGNED_LOAD ((0 << `MCAUSE_INT) | 4)
`define MCAUSE_FAULT_LOAD ((0 << `MCAUSE_INT) | 5)
`define MCAUSE_MISALIGNED_STORE ((0 << `MCAUSE_INT) | 6)
`define MCAUSE_FAULT_STORE ((0 << `MCAUSE_INT) | 7)
`define MCAUSE_ECALL_U ((0 << `MCAUSE_INT) | 8)
`define MCAUSE_ECALL_S ((0 << `MCAUSE_INT) | 9)
`define MCAUSE_ECALL_H ((0 << `MCAUSE_INT) | 10)
`define MCAUSE_ECALL_M ((0 << `MCAUSE_INT) | 11)
`define MCAUSE_PAGE_FAULT_INST ((0 << `MCAUSE_INT) | 12)
`define MCAUSE_PAGE_FAULT_LOAD ((0 << `MCAUSE_INT) | 13)
`define MCAUSE_PAGE_FAULT_STORE ((0 << `MCAUSE_INT) | 15)
`define MCAUSE_INTERRUPT (1 << `MCAUSE_INT)
`define RISCV_REGNO_FIRST 13'd0
`define RISCV_REGNO_GPR0 13'd0
`define RISCV_REGNO_GPR31 13'd31
`define RISCV_REGNO_PC 13'd32
`define RISCV_REGNO_CSR0 13'd65
`define RISCV_REGNO_CSR4095 (`RISCV_REGNO_CSR0 +  13'd4095)
`define RISCV_REGNO_PRIV 13'd4161
`define PCINFO_W 10
`define PCINFO_ALU 0
`define PCINFO_LOAD 1
`define PCINFO_STORE 2
`define PCINFO_CSR 3
`define PCINFO_DIV 4
`define PCINFO_MUL 5
`define PCINFO_BRANCH 6
`define PCINFO_RD_VALID 7
`define PCINFO_INTR 8
`define PCINFO_COMPLETE 9
`define RD_IDX_R 11:7
`define DBG_IMM_IMM20 {opcode_i[31:12], 12'b0}
`define DBG_IMM_IMM12 {{20{opcode_i[31]}}, opcode_i[31:20]}
`define DBG_IMM_BIMM {{19{opcode_i[31]}}, opcode_i[31], opcode_i[7], opcode_i[30:25], opcode_i[11:8], 1'b0}
`define DBG_IMM_JIMM20 {{12{opcode_i[31]}}, opcode_i[19:12], opcode_i[20], opcode_i[30:25], opcode_i[24:21], 1'b0}
`define DBG_IMM_STOREIMM {{20{opcode_i[31]}}, opcode_i[31:25], opcode_i[11:7]}
`define DBG_IMM_SHAMT opcode_i[24:20]

module riscv_alu;
  reg  [31:0] result_r;
  reg  [15:0] shift_right_fill_r;
  reg  [31:0] shift_right_1_r;
  reg  [31:0] shift_right_2_r;
  reg  [31:0] shift_right_4_r;
  reg  [31:0] shift_right_8_r;
  reg  [31:0] shift_left_1_r;
  reg  [31:0] shift_left_2_r;
  reg  [31:0] shift_left_4_r;
  reg  [31:0] shift_left_8_r;
  wire  [31:0] sub_res_w = alu_a_i - alu_b_i;

  always begin
    shift_right_fill_r  = 16'b0;
    shift_right_1_r  = 32'b0;
    shift_right_2_r  = 32'b0;
    shift_right_4_r  = 32'b0;
    shift_right_8_r  = 32'b0;
    shift_left_1_r  = 32'b0;
    shift_left_2_r  = 32'b0;
    shift_left_4_r  = 32'b0;
    shift_left_8_r  = 32'b0;
    case (alu_op_i)
      `ALU_SHIFTL: begin
        shift_left_1_r  = {alu_a_i[30:0], 1'b0};
        shift_left_1_r  = alu_a_i;
        shift_left_2_r  = {shift_left_1_r[29:0], 2'b00};
        shift_left_2_r  = shift_left_1_r;
        shift_left_4_r  = {shift_left_2_r[27:0], 4'b0000};
        shift_left_4_r  = shift_left_2_r;
        shift_left_8_r  = {shift_left_4_r[23:0], 8'b00000000};
        shift_left_8_r  = shift_left_4_r;
        result_r  = {shift_left_8_r[15:0], 16'b0000000000000000};
        result_r  = shift_left_8_r;
      end
      `ALU_SHIFTR, `ALU_SHIFTR_ARITH: begin
        alu_op_i  = = `ALU_SHIFTR_ARITH)
                shift_right_fill_r = 16'b1111111111111111;
        shift_right_fill_r  = 16'b0000000000000000;
        shift_right_1_r  = {shift_right_fill_r[31], alu_a_i[31:1]};
        shift_right_1_r  = alu_a_i;
        shift_right_2_r  = {shift_right_fill_r[31:30], shift_right_1_r[31:2]};
        shift_right_2_r  = shift_right_1_r;
        shift_right_4_r  = {shift_right_fill_r[31:28], shift_right_2_r[31:4]};
        shift_right_4_r  = shift_right_2_r;
        shift_right_8_r  = {shift_right_fill_r[31:24], shift_right_4_r[31:8]};
        shift_right_8_r  = shift_right_4_r;
        result_r  = {shift_right_fill_r[31:16], shift_right_8_r[31:16]};
        result_r  = shift_right_8_r;
      end
      `ALU_ADD: begin
        result_r  = ((alu_a_i + alu_b_i));
      end
      `ALU_SUB: begin
        result_r  = sub_res_w;
      end
      `ALU_AND: begin
        result_r  = ((alu_a_i & alu_b_i));
      end
      `ALU_OR: begin
        result_r  = ((alu_a_i | alu_b_i));
      end
      `ALU_XOR: begin
        result_r  = ((alu_a_i ^ alu_b_i));
      end
      `ALU_LESS_THAN: begin
        result_r  = (((alu_a_i < alu_b_i)) ? 32'h1 : 32'h0);
      end
      `ALU_LESS_THAN_SIGNED: begin
        result_r  = (alu_a_i[31] ? 32'h1 : 32'h0);
        result_r  = (sub_res_w[31] ? 32'h1 : 32'h0);
      end
      default: begin
        result_r  = alu_a_i;
      end
    endcase
  end

  assign alu_p_o = result_r;

  begin if (
  );
  begin if (
  );
  begin if (
  );
endmodule

module riscv_core
#(
  parameter int SUPPORT_MULDIV = 1,
  parameter int SUPPORT_SUPER = 0,
  parameter int SUPPORT_MMU = 0,
  parameter int SUPPORT_LOAD_BYPASS = 1,
  parameter int SUPPORT_MUL_BYPASS = 1,
  parameter int SUPPORT_REGFILE_XILINX = 0,
  parameter int EXTRA_DECODE_STAGE = 0,
  parameter int MEM_CACHE_ADDR_MIN = 32'h80000000,
  parameter int MEM_CACHE_ADDR_MAX = 32'h8fffffff
)
(
  input wire clk_i,
  input wire rst_i,
  input wire mem_d_accept_i,
  input wire mem_d_ack_i,
  input wire mem_d_error_i,
  input wire mem_i_accept_i,
  input wire mem_i_valid_i,
  input wire mem_i_error_i,
  input wire intr_i,
  output wire mem_d_rd_o,
  output wire mem_d_cacheable_o,
  output wire mem_d_invalidate_o,
  output wire mem_d_writeback_o,
  output wire mem_d_flush_o,
  output wire mem_i_rd_o,
  output wire mem_i_flush_o,
  output wire mem_i_invalidate_o
);

  wire  mmu_lsu_writeback_w;
  wire  mmu_flush_w;
  wire  fetch_accept_w;
  wire  csr_opcode_valid_w;
  wire  branch_csr_request_w;
  wire  mmu_lsu_error_w;
  wire  mul_opcode_valid_w;
  wire  mmu_mxr_w;
  wire  mmu_ifetch_valid_w;
  wire  csr_opcode_invalid_w;
  wire  fetch_instr_mul_w;
  wire  branch_exec_is_ret_w;
  wire  fetch_in_fault_w;
  wire  branch_request_w;
  wire  writeback_mem_valid_w;
  wire  fetch_fault_page_w;
  wire  squash_decode_w;
  wire  fetch_dec_fault_page_w;
  wire  exec_hold_w;
  wire  fetch_instr_invalid_w;
  wire  lsu_stall_w;
  wire  branch_exec_is_not_taken_w;
  wire  branch_d_exec_request_w;
  wire  branch_exec_is_taken_w;
  wire  fetch_dec_fault_fetch_w;
  wire  fetch_dec_valid_w;
  wire  fetch_fault_fetch_w;
  wire  lsu_opcode_invalid_w;
  wire  mul_hold_w;
  wire  mmu_ifetch_accept_w;
  wire  mmu_lsu_ack_w;
  wire  mmu_ifetch_invalidate_w;
  wire  branch_exec_request_w;
  wire  div_opcode_valid_w;
  wire  mmu_lsu_rd_w;
  wire  interrupt_inhibit_w;
  wire  mmu_ifetch_error_w;
  wire  fetch_instr_lsu_w;
  wire  writeback_div_valid_w;
  wire  opcode_invalid_w;
  wire  fetch_instr_branch_w;
  wire  mmu_ifetch_rd_w;
  wire  mmu_ifetch_flush_w;
  wire  mmu_load_fault_w;
  wire  mmu_lsu_invalidate_w;
  wire  fetch_dec_accept_w;
  wire  ifence_w;
  wire  fetch_instr_exec_w;
  wire  csr_writeback_write_w;
  wire  take_interrupt_w;
  wire  fetch_valid_w;
  wire  branch_exec_is_jmp_w;
  wire  mmu_lsu_cacheable_w;
  wire  fetch_instr_csr_w;
  wire  lsu_opcode_valid_w;
  wire  csr_result_e1_write_w;
  wire  fetch_instr_div_w;
  wire  mul_opcode_invalid_w;
  wire  fetch_instr_rd_valid_w;
  wire  exec_opcode_valid_w;
  wire  mmu_lsu_flush_w;
  wire  mmu_lsu_accept_w;
  wire  mmu_sum_w;
  wire  mmu_store_fault_w;
  wire  branch_exec_is_call_w;

  riscv_exec u_exec (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .opcode_valid_i(exec_opcode_valid_w),
    .opcode_opcode_i(opcode_opcode_w),
    .opcode_pc_i(opcode_pc_w),
    .opcode_invalid_i(opcode_invalid_w),
    .opcode_rd_idx_i(opcode_rd_idx_w),
    .opcode_ra_idx_i(opcode_ra_idx_w),
    .opcode_rb_idx_i(opcode_rb_idx_w),
    .opcode_ra_operand_i(opcode_ra_operand_w),
    .opcode_rb_operand_i(opcode_rb_operand_w),
    .hold_i(exec_hold_w),
    .branch_request_o(branch_exec_request_w),
    .branch_is_taken_o(branch_exec_is_taken_w),
    .branch_is_not_taken_o(branch_exec_is_not_taken_w),
    .branch_source_o(branch_exec_source_w),
    .branch_is_call_o(branch_exec_is_call_w),
    .branch_is_ret_o(branch_exec_is_ret_w),
    .branch_is_jmp_o(branch_exec_is_jmp_w),
    .branch_pc_o(branch_exec_pc_w),
    .branch_d_request_o(branch_d_exec_request_w),
    .branch_d_pc_o(branch_d_exec_pc_w),
    .branch_d_priv_o(branch_d_exec_priv_w),
    .writeback_value_o(writeback_exec_value_w)
  );
  riscv_decode #(
    .EXTRA_DECODE_STAGE(EXTRA_DECODE_STAGE),
    .SUPPORT_MULDIV(SUPPORT_MULDIV)
  ) u_decode (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .fetch_in_valid_i(fetch_dec_valid_w),
    .fetch_in_instr_i(fetch_dec_instr_w),
    .fetch_in_pc_i(fetch_dec_pc_w),
    .fetch_in_fault_fetch_i(fetch_dec_fault_fetch_w),
    .fetch_in_fault_page_i(fetch_dec_fault_page_w),
    .fetch_out_accept_i(fetch_accept_w),
    .squash_decode_i(squash_decode_w),
    .fetch_in_accept_o(fetch_dec_accept_w),
    .fetch_out_valid_o(fetch_valid_w),
    .fetch_out_instr_o(fetch_instr_w),
    .fetch_out_pc_o(fetch_pc_w),
    .fetch_out_fault_fetch_o(fetch_fault_fetch_w),
    .fetch_out_fault_page_o(fetch_fault_page_w),
    .fetch_out_instr_exec_o(fetch_instr_exec_w),
    .fetch_out_instr_lsu_o(fetch_instr_lsu_w),
    .fetch_out_instr_branch_o(fetch_instr_branch_w),
    .fetch_out_instr_mul_o(fetch_instr_mul_w),
    .fetch_out_instr_div_o(fetch_instr_div_w),
    .fetch_out_instr_csr_o(fetch_instr_csr_w),
    .fetch_out_instr_rd_valid_o(fetch_instr_rd_valid_w),
    .fetch_out_instr_invalid_o(fetch_instr_invalid_w)
  );
  riscv_mmu #(
    .MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX),
    .SUPPORT_MMU(SUPPORT_MMU),
    .MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
  ) u_mmu (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .priv_d_i(mmu_priv_d_w),
    .sum_i(mmu_sum_w),
    .mxr_i(mmu_mxr_w),
    .flush_i(mmu_flush_w),
    .satp_i(mmu_satp_w),
    .fetch_in_rd_i(mmu_ifetch_rd_w),
    .fetch_in_flush_i(mmu_ifetch_flush_w),
    .fetch_in_invalidate_i(mmu_ifetch_invalidate_w),
    .fetch_in_pc_i(mmu_ifetch_pc_w),
    .fetch_in_priv_i(fetch_in_priv_w),
    .fetch_out_accept_i(mem_i_accept_i),
    .fetch_out_valid_i(mem_i_valid_i),
    .fetch_out_error_i(mem_i_error_i),
    .fetch_out_inst_i(mem_i_inst_i),
    .lsu_in_addr_i(mmu_lsu_addr_w),
    .lsu_in_data_wr_i(mmu_lsu_data_wr_w),
    .lsu_in_rd_i(mmu_lsu_rd_w),
    .lsu_in_wr_i(mmu_lsu_wr_w),
    .lsu_in_cacheable_i(mmu_lsu_cacheable_w),
    .lsu_in_req_tag_i(mmu_lsu_req_tag_w),
    .lsu_in_invalidate_i(mmu_lsu_invalidate_w),
    .lsu_in_writeback_i(mmu_lsu_writeback_w),
    .lsu_in_flush_i(mmu_lsu_flush_w),
    .lsu_out_data_rd_i(mem_d_data_rd_i),
    .lsu_out_accept_i(mem_d_accept_i),
    .lsu_out_ack_i(mem_d_ack_i),
    .lsu_out_error_i(mem_d_error_i),
    .lsu_out_resp_tag_i(mem_d_resp_tag_i),
    .fetch_in_accept_o(mmu_ifetch_accept_w),
    .fetch_in_valid_o(mmu_ifetch_valid_w),
    .fetch_in_error_o(mmu_ifetch_error_w),
    .fetch_in_inst_o(mmu_ifetch_inst_w),
    .fetch_out_rd_o(mem_i_rd_o),
    .fetch_out_flush_o(mem_i_flush_o),
    .fetch_out_invalidate_o(mem_i_invalidate_o),
    .fetch_out_pc_o(mem_i_pc_o),
    .fetch_in_fault_o(fetch_in_fault_w),
    .lsu_in_data_rd_o(mmu_lsu_data_rd_w),
    .lsu_in_accept_o(mmu_lsu_accept_w),
    .lsu_in_ack_o(mmu_lsu_ack_w),
    .lsu_in_error_o(mmu_lsu_error_w),
    .lsu_in_resp_tag_o(mmu_lsu_resp_tag_w),
    .lsu_out_addr_o(mem_d_addr_o),
    .lsu_out_data_wr_o(mem_d_data_wr_o),
    .lsu_out_rd_o(mem_d_rd_o),
    .lsu_out_wr_o(mem_d_wr_o),
    .lsu_out_cacheable_o(mem_d_cacheable_o),
    .lsu_out_req_tag_o(mem_d_req_tag_o),
    .lsu_out_invalidate_o(mem_d_invalidate_o),
    .lsu_out_writeback_o(mem_d_writeback_o),
    .lsu_out_flush_o(mem_d_flush_o),
    .lsu_in_load_fault_o(mmu_load_fault_w),
    .lsu_in_store_fault_o(mmu_store_fault_w)
  );
  riscv_lsu #(
    .MEM_CACHE_ADDR_MAX(MEM_CACHE_ADDR_MAX),
    .MEM_CACHE_ADDR_MIN(MEM_CACHE_ADDR_MIN)
  ) u_lsu (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .opcode_valid_i(lsu_opcode_valid_w),
    .opcode_opcode_i(lsu_opcode_opcode_w),
    .opcode_pc_i(lsu_opcode_pc_w),
    .opcode_invalid_i(lsu_opcode_invalid_w),
    .opcode_rd_idx_i(lsu_opcode_rd_idx_w),
    .opcode_ra_idx_i(lsu_opcode_ra_idx_w),
    .opcode_rb_idx_i(lsu_opcode_rb_idx_w),
    .opcode_ra_operand_i(lsu_opcode_ra_operand_w),
    .opcode_rb_operand_i(lsu_opcode_rb_operand_w),
    .mem_data_rd_i(mmu_lsu_data_rd_w),
    .mem_accept_i(mmu_lsu_accept_w),
    .mem_ack_i(mmu_lsu_ack_w),
    .mem_error_i(mmu_lsu_error_w),
    .mem_resp_tag_i(mmu_lsu_resp_tag_w),
    .mem_load_fault_i(mmu_load_fault_w),
    .mem_store_fault_i(mmu_store_fault_w),
    .mem_addr_o(mmu_lsu_addr_w),
    .mem_data_wr_o(mmu_lsu_data_wr_w),
    .mem_rd_o(mmu_lsu_rd_w),
    .mem_wr_o(mmu_lsu_wr_w),
    .mem_cacheable_o(mmu_lsu_cacheable_w),
    .mem_req_tag_o(mmu_lsu_req_tag_w),
    .mem_invalidate_o(mmu_lsu_invalidate_w),
    .mem_writeback_o(mmu_lsu_writeback_w),
    .mem_flush_o(mmu_lsu_flush_w),
    .writeback_valid_o(writeback_mem_valid_w),
    .writeback_value_o(writeback_mem_value_w),
    .writeback_exception_o(writeback_mem_exception_w),
    .stall_o(lsu_stall_w)
  );
  riscv_csr #(
    .SUPPORT_SUPER(SUPPORT_SUPER),
    .SUPPORT_MULDIV(SUPPORT_MULDIV)
  ) u_csr (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .intr_i(intr_i),
    .opcode_valid_i(csr_opcode_valid_w),
    .opcode_opcode_i(csr_opcode_opcode_w),
    .opcode_pc_i(csr_opcode_pc_w),
    .opcode_invalid_i(csr_opcode_invalid_w),
    .opcode_rd_idx_i(csr_opcode_rd_idx_w),
    .opcode_ra_idx_i(csr_opcode_ra_idx_w),
    .opcode_rb_idx_i(csr_opcode_rb_idx_w),
    .opcode_ra_operand_i(csr_opcode_ra_operand_w),
    .opcode_rb_operand_i(csr_opcode_rb_operand_w),
    .csr_writeback_write_i(csr_writeback_write_w),
    .csr_writeback_waddr_i(csr_writeback_waddr_w),
    .csr_writeback_wdata_i(csr_writeback_wdata_w),
    .csr_writeback_exception_i(csr_writeback_exception_w),
    .csr_writeback_exception_pc_i(csr_writeback_exception_pc_w),
    .csr_writeback_exception_addr_i(csr_writeback_exception_addr_w),
    .cpu_id_i(cpu_id_i),
    .reset_vector_i(reset_vector_i),
    .interrupt_inhibit_i(interrupt_inhibit_w),
    .csr_result_e1_value_o(csr_result_e1_value_w),
    .csr_result_e1_write_o(csr_result_e1_write_w),
    .csr_result_e1_wdata_o(csr_result_e1_wdata_w),
    .csr_result_e1_exception_o(csr_result_e1_exception_w),
    .branch_csr_request_o(branch_csr_request_w),
    .branch_csr_pc_o(branch_csr_pc_w),
    .branch_csr_priv_o(branch_csr_priv_w),
    .take_interrupt_o(take_interrupt_w),
    .ifence_o(ifence_w),
    .mmu_priv_d_o(mmu_priv_d_w),
    .mmu_sum_o(mmu_sum_w),
    .mmu_mxr_o(mmu_mxr_w),
    .mmu_flush_o(mmu_flush_w),
    .mmu_satp_o(mmu_satp_w)
  );
  riscv_multiplier u_mul (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .opcode_valid_i(mul_opcode_valid_w),
    .opcode_opcode_i(mul_opcode_opcode_w),
    .opcode_pc_i(mul_opcode_pc_w),
    .opcode_invalid_i(mul_opcode_invalid_w),
    .opcode_rd_idx_i(mul_opcode_rd_idx_w),
    .opcode_ra_idx_i(mul_opcode_ra_idx_w),
    .opcode_rb_idx_i(mul_opcode_rb_idx_w),
    .opcode_ra_operand_i(mul_opcode_ra_operand_w),
    .opcode_rb_operand_i(mul_opcode_rb_operand_w),
    .hold_i(mul_hold_w),
    .writeback_value_o(writeback_mul_value_w)
  );
  riscv_divider u_div (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .opcode_valid_i(div_opcode_valid_w),
    .opcode_opcode_i(opcode_opcode_w),
    .opcode_pc_i(opcode_pc_w),
    .opcode_invalid_i(opcode_invalid_w),
    .opcode_rd_idx_i(opcode_rd_idx_w),
    .opcode_ra_idx_i(opcode_ra_idx_w),
    .opcode_rb_idx_i(opcode_rb_idx_w),
    .opcode_ra_operand_i(opcode_ra_operand_w),
    .opcode_rb_operand_i(opcode_rb_operand_w),
    .writeback_valid_o(writeback_div_valid_w),
    .writeback_value_o(writeback_div_value_w)
  );
  riscv_issue #(
    .SUPPORT_REGFILE_XILINX(SUPPORT_REGFILE_XILINX),
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MULDIV(SUPPORT_MULDIV),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS),
    .SUPPORT_DUAL_ISSUE(1)
  ) u_issue (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .fetch_valid_i(fetch_valid_w),
    .fetch_instr_i(fetch_instr_w),
    .fetch_pc_i(fetch_pc_w),
    .fetch_fault_fetch_i(fetch_fault_fetch_w),
    .fetch_fault_page_i(fetch_fault_page_w),
    .fetch_instr_exec_i(fetch_instr_exec_w),
    .fetch_instr_lsu_i(fetch_instr_lsu_w),
    .fetch_instr_branch_i(fetch_instr_branch_w),
    .fetch_instr_mul_i(fetch_instr_mul_w),
    .fetch_instr_div_i(fetch_instr_div_w),
    .fetch_instr_csr_i(fetch_instr_csr_w),
    .fetch_instr_rd_valid_i(fetch_instr_rd_valid_w),
    .fetch_instr_invalid_i(fetch_instr_invalid_w),
    .branch_exec_request_i(branch_exec_request_w),
    .branch_exec_is_taken_i(branch_exec_is_taken_w),
    .branch_exec_is_not_taken_i(branch_exec_is_not_taken_w),
    .branch_exec_source_i(branch_exec_source_w),
    .branch_exec_is_call_i(branch_exec_is_call_w),
    .branch_exec_is_ret_i(branch_exec_is_ret_w),
    .branch_exec_is_jmp_i(branch_exec_is_jmp_w),
    .branch_exec_pc_i(branch_exec_pc_w),
    .branch_d_exec_request_i(branch_d_exec_request_w),
    .branch_d_exec_pc_i(branch_d_exec_pc_w),
    .branch_d_exec_priv_i(branch_d_exec_priv_w),
    .branch_csr_request_i(branch_csr_request_w),
    .branch_csr_pc_i(branch_csr_pc_w),
    .branch_csr_priv_i(branch_csr_priv_w),
    .writeback_exec_value_i(writeback_exec_value_w),
    .writeback_mem_valid_i(writeback_mem_valid_w),
    .writeback_mem_value_i(writeback_mem_value_w),
    .writeback_mem_exception_i(writeback_mem_exception_w),
    .writeback_mul_value_i(writeback_mul_value_w),
    .writeback_div_valid_i(writeback_div_valid_w),
    .writeback_div_value_i(writeback_div_value_w),
    .csr_result_e1_value_i(csr_result_e1_value_w),
    .csr_result_e1_write_i(csr_result_e1_write_w),
    .csr_result_e1_wdata_i(csr_result_e1_wdata_w),
    .csr_result_e1_exception_i(csr_result_e1_exception_w),
    .lsu_stall_i(lsu_stall_w),
    .take_interrupt_i(take_interrupt_w),
    .fetch_accept_o(fetch_accept_w),
    .branch_request_o(branch_request_w),
    .branch_pc_o(branch_pc_w),
    .branch_priv_o(branch_priv_w),
    .exec_opcode_valid_o(exec_opcode_valid_w),
    .lsu_opcode_valid_o(lsu_opcode_valid_w),
    .csr_opcode_valid_o(csr_opcode_valid_w),
    .mul_opcode_valid_o(mul_opcode_valid_w),
    .div_opcode_valid_o(div_opcode_valid_w),
    .opcode_opcode_o(opcode_opcode_w),
    .opcode_pc_o(opcode_pc_w),
    .opcode_invalid_o(opcode_invalid_w),
    .opcode_rd_idx_o(opcode_rd_idx_w),
    .opcode_ra_idx_o(opcode_ra_idx_w),
    .opcode_rb_idx_o(opcode_rb_idx_w),
    .opcode_ra_operand_o(opcode_ra_operand_w),
    .opcode_rb_operand_o(opcode_rb_operand_w),
    .lsu_opcode_opcode_o(lsu_opcode_opcode_w),
    .lsu_opcode_pc_o(lsu_opcode_pc_w),
    .lsu_opcode_invalid_o(lsu_opcode_invalid_w),
    .lsu_opcode_rd_idx_o(lsu_opcode_rd_idx_w),
    .lsu_opcode_ra_idx_o(lsu_opcode_ra_idx_w),
    .lsu_opcode_rb_idx_o(lsu_opcode_rb_idx_w),
    .lsu_opcode_ra_operand_o(lsu_opcode_ra_operand_w),
    .lsu_opcode_rb_operand_o(lsu_opcode_rb_operand_w),
    .mul_opcode_opcode_o(mul_opcode_opcode_w),
    .mul_opcode_pc_o(mul_opcode_pc_w),
    .mul_opcode_invalid_o(mul_opcode_invalid_w),
    .mul_opcode_rd_idx_o(mul_opcode_rd_idx_w),
    .mul_opcode_ra_idx_o(mul_opcode_ra_idx_w),
    .mul_opcode_rb_idx_o(mul_opcode_rb_idx_w),
    .mul_opcode_ra_operand_o(mul_opcode_ra_operand_w),
    .mul_opcode_rb_operand_o(mul_opcode_rb_operand_w),
    .csr_opcode_opcode_o(csr_opcode_opcode_w),
    .csr_opcode_pc_o(csr_opcode_pc_w),
    .csr_opcode_invalid_o(csr_opcode_invalid_w),
    .csr_opcode_rd_idx_o(csr_opcode_rd_idx_w),
    .csr_opcode_ra_idx_o(csr_opcode_ra_idx_w),
    .csr_opcode_rb_idx_o(csr_opcode_rb_idx_w),
    .csr_opcode_ra_operand_o(csr_opcode_ra_operand_w),
    .csr_opcode_rb_operand_o(csr_opcode_rb_operand_w),
    .csr_writeback_write_o(csr_writeback_write_w),
    .csr_writeback_waddr_o(csr_writeback_waddr_w),
    .csr_writeback_wdata_o(csr_writeback_wdata_w),
    .csr_writeback_exception_o(csr_writeback_exception_w),
    .csr_writeback_exception_pc_o(csr_writeback_exception_pc_w),
    .csr_writeback_exception_addr_o(csr_writeback_exception_addr_w),
    .exec_hold_o(exec_hold_w),
    .mul_hold_o(mul_hold_w),
    .interrupt_inhibit_o(interrupt_inhibit_w)
  );
  riscv_fetch #(
    .SUPPORT_MMU(SUPPORT_MMU)
  ) u_fetch (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .fetch_accept_i(fetch_dec_accept_w),
    .icache_accept_i(mmu_ifetch_accept_w),
    .icache_valid_i(mmu_ifetch_valid_w),
    .icache_error_i(mmu_ifetch_error_w),
    .icache_inst_i(mmu_ifetch_inst_w),
    .icache_page_fault_i(fetch_in_fault_w),
    .fetch_invalidate_i(ifence_w),
    .branch_request_i(branch_request_w),
    .branch_pc_i(branch_pc_w),
    .branch_priv_i(branch_priv_w),
    .fetch_valid_o(fetch_dec_valid_w),
    .fetch_instr_o(fetch_dec_instr_w),
    .fetch_pc_o(fetch_dec_pc_w),
    .fetch_fault_fetch_o(fetch_dec_fault_fetch_w),
    .fetch_fault_page_o(fetch_dec_fault_page_w),
    .icache_rd_o(mmu_ifetch_rd_w),
    .icache_flush_o(mmu_ifetch_flush_w),
    .icache_invalidate_o(mmu_ifetch_invalidate_w),
    .icache_pc_o(mmu_ifetch_pc_w),
    .icache_priv_o(fetch_in_priv_w),
    .squash_decode_o(squash_decode_w)
  );
endmodule

module riscv_csr
#(
  parameter int SUPPORT_MULDIV = 1,
  parameter int SUPPORT_SUPER = 1
)
(
  input wire clk_i,
  input wire rst_i,
  input wire intr_i,
  input wire opcode_valid_i,
  input wire opcode_invalid_i,
  input wire csr_writeback_write_i,
  input wire interrupt_inhibit_i,
  output wire csr_result_e1_write_o,
  output wire branch_csr_request_o,
  output wire take_interrupt_o,
  output wire ifence_o,
  output wire mmu_sum_o,
  output wire mmu_mxr_o,
  output wire mmu_flush_o
);

  wire  ecall_w = opcode_valid_i && ((opcode_opcode_i & `INST_ECALL_MASK)      == `INST_ECALL);
  wire  ebreak_w = opcode_valid_i && ((opcode_opcode_i & `INST_EBREAK_MASK)     == `INST_EBREAK);
  wire  eret_w = opcode_valid_i && ((opcode_opcode_i & `INST_ERET_MASK)       == `INST_ERET);
  wire  [1:0] eret_priv_w = opcode_opcode_i[29:28];
  wire  csrrw_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRW_MASK)      == `INST_CSRRW);
  wire  csrrs_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRS_MASK)      == `INST_CSRRS);
  wire  csrrc_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRC_MASK)      == `INST_CSRRC);
  wire  csrrwi_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRWI_MASK)     == `INST_CSRRWI);
  wire  csrrsi_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRSI_MASK)     == `INST_CSRRSI);
  wire  csrrci_w = opcode_valid_i && ((opcode_opcode_i & `INST_CSRRCI_MASK)     == `INST_CSRRCI);
  wire  wfi_w = opcode_valid_i && ((opcode_opcode_i & `INST_WFI_MASK)        == `INST_WFI);
  wire  fence_w = opcode_valid_i && ((opcode_opcode_i & `INST_FENCE_MASK)      == `INST_FENCE);
  wire  sfence_w = opcode_valid_i && ((opcode_opcode_i & `INST_SFENCE_MASK)     == `INST_SFENCE);
  wire  ifence_w = opcode_valid_i && ((opcode_opcode_i & `INST_IFENCE_MASK)     == `INST_IFENCE);
  wire  [1:0] current_priv_w;
  reg  [1:0] csr_priv_r;
  reg  csr_readonly_r;
  reg  csr_write_r;
  reg  set_r;
  reg  clr_r;
  reg  csr_fault_r;
  reg  [31:0] data_r;
  wire  satp_update_w = (opcode_valid_i && (set_r || clr_r) && csr_write_r && (opcode_opcode_i[31:20] == `CSR_SATP));
  wire  timer_irq_w = 1'b0;
  wire  [31:0] misa_w = SUPPORT_MULDIV ? (`MISA_RV32 | `MISA_RVI | `MISA_RVM): (`MISA_RV32 | `MISA_RVI);
  wire  [31:0] csr_rdata_w;
  wire  csr_branch_w;
  wire  [31:0] csr_target_w;
  wire  [31:0] interrupt_w;
  wire  [31:0] status_reg_w;
  wire  [31:0] satp_reg_w;
  reg  rd_valid_e1_q;
  wire  eret_fault_w = eret_w && (current_priv_w < eret_priv_w);
  reg  take_interrupt_q;
  reg  tlb_flush_q;
  reg  ifence_q;
  reg  branch_q;
  reg  [31:0] branch_target_q;
  reg  reset_q;

  always begin
    set_r  = (csrrw_w | (csrrs_w | (csrrwi_w | csrrsi_w)));
    clr_r  = (csrrw_w | (csrrc_w | (csrrwi_w | csrrci_w)));
    csr_priv_r  = opcode_opcode_i[29:28];
    csr_readonly_r  = ((opcode_opcode_i[31:30] == 2'd3));
    csr_write_r  = ((opcode_ra_idx_i != 5'b0) | csrrw_w | csrrwi_w);
    data_r  = (((csrrwi_w | (csrrsi_w | csrrci_w))) ? {27'b0, opcode_ra_idx_i} : opcode_ra_operand_i);
    csr_fault_r  = (SUPPORT_SUPER ? ((opcode_valid_i && (((set_r | clr_r)) && (((csr_write_r && (csr_readonly_r) || ((current_priv_w < csr_priv_r)))))))) : 1'b0);
  end
  always @(posedge clk_i or posedge rst_i) begin
    rd_valid_e1_q  <= 1'b0;
    rd_result_e1_q  <= 32'b0;
    csr_wdata_e1_q  <= 32'b0;
    exception_e1_q  <= `EXCEPTION_W'b0;
  end
  always @(posedge clk_i or posedge rst_i) begin
    branch_target_q  <= 32'b0;
    branch_q  <= 1'b0;
    reset_q  <= 1'b1;
  end

  assign csr_result_e1_value_o = rd_result_e1_q;
  assign csr_result_e1_write_o = rd_valid_e1_q;
  assign csr_result_e1_wdata_o = csr_wdata_e1_q;
  assign csr_result_e1_exception_o = exception_e1_q;
  assign take_interrupt_o = take_interrupt_q;
  assign ifence_o = ifence_q;
  assign branch_csr_request_o = branch_q;
  assign branch_csr_pc_o = branch_target_q;
  assign branch_csr_priv_o = (satp_reg_w[`SATP_MODE_R] ? current_priv_w : `PRIV_MACHINE);
  assign mmu_priv_d_o = (status_reg_w[`SR_MPRV_R] ? status_reg_w[`SR_MPP_R] : current_priv_w);
  assign mmu_satp_o = satp_reg_w;
  assign mmu_flush_o = tlb_flush_q;
  assign mmu_sum_o = status_reg_w[`SR_SUM_R];
  assign mmu_mxr_o = status_reg_w[`SR_MXR_R];

  riscv_csr_regfile #(
    .SUPPORT_MTIMECMP(1),
    .SUPPORT_SUPER(SUPPORT_SUPER)
  ) u_csrfile (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .ext_intr_i(intr_i),
    .timer_intr_i(timer_irq_w),
    .cpu_id_i(cpu_id_i),
    .misa_i(misa_w),
    .csr_ren_i(opcode_valid_i),
    .csr_raddr_i(opcode_opcode_i[31:20]),
    .csr_rdata_o(csr_rdata_w),
    .exception_i(csr_writeback_exception_i),
    .exception_pc_i(csr_writeback_exception_pc_i),
    .exception_addr_i(csr_writeback_exception_addr_i),
    .csr_waddr_i((csr_writeback_write_i ? csr_writeback_waddr_i : 12'b0)),
    .csr_wdata_i(csr_writeback_wdata_i),
    .csr_branch_o(csr_branch_w),
    .csr_target_o(csr_target_w),
    .priv_o(current_priv_w),
    .status_o(status_reg_w),
    .satp_o(satp_reg_w),
    .interrupt_o(interrupt_w)
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
endmodule

module riscv_csr_regfile
#(
  parameter int SUPPORT_MTIMECMP = 1,
  parameter int SUPPORT_SUPER = 0
)
(
  input wire clk_i,
  input wire rst_i,
  input wire ext_intr_i,
  input wire timer_intr_i,
  input wire [31:0] cpu_id_i,
  input wire [31:0] misa_i,
  input wire [5:0] exception_i,
  input wire [31:0] exception_pc_i,
  input wire [31:0] exception_addr_i,
  input wire csr_ren_i,
  input wire [11:0] csr_raddr_i,
  output wire [31:0] csr_rdata_o,
  input wire [11:0] csr_waddr_i,
  input wire [31:0] csr_wdata_i,
  output wire csr_branch_o,
  output wire [31:0] csr_target_o,
  output wire [1:0] priv_o,
  output wire [31:0] status_o,
  output wire [31:0] satp_o,
  output wire [31:0] interrupt_o
);

  reg  [31:0] csr_mepc_q;
  reg  [31:0] csr_mcause_q;
  reg  [31:0] csr_sr_q;
  reg  [31:0] csr_mtvec_q;
  reg  [31:0] csr_mip_q;
  reg  [31:0] csr_mie_q;
  reg  [1:0] csr_mpriv_q;
  reg  [31:0] csr_mcycle_q;
  reg  [31:0] csr_mcycle_h_q;
  reg  [31:0] csr_mscratch_q;
  reg  [31:0] csr_mtval_q;
  reg  [31:0] csr_mtimecmp_q;
  reg  csr_mtime_ie_q;
  reg  [31:0] csr_medeleg_q;
  reg  [31:0] csr_mideleg_q;
  reg  [31:0] csr_sepc_q;
  reg  [31:0] csr_stvec_q;
  reg  [31:0] csr_scause_q;
  reg  [31:0] csr_stval_q;
  reg  [31:0] csr_satp_q;
  reg  [31:0] csr_sscratch_q;
  reg  [31:0] irq_pending_r;
  reg  [31:0] irq_masked_r;
  reg  [1:0] irq_priv_r;
  reg  m_enabled_r;
  reg  [31:0] m_interrupts_r;
  reg  s_enabled_r;
  reg  [31:0] s_interrupts_r;
  reg  [1:0] irq_priv_q;
  reg  csr_mip_upd_q;
  wire  buffer_mip_w = (csr_ren_i && csr_raddr_i == `CSR_MIP) | (csr_ren_i && csr_raddr_i == `CSR_SIP) | csr_mip_upd_q;
  reg  [31:0] rdata_r;
  reg  [31:0] csr_mepc_r;
  reg  [31:0] csr_mcause_r;
  reg  [31:0] csr_mtval_r;
  reg  [31:0] csr_sr_r;
  reg  [31:0] csr_mtvec_r;
  reg  [31:0] csr_mip_r;
  reg  [31:0] csr_mie_r;
  reg  [1:0] csr_mpriv_r;
  reg  [31:0] csr_mcycle_r;
  reg  [31:0] csr_mscratch_r;
  reg  [31:0] csr_mtimecmp_r;
  reg  csr_mtime_ie_r;
  reg  [31:0] csr_medeleg_r;
  reg  [31:0] csr_mideleg_r;
  reg  [31:0] csr_mip_next_q;
  reg  [31:0] csr_mip_next_r;
  reg  [31:0] csr_sepc_r;
  reg  [31:0] csr_stvec_r;
  reg  [31:0] csr_scause_r;
  reg  [31:0] csr_stval_r;
  reg  [31:0] csr_satp_r;
  reg  [31:0] csr_sscratch_r;
  wire  is_exception_w = ((exception_i & `EXCEPTION_TYPE_MASK) == `EXCEPTION_EXCEPTION);
  wire  exception_s_w = SUPPORT_SUPER ? ((csr_mpriv_q <= `PRIV_SUPER) & is_exception_w & csr_medeleg_q[{1'b0, exception_i[`EXCEPTION_SUBTYPE_R]}]) : 1'b0;
  reg  branch_r;
  reg  [31:0] branch_target_r;

  function [31:0] get_mcycle();
    get_mcycle  = csr_mcycle_q;
  endfunction

  always begin
    if (SUPPORT_SUPER) begin
      irq_pending_r  = ((csr_mip_q & csr_mie_q));
      m_enabled_r  = ((((csr_mpriv_q < `PRIV_MACHINE)) || (csr_mpriv_q) == (`PRIV_MACHINE && csr_sr_q[`SR_MIE_R])));
      s_enabled_r  = ((((csr_mpriv_q < `PRIV_SUPER)) || (csr_mpriv_q) == (`PRIV_SUPER && csr_sr_q[`SR_SIE_R])));
      m_interrupts_r  = (m_enabled_r ? ((irq_pending_r & <unknown_op:~>) : 32'b0);
      s_interrupts_r  = (s_enabled_r ? ((irq_pending_r & csr_mideleg_q)) : 32'b0);
      irq_masked_r  = ((( | m_interrupts_r)) ? m_interrupts_r : s_interrupts_r);
      irq_priv_r  = ((( | m_interrupts_r)) ? `PRIV_MACHINE : `PRIV_SUPER);
    end else begin
      irq_pending_r  = ((csr_mip_q & csr_mie_q));
      irq_masked_r  = (csr_sr_q[`SR_MIE_R] ? irq_pending_r : 32'b0);
      irq_priv_r  = `PRIV_MACHINE;
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    rdata_r  = 32'b0;
  end
  always begin
    csr_mip_next_r  = csr_mip_next_q;
    csr_mepc_r  = csr_mepc_q;
    csr_sr_r  = csr_sr_q;
    csr_mcause_r  = csr_mcause_q;
    csr_mtval_r  = csr_mtval_q;
    csr_mtvec_r  = csr_mtvec_q;
    csr_mip_r  = csr_mip_q;
    csr_mie_r  = csr_mie_q;
    csr_mpriv_r  = csr_mpriv_q;
    csr_mscratch_r  = csr_mscratch_q;
    csr_mcycle_r  = (csr_mcycle_q + 32'd1);
    csr_mtimecmp_r  = csr_mtimecmp_q;
    csr_mtime_ie_r  = csr_mtime_ie_q;
    csr_medeleg_r  = csr_medeleg_q;
    csr_mideleg_r  = csr_mideleg_q;
    csr_sepc_r  = csr_sepc_q;
    csr_stvec_r  = csr_stvec_q;
    csr_scause_r  = csr_scause_q;
    csr_stval_r  = csr_stval_q;
    csr_satp_r  = csr_satp_q;
    csr_sscratch_r  = csr_sscratch_q;
    if ((((exception_i & `EXCEPTION_TYPE_MASK)) == `EXCEPTION_INTERRUPT)) begin
      irq_priv_q  = = `PRIV_MACHINE)
        begin
            
            csr_sr_r[`SR_MPIE_R] = csr_sr_r[`SR_MIE_R];
      csr_mpriv_r  = `PRIV_MACHINE;
      csr_mepc_r  = exception_pc_i;
      csr_mtval_r  = 32'b0;
      csr_mcause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_M_SOFT);
      csr_mcause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_M_TIMER);
      csr_mcause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_M_EXT);
      csr_mpriv_q  = = `PRIV_SUPER);
      csr_mpriv_r  = `PRIV_SUPER;
      csr_sepc_r  = exception_pc_i;
      csr_stval_r  = 32'b0;
      csr_scause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_S_SOFT);
      csr_scause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_S_TIMER);
      csr_scause_r  = (`MCAUSE_INTERRUPT + 32'd`IRQ_S_EXT);
    end else begin
      exception_i[1:0]  = = `PRIV_MACHINE)
        begin
            
            csr_mpriv_r          = csr_sr_r[`SR_MPP_R];
      csr_mpriv_r  = (csr_sr_r[`SR_SPP_R] ? `PRIV_SUPER : `PRIV_USER);
    end
    if ((is_exception_w && exception_s_w)) begin
      csr_mpriv_q  = = `PRIV_SUPER);
      csr_mpriv_r  = `PRIV_SUPER;
      csr_sepc_r  = exception_pc_i;
      csr_stval_r  = exception_pc_i;
      csr_stval_r  = exception_addr_i;
      csr_stval_r  = 32'b0;
      csr_scause_r  = {28'b0, exception_i[3:0]};
    end else begin
      csr_mpriv_r  = `PRIV_MACHINE;
      csr_mepc_r  = exception_pc_i;
      csr_mtval_r  = exception_pc_i;
      csr_mtval_r  = exception_addr_i;
      csr_mtval_r  = 32'b0;
      csr_mcause_r  = {28'b0, exception_i[3:0]};
    end
    case (csr_waddr_i)
      (csr_mideleg_r  = csr_wdata_i & `CSR_MIDELEG_MASK;
        
        `CSR_MTIMECMP): begin
        csr_mtimecmp_r  = (csr_wdata_i & `CSR_MTIMECMP_MASK);
        csr_mtime_ie_r  = 1'b1;
      end
    endcase
    if ((ext_intr_i && csr_mideleg_q[`SR_IP_MEIP_R])) begin
      csr_mtime_ie_r  = 1'b0;
    end
    csr_mip_r  = (csr_mip_r | csr_mip_next_r);
  end
  always @(posedge clk_i or posedge rst_i) begin
    csr_mepc_q  <= 32'b0;
    csr_sr_q  <= 32'b0;
    csr_mcause_q  <= 32'b0;
    csr_mtval_q  <= 32'b0;
    csr_mtvec_q  <= 32'b0;
    csr_mip_q  <= 32'b0;
    csr_mie_q  <= 32'b0;
    csr_mpriv_q  <= `PRIV_MACHINE;
    csr_mcycle_q  <= 32'b0;
    csr_mcycle_h_q  <= 32'b0;
    csr_mscratch_q  <= 32'b0;
    csr_mtimecmp_q  <= 32'b0;
    csr_mtime_ie_q  <= 1'b0;
    csr_medeleg_q  <= 32'b0;
    csr_mideleg_q  <= 32'b0;
    csr_sepc_q  <= 32'b0;
    csr_stvec_q  <= 32'b0;
    csr_scause_q  <= 32'b0;
    csr_stval_q  <= 32'b0;
    csr_satp_q  <= 32'b0;
    csr_sscratch_q  <= 32'b0;
    csr_mip_next_q  <= 32'b0;
  end
  always begin
    branch_r  = 1'b0;
    branch_target_r  = 32'b0;
    if ((exception_i == `EXCEPTION_INTERRUPT)) begin
      branch_r  = 1'b1;
      branch_target_r  = (((irq_priv_q == `PRIV_MACHINE)) ? csr_mtvec_q : csr_stvec_q);
    end else begin
      exception_i[1:0]  = = `PRIV_MACHINE)
        begin    
            branch_r        = 1'b1;
      branch_target_r  = csr_mepc_q;
      branch_r  = 1'b1;
      branch_target_r  = csr_sepc_q;
    end
    if ((is_exception_w && exception_s_w)) begin
      branch_r  = 1'b1;
      branch_target_r  = csr_stvec_q;
    end else begin
      branch_r  = 1'b1;
      branch_target_r  = csr_mtvec_q;
    end
    if ((exception_i == `EXCEPTION_FENCE)) begin
      branch_r  = 1'b1;
      branch_target_r  = (exception_pc_i + 32'd4);
    end
  end

  assign interrupt_o = irq_masked_r;
  assign csr_rdata_o = rdata_r;
  assign priv_o = csr_mpriv_q;
  assign status_o = csr_sr_q;
  assign satp_o = csr_satp_q;
  assign csr_branch_o = branch_r;
  assign csr_target_o = branch_target_r;

  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  begin case (
  );
  end if (
  );
  begin if (
  );
  HAS_SIM_CTRL if (
  );
  begin case (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
endmodule

module riscv_decode
#(
  parameter int SUPPORT_MULDIV = 1,
  parameter int EXTRA_DECODE_STAGE = 0
)
(
  input wire clk_i,
  input wire rst_i,
  input wire fetch_in_valid_i,
  input wire fetch_in_fault_fetch_i,
  input wire fetch_in_fault_page_i,
  input wire fetch_out_accept_i,
  input wire squash_decode_i,
  output wire fetch_in_accept_o,
  output wire fetch_out_valid_o,
  output wire fetch_out_fault_fetch_o,
  output wire fetch_out_fault_page_o,
  output wire fetch_out_instr_exec_o,
  output wire fetch_out_instr_lsu_o,
  output wire fetch_out_instr_branch_o,
  output wire fetch_out_instr_mul_o,
  output wire fetch_out_instr_div_o,
  output wire fetch_out_instr_csr_o,
  output wire fetch_out_instr_rd_valid_o,
  output wire fetch_out_instr_invalid_o
);

  wire  enable_muldiv_w = SUPPORT_MULDIV;

  always @(posedge clk_i or posedge rst_i) begin
    fetch_in_instr_w  = (((fetch_in_fault_page_i | fetch_in_fault_fetch_i)) ? 32'b0 : fetch_in_instr_i);
    fetch_out_valid_o  = fetch_in_valid_i;
    fetch_out_pc_o  = fetch_in_pc_i;
    fetch_out_instr_o  = fetch_in_instr_w;
    fetch_out_fault_page_o  = fetch_in_fault_page_i;
    fetch_out_fault_fetch_o  = fetch_in_fault_fetch_i;
    fetch_in_accept_o  = fetch_out_accept_i;
  end

  assign fetch_in_accept_o = fetch_out_accept_i;
  assign fetch_out_valid_o = fetch_in_valid_i;
  assign fetch_out_pc_o = fetch_in_pc_i;
  assign fetch_out_instr_o = fetch_in_instr_w;
  assign fetch_out_fault_page_o = fetch_in_fault_page_i;
  assign fetch_out_fault_fetch_o = fetch_in_fault_fetch_i;
  assign fetch_in_accept_o = fetch_out_accept_i;

  else if (
  );
  else if (
  );
  riscv_decoder u_dec (
    .valid_i(fetch_out_valid_o),
    .fetch_fault_i((fetch_out_fault_page_o | fetch_out_fault_fetch_o)),
    .enable_muldiv_i(enable_muldiv_w),
    .opcode_i(fetch_out_instr_o),
    .invalid_o(fetch_out_instr_invalid_o),
    .exec_o(fetch_out_instr_exec_o),
    .lsu_o(fetch_out_instr_lsu_o),
    .branch_o(fetch_out_instr_branch_o),
    .mul_o(fetch_out_instr_mul_o),
    .div_o(fetch_out_instr_div_o),
    .csr_o(fetch_out_instr_csr_o),
    .rd_valid_o(fetch_out_instr_rd_valid_o)
  );
  riscv_decoder u_dec (
    .valid_i(fetch_in_valid_i),
    .fetch_fault_i((fetch_in_fault_fetch_i | fetch_in_fault_page_i)),
    .enable_muldiv_i(enable_muldiv_w),
    .opcode_i(fetch_out_instr_o),
    .invalid_o(fetch_out_instr_invalid_o),
    .exec_o(fetch_out_instr_exec_o),
    .lsu_o(fetch_out_instr_lsu_o),
    .branch_o(fetch_out_instr_branch_o),
    .mul_o(fetch_out_instr_mul_o),
    .div_o(fetch_out_instr_div_o),
    .csr_o(fetch_out_instr_csr_o),
    .rd_valid_o(fetch_out_instr_rd_valid_o)
  );

  generate
    if (EXTRA_DECODE_STAGE) begin
    end
  endgenerate
endmodule

module riscv_decoder
(
  input wire valid_i,
  input wire fetch_fault_i,
  input wire enable_muldiv_i,
  input wire [31:0] opcode_i,
  output wire invalid_o,
  output wire exec_o,
  output wire lsu_o,
  output wire branch_o,
  output wire mul_o,
  output wire div_o,
  output wire csr_o,
  output wire rd_valid_o
);
  wire  invalid_w = valid_i && 
                   ~(((opcode_i & `INST_ANDI_MASK) == `INST_ANDI)             ||
                    ((opcode_i & `INST_ADDI_MASK) == `INST_ADDI)              ||
                    ((opcode_i & `INST_SLTI_MASK) == `INST_SLTI)              ||
                    ((opcode_i & `INST_SLTIU_MASK) == `INST_SLTIU)            ||
                    ((opcode_i & `INST_ORI_MASK) == `INST_ORI)                ||
                    ((opcode_i & `INST_XORI_MASK) == `INST_XORI)              ||
                    ((opcode_i & `INST_SLLI_MASK) == `INST_SLLI)              ||
                    ((opcode_i & `INST_SRLI_MASK) == `INST_SRLI)              ||
                    ((opcode_i & `INST_SRAI_MASK) == `INST_SRAI)              ||
                    ((opcode_i & `INST_LUI_MASK) == `INST_LUI)                ||
                    ((opcode_i & `INST_AUIPC_MASK) == `INST_AUIPC)            ||
                    ((opcode_i & `INST_ADD_MASK) == `INST_ADD)                ||
                    ((opcode_i & `INST_SUB_MASK) == `INST_SUB)                ||
                    ((opcode_i & `INST_SLT_MASK) == `INST_SLT)                ||
                    ((opcode_i & `INST_SLTU_MASK) == `INST_SLTU)              ||
                    ((opcode_i & `INST_XOR_MASK) == `INST_XOR)                ||
                    ((opcode_i & `INST_OR_MASK) == `INST_OR)                  ||
                    ((opcode_i & `INST_AND_MASK) == `INST_AND)                ||
                    ((opcode_i & `INST_SLL_MASK) == `INST_SLL)                ||
                    ((opcode_i & `INST_SRL_MASK) == `INST_SRL)                ||
                    ((opcode_i & `INST_SRA_MASK) == `INST_SRA)                ||
                    ((opcode_i & `INST_JAL_MASK) == `INST_JAL)                ||
                    ((opcode_i & `INST_JALR_MASK) == `INST_JALR)              ||
                    ((opcode_i & `INST_BEQ_MASK) == `INST_BEQ)                ||
                    ((opcode_i & `INST_BNE_MASK) == `INST_BNE)                ||
                    ((opcode_i & `INST_BLT_MASK) == `INST_BLT)                ||
                    ((opcode_i & `INST_BGE_MASK) == `INST_BGE)                ||
                    ((opcode_i & `INST_BLTU_MASK) == `INST_BLTU)              ||
                    ((opcode_i & `INST_BGEU_MASK) == `INST_BGEU)              ||
                    ((opcode_i & `INST_LB_MASK) == `INST_LB)                  ||
                    ((opcode_i & `INST_LH_MASK) == `INST_LH)                  ||
                    ((opcode_i & `INST_LW_MASK) == `INST_LW)                  ||
                    ((opcode_i & `INST_LBU_MASK) == `INST_LBU)                ||
                    ((opcode_i & `INST_LHU_MASK) == `INST_LHU)                ||
                    ((opcode_i & `INST_LWU_MASK) == `INST_LWU)                ||
                    ((opcode_i & `INST_SB_MASK) == `INST_SB)                  ||
                    ((opcode_i & `INST_SH_MASK) == `INST_SH)                  ||
                    ((opcode_i & `INST_SW_MASK) == `INST_SW)                  ||
                    ((opcode_i & `INST_ECALL_MASK) == `INST_ECALL)            ||
                    ((opcode_i & `INST_EBREAK_MASK) == `INST_EBREAK)          ||
                    ((opcode_i & `INST_ERET_MASK) == `INST_ERET)              ||
                    ((opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW)            ||
                    ((opcode_i & `INST_CSRRS_MASK) == `INST_CSRRS)            ||
                    ((opcode_i & `INST_CSRRC_MASK) == `INST_CSRRC)            ||
                    ((opcode_i & `INST_CSRRWI_MASK) == `INST_CSRRWI)          ||
                    ((opcode_i & `INST_CSRRSI_MASK) == `INST_CSRRSI)          ||
                    ((opcode_i & `INST_CSRRCI_MASK) == `INST_CSRRCI)          ||
                    ((opcode_i & `INST_WFI_MASK) == `INST_WFI)                ||
                    ((opcode_i & `INST_FENCE_MASK) == `INST_FENCE)            ||
                    ((opcode_i & `INST_IFENCE_MASK) == `INST_IFENCE)          ||
                    ((opcode_i & `INST_SFENCE_MASK) == `INST_SFENCE)          ||
                    (enable_muldiv_i && (opcode_i & `INST_MUL_MASK) == `INST_MUL)       ||
                    (enable_muldiv_i && (opcode_i & `INST_MULH_MASK) == `INST_MULH)     ||
                    (enable_muldiv_i && (opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU) ||
                    (enable_muldiv_i && (opcode_i & `INST_MULHU_MASK) == `INST_MULHU)   ||
                    (enable_muldiv_i && (opcode_i & `INST_DIV_MASK) == `INST_DIV)       ||
                    (enable_muldiv_i && (opcode_i & `INST_DIVU_MASK) == `INST_DIVU)     ||
                    (enable_muldiv_i && (opcode_i & `INST_REM_MASK) == `INST_REM)       ||
                    (enable_muldiv_i && (opcode_i & `INST_REMU_MASK) == `INST_REMU));

  assign invalid_o = invalid_w;
  assign rd_valid_o = ((((opcode_i & `INST_JALR_MASK)) == ((`INST_JALR) || (((opcode_i & `INST_JAL_MASK))) == ((`INST_JAL) || (((opcode_i & `INST_LUI_MASK))) == ((`INST_LUI) || (((opcode_i & `INST_AUIPC_MASK))) == ((`INST_AUIPC) || (((opcode_i & `INST_ADDI_MASK))) == ((`INST_ADDI) || (((opcode_i & `INST_SLLI_MASK))) == ((`INST_SLLI) || (((opcode_i & `INST_SLTI_MASK))) == ((`INST_SLTI) || (((opcode_i & `INST_SLTIU_MASK))) == ((`INST_SLTIU) || (((opcode_i & `INST_XORI_MASK))) == ((`INST_XORI) || (((opcode_i & `INST_SRLI_MASK))) == ((`INST_SRLI) || (((opcode_i & `INST_SRAI_MASK))) == ((`INST_SRAI) || (((opcode_i & `INST_ORI_MASK))) == ((`INST_ORI) || (((opcode_i & `INST_ANDI_MASK))) == ((`INST_ANDI) || (((opcode_i & `INST_ADD_MASK))) == ((`INST_ADD) || (((opcode_i & `INST_SUB_MASK))) == ((`INST_SUB) || (((opcode_i & `INST_SLL_MASK))) == ((`INST_SLL) || (((opcode_i & `INST_SLT_MASK))) == ((`INST_SLT) || (((opcode_i & `INST_SLTU_MASK))) == ((`INST_SLTU) || (((opcode_i & `INST_XOR_MASK))) == ((`INST_XOR) || (((opcode_i & `INST_SRL_MASK))) == ((`INST_SRL) || (((opcode_i & `INST_SRA_MASK))) == ((`INST_SRA) || (((opcode_i & `INST_OR_MASK))) == ((`INST_OR) || (((opcode_i & `INST_AND_MASK))) == ((`INST_AND) || (((opcode_i & `INST_LB_MASK))) == ((`INST_LB) || (((opcode_i & `INST_LH_MASK))) == ((`INST_LH) || (((opcode_i & `INST_LW_MASK))) == ((`INST_LW) || (((opcode_i & `INST_LBU_MASK))) == ((`INST_LBU) || (((opcode_i & `INST_LHU_MASK))) == ((`INST_LHU) || (((opcode_i & `INST_LWU_MASK))) == ((`INST_LWU) || (((opcode_i & `INST_MUL_MASK))) == ((`INST_MUL) || (((opcode_i & `INST_MULH_MASK))) == ((`INST_MULH) || (((opcode_i & `INST_MULHSU_MASK))) == ((`INST_MULHSU) || (((opcode_i & `INST_MULHU_MASK))) == ((`INST_MULHU) || (((opcode_i & `INST_DIV_MASK))) == ((`INST_DIV) || (((opcode_i & `INST_DIVU_MASK))) == ((`INST_DIVU) || (((opcode_i & `INST_REM_MASK))) == ((`INST_REM) || (((opcode_i & `INST_REMU_MASK))) == ((`INST_REMU) || (((opcode_i & `INST_CSRRW_MASK))) == ((`INST_CSRRW) || (((opcode_i & `INST_CSRRS_MASK))) == ((`INST_CSRRS) || (((opcode_i & `INST_CSRRC_MASK))) == ((`INST_CSRRC) || (((opcode_i & `INST_CSRRWI_MASK))) == ((`INST_CSRRWI) || (((opcode_i & `INST_CSRRSI_MASK))) == ((`INST_CSRRSI) || (((opcode_i & `INST_CSRRCI_MASK))) == `INST_CSRRCI))))))))))))))))))))))))))))))))))))))))))));
  assign exec_o = ((((opcode_i & `INST_ANDI_MASK)) == ((`INST_ANDI) || (((opcode_i & `INST_ADDI_MASK))) == ((`INST_ADDI) || (((opcode_i & `INST_SLTI_MASK))) == ((`INST_SLTI) || (((opcode_i & `INST_SLTIU_MASK))) == ((`INST_SLTIU) || (((opcode_i & `INST_ORI_MASK))) == ((`INST_ORI) || (((opcode_i & `INST_XORI_MASK))) == ((`INST_XORI) || (((opcode_i & `INST_SLLI_MASK))) == ((`INST_SLLI) || (((opcode_i & `INST_SRLI_MASK))) == ((`INST_SRLI) || (((opcode_i & `INST_SRAI_MASK))) == ((`INST_SRAI) || (((opcode_i & `INST_LUI_MASK))) == ((`INST_LUI) || (((opcode_i & `INST_AUIPC_MASK))) == ((`INST_AUIPC) || (((opcode_i & `INST_ADD_MASK))) == ((`INST_ADD) || (((opcode_i & `INST_SUB_MASK))) == ((`INST_SUB) || (((opcode_i & `INST_SLT_MASK))) == ((`INST_SLT) || (((opcode_i & `INST_SLTU_MASK))) == ((`INST_SLTU) || (((opcode_i & `INST_XOR_MASK))) == ((`INST_XOR) || (((opcode_i & `INST_OR_MASK))) == ((`INST_OR) || (((opcode_i & `INST_AND_MASK))) == ((`INST_AND) || (((opcode_i & `INST_SLL_MASK))) == ((`INST_SLL) || (((opcode_i & `INST_SRL_MASK))) == ((`INST_SRL) || (((opcode_i & `INST_SRA_MASK))) == `INST_SRA))))))))))))))))))))));
  assign lsu_o = ((((opcode_i & `INST_LB_MASK)) == ((`INST_LB) || (((opcode_i & `INST_LH_MASK))) == ((`INST_LH) || (((opcode_i & `INST_LW_MASK))) == ((`INST_LW) || (((opcode_i & `INST_LBU_MASK))) == ((`INST_LBU) || (((opcode_i & `INST_LHU_MASK))) == ((`INST_LHU) || (((opcode_i & `INST_LWU_MASK))) == ((`INST_LWU) || (((opcode_i & `INST_SB_MASK))) == ((`INST_SB) || (((opcode_i & `INST_SH_MASK))) == ((`INST_SH) || (((opcode_i & `INST_SW_MASK))) == `INST_SW))))))))));
  assign branch_o = ((((opcode_i & `INST_JAL_MASK)) == ((`INST_JAL) || (((opcode_i & `INST_JALR_MASK))) == ((`INST_JALR) || (((opcode_i & `INST_BEQ_MASK))) == ((`INST_BEQ) || (((opcode_i & `INST_BNE_MASK))) == ((`INST_BNE) || (((opcode_i & `INST_BLT_MASK))) == ((`INST_BLT) || (((opcode_i & `INST_BGE_MASK))) == ((`INST_BGE) || (((opcode_i & `INST_BLTU_MASK))) == ((`INST_BLTU) || (((opcode_i & `INST_BGEU_MASK))) == `INST_BGEU)))))))));
  assign mul_o = ((enable_muldiv_i && ((((opcode_i & `INST_MUL_MASK))) == ((`INST_MUL) || (((opcode_i & `INST_MULH_MASK))) == ((`INST_MULH) || (((opcode_i & `INST_MULHSU_MASK))) == ((`INST_MULHSU) || (((opcode_i & `INST_MULHU_MASK))) == `INST_MULHU))))));
  assign div_o = ((enable_muldiv_i && ((((opcode_i & `INST_DIV_MASK))) == ((`INST_DIV) || (((opcode_i & `INST_DIVU_MASK))) == ((`INST_DIVU) || (((opcode_i & `INST_REM_MASK))) == ((`INST_REM) || (((opcode_i & `INST_REMU_MASK))) == `INST_REMU))))));
  assign csr_o = ((((opcode_i & `INST_ECALL_MASK)) == ((`INST_ECALL) || (((opcode_i & `INST_EBREAK_MASK))) == ((`INST_EBREAK) || (((opcode_i & `INST_ERET_MASK))) == ((`INST_ERET) || (((opcode_i & `INST_CSRRW_MASK))) == ((`INST_CSRRW) || (((opcode_i & `INST_CSRRS_MASK))) == ((`INST_CSRRS) || (((opcode_i & `INST_CSRRC_MASK))) == ((`INST_CSRRC) || (((opcode_i & `INST_CSRRWI_MASK))) == ((`INST_CSRRWI) || (((opcode_i & `INST_CSRRSI_MASK))) == ((`INST_CSRRSI) || (((opcode_i & `INST_CSRRCI_MASK))) == ((`INST_CSRRCI) || (((opcode_i & `INST_WFI_MASK))) == ((`INST_WFI) || (((opcode_i & `INST_FENCE_MASK))) == ((`INST_FENCE) || (((opcode_i & `INST_IFENCE_MASK))) == ((`INST_IFENCE) || (((opcode_i & `INST_SFENCE_MASK))) == (`INST_SFENCE) || (invalid_w || fetch_fault_i)))))))))))))));
endmodule

module riscv_divider
(
  input wire clk_i,
  input wire rst_i,
  input wire opcode_valid_i,
  input wire opcode_invalid_i,
  output wire writeback_valid_o
);
  reg  valid_q;
  reg  [31:0] wb_result_q;
  wire  inst_div_w = (opcode_opcode_i & `INST_DIV_MASK) == `INST_DIV;
  wire  inst_divu_w = (opcode_opcode_i & `INST_DIVU_MASK) == `INST_DIVU;
  wire  inst_rem_w = (opcode_opcode_i & `INST_REM_MASK) == `INST_REM;
  wire  inst_remu_w = (opcode_opcode_i & `INST_REMU_MASK) == `INST_REMU;
  wire  div_rem_inst_w = ((opcode_opcode_i & `INST_DIV_MASK) == `INST_DIV)  || 
                          ((opcode_opcode_i & `INST_DIVU_MASK) == `INST_DIVU) ||
                          ((opcode_opcode_i & `INST_REM_MASK) == `INST_REM)  ||
                          ((opcode_opcode_i & `INST_REMU_MASK) == `INST_REMU);
  wire signed  _operation_w = ((opcode_opcode_i & `INST_DIV_MASK) == `INST_DIV) || ((opcode_opcode_i & `INST_REM_MASK) == `INST_REM);
  wire  div_operation_w = ((opcode_opcode_i & `INST_DIV_MASK) == `INST_DIV) || ((opcode_opcode_i & `INST_DIVU_MASK) == `INST_DIVU);
  reg  [31:0] dividend_q;
  reg  [62:0] divisor_q;
  reg  [31:0] quotient_q;
  reg  [31:0] q_mask_q;
  reg  div_inst_q;
  reg  div_busy_q;
  reg  invert_res_q;
  wire  div_start_w = opcode_valid_i & div_rem_inst_w;
  wire  div_complete_w = !(|q_mask_q) & div_busy_q;
  reg  [31:0] div_result_r;

  always @(posedge clk_i or posedge rst_i) begin
    div_busy_q  <= 1'b0;
    dividend_q  <= 32'b0;
    divisor_q  <= 63'b0;
    invert_res_q  <= 1'b0;
    quotient_q  <= 32'b0;
    q_mask_q  <= 32'b0;
    div_inst_q  <= 1'b0;
  end
  always begin
    div_result_r  = 32'b0;
    if (div_inst_q) begin
    end
  end

  assign writeback_valid_o = valid_q;
  assign writeback_value_o = wb_result_q;

  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
endmodule

module riscv_exec
(
  input wire clk_i,
  input wire rst_i,
  input wire opcode_valid_i,
  input wire opcode_invalid_i,
  input wire hold_i,
  output wire branch_request_o,
  output wire branch_is_taken_o,
  output wire branch_is_not_taken_o,
  output wire branch_is_call_o,
  output wire branch_is_ret_o,
  output wire branch_is_jmp_o,
  output wire branch_d_request_o
);
  reg  [31:0] imm20_r;
  reg  [31:0] imm12_r;
  reg  [31:0] bimm_r;
  reg  [31:0] jimm20_r;
  reg  [4:0] shamt_r;
  reg  [3:0] alu_func_r;
  reg  [31:0] alu_input_a_r;
  reg  [31:0] alu_input_b_r;
  wire  [31:0] alu_p_w;
  reg  [31:0] result_q;
  reg  branch_r;
  reg  branch_taken_r;
  reg  [31:0] branch_target_r;
  reg  branch_call_r;
  reg  branch_ret_r;
  reg  branch_jmp_r;
  reg  branch_taken_q;
  reg  branch_ntaken_q;
  reg  [31:0] pc_x_q;
  reg  [31:0] pc_m_q;
  reg  branch_call_q;
  reg  branch_ret_q;
  reg  branch_jmp_q;

  function [0:0] less_than_signed();
    v  = ((x - y));
    less_than_signed  = x[31];
    less_than_signed  = v[31];
  endfunction
  function [0:0] greater_than_signed();
    v  = ((y - x));
    greater_than_signed  = y[31];
    greater_than_signed  = v[31];
  endfunction

  always begin
    imm20_r  = {opcode_opcode_i[31:12], 12'b0};
    imm12_r  = {{20{opcode_opcode_i[31]}}, opcode_opcode_i[31:20]};
    bimm_r  = {{19{opcode_opcode_i[31]}}, opcode_opcode_i[31], opcode_opcode_i[7], opcode_opcode_i[30:25], opcode_opcode_i[11:8], 1'b0};
    jimm20_r  = {{12{opcode_opcode_i[31]}}, opcode_opcode_i[19:12], opcode_opcode_i[20], opcode_opcode_i[30:25], opcode_opcode_i[24:21], 1'b0};
    shamt_r  = opcode_opcode_i[24:20];
  end
  always begin
    alu_func_r  = `ALU_NONE;
    alu_input_a_r  = 32'b0;
    alu_input_b_r  = 32'b0;
    if ((((opcode_opcode_i & `INST_ADD_MASK)) == `INST_ADD)) begin
      alu_func_r  = `ALU_ADD;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end else begin
      alu_func_r  = `ALU_AND;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end
    if ((((opcode_opcode_i & `INST_OR_MASK)) == `INST_OR)) begin
      alu_func_r  = `ALU_OR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end else begin
      alu_func_r  = `ALU_SHIFTL;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end
    if ((((opcode_opcode_i & `INST_SRA_MASK)) == `INST_SRA)) begin
      alu_func_r  = `ALU_SHIFTR_ARITH;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end else begin
      alu_func_r  = `ALU_SHIFTR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end
    if ((((opcode_opcode_i & `INST_SUB_MASK)) == `INST_SUB)) begin
      alu_func_r  = `ALU_SUB;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end else begin
      alu_func_r  = `ALU_XOR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end
    if ((((opcode_opcode_i & `INST_SLT_MASK)) == `INST_SLT)) begin
      alu_func_r  = `ALU_LESS_THAN_SIGNED;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end else begin
      alu_func_r  = `ALU_LESS_THAN;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = opcode_rb_operand_i;
    end
    if ((((opcode_opcode_i & `INST_ADDI_MASK)) == `INST_ADDI)) begin
      alu_func_r  = `ALU_ADD;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end else begin
      alu_func_r  = `ALU_AND;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end
    if ((((opcode_opcode_i & `INST_SLTI_MASK)) == `INST_SLTI)) begin
      alu_func_r  = `ALU_LESS_THAN_SIGNED;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end else begin
      alu_func_r  = `ALU_LESS_THAN;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end
    if ((((opcode_opcode_i & `INST_ORI_MASK)) == `INST_ORI)) begin
      alu_func_r  = `ALU_OR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end else begin
      alu_func_r  = `ALU_XOR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = imm12_r;
    end
    if ((((opcode_opcode_i & `INST_SLLI_MASK)) == `INST_SLLI)) begin
      alu_func_r  = `ALU_SHIFTL;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = {27'b0, shamt_r};
    end else begin
      alu_func_r  = `ALU_SHIFTR;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = {27'b0, shamt_r};
    end
    if ((((opcode_opcode_i & `INST_SRAI_MASK)) == `INST_SRAI)) begin
      alu_func_r  = `ALU_SHIFTR_ARITH;
      alu_input_a_r  = opcode_ra_operand_i;
      alu_input_b_r  = {27'b0, shamt_r};
    end else begin
      alu_input_a_r  = imm20_r;
    end
    if ((((opcode_opcode_i & `INST_AUIPC_MASK)) == `INST_AUIPC)) begin
      alu_func_r  = `ALU_ADD;
      alu_input_a_r  = opcode_pc_i;
      alu_input_b_r  = imm20_r;
    end else begin
      alu_func_r  = `ALU_ADD;
      alu_input_a_r  = opcode_pc_i;
      alu_input_b_r  = 32'd4;
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    v  = ((x - y));
    if ((x[31] != y[31])) begin
    end
  end
  always begin
    branch_r  = 1'b0;
    branch_taken_r  = 1'b0;
    branch_call_r  = 1'b0;
    branch_ret_r  = 1'b0;
    branch_jmp_r  = 1'b0;
    branch_target_r  = (opcode_pc_i + bimm_r);
    if ((((opcode_opcode_i & `INST_JAL_MASK)) == `INST_JAL)) begin
      branch_r  = 1'b1;
      branch_taken_r  = 1'b1;
      branch_target_r  = (opcode_pc_i + jimm20_r);
      branch_call_r  = ((opcode_rd_idx_i == 5'd1));
      branch_jmp_r  = 1'b1;
    end else begin
      branch_r  = 1'b1;
      branch_taken_r  = 1'b1;
      branch_target_r  = (opcode_ra_operand_i + imm12_r);
      branch_ret_r  = ((opcode_ra_idx_i == 5'd1 && imm12_r[11:0] == 12'b0));
      branch_call_r  = ((<unknown_op:~> && (opcode_rd_idx_i) == 5'd1));
      branch_jmp_r  = <unknown_op:~>;
    end
    if ((((opcode_opcode_i & `INST_BEQ_MASK)) == `INST_BEQ)) begin
      branch_r  = 1'b1;
      branch_taken_r  = ((opcode_ra_operand_i == opcode_rb_operand_i));
    end else begin
      branch_r  = 1'b1;
      branch_taken_r  = ((opcode_ra_operand_i != opcode_rb_operand_i));
    end
    if ((((opcode_opcode_i & `INST_BLT_MASK)) == `INST_BLT)) begin
      branch_r  = 1'b1;
      branch_taken_r  = less_than_signed(opcode_ra_operand_i, opcode_rb_operand_i);
    end else begin
      branch_r  = 1'b1;
      branch_taken_r  = ((greater_than_signed(opcode_ra_operand_i, opcode_rb_operand_i) | (opcode_ra_operand_i) == opcode_rb_operand_i));
    end
    if ((((opcode_opcode_i & `INST_BLTU_MASK)) == `INST_BLTU)) begin
      branch_r  = 1'b1;
      branch_taken_r  = ((opcode_ra_operand_i < opcode_rb_operand_i));
    end else begin
      branch_r  = 1'b1;
      branch_taken_r  = ((opcode_ra_operand_i >= opcode_rb_operand_i));
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    branch_taken_q  <= 1'b0;
    branch_ntaken_q  <= 1'b0;
    pc_x_q  <= 32'b0;
    pc_m_q  <= 32'b0;
    branch_call_q  <= 1'b0;
    branch_ret_q  <= 1'b0;
    branch_jmp_q  <= 1'b0;
  end

  assign writeback_value_o = result_q;
  assign branch_request_o = (branch_taken_q | branch_ntaken_q);
  assign branch_is_taken_o = branch_taken_q;
  assign branch_is_not_taken_o = branch_ntaken_q;
  assign branch_source_o = pc_m_q;
  assign branch_pc_o = pc_x_q;
  assign branch_is_call_o = branch_call_q;
  assign branch_is_ret_o = branch_ret_q;
  assign branch_is_jmp_o = branch_jmp_q;
  assign branch_d_request_o = ((branch_r && (opcode_valid_i && branch_taken_r)));
  assign branch_d_pc_o = branch_target_r;
  assign branch_d_priv_o = 2'b0;

  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  riscv_alu u_alu (
    .alu_op_i(alu_func_r),
    .alu_a_i(alu_input_a_r),
    .alu_b_i(alu_input_b_r),
    .alu_p_o(alu_p_w)
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
endmodule

module riscv_fetch
#(
  parameter int SUPPORT_MMU = 1
)
(
  input wire clk_i,
  input wire rst_i,
  input wire fetch_accept_i,
  input wire icache_accept_i,
  input wire icache_valid_i,
  input wire icache_error_i,
  input wire icache_page_fault_i,
  input wire fetch_invalidate_i,
  input wire branch_request_i,
  output wire fetch_valid_o,
  output wire fetch_fault_fetch_o,
  output wire fetch_fault_page_o,
  output wire icache_rd_o,
  output wire icache_flush_o,
  output wire icache_invalidate_o,
  output wire squash_decode_o
);

  reg  active_q;
  wire  icache_busy_w;
  wire  stall_w = !fetch_accept_i || icache_busy_w || !icache_accept_i;
  reg  branch_q;
  reg  [31:0] branch_pc_q;
  reg  [1:0] branch_priv_q;
  wire  branch_w = branch_q;
  wire  [31:0] branch_pc_w = branch_pc_q;
  wire  [1:0] branch_priv_w = branch_priv_q;
  reg  stall_q;
  reg  icache_fetch_q;
  reg  icache_invalidate_q;
  reg  [31:0] pc_f_q;
  reg  [31:0] pc_d_q;
  wire  [31:0] icache_pc_w;
  wire  [1:0] icache_priv_w;
  wire  fetch_resp_drop_w;
  reg  [1:0] priv_f_q;
  reg  branch_d_q;
  reg  [65:0] skid_buffer_q;
  reg  skid_valid_q;

  always @(posedge clk_i or posedge rst_i) begin
    branch_q  <= 1'b0;
    branch_pc_q  <= 32'b0;
    branch_priv_q  <= `PRIV_MACHINE;
  end
  always @(posedge clk_i or posedge rst_i) begin
    skid_buffer_q  <= 66'b0;
    skid_valid_q  <= 1'b0;
  end

  assign squash_decode_o = branch_request_i;
  assign icache_pc_w = pc_f_q;
  assign icache_priv_w = priv_f_q;
  assign fetch_resp_drop_w = (branch_w | branch_d_q);
  assign icache_rd_o = (active_q & (fetch_accept_i & !icache_busy_w));
  assign icache_pc_o = {icache_pc_w[31:2], 2'b0};
  assign icache_priv_o = icache_priv_w;
  assign icache_flush_o = (fetch_invalidate_i | icache_invalidate_q);
  assign icache_invalidate_o = 1'b0;
  assign icache_busy_w = (icache_fetch_q && !icache_valid_i);
  assign fetch_valid_o = ((icache_valid_i || (skid_valid_q) & !fetch_resp_drop_w));
  assign fetch_pc_o = (skid_valid_q ? skid_buffer_q[63 : 32] : {pc_d_q[31:2],2'b0});
  assign fetch_instr_o = (skid_valid_q ? skid_buffer_q[31 : 0]  : icache_inst_i);
  assign fetch_fault_fetch_o = (skid_valid_q ? skid_buffer_q[64] : icache_error_i);
  assign fetch_fault_page_o = (skid_valid_q ? skid_buffer_q[65] : icache_page_fault_i);

  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
endmodule

module riscv_issue
#(
  parameter int SUPPORT_MULDIV = 1,
  parameter int SUPPORT_DUAL_ISSUE = 1,
  parameter int SUPPORT_LOAD_BYPASS = 1,
  parameter int SUPPORT_MUL_BYPASS = 1,
  parameter int SUPPORT_REGFILE_XILINX = 0
)
(
  input wire clk_i,
  input wire rst_i,
  input wire fetch_valid_i,
  input wire fetch_fault_fetch_i,
  input wire fetch_fault_page_i,
  input wire fetch_instr_exec_i,
  input wire fetch_instr_lsu_i,
  input wire fetch_instr_branch_i,
  input wire fetch_instr_mul_i,
  input wire fetch_instr_div_i,
  input wire fetch_instr_csr_i,
  input wire fetch_instr_rd_valid_i,
  input wire fetch_instr_invalid_i,
  input wire branch_exec_request_i,
  input wire branch_exec_is_taken_i,
  input wire branch_exec_is_not_taken_i,
  input wire branch_exec_is_call_i,
  input wire branch_exec_is_ret_i,
  input wire branch_exec_is_jmp_i,
  input wire branch_d_exec_request_i,
  input wire branch_csr_request_i,
  input wire writeback_mem_valid_i,
  input wire writeback_div_valid_i,
  input wire csr_result_e1_write_i,
  input wire lsu_stall_i,
  input wire take_interrupt_i,
  output wire fetch_accept_o,
  output wire branch_request_o,
  output wire exec_opcode_valid_o,
  output wire lsu_opcode_valid_o,
  output wire csr_opcode_valid_o,
  output wire mul_opcode_valid_o,
  output wire div_opcode_valid_o,
  output wire opcode_invalid_o,
  output wire lsu_opcode_invalid_o,
  output wire mul_opcode_invalid_o,
  output wire csr_opcode_invalid_o,
  output wire csr_writeback_write_o,
  output wire exec_hold_o,
  output wire mul_hold_o,
  output wire interrupt_inhibit_o
);

  wire  enable_muldiv_w = SUPPORT_MULDIV;
  wire  enable_mul_bypass_w = SUPPORT_MUL_BYPASS;
  wire  stall_w;
  wire  squash_w;
  reg  [1:0] priv_x_q;
  wire  opcode_valid_w = fetch_valid_i & ~squash_w & ~branch_csr_request_i;
  wire  [4:0] issue_ra_idx_w = fetch_instr_i[19:15];
  wire  [4:0] issue_rb_idx_w = fetch_instr_i[24:20];
  wire  [4:0] issue_rd_idx_w = fetch_instr_i[11:7];
  wire  issue_sb_alloc_w = fetch_instr_rd_valid_i;
  wire  issue_exec_w = fetch_instr_exec_i;
  wire  issue_lsu_w = fetch_instr_lsu_i;
  wire  issue_branch_w = fetch_instr_branch_i;
  wire  issue_mul_w = fetch_instr_mul_i;
  wire  issue_div_w = fetch_instr_div_i;
  wire  issue_csr_w = fetch_instr_csr_i;
  wire  issue_invalid_w = fetch_instr_invalid_i;
  wire  pipe_squash_e1_e2_w;
  reg  opcode_issue_r;
  reg  opcode_accept_r;
  wire  pipe_stall_raw_w;
  wire  pipe_load_e1_w;
  wire  pipe_store_e1_w;
  wire  pipe_mul_e1_w;
  wire  pipe_branch_e1_w;
  wire  [4:0] pipe_rd_e1_w;
  wire  [31:0] pipe_pc_e1_w;
  wire  [31:0] pipe_opcode_e1_w;
  wire  [31:0] pipe_operand_ra_e1_w;
  wire  [31:0] pipe_operand_rb_e1_w;
  wire  pipe_load_e2_w;
  wire  pipe_mul_e2_w;
  wire  [4:0] pipe_rd_e2_w;
  wire  [31:0] pipe_result_e2_w;
  wire  pipe_valid_wb_w;
  wire  pipe_csr_wb_w;
  wire  [4:0] pipe_rd_wb_w;
  wire  [31:0] pipe_result_wb_w;
  wire  [31:0] pipe_pc_wb_w;
  wire  [31:0] pipe_opc_wb_w;
  wire  [31:0] pipe_ra_val_wb_w;
  wire  [31:0] pipe_rb_val_wb_w;
  reg  div_pending_q;
  reg  csr_pending_q;
  reg  [31:0] scoreboard_r;
  wire  [31:0] issue_ra_value_w;
  wire  [31:0] issue_rb_value_w;
  wire  [31:0] issue_b_ra_value_w;
  wire  [31:0] issue_b_rb_value_w;
  reg  [31:0] issue_ra_value_r;
  reg  [31:0] issue_rb_value_r;
  wire  [4:0] v_pipe_rs1_w = pipe_opc_wb_w[19:15];
  wire  [4:0] v_pipe_rs2_w = pipe_opc_wb_w[24:20];

  function [0:0] complete_valid0();
    complete_valid0  = pipe_valid_wb_w;
  endfunction
  function [31:0] complete_pc0();
    complete_pc0  = pipe_pc_wb_w;
  endfunction
  function [31:0] complete_opcode0();
    complete_opcode0  = pipe_opc_wb_w;
  endfunction
  function [4:0] complete_ra0();
    complete_ra0  = v_pipe_rs1_w;
  endfunction
  function [4:0] complete_rb0();
    complete_rb0  = v_pipe_rs2_w;
  endfunction
  function [4:0] complete_rd0();
    complete_rd0  = pipe_rd_wb_w;
  endfunction
  function [31:0] complete_ra_val0();
    complete_ra_val0  = pipe_ra_val_wb_w;
  endfunction
  function [31:0] complete_rb_val0();
    complete_rb_val0  = pipe_rb_val_wb_w;
  endfunction
  function [31:0] complete_rd_val0();
    complete_rd_val0  = pipe_result_wb_w;
    complete_rd_val0  = 32'b0;
  endfunction
  function [5:0] complete_exception();
    complete_exception  = pipe_exception_wb_w;
  endfunction

  always @(posedge clk_i or posedge rst_i) begin
    opcode_issue_r  = 1'b0;
    opcode_accept_r  = 1'b0;
    scoreboard_r  = 32'b0;
    if ((SUPPORT_LOAD_BYPASS == 0)) begin
    end
    if ((SUPPORT_MUL_BYPASS == 0)) begin
    end
    if ((pipe_load_e1_w || pipe_mul_e1_w)) begin
      opcode_issue_r  = 1'b1;
      opcode_accept_r  = 1'b1;
    end
  end
  always begin
    issue_ra_value_r  = issue_ra_value_w;
    issue_rb_value_r  = issue_rb_value_w;
    if ((pipe_rd_wb_w == issue_ra_idx_w)) begin
    end
  end

  assign branch_request_o = (branch_csr_request_i | branch_d_exec_request_i);
  assign branch_pc_o = (branch_csr_request_i ? branch_csr_pc_i : branch_d_exec_pc_i);
  assign branch_priv_o = (branch_csr_request_i ? branch_csr_priv_i : priv_x_q);
  assign exec_hold_o = stall_w;
  assign mul_hold_o = stall_w;
  assign csr_writeback_exception_o = pipe_exception_wb_w;
  assign csr_writeback_exception_pc_o = pipe_pc_wb_w;
  assign csr_writeback_exception_addr_o = pipe_result_wb_w;
  assign squash_w = pipe_squash_e1_e2_w;
  assign lsu_opcode_valid_o = (opcode_issue_r & <unknown_op:~>);
  assign exec_opcode_valid_o = opcode_issue_r;
  assign mul_opcode_valid_o = (enable_muldiv_w & opcode_issue_r);
  assign div_opcode_valid_o = (enable_muldiv_w & opcode_issue_r);
  assign interrupt_inhibit_o = (csr_pending_q || issue_csr_w);
  assign fetch_accept_o = (opcode_valid_w ? ((opcode_accept_r & <unknown_op:~>) : 1'b1);
  assign stall_w = pipe_stall_raw_w;
  assign opcode_opcode_o = fetch_instr_i;
  assign opcode_pc_o = fetch_pc_i;
  assign opcode_rd_idx_o = issue_rd_idx_w;
  assign opcode_ra_idx_o = issue_ra_idx_w;
  assign opcode_rb_idx_o = issue_rb_idx_w;
  assign opcode_invalid_o = 1'b0;
  assign opcode_ra_operand_o = issue_ra_value_r;
  assign opcode_rb_operand_o = issue_rb_value_r;
  assign lsu_opcode_opcode_o = opcode_opcode_o;
  assign lsu_opcode_pc_o = opcode_pc_o;
  assign lsu_opcode_rd_idx_o = opcode_rd_idx_o;
  assign lsu_opcode_ra_idx_o = opcode_ra_idx_o;
  assign lsu_opcode_rb_idx_o = opcode_rb_idx_o;
  assign lsu_opcode_ra_operand_o = opcode_ra_operand_o;
  assign lsu_opcode_rb_operand_o = opcode_rb_operand_o;
  assign lsu_opcode_invalid_o = 1'b0;
  assign mul_opcode_opcode_o = opcode_opcode_o;
  assign mul_opcode_pc_o = opcode_pc_o;
  assign mul_opcode_rd_idx_o = opcode_rd_idx_o;
  assign mul_opcode_ra_idx_o = opcode_ra_idx_o;
  assign mul_opcode_rb_idx_o = opcode_rb_idx_o;
  assign mul_opcode_ra_operand_o = opcode_ra_operand_o;
  assign mul_opcode_rb_operand_o = opcode_rb_operand_o;
  assign mul_opcode_invalid_o = 1'b0;
  assign csr_opcode_valid_o = (opcode_issue_r & <unknown_op:~>);
  assign csr_opcode_opcode_o = opcode_opcode_o;
  assign csr_opcode_pc_o = opcode_pc_o;
  assign csr_opcode_rd_idx_o = opcode_rd_idx_o;
  assign csr_opcode_ra_idx_o = opcode_ra_idx_o;
  assign csr_opcode_rb_idx_o = opcode_rb_idx_o;
  assign csr_opcode_ra_operand_o = opcode_ra_operand_o;
  assign csr_opcode_rb_operand_o = opcode_rb_operand_o;
  assign csr_opcode_invalid_o = (opcode_issue_r && issue_invalid_w);

  else if (
  );
  riscv_pipe_ctrl #(
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
  ) u_pipe_ctrl (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .issue_valid_i(opcode_issue_r),
    .issue_accept_i(opcode_accept_r),
    .issue_stall_i(stall_w),
    .issue_lsu_i(issue_lsu_w),
    .issue_csr_i(issue_csr_w),
    .issue_div_i(issue_div_w),
    .issue_mul_i(issue_mul_w),
    .issue_branch_i(issue_branch_w),
    .issue_rd_valid_i(issue_sb_alloc_w),
    .issue_rd_i(issue_rd_idx_w),
    .issue_exception_i(issue_fault_w),
    .issue_pc_i(opcode_pc_o),
    .issue_opcode_i(opcode_opcode_o),
    .issue_operand_ra_i(opcode_ra_operand_o),
    .issue_operand_rb_i(opcode_rb_operand_o),
    .issue_branch_taken_i(branch_d_exec_request_i),
    .issue_branch_target_i(branch_d_exec_pc_i),
    .take_interrupt_i(take_interrupt_i),
    .alu_result_e1_i(writeback_exec_value_i),
    .csr_result_value_e1_i(csr_result_e1_value_i),
    .csr_result_write_e1_i(csr_result_e1_write_i),
    .csr_result_wdata_e1_i(csr_result_e1_wdata_i),
    .csr_result_exception_e1_i(csr_result_e1_exception_i),
    .load_e1_o(pipe_load_e1_w),
    .store_e1_o(pipe_store_e1_w),
    .mul_e1_o(pipe_mul_e1_w),
    .branch_e1_o(pipe_branch_e1_w),
    .rd_e1_o(pipe_rd_e1_w),
    .pc_e1_o(pipe_pc_e1_w),
    .opcode_e1_o(pipe_opcode_e1_w),
    .operand_ra_e1_o(pipe_operand_ra_e1_w),
    .operand_rb_e1_o(pipe_operand_rb_e1_w),
    .mem_complete_i(writeback_mem_valid_i),
    .mem_result_e2_i(writeback_mem_value_i),
    .mem_exception_e2_i(writeback_mem_exception_i),
    .mul_result_e2_i(writeback_mul_value_i),
    .load_e2_o(pipe_load_e2_w),
    .mul_e2_o(pipe_mul_e2_w),
    .rd_e2_o(pipe_rd_e2_w),
    .result_e2_o(pipe_result_e2_w),
    .stall_o(pipe_stall_raw_w),
    .squash_e1_e2_o(pipe_squash_e1_e2_w),
    .squash_e1_e2_i(1'b0),
    .squash_wb_i(1'b0),
    .div_complete_i(writeback_div_valid_i),
    .div_result_i(writeback_div_value_i),
    .valid_wb_o(pipe_valid_wb_w),
    .csr_wb_o(pipe_csr_wb_w),
    .rd_wb_o(pipe_rd_wb_w),
    .result_wb_o(pipe_result_wb_w),
    .pc_wb_o(pipe_pc_wb_w),
    .opcode_wb_o(pipe_opc_wb_w),
    .operand_ra_wb_o(pipe_ra_val_wb_w),
    .operand_rb_wb_o(pipe_rb_val_wb_w),
    .exception_wb_o(pipe_exception_wb_w),
    .csr_write_wb_o(csr_writeback_write_o),
    .csr_waddr_wb_o(csr_writeback_waddr_o),
    .csr_wdata_wb_o(csr_writeback_wdata_o)
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  end if (
  );
  begin if (
  );
  end if (
  );
  else if (
  );
  riscv_regfile #(
    .SUPPORT_REGFILE_XILINX(SUPPORT_REGFILE_XILINX)
  ) u_regfile (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rd0_i(pipe_rd_wb_w),
    .rd0_value_i(pipe_result_wb_w),
    .ra0_i(issue_ra_idx_w),
    .rb0_i(issue_rb_idx_w),
    .ra0_value_o(issue_ra_value_w),
    .rb0_value_o(issue_rb_value_w)
  );
  riscv_trace_sim u_pipe_dec0_verif (
    .valid_i(pipe_valid_wb_w),
    .pc_i(pipe_pc_wb_w),
    .opcode_i(pipe_opc_wb_w)
  );
endmodule

module riscv_lsu
#(
  parameter int MEM_CACHE_ADDR_MIN = 32'h80000000,
  parameter int MEM_CACHE_ADDR_MAX = 32'h8fffffff
)
(
  input wire clk_i,
  input wire rst_i,
  input wire opcode_valid_i,
  input wire opcode_invalid_i,
  input wire mem_accept_i,
  input wire mem_ack_i,
  input wire mem_error_i,
  input wire mem_load_fault_i,
  input wire mem_store_fault_i,
  output wire mem_rd_o,
  output wire mem_cacheable_o,
  output wire mem_invalidate_o,
  output wire mem_writeback_o,
  output wire mem_flush_o,
  output wire writeback_valid_o,
  output wire stall_o
);

  reg  mem_rd_q;
  reg  mem_cacheable_q;
  reg  mem_invalidate_q;
  reg  mem_writeback_q;
  reg  mem_flush_q;
  reg  mem_unaligned_e1_q;
  reg  mem_unaligned_e2_q;
  reg  mem_load_q;
  reg  mem_xb_q;
  reg  mem_xh_q;
  reg  mem_ls_q;
  reg  pending_lsu_e2_q;
  wire  issue_lsu_e1_w = (mem_rd_o || (|mem_wr_o) || mem_writeback_o || mem_invalidate_o || mem_flush_o) && mem_accept_i;
  wire  complete_ok_e2_w = mem_ack_i & ~mem_error_i;
  wire  complete_err_e2_w = mem_ack_i & mem_error_i;
  wire  delay_lsu_e2_w = pending_lsu_e2_q && !complete_ok_e2_w;
  wire  load_inst_w = (((opcode_opcode_i & `INST_LB_MASK) == `INST_LB)  || 
                    ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH)  || 
                    ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW)  || 
                    ((opcode_opcode_i & `INST_LBU_MASK) == `INST_LBU) || 
                    ((opcode_opcode_i & `INST_LHU_MASK) == `INST_LHU) || 
                    ((opcode_opcode_i & `INST_LWU_MASK) == `INST_LWU));
  wire  load_signed_inst_w = (((opcode_opcode_i & `INST_LB_MASK) == `INST_LB)  || 
                           ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH)  || 
                           ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW));
  wire  store_inst_w = (((opcode_opcode_i & `INST_SB_MASK) == `INST_SB)  || 
                     ((opcode_opcode_i & `INST_SH_MASK) == `INST_SH)  || 
                     ((opcode_opcode_i & `INST_SW_MASK) == `INST_SW));
  wire  req_lb_w = ((opcode_opcode_i & `INST_LB_MASK) == `INST_LB) || ((opcode_opcode_i & `INST_LBU_MASK) == `INST_LBU);
  wire  req_lh_w = ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH) || ((opcode_opcode_i & `INST_LHU_MASK) == `INST_LHU);
  wire  req_lw_w = ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW) || ((opcode_opcode_i & `INST_LWU_MASK) == `INST_LWU);
  wire  req_sb_w = ((opcode_opcode_i & `INST_LB_MASK) == `INST_SB);
  wire  req_sh_w = ((opcode_opcode_i & `INST_LH_MASK) == `INST_SH);
  wire  req_sw_w = ((opcode_opcode_i & `INST_LW_MASK) == `INST_SW);
  wire  req_sw_lw_w = ((opcode_opcode_i & `INST_SW_MASK) == `INST_SW) || ((opcode_opcode_i & `INST_LW_MASK) == `INST_LW) || ((opcode_opcode_i & `INST_LWU_MASK) == `INST_LWU);
  wire  req_sh_lh_w = ((opcode_opcode_i & `INST_SH_MASK) == `INST_SH) || ((opcode_opcode_i & `INST_LH_MASK) == `INST_LH) || ((opcode_opcode_i & `INST_LHU_MASK) == `INST_LHU);
  reg  [31:0] mem_addr_r;
  reg  mem_unaligned_r;
  reg  [31:0] mem_data_r;
  reg  mem_rd_r;
  reg  [3:0] mem_wr_r;
  wire  dcache_flush_w = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DFLUSH);
  wire  dcache_writeback_w = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DWRITEBACK);
  wire  dcache_invalidate_w = ((opcode_opcode_i & `INST_CSRRW_MASK) == `INST_CSRRW) && (opcode_opcode_i[31:20] == `CSR_DINVALIDATE);
  wire  resp_load_w;
  wire  [31:0] resp_addr_w;
  wire  resp_byte_w;
  wire  resp_half_w;
  wire  resp_signed_w;
  reg  [1:0] addr_lsb_r;
  reg  load_byte_r;
  reg  load_half_r;
  reg  load_signed_r;
  reg  [31:0] wb_result_r;
  wire  fault_load_align_w = mem_unaligned_e2_q & resp_load_w;
  wire  fault_store_align_w = mem_unaligned_e2_q & ~resp_load_w;
  wire  fault_load_bus_w = mem_error_i &&  resp_load_w;
  wire  fault_store_bus_w = mem_error_i && ~resp_load_w;
  wire  fault_load_page_w = mem_error_i && mem_load_fault_i;
  wire  fault_store_page_w = mem_error_i && mem_store_fault_i;

  always @(posedge clk_i or posedge rst_i) begin
    mem_addr_r  = 32'b0;
    mem_data_r  = 32'b0;
    mem_unaligned_r  = 1'b0;
    mem_wr_r  = 4'b0;
    mem_rd_r  = 1'b0;
    if (((opcode_valid_i && (((opcode_opcode_i & `INST_CSRRW_MASK))) == `INST_CSRRW))) begin
      mem_data_r  = opcode_rb_operand_i;
      mem_wr_r  = 4'hF;
    end else begin
      mem_data_r  = {opcode_rb_operand_i[15:0], 16'h0000};
      mem_wr_r  = 4'b1100;
      mem_data_r  = {16'h0000, opcode_rb_operand_i[15:0]};
      mem_wr_r  = 4'b0011;
    end
    if (((opcode_valid_i && (((opcode_opcode_i & `INST_SB_MASK))) == `INST_SB))) begin
      mem_data_r  = {opcode_rb_operand_i[7:0], 24'h000000};
      mem_wr_r  = 4'b1000;
      mem_data_r  = {{8'h00, opcode_rb_operand_i[7:0]}, 16'h0000};
      mem_wr_r  = 4'b0100;
      mem_data_r  = {{16'h0000, opcode_rb_operand_i[7:0]}, 8'h00};
      mem_wr_r  = 4'b0010;
      mem_data_r  = {24'h000000, opcode_rb_operand_i[7:0]};
      mem_wr_r  = 4'b0001;
    end else begin
      mem_wr_r  = 4'b0;
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    mem_addr_q  <= 32'b0;
    mem_data_wr_q  <= 32'b0;
    mem_rd_q  <= 1'b0;
    mem_wr_q  <= 4'b0;
    mem_cacheable_q  <= 1'b0;
    mem_invalidate_q  <= 1'b0;
    mem_writeback_q  <= 1'b0;
    mem_flush_q  <= 1'b0;
    mem_unaligned_e1_q  <= 1'b0;
    mem_load_q  <= 1'b0;
    mem_xb_q  <= 1'b0;
    mem_xh_q  <= 1'b0;
    mem_ls_q  <= 1'b0;
  end
  always begin
    wb_result_r  = 32'b0;
    addr_lsb_r  = resp_addr_w[1:0];
    load_byte_r  = resp_byte_w;
    load_half_r  = resp_half_w;
    load_signed_r  = resp_signed_w;
    if (((mem_ack_i && (mem_error_i) || mem_unaligned_e2_q))) begin
      wb_result_r  = {24'b0, mem_data_rd_i[31:24]};
      wb_result_r  = {24'b0, mem_data_rd_i[23:16]};
      wb_result_r  = {24'b0, mem_data_rd_i[15:8]};
      wb_result_r  = {24'b0, mem_data_rd_i[7:0]};
      wb_result_r  = {24'hFFFFFF, wb_result_r[7:0]};
      wb_result_r  = {16'b0, mem_data_rd_i[31:16]};
      wb_result_r  = {16'b0, mem_data_rd_i[15:0]};
      wb_result_r  = {16'hFFFF, wb_result_r[15:0]};
      wb_result_r  = mem_data_rd_i;
    end
  end

  assign mem_addr_o = {mem_addr_q[31:2], 2'b0};
  assign mem_data_wr_o = mem_data_wr_q;
  assign mem_rd_o = (mem_rd_q & <unknown_op:~>);
  assign mem_wr_o = (mem_wr_q & <unknown_op:~>);
  assign mem_cacheable_o = mem_cacheable_q;
  assign mem_req_tag_o = 11'b0;
  assign mem_invalidate_o = mem_invalidate_q;
  assign mem_writeback_o = mem_writeback_q;
  assign mem_flush_o = mem_flush_q;
  assign stall_o = ((((mem_writeback_o || (mem_invalidate_o || (mem_flush_o || (mem_rd_o || mem_wr_o)))) != 4'b0) && !mem_accept_i) || delay_lsu_e2_w || mem_unaligned_e1_q);
  assign writeback_valid_o = (mem_ack_i | mem_unaligned_e2_q);
  assign writeback_value_o = wb_result_r;
  assign writeback_exception_o = (fault_load_align_w ? `EXCEPTION_MISALIGNED_LOAD : (fault_store_align_w ? `EXCEPTION_MISALIGNED_STORE : (fault_load_page_w ? `EXCEPTION_PAGE_FAULT_LOAD : (fault_store_page_w ? `EXCEPTION_PAGE_FAULT_STORE : (fault_load_bus_w ? `EXCEPTION_FAULT_LOAD : (fault_store_bus_w ? `EXCEPTION_FAULT_STORE : `EXCEPTION_W'b0))))));

  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin case (
  );
  else if (
  );
  begin case (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  riscv_lsu_fifo #(
    .WIDTH(36),
    .DEPTH(2),
    .ADDR_W(1)
  ) u_lsu_request (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .push_i((((mem_rd_o || (( | mem_wr_o))),
    .data_in_i({mem_addr_q, mem_ls_q, mem_xh_q, mem_xb_q, mem_load_q}),
    .accept_o(),
    .valid_o(),
    .data_out_o({resp_addr_w, resp_signed_w, resp_half_w, resp_byte_w, resp_load_w}),
    .pop_i((mem_ack_i || mem_unaligned_e2_q))
  );
  else if (
  );
  begin if (
  );
  begin case (
  );
  endcase if (
  );
  else if (
  );
  begin if (
  );
endmodule

module riscv_lsu_fifo
#(
  parameter int WIDTH = 8,
  parameter int DEPTH = 4,
  parameter int ADDR_W = 2
)
(
  input wire clk_i,
  input wire rst_i,
  input wire push_i,
  input wire pop_i,
  output wire accept_o,
  output wire valid_o
);


  always @(posedge clk_i or posedge rst_i) begin
    count_q  <= {(COUNT_W) {1'b0}};
    rd_ptr_q  <= {(ADDR_W) {1'b0}};
    wr_ptr_q  <= {(ADDR_W) {1'b0}};
    i  = 0;
    i  = ((i + 1)
    begin
        ram_q[i]) <= {(WIDTH) {1'b0}});
  end

  assign valid_o = ((count_q != 0));
  assign accept_o = ((count_q != DEPTH));
  assign data_out_o = ram_q[rd_ptr_q];

  begin if (
  );
  end if (
  );
  else if (
  );
endmodule

module riscv_mmu
#(
  parameter int MEM_CACHE_ADDR_MIN = 32'h80000000,
  parameter int MEM_CACHE_ADDR_MAX = 32'h8fffffff,
  parameter int SUPPORT_MMU = 1
)
(
  input wire clk_i,
  input wire rst_i,
  input wire sum_i,
  input wire mxr_i,
  input wire flush_i,
  input wire fetch_in_rd_i,
  input wire fetch_in_flush_i,
  input wire fetch_in_invalidate_i,
  input wire fetch_out_accept_i,
  input wire fetch_out_valid_i,
  input wire fetch_out_error_i,
  input wire lsu_in_rd_i,
  input wire lsu_in_cacheable_i,
  input wire lsu_in_invalidate_i,
  input wire lsu_in_writeback_i,
  input wire lsu_in_flush_i,
  input wire lsu_out_accept_i,
  input wire lsu_out_ack_i,
  input wire lsu_out_error_i,
  output wire fetch_in_accept_o,
  output wire fetch_in_valid_o,
  output wire fetch_in_error_o,
  output wire fetch_out_rd_o,
  output wire fetch_out_flush_o,
  output wire fetch_out_invalidate_o,
  output wire fetch_in_fault_o,
  output wire lsu_in_accept_o,
  output wire lsu_in_ack_o,
  output wire lsu_in_error_o,
  output wire lsu_out_rd_o,
  output wire lsu_out_cacheable_o,
  output wire lsu_out_invalidate_o,
  output wire lsu_out_writeback_o,
  output wire lsu_out_flush_o,
  output wire lsu_in_load_fault_o,
  output wire lsu_in_store_fault_o
);


  always @(posedge clk_i or posedge rst_i) begin
    pte_addr_q  <= 32'b0;
    pte_entry_q  <= 32'b0;
    virt_addr_q  <= 32'b0;
    dtlb_req_q  <= 1'b0;
    state_q  <= STATE_IDLE;
  end
  always @(posedge clk_i or posedge rst_i) begin
    itlb_va_addr_q  <= 20'b0;
    itlb_entry_q  <= 32'b0;
  end
  always begin
    pc_fault_r  = 1'b0;
    if ((vm_i_enable_w && itlb_hit_w)) begin
      pc_fault_r  = 1'b1;
      pc_fault_r  = <unknown_op:~>;
      pc_fault_r  = <unknown_op:~>;
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    dtlb_va_addr_q  <= 20'b0;
    dtlb_entry_q  <= 32'b0;
  end
  always begin
    load_fault_r  = 1'b0;
    if ((vm_d_enable_w && (load_w && dtlb_hit_w))) begin
      load_fault_r  = 1'b1;
      load_fault_r  = <unknown_op:~>;
      load_fault_r  = <unknown_op:~>;
    end
  end
  always begin
    store_fault_r  = 1'b0;
    if ((vm_d_enable_w && ((( | store_w)) && dtlb_hit_w))) begin
      store_fault_r  = 1'b1;
      store_fault_r  = <unknown_op:~>;
      store_fault_r  = <unknown_op:~>;
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    if ((lsu_in_invalidate_i || (lsu_in_writeback_i || lsu_in_flush_i))) begin
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    read_hold_q  <= 1'b0;
    src_mmu_q  <= 1'b0;
  end

  assign itlb_hit_w = ((fetch_in_rd_i & (itlb_valid_q & (itlb_va_addr_q)) == fetch_in_pc_i[31:12]);
  assign fetch_out_rd_o = (<unknown_op:~> || ((itlb_hit_w & <unknown_op:~>));
  assign fetch_out_pc_o = (vm_i_enable_w ? {itlb_entry_q[31 : 12], fetch_in_pc_i[11:0]} : fetch_in_pc_i);
  assign fetch_out_flush_o = fetch_in_flush_i;
  assign fetch_out_invalidate_o = fetch_in_invalidate_i;
  assign fetch_in_accept_o = <unknown_op:~>;
  assign fetch_in_valid_o = (fetch_out_valid_i | pc_fault_q);
  assign fetch_in_error_o = (fetch_out_valid_i & fetch_out_error_i);
  assign fetch_in_fault_o = pc_fault_q;
  assign fetch_in_inst_o = fetch_out_inst_i;
  assign dtlb_hit_w = ((dtlb_valid_q & (dtlb_va_addr_q) == lsu_addr_w[31:12]);
  assign lsu_in_ack_o = ((lsu_out_ack_i & <unknown_op:~>);
  assign lsu_in_resp_tag_o = lsu_out_resp_tag_i;
  assign lsu_in_error_o = ((lsu_out_error_i & <unknown_op:~>);
  assign lsu_in_data_rd_o = lsu_out_data_rd_i;
  assign lsu_in_store_fault_o = store_fault_q;
  assign lsu_in_load_fault_o = load_fault_q;
  assign lsu_in_accept_o = <unknown_op:~>;
  assign mmu_accept_w = (src_mmu_w & lsu_out_accept_i);
  assign cpu_accept_w = <unknown_op:~>;
  assign lsu_out_rd_o = (src_mmu_w ? mem_req_q : lsu_out_rd_w);
  assign lsu_out_wr_o = (src_mmu_w ? 4'b0 : lsu_out_wr_w);
  assign lsu_out_addr_o = (src_mmu_w ? pte_addr_q : lsu_out_addr_w);
  assign lsu_out_data_wr_o = lsu_out_data_wr_w;
  assign lsu_out_invalidate_o = (src_mmu_w ? 1'b0 : lsu_out_invalidate_w);
  assign lsu_out_writeback_o = (src_mmu_w ? 1'b0 : lsu_out_writeback_w);
  assign lsu_out_cacheable_o = (src_mmu_w ? 1'b1 : lsu_out_cacheable_r);
  assign lsu_out_req_tag_o = (src_mmu_w ? {1'b0, 3'b111, 7'b0} : lsu_out_req_tag_w);
  assign lsu_out_flush_o = (src_mmu_w ? 1'b0 : lsu_out_flush_w);
  assign fetch_out_rd_o = fetch_in_rd_i;
  assign fetch_out_pc_o = fetch_in_pc_i;
  assign fetch_out_flush_o = fetch_in_flush_i;
  assign fetch_out_invalidate_o = fetch_in_invalidate_i;
  assign fetch_in_accept_o = fetch_out_accept_i;
  assign fetch_in_valid_o = fetch_out_valid_i;
  assign fetch_in_error_o = fetch_out_error_i;
  assign fetch_in_fault_o = 1'b0;
  assign fetch_in_inst_o = fetch_out_inst_i;
  assign lsu_out_rd_o = lsu_in_rd_i;
  assign lsu_out_wr_o = lsu_in_wr_i;
  assign lsu_out_addr_o = lsu_in_addr_i;
  assign lsu_out_data_wr_o = lsu_in_data_wr_i;
  assign lsu_out_invalidate_o = lsu_in_invalidate_i;
  assign lsu_out_writeback_o = lsu_in_writeback_i;
  assign lsu_out_cacheable_o = lsu_in_cacheable_i;
  assign lsu_out_req_tag_o = lsu_in_req_tag_i;
  assign lsu_out_flush_o = lsu_in_flush_i;
  assign lsu_in_ack_o = lsu_out_ack_i;
  assign lsu_in_resp_tag_o = lsu_out_resp_tag_i;
  assign lsu_in_error_o = lsu_out_error_i;
  assign lsu_in_data_rd_o = lsu_out_data_rd_i;
  assign lsu_in_store_fault_o = 1'b0;
  assign lsu_in_load_fault_o = 1'b0;
  assign lsu_in_accept_o = lsu_out_accept_i;

  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  begin if (
  );
  begin if (
  );
  begin if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );

  generate
    if (SUPPORT_MMU) begin
    end
  endgenerate
endmodule

module riscv_multiplier
(
  input wire clk_i,
  input wire rst_i,
  input wire opcode_valid_i,
  input wire opcode_invalid_i,
  input wire hold_i
);
  reg  [31:0] result_e2_q;
  reg  [31:0] result_e3_q;
  reg  [32:0] operand_a_e1_q;
  reg  [32:0] operand_b_e1_q;
  reg  mulhi_sel_e1_q;
  wire  [64:0] mult_result_w;
  reg  [32:0] operand_b_r;
  reg  [32:0] operand_a_r;
  reg  [31:0] result_r;
  wire  mult_inst_w = ((opcode_opcode_i & `INST_MUL_MASK) == `INST_MUL)        || 
                      ((opcode_opcode_i & `INST_MULH_MASK) == `INST_MULH)      ||
                      ((opcode_opcode_i & `INST_MULHSU_MASK) == `INST_MULHSU)  ||
                      ((opcode_opcode_i & `INST_MULHU_MASK) == `INST_MULHU);

  always begin
    if ((((opcode_opcode_i & `INST_MULHSU_MASK)) == `INST_MULHSU)) begin
    end
  end
  always begin
    if ((((opcode_opcode_i & `INST_MULHSU_MASK)) == `INST_MULHSU)) begin
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    operand_a_e1_q  <= 33'b0;
    operand_b_e1_q  <= 33'b0;
    mulhi_sel_e1_q  <= 1'b0;
  end
  always begin
    result_r  = (mulhi_sel_e1_q ? mult_result_w[63 : 32] : mult_result_w[31:0]);
  end

  assign mult_result_w = {{32 {operand_a_e1_q[32]}}, (operand_a_e1_q} * {{32 {operand_b_e1_q[32]}}), operand_b_e1_q};
  assign writeback_value_o = (((MULT_STAGES == 3)) ? result_e3_q : result_e2_q);

  begin if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
endmodule

module riscv_pipe_ctrl
#(
  parameter int SUPPORT_LOAD_BYPASS = 1,
  parameter int SUPPORT_MUL_BYPASS = 1
)
(
  input wire clk_i,
  input wire rst_i,
  input wire issue_valid_i,
  input wire issue_accept_i,
  input wire issue_stall_i,
  input wire issue_lsu_i,
  input wire issue_csr_i,
  input wire issue_div_i,
  input wire issue_mul_i,
  input wire issue_branch_i,
  input wire issue_rd_valid_i,
  input wire [4:0] issue_rd_i,
  input wire [5:0] issue_exception_i,
  input wire take_interrupt_i,
  input wire issue_branch_taken_i,
  input wire [31:0] issue_branch_target_i,
  input wire [31:0] issue_pc_i,
  input wire [31:0] issue_opcode_i,
  input wire [31:0] issue_operand_ra_i,
  input wire [31:0] issue_operand_rb_i,
  input wire [31:0] alu_result_e1_i,
  input wire csr_result_write_e1_i,
  output wire load_e1_o,
  output wire store_e1_o,
  output wire mul_e1_o,
  output wire branch_e1_o,
  output wire [31:0] pc_e1_o,
  output wire [31:0] opcode_e1_o,
  output wire [31:0] operand_ra_e1_o,
  output wire [31:0] operand_rb_e1_o,
  input wire mem_complete_i,
  input wire [31:0] mem_result_e2_i,
  input wire [5:0] mem_exception_e2_i,
  input wire [31:0] mul_result_e2_i,
  output wire load_e2_o,
  output wire mul_e2_o,
  output wire [31:0] result_e2_o,
  input wire div_complete_i,
  input wire [31:0] div_result_i,
  output wire valid_wb_o,
  output wire csr_wb_o,
  output wire [31:0] result_wb_o,
  output wire [31:0] pc_wb_o,
  output wire [31:0] opcode_wb_o,
  output wire [31:0] operand_ra_wb_o,
  output wire [31:0] operand_rb_wb_o,
  output wire [5:0] exception_wb_o,
  output wire csr_write_wb_o,
  output wire [11:0] csr_waddr_wb_o,
  output wire [31:0] csr_wdata_wb_o,
  output wire stall_o,
  output wire squash_e1_e2_o,
  input wire squash_e1_e2_i,
  input wire squash_wb_i
);

  wire  squash_e1_e2_w;
  wire  branch_misaligned_w = (issue_branch_taken_i && issue_branch_target_i[1:0] != 2'b0);
  reg  valid_e1_q;
  reg  [31:0] pc_e1_q;
  reg  [31:0] npc_e1_q;
  reg  [31:0] opcode_e1_q;
  reg  [31:0] operand_ra_e1_q;
  reg  [31:0] operand_rb_e1_q;
  wire  alu_e1_w = ctrl_e1_q[`PCINFO_ALU];
  wire  csr_e1_w = ctrl_e1_q[`PCINFO_CSR];
  wire  div_e1_w = ctrl_e1_q[`PCINFO_DIV];
  reg  valid_e2_q;
  reg  csr_wr_e2_q;
  reg  [31:0] csr_wdata_e2_q;
  reg  [31:0] result_e2_q;
  reg  [31:0] pc_e2_q;
  reg  [31:0] npc_e2_q;
  reg  [31:0] opcode_e2_q;
  reg  [31:0] operand_ra_e2_q;
  reg  [31:0] operand_rb_e2_q;
  reg  [31:0] result_e2_r;
  wire  valid_e2_w = valid_e2_q & ~issue_stall_i;
  wire  load_store_e2_w = ctrl_e2_q[`PCINFO_LOAD] | ctrl_e2_q[`PCINFO_STORE];
  reg  squash_e1_e2_q;
  reg  valid_wb_q;
  reg  csr_wr_wb_q;
  reg  [31:0] csr_wdata_wb_q;
  reg  [31:0] result_wb_q;
  reg  [31:0] pc_wb_q;
  reg  [31:0] npc_wb_q;
  reg  [31:0] opcode_wb_q;
  reg  [31:0] operand_ra_wb_q;
  reg  [31:0] operand_rb_wb_q;
  wire  complete_wb_w = ctrl_wb_q[`PCINFO_COMPLETE] & ~issue_stall_i;

  always @(posedge clk_i or posedge rst_i) begin
    valid_e1_q  <= 1'b0;
    ctrl_e1_q  <= `PCINFO_W'b0;
    pc_e1_q  <= 32'b0;
    npc_e1_q  <= 32'b0;
    opcode_e1_q  <= 32'b0;
    operand_ra_e1_q  <= 32'b0;
    operand_rb_e1_q  <= 32'b0;
    exception_e1_q  <= `EXCEPTION_W'b0;
  end
  always @(posedge clk_i or posedge rst_i) begin
    valid_e2_q  <= 1'b0;
    ctrl_e2_q  <= `PCINFO_W'b0;
    csr_wr_e2_q  <= 1'b0;
    csr_wdata_e2_q  <= 32'b0;
    pc_e2_q  <= 32'b0;
    npc_e2_q  <= 32'b0;
    opcode_e2_q  <= 32'b0;
    operand_ra_e2_q  <= 32'b0;
    operand_rb_e2_q  <= 32'b0;
    result_e2_q  <= 32'b0;
    exception_e2_q  <= `EXCEPTION_W'b0;
  end
  always begin
    result_e2_r  = result_e2_q;
    if ((SUPPORT_LOAD_BYPASS && (valid_e2_w && ((ctrl_e2_q[`PCINFO_LOAD] || ctrl_e2_q[`PCINFO_STORE]))))) begin
    end
  end
  always begin
    if ((valid_e2_q && (((ctrl_e2_q[`PCINFO_LOAD] || ctrl_e2_q[`PCINFO_STORE])) && mem_complete_i))) begin
    end
  end
  always @(posedge clk_i or posedge rst_i) begin
    valid_wb_q  <= 1'b0;
    ctrl_wb_q  <= `PCINFO_W'b0;
    csr_wr_wb_q  <= 1'b0;
    csr_wdata_wb_q  <= 32'b0;
    pc_wb_q  <= 32'b0;
    npc_wb_q  <= 32'b0;
    opcode_wb_q  <= 32'b0;
    operand_ra_wb_q  <= 32'b0;
    operand_rb_wb_q  <= 32'b0;
    result_wb_q  <= 32'b0;
    exception_wb_q  <= `EXCEPTION_W'b0;
  end

  assign load_e1_o = ctrl_e1_q[`PCINFO_LOAD];
  assign store_e1_o = ctrl_e1_q[`PCINFO_STORE];
  assign mul_e1_o = ctrl_e1_q[`PCINFO_MUL];
  assign branch_e1_o = ctrl_e1_q[`PCINFO_BRANCH];
  assign rd_e1_o = ({5{ctrl_e1_q[`PCINFO_RD_VALID]}} & opcode_e1_q[`RD_IDX_R]);
  assign pc_e1_o = pc_e1_q;
  assign opcode_e1_o = opcode_e1_q;
  assign operand_ra_e1_o = operand_ra_e1_q;
  assign operand_rb_e1_o = operand_rb_e1_q;
  assign load_e2_o = ctrl_e2_q[`PCINFO_LOAD];
  assign mul_e2_o = ctrl_e2_q[`PCINFO_MUL];
  assign rd_e2_o = ({5{(valid_e2_w && (ctrl_e2_q[`PCINFO_RD_VALID] && <unknown_op:~>));
  assign result_e2_o = result_e2_r;
  assign stall_o = ((ctrl_e1_q[`PCINFO_DIV] && (<unknown_op:~> || (((ctrl_e2_q[`PCINFO_LOAD] | (ctrl_e2_q[`PCINFO_STORE]) & <unknown_op:~>))));
  assign squash_e1_e2_w = ( | exception_e2_r);
  assign squash_e1_e2_o = (squash_e1_e2_w | squash_e1_e2_q);
  assign valid_wb_o = (valid_wb_q & <unknown_op:~>);
  assign csr_wb_o = (ctrl_wb_q[`PCINFO_CSR] & <unknown_op:~>);
  assign rd_wb_o = ({5{(valid_wb_o && (ctrl_wb_q[`PCINFO_RD_VALID] && <unknown_op:~>));
  assign result_wb_o = result_wb_q;
  assign pc_wb_o = pc_wb_q;
  assign opcode_wb_o = opcode_wb_q;
  assign operand_ra_wb_o = operand_ra_wb_q;
  assign operand_rb_wb_o = operand_rb_wb_q;
  assign exception_wb_o = exception_wb_q;
  assign csr_write_wb_o = csr_wr_wb_q;
  assign csr_waddr_wb_o = opcode_wb_q[31:20];
  assign csr_wdata_wb_o = csr_wdata_wb_q;

  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin if (
  );
  else if (
  );
  else if (
  );
  else if (
  );
  begin case (
  );
  else if (
  );
  riscv_trace_sim u_trace_d (
    .valid_i(issue_valid_i),
    .pc_i(issue_pc_i),
    .opcode_i(issue_opcode_i)
  );
  riscv_trace_sim u_trace_wb (
    .valid_i(valid_wb_o),
    .pc_i(pc_wb_o),
    .opcode_i(opcode_wb_o)
  );
endmodule

module riscv_regfile
#(
  parameter int SUPPORT_REGFILE_XILINX = 0
)
(
  input wire clk_i,
  input wire rst_i
);


  function [31:0] get_register();
    get_register  = reg_r1_q;
    get_register  = reg_r2_q;
    get_register  = reg_r3_q;
    get_register  = reg_r4_q;
    get_register  = reg_r5_q;
    get_register  = reg_r6_q;
    get_register  = reg_r7_q;
    get_register  = reg_r8_q;
    get_register  = reg_r9_q;
    get_register  = reg_r10_q;
    get_register  = reg_r11_q;
    get_register  = reg_r12_q;
    get_register  = reg_r13_q;
    get_register  = reg_r14_q;
    get_register  = reg_r15_q;
    get_register  = reg_r16_q;
    get_register  = reg_r17_q;
    get_register  = reg_r18_q;
    get_register  = reg_r19_q;
    get_register  = reg_r20_q;
    get_register  = reg_r21_q;
    get_register  = reg_r22_q;
    get_register  = reg_r23_q;
    get_register  = reg_r24_q;
    get_register  = reg_r25_q;
    get_register  = reg_r26_q;
    get_register  = reg_r27_q;
    get_register  = reg_r28_q;
    get_register  = reg_r29_q;
    get_register  = reg_r30_q;
    get_register  = reg_r31_q;
    get_register  = 32'h00000000;
  endfunction

  always @(posedge clk_i) begin
    reg_r1_q  <= 32'h00000000;
    reg_r2_q  <= 32'h00000000;
    reg_r3_q  <= 32'h00000000;
    reg_r4_q  <= 32'h00000000;
    reg_r5_q  <= 32'h00000000;
    reg_r6_q  <= 32'h00000000;
    reg_r7_q  <= 32'h00000000;
    reg_r8_q  <= 32'h00000000;
    reg_r9_q  <= 32'h00000000;
    reg_r10_q  <= 32'h00000000;
    reg_r11_q  <= 32'h00000000;
    reg_r12_q  <= 32'h00000000;
    reg_r13_q  <= 32'h00000000;
    reg_r14_q  <= 32'h00000000;
    reg_r15_q  <= 32'h00000000;
    reg_r16_q  <= 32'h00000000;
    reg_r17_q  <= 32'h00000000;
    reg_r18_q  <= 32'h00000000;
    reg_r19_q  <= 32'h00000000;
    reg_r20_q  <= 32'h00000000;
    reg_r21_q  <= 32'h00000000;
    reg_r22_q  <= 32'h00000000;
    reg_r23_q  <= 32'h00000000;
    reg_r24_q  <= 32'h00000000;
    reg_r25_q  <= 32'h00000000;
    reg_r26_q  <= 32'h00000000;
    reg_r27_q  <= 32'h00000000;
    reg_r28_q  <= 32'h00000000;
    reg_r29_q  <= 32'h00000000;
    reg_r30_q  <= 32'h00000000;
    reg_r31_q  <= 32'h00000000;
  end

  assign ra0_value_o = ra0_value_r;
  assign rb0_value_o = rb0_value_r;

  riscv_xilinx_2r1w u_reg (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .rd0_i(rd0_i),
    .rd0_value_i(rd0_value_i),
    .ra_i(ra0_i),
    .rb_i(rb0_i),
    .ra_value_o(ra0_value_o),
    .rb_value_o(rb0_value_o)
  );
  begin if (
  );
  begin case (
  );
  endcase case (
  );

  generate
    if (SUPPORT_REGFILE_XILINX) begin
    end
  endgenerate
endmodule

module riscv_trace_sim
(
  input wire valid_i,
  input wire [31:0] pc_i,
  input wire [31:0] opcode_i
);
  reg  [79:0] dbg_inst_str;
  reg  [79:0] dbg_inst_ra;
  reg  [79:0] dbg_inst_rb;
  reg  [79:0] dbg_inst_rd;
  reg  [31:0] dbg_inst_imm;
  reg  [31:0] dbg_inst_pc;
  wire  [4:0] ra_idx_w = opcode_i[19:15];
  wire  [4:0] rb_idx_w = opcode_i[24:20];
  wire  [4:0] rd_idx_w = opcode_i[11:7];

  function [79:0] get_regname_str();
    get_regname_str  = "zero";
    get_regname_str  = "ra";
    get_regname_str  = "sp";
    get_regname_str  = "gp";
    get_regname_str  = "tp";
    get_regname_str  = "t0";
    get_regname_str  = "t1";
    get_regname_str  = "t2";
    get_regname_str  = "s0";
    get_regname_str  = "s1";
    get_regname_str  = "a0";
    get_regname_str  = "a1";
    get_regname_str  = "a2";
    get_regname_str  = "a3";
    get_regname_str  = "a4";
    get_regname_str  = "a5";
    get_regname_str  = "a6";
    get_regname_str  = "a7";
    get_regname_str  = "s2";
    get_regname_str  = "s3";
    get_regname_str  = "s4";
    get_regname_str  = "s5";
    get_regname_str  = "s6";
    get_regname_str  = "s7";
    get_regname_str  = "s8";
    get_regname_str  = "s9";
    get_regname_str  = "s10";
    get_regname_str  = "s11";
    get_regname_str  = "t3";
    get_regname_str  = "t4";
    get_regname_str  = "t5";
    get_regname_str  = "t6";
  endfunction

  always begin
    dbg_inst_str  = (" - ");
    dbg_inst_ra  = (" - ");
    dbg_inst_rb  = (" - ");
    dbg_inst_rd  = (" - ");
    dbg_inst_pc  = 32'bx;
    if (valid_i) begin
      dbg_inst_pc  = pc_i;
      dbg_inst_ra  = get_regname_str(ra_idx_w);
      dbg_inst_rb  = get_regname_str(rb_idx_w);
      dbg_inst_rd  = get_regname_str(rd_idx_w);
      dbg_inst_str  = "andi";
      dbg_inst_str  = "addi";
      dbg_inst_str  = "slti";
      dbg_inst_str  = "sltiu";
      dbg_inst_str  = "ori";
      dbg_inst_str  = "xori";
      dbg_inst_str  = "slli";
      dbg_inst_str  = "srli";
      dbg_inst_str  = "srai";
      dbg_inst_str  = "lui";
      dbg_inst_str  = "auipc";
      dbg_inst_str  = "add";
      dbg_inst_str  = "sub";
      dbg_inst_str  = "slt";
      dbg_inst_str  = "sltu";
      dbg_inst_str  = "xor";
      dbg_inst_str  = "or";
      dbg_inst_str  = "and";
      dbg_inst_str  = "sll";
      dbg_inst_str  = "srl";
      dbg_inst_str  = "sra";
      dbg_inst_str  = "jal";
      dbg_inst_str  = "jalr";
      dbg_inst_str  = "beq";
      dbg_inst_str  = "bne";
      dbg_inst_str  = "blt";
      dbg_inst_str  = "bge";
      dbg_inst_str  = "bltu";
      dbg_inst_str  = "bgeu";
      dbg_inst_str  = "lb";
      dbg_inst_str  = "lh";
      dbg_inst_str  = "lw";
      dbg_inst_str  = "lbu";
      dbg_inst_str  = "lhu";
      dbg_inst_str  = "lwu";
      dbg_inst_str  = "sb";
      dbg_inst_str  = "sh";
      dbg_inst_str  = "sw";
      dbg_inst_str  = "ecall";
      dbg_inst_str  = "ebreak";
      dbg_inst_str  = "eret";
      dbg_inst_str  = "csrrw";
      dbg_inst_str  = "csrrs";
      dbg_inst_str  = "csrrc";
      dbg_inst_str  = "csrrwi";
      dbg_inst_str  = "csrrsi";
      dbg_inst_str  = "csrrci";
      dbg_inst_str  = "mul";
      dbg_inst_str  = "mulh";
      dbg_inst_str  = "mulhsu";
      dbg_inst_str  = "mulhu";
      dbg_inst_str  = "div";
      dbg_inst_str  = "divu";
      dbg_inst_str  = "rem";
      dbg_inst_str  = "remu";
      dbg_inst_str  = "fence.i";
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = `DBG_IMM_IMM12;
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = {27'b0, `DBG_IMM_SHAMT};
      dbg_inst_ra  = (" - ");
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = `DBG_IMM_IMM20;
      dbg_inst_ra  = "pc";
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = `DBG_IMM_IMM20;
      dbg_inst_ra  = (" - ");
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = (pc_i + `DBG_IMM_JIMM20);
      rd_idx_w  = = 5'd1)
                    dbg_inst_str = "call";
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = `DBG_IMM_IMM12;
      ra_idx_w  = ((= 5'd1 && `DBG_IMM_IMM12) == 32'b0)
                    dbg_inst_str = "ret");
      rd_idx_w  = = 5'd1)
                    dbg_inst_str = "call (R)";
      dbg_inst_rb  = (" - ");
      dbg_inst_imm  = `DBG_IMM_IMM12;
      dbg_inst_rd  = (" - ");
      dbg_inst_imm  = `DBG_IMM_STOREIMM;
    end
  end

  endcase case (
  );
  else if (
  );
endmodule

module riscv_xilinx_2r1w
(
  input wire clk_i,
  input wire rst_i
);
  wire  [31:0] reg_rs1_w;
  wire  [31:0] reg_rs2_w;
  wire  [31:0] rs1_0_15_w;
  wire  [31:0] rs1_16_31_w;
  wire  [31:0] rs2_0_15_w;
  wire  [31:0] rs2_16_31_w;
  wire  write_enable_w;
  wire  write_banka_w;
  wire  write_bankb_w;
  reg  [31:0] ra_value_r;
  reg  [31:0] rb_value_r;

  always begin
    if ((ra_i == 5'b00000)) begin
    end
  end

  assign reg_rs1_w = (((ra_i[4] == 1'b0)) ? rs1_0_15_w : rs1_16_31_w);
  assign reg_rs2_w = (((rb_i[4] == 1'b0)) ? rs2_0_15_w : rs2_16_31_w);
  assign write_enable_w = ((rd0_i != 5'b00000));
  assign write_banka_w = ((write_enable_w & <unknown_op:~>);
  assign write_bankb_w = ((write_enable_w & rd0_i[4]);
  assign ra_value_o = ra_value_r;
  assign rb_value_o = rb_value_r;

  RAM16X1D reg_bit1a (
    .WCLK(clk_i),
    .WE(write_banka_w),
    .A0(rd0_i[0]),
    .A1(rd0_i[1]),
    .A2(rd0_i[2]),
    .A3(rd0_i[3]),
    .D(rd0_value_i[i]),
    .DPRA0(ra_i[0]),
    .DPRA1(ra_i[1]),
    .DPRA2(ra_i[2]),
    .DPRA3(ra_i[3]),
    .DPO(rs1_0_15_w[i]),
    .SPO()
  );
  RAM16X1D reg_bit2a (
    .WCLK(clk_i),
    .WE(write_banka_w),
    .A0(rd0_i[0]),
    .A1(rd0_i[1]),
    .A2(rd0_i[2]),
    .A3(rd0_i[3]),
    .D(rd0_value_i[i]),
    .DPRA0(rb_i[0]),
    .DPRA1(rb_i[1]),
    .DPRA2(rb_i[2]),
    .DPRA3(rb_i[3]),
    .DPO(rs2_0_15_w[i]),
    .SPO()
  );
  end for (
  );
  RAM16X1D reg_bit1b (
    .WCLK(clk_i),
    .WE(write_bankb_w),
    .A0(rd0_i[0]),
    .A1(rd0_i[1]),
    .A2(rd0_i[2]),
    .A3(rd0_i[3]),
    .D(rd0_value_i[i]),
    .DPRA0(ra_i[0]),
    .DPRA1(ra_i[1]),
    .DPRA2(ra_i[2]),
    .DPRA3(ra_i[3]),
    .DPO(rs1_16_31_w[i]),
    .SPO()
  );
  RAM16X1D reg_bit2b (
    .WCLK(clk_i),
    .WE(write_bankb_w),
    .A0(rd0_i[0]),
    .A1(rd0_i[1]),
    .A2(rd0_i[2]),
    .A3(rd0_i[3]),
    .D(rd0_value_i[i]),
    .DPRA0(rb_i[0]),
    .DPRA1(rb_i[1]),
    .DPRA2(rb_i[2]),
    .DPRA3(rb_i[3]),
    .DPO(rs2_16_31_w[i]),
    .SPO()
  );
  begin if (
  );
endmodule

module RAM16X1D;
  reg  [15:0] mem;
  wire  [3:0] adr;

  assign adr = {A3, A2, A1, A0};
  assign SPO = mem[adr];
  assign DPO = mem[{DPRA3, DPRA2, DPRA1, DPRA0}];
endmodule
