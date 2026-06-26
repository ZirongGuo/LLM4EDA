module sub_full (
  input  wire [7:0] din,
  input  wire       clk,
  output reg  [7:0] dout
);
  always_ff @(posedge clk) begin
    dout <= din;
  end
endmodule

module test_043 (
  input  wire       clk,
  input  wire [7:0] data,
  output wire [7:0] result
);
  sub_full u_reg (.din(data), .clk(clk), .dout(result));
endmodule
