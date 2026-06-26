module test_085 (
  inout wire [7:0] data_bus,
  input  wire       dir,
  input  wire [7:0] data_out
);
  assign data_bus = dir ? data_out : 8'hzz;
endmodule
