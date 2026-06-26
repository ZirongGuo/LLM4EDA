module test_082 (
  input  wire [7:0] a, b,
  input  wire       sel,
  output wire [7:0] out
);
  assign out = (sel) ? (a + 8'h01) : (b - 8'h01);
endmodule
