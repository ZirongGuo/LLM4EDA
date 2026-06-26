module test_099 (
  input  wire [7:0] a, b,
  input  wire       sel,
  output reg  [7:0] out
);
  always_comb begin
    if (sel)
      out = a;
    else
      out = b;
  end
endmodule
