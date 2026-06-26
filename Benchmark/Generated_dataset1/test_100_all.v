`define W 8

module test_100 #(
  parameter P = 16
) (
  input  wire          clk,
  input  wire          rst_n,
  input  wire [3:0]    sel,
  input  wire [`W-1:0] a, b,
  output reg  [`W-1:0] out,
  output wire [`W-1:0] pass
);

  localparam LP = P * 2;
  wire [`W-1:0] w1, w2;
  reg signed [7:0] r1;

  assign w1 = a + b;
  assign w2 = a - b;
  assign pass = (sel == 4'h0) ? w1 : w2;

  function [`W-1:0] max_val(input [`W-1:0] x, input [`W-1:0] y);
    if (x > y)
      max_val = x;
    else
      max_val = y;
  endfunction

  task set_out(input [`W-1:0] v);
    out = v;
  endtask

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      out <= {`W{1'b0}};
    else begin
      case (sel)
        4'h0: out <= a + b;
        4'h1: out <= a - b;
        4'h2: out <= a & b;
        4'h3: out <= a | b;
        default: out <= {`W{1'b0}};
      endcase
    end
  end

  generate
    if (P > 8) begin
      assign pass = w1;
    end else begin
      assign pass = w2;
    end
  endgenerate
endmodule
