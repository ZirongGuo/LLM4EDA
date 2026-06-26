module test_039 (
  input  wire [7:0] a, b,
  output wire [7:0] band, bor, bxor, bxnor
);
  assign band = a & b;
  assign bor  = a | b;
  assign bxor = a ^ b;
  assign bxnor = a ^~ b;
endmodule
