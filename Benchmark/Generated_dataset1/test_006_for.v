module test_006 (
  input  wire       clk,
  input  wire [7:0] in,
  output reg  [7:0] out
);
  integer i;
  always_ff @(posedge clk) begin
    for (i = 0; i < 8; i = i + 1) begin
      out[i] <= in[i];
    end
  end
endmodule
