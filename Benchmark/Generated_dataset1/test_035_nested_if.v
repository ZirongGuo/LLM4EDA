module test_035 (
  input  wire [1:0] sel,
  input  wire [7:0] a, b, c,
  output reg  [7:0] out
);
  always_comb begin
    if (sel == 2'b00) begin
      out = a;
    end else begin
      if (sel == 2'b01) begin
        out = b;
      end else begin
        out = c;
      end
    end
  end
endmodule
