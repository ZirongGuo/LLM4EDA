module test_012 (
  input  wire       signed [7:0] a,
  input  wire       signed [7:0] b,
  output reg  signed [8:0] result
);
  always_comb begin
    result = a * b;
  end
endmodule
