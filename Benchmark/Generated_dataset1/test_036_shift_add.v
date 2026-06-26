module test_036 (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [15:0] product
);
  assign product = a * b;
endmodule
