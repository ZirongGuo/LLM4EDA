module test_014 (
  input  wire [7:0] in,
  output wire [7:0] out
);
  localparam OFFSET = 8'h20;
  assign out = in + OFFSET;
endmodule
