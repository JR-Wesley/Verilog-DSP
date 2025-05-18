`ifndef __IIR_SV__
`define __IIR_SV__
`include "./IIR2nd.sv"

module IIR #(
    parameter int  DW           = 10,
    parameter int  EW           = 4,
    parameter int  STG          = 2,
    parameter real GAIN[STG],
    parameter real NUM [STG][3],
    parameter real DEN [STG][2]
) (
  input  logic                   clk,
  input  logic                   rst_n,
  input  logic                   en,
  input  logic signed [DW-1 : 0] in,
  output logic signed [DW-1 : 0] out
);

  localparam int W = EW + DW;
  logic signed [W-1 : 0] sio[STG+1];

  assign sio[0] = in, out = sio[STG];
  generate
    for (genvar s = 0; s < STG; s++) begin : g_IIR2nd
      IIR2nd #(
          .DW  (W),
          .FW  (DW - 1),
          .GAIN(GAIN[s]),
          .NUM (NUM[s]),
          .DEN (DEN[s])
      ) theIir (
        .*,
        .in (sio[s]),
        .out(sio[s+1])
      );
    end
  endgenerate
endmodule

`endif
