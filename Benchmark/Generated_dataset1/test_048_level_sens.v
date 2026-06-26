module test_048 (
  input  wire [7:0] a, b,
  input  wire       sel,
  output reg  [7:0] out
);
  always @(a or b or sel) begin
    if (sel)
      out = a;
    else
      out = b;
  end
endmodule
