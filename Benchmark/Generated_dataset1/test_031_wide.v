module test_031 (
  input  wire [31:0] a,
  input  wire [31:0] b,
  output wire [31:0] sum,
  output wire [31:0] diff
);
  assign sum  = a + b;
  assign diff = a - b;
endmodule
