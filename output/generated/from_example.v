`include "defines.vh"
`define WORD_SIZE 32
`define RESET_PC 32'h00001000

module riscv_core
#(
  parameter int XLEN = 32
)
(
  input wire clk,
  input wire rst_n,
  output reg [31:0] inst_mem_addr,
  input wire [31:0] inst_mem_data
);

  reg  [31:0] pc_current = 32'h0;
  wire  [31:0] pc_next;
  wire  [31:0] instruction;

  function logic [31:0] alu_add(logic [31:0] a, logic [31:0] b);
    return (a + b);
  endfunction

  task pipeline_flush();
    pc_current  = pc_next;
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      pc_current  <= 32'h00001000;
    end else begin
      pc_current  <= (pc_current + 32'h4);
    end
  end
  always_comb begin
    case (instruction)
      32'b00000000000000000000000000110011: begin
        pc_next  = alu_result;
      end
      default: begin
        pc_next  = (pc_current + 32'h4);
      end
    endcase
  end

  assign #1 inst_mem_addr = pc_current;

  alu #(
    .WIDTH(XLEN)
  ) u_alu (
    .a(pc_current),
    .b(32'h4),
    .op(alu_op),
    .result(alu_result)
  );

  generate
    if ((XLEN == 32)) begin
  special_alu_32 u_special_32bit (
  );
    end
  endgenerate
endmodule
