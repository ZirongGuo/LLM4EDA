module test_073 #(
  parameter integer WIDTH = 8,
  parameter real    DELAY = 1.5,
  parameter         STR  = "hello"
) (
  input  wire [WIDTH-1:0] in,
  output wire [WIDTH-1:0] out
);
  assign out = in;
endmodule
