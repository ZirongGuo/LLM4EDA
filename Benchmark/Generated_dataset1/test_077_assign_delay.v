module test_077 (
  input  wire [7:0] in,
  output wire [7:0] out
);
  assign #5 out = in;
endmodule
