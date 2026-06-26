module test_080 (
  input  wire [7:0] a, b,
  output wire [7:0] result
);
  assign result = a % b;
endmodule
