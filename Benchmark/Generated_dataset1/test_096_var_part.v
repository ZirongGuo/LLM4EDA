module test_096 (
  input  wire [31:0] data,
  input  wire [3:0]  idx,
  output wire [7:0]  slice
);
  assign slice = data[idx*8 +: 8];
endmodule
