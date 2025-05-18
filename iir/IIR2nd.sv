`ifndef __IIR2ND_SV__
`define __IIR2ND_SV__
`include "../Fixedpoint.sv"

module IIR2nd #(
    parameter int  DW      = 14,
    parameter int  FW      = 9,
    parameter real GAIN,
    parameter real NUM [3],
    parameter real DEN [2]
) (
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   en,
  input  logic signed [DW-1 : 0] in,     // Q(DW-FW).FW
  output logic signed [DW-1 : 0] out     // Q(DW-FW).FW
);

  import Fixedpoint::*;
  wire signed [DW-1:0] n0 = (NUM[0] * 2.0 ** FW);
  wire signed [DW-1:0] n1 = (NUM[1] * 2.0 ** FW);
  wire signed [DW-1:0] n2 = (NUM[2] * 2.0 ** FW);
  wire signed [DW-1:0] d1 = (DEN[0] * 2.0 ** FW);
  wire signed [DW-1:0] d2 = (DEN[1] * 2.0 ** FW);
  wire signed [DW-1:0] g = (GAIN * 2.0 ** FW);
  `DEF_FP_MUL(mul, DW - FW, FW, DW - FW, FW, FW);

  logic signed [DW-1:0] z1, z0;
  wire signed [DW-1:0] pn0 = mul(in, n0);
  wire signed [DW-1:0] pn1 = mul(in, n1);
  wire signed [DW-1:0] pn2 = mul(in, n2);

  wire signed [DW-1:0] o = pn0 + z0;
  wire signed [DW-1:0] pd1 = mul(o, d1);
  wire signed [DW-1:0] pd2 = mul(o, d2);

  always_ff @(posedge clk) begin
    if (!rst_n) begin
      z0 <= '0;
      z1 <= '0;
      out <= '0;
    end else if (en) begin
      z1 <= pn2 - pd2;
      z0 <= pn1 - pd1 + z1;
      out <= mul(o, g);
    end
  end

endmodule

`endif
