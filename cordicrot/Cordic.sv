`ifndef __CORDIC_SV__
`define __CORDIC_SV__

`include "./CordicStage.sv"

module Cordic #(
    parameter int  DW   = 10,
    parameter int  AW   = DW,
    parameter type dw_t = logic signed [DW-1 : 0],
    parameter type aw_t = logic signed [AW-1 : 0],
    parameter int  ITER = DW
) (
  input  logic clk,
  input  logic rst,
  input  logic en,
  input  dw_t  xin,   //Q1.9
  input  dw_t  yin,   //Q1.9
  input  aw_t  ain,   //Q1.9 [-1,1)->[-pi,pi)
  output dw_t  xout,  //Q1.9
  output dw_t  yout,  //Q1.9
  output aw_t  arem   //Q1.9 [-1,1)->[-pi,pi)
);

  logic signed [DW : 0] x[ITER+1];  //Q2.9 to against overflow
  logic signed [DW : 0] y[ITER+1];  //Q2.9 to against overflow
  logic signed [AW : 0] a[ITER+1];  //Q1.10 [-1,1)->[-pi,pi)
  assign x[0] = xin, y[0] = yin, a[0] = ain <<< 1;  //Q1.9 to Q1.10
  generate
    for (genvar i = 0; i < ITER; i++) begin : g_stages
      CordicStage #(
          .DW (DW + 1),
          .AW (AW + 1),
          .STG(i)
      ) cordicStgs (
        .*,
        .xin (x[i]),
        .yin (y[i]),
        .ain (a[i]),
        .xout(x[i+1]),
        .yout(y[i+1]),
        .aout(a[i+1])
      );
    end
  endgenerate

  localparam real lambda = 0.6072529350;
  wire signed [DW : 0] lam = lambda * 2 ** DW;  // 0.607253(Q1.10)
  // NOTE: [XSIM] SystemVerilog feature "Let" not supported yet for simulation
  // `DEF_FP_MUL(mul, 2, DW - 1, 1, DW, DW - 1);  // Q2.9*Q1.10->Q2.9
  // `DEF_FP_MUL(mul, 2, 9, 1, 10, 9);    // Q2.9*Q1.10->Q2.9

  always_ff @(posedge clk) begin
    if (rst) begin
      xout <= '0;
      yout <= '0;
      arem <= '0;
    end else if (en) begin
      // xout <= mul(x[ITER], lam);
      // yout <= mul(y[ITER], lam);
      xout <= (22'sd1 * x[ITER] * lam) >>> 10;
      yout <= (22'sd1 * y[ITER] * lam) >>> 10;
      //            xout <= (22'(x[ITER]) * 22'(lam)) >>> 10;
      //            yout <= (22'(y[ITER]) * 22'(lam)) >>> 10;
      arem <= a[ITER] >>> 1;
    end
  end
endmodule

`endif
