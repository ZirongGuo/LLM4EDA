module test_075 (
  output reg [7:0] val
);
  function [7:0] get_const;
    get_const = 8'h42;
  endfunction

  always_comb begin
    val = get_const();
  end
endmodule
