module test_022 (
  input  wire [7:0] in,
  output wire [7:0] out [0:3]
);
  generate
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin
      assign out[i] = in + i;
    end
  endgenerate
endmodule
