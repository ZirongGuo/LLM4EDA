module test_087 (
  input  wire [1:0] sel,
  input  wire [7:0] a, b,
  output reg  [7:0] result
);
  always_comb begin
    case (sel)
      2'b00: begin
        result = a + b;
      end
      2'b01: begin
        result = a - b;
      end
      2'b10: begin
        result = a & b;
      end
      default: begin
        result = 8'h00;
      end
    endcase
  end
endmodule
