`ifdef USE_FAST
  `define DELAY 1
`else
  `define DELAY 2
`endif

module test_068 (
  input  wire [7:0] in,
  output wire [7:0] out
);
  assign out = in;
endmodule
