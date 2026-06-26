module test_009 (
  input  wire [7:0] a,
  input  wire [7:0] b,
  output reg  [7:0] result
);
  function [7:0] max(input [7:0] x, input [7:0] y);
    if (x > y)
      max = x;
    else
      max = y;
  endfunction

  always_comb begin
    result = max(a, b);
  end
endmodule
