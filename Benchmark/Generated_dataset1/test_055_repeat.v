module test_055 (
  input  wire       clk,
  input  wire [7:0] din,
  output reg  [7:0] dout
);
  integer m;
  always_ff @(posedge clk) begin
    m = 0;
    repeat (8) begin
      dout[m] <= din[m];
      m = m + 1;
    end
  end
endmodule
