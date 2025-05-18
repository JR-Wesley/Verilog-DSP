`ifndef __DDS_SV__
`define __DDS_SV__

module DDS #(
    parameter int PW = 32,
    parameter int DW = 10,
    parameter int AW = 13
) (
  input  logic                     clk,
  input  logic                     rst_n,
  input  logic                     en,
  input  logic signed [PW - 1 : 0] freq,
  input  logic signed [PW - 1 : 0] phase,
  output logic signed [DW - 1 : 0] out
);

  localparam int LEN = 2 ** AW;
  localparam real PI = 3.1415926535897932;

  // NOTE: `initial` is only used in FPGA
  logic signed [DW-1 : 0] sine[LEN];
  initial begin
    for (int i = 0; i < LEN; i++) begin
      sine[i] = $sin(2.0 * PI * i / LEN) * (2.0 ** (DW - 1) - 1.0);
    end
  end

  logic [PW-1 : 0] phaseAcc;
  always_ff @(posedge clk) begin
    if (!rst_n) phaseAcc <= '0;
    else if (en) phaseAcc <= phaseAcc + freq;
  end

  wire [PW-1 : 0] phaseSum = phaseAcc + phase;
  always_ff @(posedge clk) begin
    if (!rst_n) out <= '0;
    else if (en) out <= sine[phaseSum[PW-1-:AW]];
  end

endmodule

`endif
