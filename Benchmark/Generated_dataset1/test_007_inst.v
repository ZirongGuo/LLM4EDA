module sub_add (
  input  wire [3:0] a, b,
  output wire [4:0] sum
);
  assign sum = a + b;
endmodule

module test_007 (
  input  wire [3:0] x, y,
  output wire [4:0] z
);
  sub_add u_add (.a(x), .b(y), .sum(z));
endmodule
