module test_090 (
  input  wire [7:0] a, b,
  output reg  [7:0] sum,
  output reg  [7:0] diff
);
  function [7:0] add(input [7:0] x, input [7:0] y);
    add = x + y;
  endfunction

  function [7:0] sub(input [7:0] x, input [7:0] y);
    sub = x - y;
  endfunction

  always_comb begin
    sum  = add(a, b);
    diff = sub(a, b);
  end
endmodule
