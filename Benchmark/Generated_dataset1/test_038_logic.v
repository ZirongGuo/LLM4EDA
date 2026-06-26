module test_038 (
  input  wire [7:0] a, b,
  output wire       logic_and,
  output wire       logic_or,
  output wire       logic_not
);
  assign logic_and = a && b;
  assign logic_or  = a || b;
  assign logic_not = !a;
endmodule
