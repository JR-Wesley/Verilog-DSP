
module R22SdfCoefRom #(
    parameter integer DW = 16,
    parameter integer AW = 8,
    parameter string  RI = "Real"
) (
    input  wire                  clk,
    input  wire         [AW-1:0] addr,
    output logic signed [DW-1:0] qout
);
  logic signed [DW-1:0] ram[2**AW - 1];

  initial begin
    for (int k = 0; k < 2 ** AW; k++) begin
      if (RI == "Real") ram[k] = $cos(2.0 * 3.1415926536 * k / 2 ** AW) * (2 ** (DW - 1) - 1);
      else ram[k] = $sin(2.0 * 3.1415926536 * k / 2 ** AW) * (2 ** (DW - 1) - 1);
    end
  end
  //    always_ff@(posedge clk) qout <= ram[addr];
  always_comb qout = ram[addr];

endmodule

