`ifndef __ORTH_DDS_SV__
`define __ORTH_DDS_SV__

module OrthDDS #(
    parameter int PW = 32,
    parameter int DW = 10,
    parameter int AW = 13
) (
  input  logic                     clk,
  input  logic                     rst,
  input  logic                     en,
  input  logic signed [PW - 1 : 0] freq,
  input  logic signed [PW - 1 : 0] phase,
  output logic signed [DW - 1 : 0] sin,
  output logic signed [DW - 1 : 0] cos
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

  logic [PW-1 : 0] phaseAcc, phSum0, phSum1;
  always_ff @(posedge clk) begin
    if (rst) phaseAcc <= '0;
    else if (en) phaseAcc <= phaseAcc + freq;
  end
  always_ff @(posedge clk) begin
    if (rst) begin
      phSum0 <= '0;
      phSum1 <= PW'(1) <<< (PW - 2);  // 90deg
    end else if (en) begin
      phSum0 <= phaseAcc + phase;
      phSum1 <= phaseAcc + phase + (PW'(1) <<< (PW - 2));
    end
  end
  always_ff @(posedge clk) begin
    if (rst) sin <= '0;
    else if (en) sin <= sine[phSum0[PW-1-:AW]];
  end
  always_ff @(posedge clk) begin
    if (rst) cos <= '0;
    else if (en) cos <= sine[phSum1[PW-1-:AW]];
  end
endmodule

`endif
