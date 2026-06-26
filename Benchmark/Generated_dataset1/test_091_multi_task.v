module test_091 (
  input  wire [7:0] a, b,
  output reg  [7:0] sum,
  output reg  [7:0] diff
);
  task do_add(input [7:0] x, input [7:0] y, output [7:0] z);
    z = x + y;
  endtask

  task do_sub(input [7:0] x, input [7:0] y, output [7:0] z);
    z = x - y;
  endtask

  always_comb begin
    do_add(a, b, sum);
    do_sub(a, b, diff);
  end
endmodule
