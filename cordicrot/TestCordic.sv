`timescale 1ns / 100ps

`include "../SimSrcGen.sv"
`include "./Cordic.sv"

module TestCordic;
  import SimSrcGen::*;
  logic clk, rst;
  initial GenClk(clk, 8, 10);
  initial GenRst(clk, rst, 2, 2);
  initial #20000 $finish();

  logic signed [9:0] ang = '0, cos, sin, arem;
  always_ff @(posedge clk) begin
    if (rst) ang <= '0;
    else ang <= ang + 1'b1;
  end
  logic en = '1;

  Cordic #(
      .DW(10)
  ) theCordic (
    .*,
    .xin (10'sd500),
    .yin (10'sd0),
    .ain (ang),
    .xout(cos),
    .yout(sin),
    .arem(arem)
  );

endmodule

