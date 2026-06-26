module test_016 (
  input  wire [7:0] data,
  output wire [3:0] hi_nibble,
  output wire       lsb,
  output wire [7:0] swapped
);
  assign hi_nibble = data[7:4];
  assign lsb = data[0];
  assign swapped = {data[3:0], data[7:4]};
endmodule
