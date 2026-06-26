module test_061 (
  input  wire       clk,
  input  wire [7:0] in,
  output reg  [7:0] out
);
  integer idx;
  always_ff @(posedge clk) begin
    for (idx = 0; idx < 8; idx = idx + 1) begin
      out[idx] <= in[idx];
    end
  end
endmodule
