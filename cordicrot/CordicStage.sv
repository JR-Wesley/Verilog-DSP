`ifndef __CORDIC_STAGE_SV__
`define __CORDIC_STAGE_SV__

module CordicStage #(
    parameter int  DW   = 10,
    parameter int  AW   = DW,
    parameter type dw_t = logic signed [DW-1 : 0],
    parameter type aw_t = logic signed [AW-1 : 0],
    parameter int  STG  = 0
) (
  input  logic clk,
  input  logic rst,
  input  logic en,
  input  dw_t  xin,   // x_i
  input  dw_t  yin,   // y_i
  input  aw_t  ain,   // theta_i
  output dw_t  xout,  // x_i+1
  output dw_t  yout,  // y_i+1
  output aw_t  aout   // theta_i+1
);

  // atan:real:[-pi, pi) <=> theta:(Q1.(AW-1)):[-1.0, 1.0) 
  localparam real atan = $atan(2.0 ** (-STG));
  wire [AW-1 : 0] theta = atan / 3.1415926536 * 2.0 ** (AW - 1);
  wire signed [DW-1 : 0] x_shifted = (xin >>> STG);
  wire signed [DW-1 : 0] y_shifted = (yin >>> STG);
  always_ff @(posedge clk) begin
    if (rst) begin
      aout <= '0;
      xout <= '0;
      yout <= '0;
    end else if (en) begin
      if (ain >= 0) begin
        aout <= ain - theta;
        xout <= xin - y_shifted;
        yout <= yin + x_shifted;
      end else begin
        aout <= ain + theta;
        xout <= xin + y_shifted;
        yout <= yin - x_shifted;
      end
    end
  end
endmodule

`endif
