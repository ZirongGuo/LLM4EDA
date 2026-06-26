module test_088 (
  input  wire [3:0] lo, hi,
  output wire [3:0] out_hi,
  output wire [3:0] out_lo
);
  wire [7:0] merged = {hi, lo};
  assign out_hi = merged[7:4];
  assign out_lo = merged[3:0];
endmodule
