module test_015 (
  input  wire [1:0] mode,
  input  wire [7:0] a, b,
  output reg  [7:0] out
);
  always_comb begin
    if (mode == 2'b00)
      out = a;
    else if (mode == 2'b01)
      out = b;
    else if (mode == 2'b10)
      out = a + b;
    else
      out = a - b;
  end
endmodule
