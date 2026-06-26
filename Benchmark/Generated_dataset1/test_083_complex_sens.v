module test_083 (
  input  wire [7:0] a, b, c, d,
  output reg  [7:0] out
);
  always @(a or b or c or d) begin
    out = (a & b) | (c ^ d);
  end
endmodule
