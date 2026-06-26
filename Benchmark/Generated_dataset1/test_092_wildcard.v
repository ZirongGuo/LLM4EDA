module test_092 (
  input  wire [7:0] a, b,
  output reg  [7:0] out
);
  always @* begin
    out = a & b;
  end
endmodule
