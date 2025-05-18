`timescale 1ns / 100ps

`include "../SimSrcGen.sv"
`include "../dds/DDS.sv"
`include "./Counter.sv"
`include "./FIR.sv"

module TestFir;
  import SimSrcGen::*;
  logic clk, rst_n;
  initial GenClk(clk, 80, 100);
  initial GenRstn(clk, rst_n, 2, 2);
  initial #1e7 $finish();

  // frequency step control
  real freqr = 1e6, fstepr = 49e6 / (1e-3 * 100e6);  // from 1MHz to 50MHz in 1ms
  always @(posedge clk) begin
    if (!rst_n) freqr = 1e6;
    else freqr += fstepr;
  end
  logic signed [31:0] freq;
  always @(posedge clk) begin
    freq <= 2.0 ** 32 * freqr / 100e6;  // frequency to freq control word
  end

  logic signed [31:0] phase = '0;
  logic signed [9:0] swave;
  logic en;
  assign en = 1'b1;
  DDS #(
      .PW(32),
      .DW(10),
      .AW(13)
  ) theDDS (
    .*,
    .out(swave)
  );

  logic square = '0, en15;
  Counter #(15) cnt15 (
    .*,
    .cnt(),
    .co (en15)
  );
  always_ff @(posedge clk) if (en15) square <= ~square;

  // 26-stage FIR band pass 0.18pi~0.22pi (9M-11M@100MHz)
  // band ripple 1dB， stop band 0~0.07pi 0.33pi~pi
  // stop band reduction 38dB
  logic signed [9:0] filtered, harm3;
  FIR #(
      .DW(10),
      .TAPS(27),
      .COEF(
      '{
          -0.005646,
          0.006428,
          0.019960,
          0.033857,
          0.036123,
          0.016998,
          -0.022918,
          -0.068988,
          -0.097428,
          -0.087782,
          -0.036153,
          0.039431,
          0.106063,
          0.132519,
          0.106063,
          0.039431,
          -0.036153,
          -0.087782,
          -0.097428,
          -0.068988,
          -0.022918,
          0.016998,
          0.036123,
          0.033857,
          0.019960,
          0.006428,
          -0.005646
      }
      )
  )
      theFir1 (
        .*,
        .in (10'(integer'(swave * 0.9))),
        .out(filtered)
      ),
      theFir2 (
        .*,
        .in (square ? 10'sd500 : -10'sd500),
        .out(harm3)
      );

endmodule

