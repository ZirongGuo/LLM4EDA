module test_089 (
  input  wire [7:0] in,
  output wire [7:0] out [0:3]
);
  generate
    genvar gi;
    for (gi = 0; gi < 4; gi = gi + 1) begin
      if (gi < 2) begin
        assign out[gi] = in + gi;
      end else begin
        assign out[gi] = in - gi;
      end
    end
  endgenerate
endmodule
