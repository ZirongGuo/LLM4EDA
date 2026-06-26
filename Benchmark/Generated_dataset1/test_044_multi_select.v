module test_044 (
  input  wire [31:0] word,
  output wire [7:0] byte0,
  output wire [7:0] byte1,
  output wire [7:0] byte2,
  output wire [7:0] byte3
);
  assign byte0 = word[7:0];
  assign byte1 = word[15:8];
  assign byte2 = word[23:16];
  assign byte3 = word[31:24];
endmodule
