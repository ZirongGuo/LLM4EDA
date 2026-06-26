module test_020 (
  input  wire       oe,
  input  wire [7:0] data_in,
  output wire [7:0] data_bus
);
  assign data_bus = oe ? data_in : 8'hzz;
endmodule
