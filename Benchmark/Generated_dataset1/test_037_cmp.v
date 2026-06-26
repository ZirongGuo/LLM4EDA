module test_037 (
  input  wire [7:0] a, b,
  output wire lt, gt, eq, le, ge, ne
);
  assign lt = a <  b;
  assign gt = a >  b;
  assign eq = a == b;
  assign le = a <= b;
  assign ge = a >= b;
  assign ne = a != b;
endmodule
