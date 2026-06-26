`define BUS_WIDTH 8
`define ZERO {`BUS_WIDTH{1'b0}}

module test_027 (
  input  wire [`BUS_WIDTH-1:0] in,
  output wire [`BUS_WIDTH-1:0] out
);
  assign out = in ^ `ZERO;
endmodule
