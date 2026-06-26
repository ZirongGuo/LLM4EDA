module test_078 (
  input  wire [7:0] a, b, c,
  output wire [7:0] x, y
);
  assign x = a + b;
  assign y = b + c;
endmodule
