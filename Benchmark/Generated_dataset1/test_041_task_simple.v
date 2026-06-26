module test_041 (
  input  wire       clk,
  input  wire [7:0] d,
  output reg  [7:0] q
);
  task update;
    q <= d;
  endtask

  always_ff @(posedge clk) begin
    update;
  end
endmodule
