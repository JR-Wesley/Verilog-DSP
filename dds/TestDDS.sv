`timescale 1ns / 100ps

`include "../SimSrcGen.sv"
`include "./DDS.sv"

module TestDDS;
  import SimSrcGen::*;
  logic clk, rst;
  initial GenClk(clk, 8, 10);
  initial GenRst(clk, rst, 2, 2);
  initial #3000000 $finish();

  real freqr = 1e6, fstepr = 49e6 / (1e-3 * 100e6);  // from 1MHz to 50MHz in 1ms
  always @(posedge clk) begin
    if (rst) freqr <= 1e6;
    else freqr <= freqr + fstepr;
  end

  logic signed [31:0] freq;
  always @(posedge clk) begin
    freq <= 2.0 ** 32 * freqr / 100e6;  // frequency to freq control word
  end
  logic signed [31:0] phase = '0;
  logic signed [9:0] swave;
  logic en = '1;
  DDS #(
      .PW(32),
      .DW(10),
      .AW(13)
  ) theDDS (
    .*,
    .out(swave)
  );

endmodule

