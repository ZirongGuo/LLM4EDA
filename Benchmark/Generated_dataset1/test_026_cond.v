module test_026 (
  input  wire       sel,
  input  wire [7:0] a, b,
  output wire [7:0] out
);
  assign out = sel ? a : b;
endmodule
