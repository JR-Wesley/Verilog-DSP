`timescale 1ns / 100ps

`include "../SimSrcGen.sv"
`include "./Counter.sv"
`include "../dds/DDS.sv"
`include "./IIR.sv"

module TestIir;
  import SimSrcGen::*;
  logic clk, rst_n;
  initial GenClk(clk, 80, 100);
  initial GenRstn(clk, rst_n, 2, 2);
  initial #1e7 $finish();

  real freqr = 1e6, fstepr = 49e6 / (1e-3 * 100e6);  // from 1MHz to 50MHz in 1ms
  always @(posedge clk) begin
    if (!rst_n) freqr <= 1e6;
    else freqr <= freqr + fstepr;
  end
  logic signed [31:0] freq;
  always @(posedge clk) begin
    freq <= 2.0 ** 32 * freqr / 100e6;  // freq control word
  end

  logic en;
  assign en = 1'b1;
  logic signed [31:0] phase = '0;
  logic signed [9:0] swave;
  DDS #(
      .PW(32),
      .DW(10),
      .AW(13)
  ) theDDS (
    .*,
    .out(swave)
  );

  logic signed [9:0] filtered, harm3;
  logic square = '0, en15;
  Counter #(
      .M(15)
  ) cnt15 (
    .*,
    .cnt(),
    .co (en15)
  );

  always_ff @(posedge clk) if (en15) square <= ~square;
  IIR #(
      .DW(10),
      .EW(5),
      .STG(3),
      .GAIN('{0.262748, 0.262748, 0.060908})
      ,  // GAIN
      .NUM(
      '{
          '{1, -1.368053, 1},  // s0:NUM
          '{1, -1.779618, 1},  // s1:NUM
          '{1, 0, -1}
      }
      ),  // s2:NUM
      .DEN(
      '{
          '{-1.519556, 0.969571},  // s0:DEN
          '{-1.665517, 0.974258},  // s1:DEN
          '{-1.569518, 0.936203}
      }  // s2:DEN
      )
  )
      theIir1 (
        .*,
        .in (10'(integer'(swave * 0.9))),
        .out(filtered)
      ),
      theIir2 (
        .*,
        .in (square ? 10'sd500 : -10'sd500),
        .out(harm3)
      );

endmodule


