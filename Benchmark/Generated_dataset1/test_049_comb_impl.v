module test_049 (
  input  wire [7:0] a, b,
  output reg  [7:0] out
);
  always_comb begin
    out = a ^ b;
  end
endmodule
