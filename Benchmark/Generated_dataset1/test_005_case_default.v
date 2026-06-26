module test_005 (
  input  wire [1:0] sel,
  input  wire [7:0] a, b,
  output reg  [7:0] out
);
  always_comb begin
    case (sel)
      2'b00: out = a;
      2'b01: out = b;
      default: out = 8'hFF;
    endcase
  end
endmodule
