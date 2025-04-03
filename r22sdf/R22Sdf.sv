`ifndef __R22SDF_SV__
`define __R22SDF_SV__

`include "../../chapter4/delay_chain_mem.sv"
`include "R22SdfDefines.sv"

module R22Sdf
  import R22SdfDefines::*;
#(
    parameter integer STG = 3
) (
    input  wire   clk,
    input  wire   rst,
    input  wire   en,
    input  Cplx_t in,
    output Cplx_t out,
    input  wire   sync,
    input  wire   scale,
    input  wire   invexp
);

  Cplx_t bf2i_x0[STG], bf2i_x1[STG], bf2i_z0[STG], bf2i_z1[STG];
  Cplx_t bf2ii_x0[STG], bf2ii_x1[STG], bf2ii_z0[STG], bf2ii_z1[STG];
  assign bf2i_x1[STG-1] = in;
  assign out = bf2ii_z0[0];
  logic [STG * 2 - 1 : 0] ccnt;
  logic sc, inv;

  always @(posedge clk) begin
    if (rst) begin
      ccnt <= 'b0;
      sc <= scale;
      inv <= invexp;
    end else if (en) begin
      if (sync) begin
        ccnt <= 'b0;
        sc <= scale;
        inv <= invexp;
      end else ccnt <= ccnt + 1'b1;
    end
  end

  generate
    for (genvar s = STG - 1; s >= 0; s--) begin : g_bfStg
      Bf2I theBf2I (
          .x0   (bf2i_x0[s]),
          .x1   (bf2i_x1[s]),
          .z0(bf2i_z0[s]),
          .z1(bf2i_z1[s]),
          .s(ccnt[s*2+1]),
          .scale(sc)
      );
      DelayChainMem #(
          .DW (DW),
          .LEN(4 ** s * 2)
      ) dcBf2iReal (
          clk,
          rst,
          en,
          bf2i_z1[s].re,
          bf2i_x0[s].re
      );
      DelayChainMem #(
          .DW (DW),
          .LEN(4 ** s * 2)
      ) dcBf2iImag (
          clk,
          rst,
          en,
          bf2i_z1[s].im,
          bf2i_x0[s].im
      );
      assign bf2ii_x1[s] = bf2i_z0[s];
      Bf2II theBf2II (
          .x0(bf2ii_x0[s]),
          .x1(bf2ii_x1[s]),
          .z0(bf2ii_z0[s]),
          .z1(bf2ii_z1[s]),
          .s(ccnt[s*2]),
          .t(ccnt[s*2+1]),
          .scale(sc),
          .invexp(inv)
      );
      DelayChainMem #(
          .DW (DW),
          .LEN(4 ** s)
      ) dcBf2iiReal (
          clk,
          rst,
          en,
          bf2ii_z1[s].re,
          bf2ii_x0[s].re
      );
      DelayChainMem #(
          .DW (DW),
          .LEN(4 ** s)
      ) dcBf2iiImag (
          clk,
          rst,
          en,
          bf2ii_z1[s].im,
          bf2ii_x0[s].im
      );
    end
  endgenerate

  generate
    for (genvar s = STG - 2; s >= 0; s--) begin : g_mulStg
      Cplx_t mulin, w, mulout;
      logic [s*2+3 : 0] waddr;
      assign mulin = bf2ii_z0[s+1];
      //    assign waddr = ccnt[0 +: (s*2+2)] * ccnt[(s*2+2) +: 2];
      assign waddr = ccnt[0+:(s*2+2)] * 2'({<<{ccnt[(s*2+2)+:2]}});

      R22SdfCoefRom #(DW, s * 2 + 4, "Real") wReal (
          clk,
          waddr,
          w.re
      );
      R22SdfCoefRom #(DW, s * 2 + 4, "Imag") wImag (
          clk,
          waddr,
          w.im
      );

      always_comb mulout = cmul(mulin, w);
      assign bf2i_x1[s] = mulout;
    end
  endgenerate

endmodule
// change addr : x
// change back addr, change ~(~t & s) : x
// change back to (~t & s), change rom to -sin : x

`endif
