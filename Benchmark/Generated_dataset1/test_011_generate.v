module test_011 #(
  parameter USE_ADD = 1
) (
  input  wire [7:0] a, b,
  output wire [7:0] out
);
  generate
    if (USE_ADD) begin
      assign out = a + b;
    end else begin
      assign out = a - b;
    end
  endgenerate
endmodule
