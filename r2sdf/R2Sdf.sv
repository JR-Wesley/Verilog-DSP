`ifndef _R2SDF_SV__
`define _R2SDF_SV__

`include "../../chapter4/delay_chain/DelayChain.sv"
`include "../../chapter4/delay_chain_mem/DelayChainMem.sv"
`include "./R2SdfDefinesPkg.sv"
`include "./R2SdfCoefRom.sv"
`include "./Bf2.sv"

module R2Sdf
  import R2SdfDefinesPkg::*;
#(
    parameter int STG = 4
) (
    input  wire  clk,
    input  wire  rst_n,
    input  wire  en,
    // Reconfigurable
    input  wire  scale,
    input  wire  invexp,
    // I/O
    input  Cplx  in,
    input  wire  in_sync,
    output Cplx  out,
    output logic out_sync
);

  // Control Counter
  logic [STG - 1 : 0] ccnt, ccnt_next;
  assign ccnt_next = in_sync ? '0 : ccnt + 1'b1;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) ccnt <= '0;
    else if (en) ccnt <= ccnt_next;
  end

  // Output sync, the last of the output sequence
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) out_sync <= '0;
    else if (en) out_sync <= ccnt == STG'(STG * 2 - 4);
  end

  Cplx bf2_x0[STG], bf2_x1[STG], bf2_z0[STG], bf2_z1[STG];
  // I/O stage
  assign bf2_x1[STG-1] = in;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) out <= '{'0, '0};
    else if (en) out <= bf2_z0[0];
  end

  generate
    for (genvar s = STG - 1; s >= 0; s--) begin : g_bfStg
      logic s_dly;
      DelayChain #(
          .DW(1),
          .LEN(2 * (STG - s - 1))
      ) dlyCnt (
          .clk  (clk),
          .rst_n(rst_n),
          .en   (ccnt[s]),
          .in   (ccnt[s]),
          .out  (s_dly)
      );
      Bf2 theBf2 (
          .x0   (bf2_x0[s]),
          .x1   (bf2_x1[s]),
          .z0   (bf2_z0[s]),
          .z1   (bf2_z1[s]),
          .sel  (s_dly),
          .scale(scale)
      );
      DelayChainMem #(
          .DW(2 * DW),
          .LEN(2 ** s)
      ) dcBf2Real (
          .clk  (clk),
          .rst_n(rst_n),
          .en   (en),
          .din  ({bf2_z1[s].re, bf2_z1[s].im}),
          .dout ({bf2_x0[s].re, bf2_x0[s].im})
      );
    end
  endgenerate

  generate
    for (genvar s = STG - 2; s >= 0; s--) begin : g_mulStg
      logic [s+1 : 0] cnt_dly;
      DelayChain #(
          .DW(s + 2),
          .LEN(2 * (STG - s - 2))
      ) dlyCnt (
          .clk  (clk),
          .rst_n(rst_n),
          .en   (en),
          .in   (ccnt[s+1 : 0]),
          .out  (cnt_dly)
      );

      Cplx mulin, w, mulout;
      logic [s : 0] waddr;
      always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) mulin <= '{'0, '0};
        else if (en) mulin <= bf2_z0[s+1];
      end

      assign waddr = cnt_dly[s+1] ? '0 : cnt_dly[s : 0];
      R2SdfCoefRom #(
          .DW(DW),
          .AW(s + 1),
          .RI("Real")
      ) wReal (
          .clk (clk),
          .addr(waddr),
          .qout(w.re)
      );
      R2SdfCoefRom #(
          .DW(DW),
          .AW(s + 1),
          .RI("Imag")
      ) wImag (
          .clk (clk),
          .addr(waddr),
          .qout(w.im)
      );

      always_comb mulout = cmul(mulin, '{w.re, invexp ? -w.im : w.im});
      always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) bf2_x1[s] <= '{'0, '0};
        else if (en) bf2_x1[s] <= mulout;
      end
    end
  endgenerate

endmodule

`endif
