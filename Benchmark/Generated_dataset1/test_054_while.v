module test_054 (
  input  wire       clk,
  input  wire [7:0] din,
  output reg  [7:0] dout
);
  integer k;
  always_ff @(posedge clk) begin
    k = 0;
    while (k < 8) begin
      dout[k] <= din[k];
      k = k + 1;
    end
  end
endmodule
