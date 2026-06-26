module mul2 (
  input  wire [7:0] in,
  output wire [7:0] out
);
  assign out = in << 1;
endmodule

module test_021 (
  input  wire [7:0] in,
  output wire [7:0] out
);
  mul2 u_mul (.in(in), .out(out));
endmodule
