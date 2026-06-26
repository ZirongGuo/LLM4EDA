module test_017 (
  input  wire       clk,
  input  wire [7:0] d,
  output reg  [7:0] q_comb,
  output reg  [7:0] q_seq
);
  always_comb begin
    q_comb = d;
  end
  always_ff @(posedge clk) begin
    q_seq <= d;
  end
endmodule
