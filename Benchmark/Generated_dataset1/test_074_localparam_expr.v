module test_074 #(
  parameter BASE = 16
) (
  input  wire [7:0] in,
  output wire [7:0] out
);
  localparam DOUBLE = BASE * 2;
  localparam HALF   = BASE / 2;
  assign out = in + DOUBLE;
endmodule
