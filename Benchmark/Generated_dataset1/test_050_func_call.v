module test_050 (
  input  wire [7:0] a, b,
  output reg  [7:0] out
);
  function [7:0] add(input [7:0] x, input [7:0] y);
    add = x + y;
  endfunction

  always_comb begin
    out = add(a, b) + 8'h01;
  end
endmodule
