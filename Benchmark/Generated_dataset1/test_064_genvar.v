module test_064 (
  input  wire [7:0] in [0:3],
  output wire [7:0] out [0:3]
);
  genvar g;
  generate
    for (g = 0; g < 4; g = g + 1) begin
      assign out[g] = ~in[g];
    end
  endgenerate
endmodule
