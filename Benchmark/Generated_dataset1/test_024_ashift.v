module test_024 (
  input  wire signed [7:0] a,
  output wire signed [7:0] sha,
  output wire signed [7:0] shb
);
  assign sha = a >>> 2;
  assign shb = a <<< 2;
endmodule
