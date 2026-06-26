module test_030 (
  input  wire [3:0] sel,
  output reg  [7:0] out
);
  always_comb begin
    casez (sel)
      4'b1???: out = 8'h11;
      4'b01??: out = 8'h22;
      4'b001?: out = 8'h33;
      default: out = 8'hFF;
    endcase
  end
endmodule
