module test_025 (
  input  wire [7:0] a, b,
  output wire eq,
  output wire neq,
  output wire case_eq,
  output wire case_neq
);
  assign eq      = (a == b);
  assign neq     = (a != b);
  assign case_eq = (a === b);
  assign case_neq = (a !== b);
endmodule
