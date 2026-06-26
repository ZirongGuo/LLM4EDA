module test_066 (
  input  wire [7:0] a, b,
  output wire [7:0] xnor_out
);
  assign xnor_out = ~(a ^ b);
endmodule
