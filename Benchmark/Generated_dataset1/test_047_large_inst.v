module sub_alu (
  input  wire [7:0] a, b,
  input  wire       op,
  output wire [7:0] result
);
  assign result = op ? (a + b) : (a - b);
endmodule

module test_047 (
  input  wire [7:0] x, y,
  input  wire       op_sel,
  output wire [7:0] res
);
  sub_alu u_alu (.a(x), .b(y), .op(op_sel), .result(res));
endmodule
