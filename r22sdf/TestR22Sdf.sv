`include "R22SdfDefinesPkg.svh"

`include "../../SimSrcGen.sv"
// `default_nettype none
// `timescale 1ns / 100ps

module TestR22Sdf;
  import SimSrcGen::*;
  import R22SdfDefinesPkg::*;

  localparam unsigned STG = 2, LEN = 4 ** STG;

  logic clk, rst;
  initial GenClk(clk, 8000, 10000);
  initial GenRst(clk, rst, 2, 2);

  cplx_t x[LEN];

  initial begin
    for (int n = 0; n < LEN; n++) begin
      x[n].re = n < 3 * LEN / 4 ? 16'sd500 : -16'sd500;
      x[n].im = 16'sd0;
    end
  end

  logic [STG*2 - 1 : 0] cnt = '0, cntidx;
  assign cntidx = {<<{cnt+ 1'b1}};
  logic sc = '0, inv = '0;
  cplx_t out;
  wire sync = cnt == '1;

  R22Sdf #(STG) theR22Sdf (
      clk,
      rst,
      1'b1,
      x[cnt],
      out,
      sync,
      sc,
      inv
  );

  always @(posedge clk) begin
    if (rst) cnt <= '0;
    else cnt <= cnt + 1'b1;
  end

endmodule

