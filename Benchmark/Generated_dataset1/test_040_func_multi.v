module test_040 (
  input  wire [7:0] a, b, c,
  output reg  [7:0] result
);
  function [7:0] median(input [7:0] x, input [7:0] y, input [7:0] z);
    if ((x >= y && x <= z) || (x >= z && x <= y))
      median = x;
    else if ((y >= x && y <= z) || (y >= z && y <= x))
      median = y;
    else
      median = z;
  endfunction

  always_comb begin
    result = median(a, b, c);
  end
endmodule
