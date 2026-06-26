module test_052 #(
  parameter OP = 0
) (
  input  wire [7:0] a, b,
  output wire [7:0] out
);
  generate
    case (OP)
      0: assign out = a + b;
      1: assign out = a - b;
      2: assign out = a & b;
      default: assign out = 8'h00;
    endcase
  endgenerate
endmodule
