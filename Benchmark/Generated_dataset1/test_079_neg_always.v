module test_079 (
  input  wire [7:0] in,
  output reg  [7:0] out
);
  always_comb begin
    out = ~in;
  end
endmodule
