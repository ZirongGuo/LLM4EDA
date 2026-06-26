module test_069 (
  input  wire       clk,
  input  wire       rst_n,
  input  wire [7:0] addr,
  input  wire [7:0] wdata,
  output reg  [7:0] rdata,
  input  wire       we
);
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      rdata <= 8'h00;
    else if (we)
      rdata <= wdata;
  end
endmodule
