module test_053 (
  input  wire       clk,
  input  wire [7:0] din,
  output reg  [7:0] dout
);
  integer j;
  always_ff @(posedge clk) begin
    for (j = 7; j >= 0; j = j - 1) begin
      dout[j] <= din[j];
    end
  end
endmodule
