`ifndef __FIR_SV__
`define __FIR_SV__

// TAPS = N + 1, N is the number of the coef
// There is one more register in port `out`
module FIR #(
    parameter int  DW         = 10,
    parameter int  TAPS       = 8,
    parameter real COEF[TAPS] = '{TAPS{0.124}},
    parameter type dw_t       = logic signed   [DW-1 : 0]  // Q1.9
) (
  input  logic clk,
  input  logic rst_n,
  input  logic en,
  input  dw_t  in,
  output dw_t  out     // Q1.9
);

  localparam int N = TAPS - 1;
  dw_t coef[TAPS];
  dw_t prod[TAPS];
  dw_t delay[TAPS];

  //`DEF_FP_MUL(mul, 1, DW-1, 1, DW-1, DW-1); //Q1.9 * Q1.9 -> Q1.9
  generate
    for (genvar t = 0; t < TAPS; t++) begin : g_coef
      assign coef[t] = COEF[t] * 2.0 ** (DW - 1.0);
      assign prod[t] =  //mul(in, coef[t]);
          ((2 * DW)'(in) * (2 * DW)'(coef[t])) >>> (DW - 1);
    end
  endgenerate

  generate
    for (genvar t = 0; t < TAPS; t++) begin : g_dff
      always_ff @(posedge clk) begin
        if (!rst_n) delay[t] <= '0;
        else if (en) begin
          if (t == 0) delay[0] <= prod[N-t];
          else delay[t] <= prod[N-t] + delay[t-1];
        end
      end
    end
  endgenerate

  assign out = delay[N];

endmodule

`endif
