module test_013 (
  input  wire [3:0] nibble,
  output wire [7:0] byte_out,
  output wire [15:0] wide
);
  assign byte_out = {4'h0, nibble};
  assign wide = {2{byte_out}};
endmodule
