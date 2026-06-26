module test_094 (
  input  wire [7:0] a [0:3],
  output wire [7:0] out [0:3]
);
  assign out[0] = a[0];
  assign out[1] = a[1];
  assign out[2] = a[2];
  assign out[3] = a[3];
endmodule
