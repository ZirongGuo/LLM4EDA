module test_018 (
  input  wire       enable,
  input  wire [7:0] d,
  output reg  [7:0] q
);
  always_latch begin
    if (enable)
      q <= d;
  end
endmodule
