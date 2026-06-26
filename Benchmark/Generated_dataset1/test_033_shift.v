module test_033 (
  input  wire [7:0] a,
  input  wire [2:0] shamt,
  output wire [7:0] shl,
  output wire [7:0] shr
);
  assign shl = a << shamt;
  assign shr = a >> shamt;
endmodule
