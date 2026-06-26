module test_001 (
  input  wire       clk,
  input  wire       rst_n,
  output reg  [7:0] q
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      q <= 8'h00;
    else
      q <= q + 8'h01;
  end
endmodule
