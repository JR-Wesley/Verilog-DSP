`timescale 1ns / 100ps

`include "../SimSrcGen.sv"
`include "./SlowMult.sv"

module TestSlowMult;

  import SimSrcGen::*;
  logic clk, rst;
  initial GenClk(clk, 8, 10);
  initial GenRst(clk, rst, 2, 2);
  wire rst_n = ~rst;

  localparam int DW = 8;
  logic [DW-1 : 0] mcand = '0, mer = '0;
  logic start = '0, valid, busy;
  logic [2*DW-1 : 0] product;
  SlowMult #(DW) theSM (
    .*,
    .multiplicand(mcand),
    .multiplier  (mer)
  );

  initial begin
    repeat (10) @(posedge clk);
    repeat (10) begin
      @(negedge clk) begin
        mcand = ($urandom() % (2 ** DW));
        mer = ($urandom() % (2 ** DW));
        start = '1;
      end
      @(negedge clk) start = '0;
      do @(negedge clk); while (busy);
    end
    @(posedge clk) $finish();
  end

  always_ff @(posedge clk) begin
    if (valid & product != (32'(mcand) * mer))
      $display("err: %d * %d -> %d should be %d", mcand, mer, product, (32'(mcand) * mer));
  end
endmodule

