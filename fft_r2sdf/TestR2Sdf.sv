`timescale 1ns / 100ps

`include "../../SimSrcGen.sv"
`include "../../chapter4/memory/SpRamRf.sv"
`include "../../chapter6/mm_intercon.sv"
`include "./R2SdfDefinesPkg.sv"
`include "./R2Sdf.sv"

`default_nettype none

module TestR2Sdf;
  initial #50000 $finish;

  import SimSrcGen::*;
  import R2SdfDefinesPkg::*;

  logic clk, rst_n;
  initial GenClk(clk, 8, 10);
  initial GenRstn(clk, rst_n, 2, 2);

  localparam int STG = 4, LEN = 2 ** STG;
  Cplx x[LEN];

  initial begin
    for (int n = 0; n < LEN; n++) begin
      x[n].re = n < 2 * LEN / 4 ? 16'sd10000 : -16'sd10000;
      x[n].im = 16'sd0;
    end
  end

  logic [STG - 1 : 0] cnt = '0;
  logic sc = '1, inv = '0, osync;
  Cplx out;
  wire isync = cnt == '1;

  R2Sdf #(STG) theR2Sdf (
      .clk     (clk),
      .rst_n   (rst_n),
      .en      (1'b1),
      .scale   (sc),
      .invexp  (inv),
      .in      (x[cnt]),
      .in_sync (isync),
      .out     (out),
      .out_sync(osync)
  );

  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) cnt <= '0;
    else cnt <= cnt + 1'b1;
  end

  logic [STG - 1 : 0] dicnt = '0;
  always @(posedge clk, negedge rst_n) begin
    if (!rst_n) dicnt <= '0;
    if (osync) dicnt <= '0;
    else dicnt <= dicnt + 1'b1;
  end

  wire [STG - 1 : 0] dataIdx = {<<{dicnt}};

endmodule

