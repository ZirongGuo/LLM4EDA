module test_032 (
  input  wire [7:0] a,
  output wire [7:0] not_a,
  output wire [7:0] neg_a
);
  assign not_a = ~a;
  assign neg_a = -a;
endmodule
