module test_010 (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] sum,
  output reg  [7:0] diff
);
  task add_sub(input [7:0] x, input [7:0] y, output [7:0] s, output [7:0] d);
    s = x + y;
    d = x - y;
  endtask

  always_comb begin
    add_sub(a, b, sum, diff);
  end
endmodule
