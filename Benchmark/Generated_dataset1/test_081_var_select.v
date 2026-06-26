module test_081 (
  input  wire [7:0] data,
  input  wire [2:0] index,
  output wire       bit_out
);
  assign bit_out = data[index];
endmodule
