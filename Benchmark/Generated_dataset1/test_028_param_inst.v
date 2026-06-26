module sub_width #(
  parameter W = 8
) (
  input  wire [W-1:0] in,
  output wire [W-1:0] out
);
  assign out = ~in;
endmodule

module test_028 (
  input  wire [15:0] in,
  output wire [15:0] out
);
  sub_width #(.W(16)) u_inv (.in(in), .out(out));
endmodule
