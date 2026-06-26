module test_042 (
  input  wire [7:0] a, b, c, d,
  output wire [7:0] result
);
  assign result = (a + b) * (c - d) / 8'h02;
endmodule
