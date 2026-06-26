module test_098 (
  input  wire [3:0] a, b, c, d,
  output wire [15:0] out
);
  assign out = {a, b, c, d};
endmodule
