module test_046 (
  input  wire       clk,
  input  wire       rst_n,
  output reg  [7:0] cnt
);
  reg [7:0] state = 8'hA5;
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      cnt <= 8'h00;
      state <= 8'hA5;
    end else begin
      cnt <= cnt + 8'h01;
      state <= state + 8'h01;
    end
  end
endmodule
