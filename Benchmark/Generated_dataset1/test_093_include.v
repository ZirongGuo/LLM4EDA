`include "test_001_basic.v"

module test_093 (
  input  wire clk,
  output wire [7:0] q
);
  test_001 u_test (.clk(clk), .rst_n(1'b1), .q(q));
endmodule
