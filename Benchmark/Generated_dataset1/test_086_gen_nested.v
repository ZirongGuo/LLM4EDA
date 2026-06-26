module test_086 #(
  parameter A = 1,
  parameter B = 0
) (
  input  wire [7:0] in,
  output wire [7:0] out
);
  generate
    if (A) begin
      if (B) begin
        assign out = in + 8'h01;
      end else begin
        assign out = in;
      end
    end else begin
      assign out = 8'h00;
    end
  endgenerate
endmodule
