`ifndef _R2SDFCOEFROM_SV__
`define _R2SDFCOEFROM_SV__

module R2SdfCoefRom #(
    parameter int    DW = 16,
    parameter int    AW = 8,
    parameter string RI = "Real"
) (
  input  wire                      clk,
  input  wire         [AW - 1 : 0] addr,
  output logic signed [DW - 1 : 0] qout
);

  logic signed [DW - 1 : 0] ram[2**AW];

  initial begin
    for (int k = 0; k < 2 ** AW; k++) begin
      if (RI == "Real") ram[k] = $cos(3.1415926536 * k / 2 ** AW) * (2 ** (DW - 1) - 1);
      else ram[k] = $sin(3.1415926536 * k / 2 ** AW) * (2 ** (DW - 1) - 1);
    end
  end

  always_ff @(posedge clk) begin
    qout <= ram[addr];
  end

endmodule

`endif
