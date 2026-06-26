module test_045 (
  input  wire [3:0] a, b,
  output wire [15:0] out
);
  assign out = {a, b, {2{4'hF}}};
endmodule
