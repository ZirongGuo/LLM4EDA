module test_095 #(
  parameter W = 8,
  parameter N = W * 2,
  parameter M = W + 4
) (
  input  wire [N-1:0] in,
  output wire [M-1:0] out
);
  assign out = in[M-1:0];
endmodule
