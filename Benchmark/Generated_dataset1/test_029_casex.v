module test_029 (
  input  wire [3:0] cmd,
  output reg  [7:0] out
);
  always_comb begin
    casex (cmd)
      4'b1xxx: out = 8'hA0;
      4'b01xx: out = 8'hB0;
      4'b001x: out = 8'hC0;
      4'b0001: out = 8'hD0;
      default: out = 8'h00;
    endcase
  end
endmodule
