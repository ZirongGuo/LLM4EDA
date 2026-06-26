module test_023 (
  input  wire [7:0] data,
  output wire       all_and,
  output wire       all_or,
  output wire       all_xor
);
  assign all_and = &data;
  assign all_or  = |data;
  assign all_xor = ^data;
endmodule
