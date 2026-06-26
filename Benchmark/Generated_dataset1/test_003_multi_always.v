module test_003 (
  input  wire       clk,
  input  wire [7:0] d,
  output reg  [7:0] q1,
  output reg  [7:0] q2
);
  always_ff @(posedge clk) begin
    q1 <= d;
  end
  always_ff @(posedge clk) begin
    q2 <= q1;
  end
endmodule
