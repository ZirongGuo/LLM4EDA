`define ADD(a, b) ((a) + (b))
`define MUL(a, b) ((a) * (b))

module test_067 (
  input  wire [7:0] x, y,
  output wire [7:0] result
);
  assign result = `ADD(x, y);
endmodule
