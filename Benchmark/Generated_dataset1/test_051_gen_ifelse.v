module test_051 #(
  parameter MODE = 0
) (
  input  wire [7:0] in,
  output wire [7:0] out
);
  generate
    if (MODE == 0) begin
      assign out = in;
    end else if (MODE == 1) begin
      assign out = ~in;
    end else begin
      assign out = 8'h00;
    end
  endgenerate
endmodule
