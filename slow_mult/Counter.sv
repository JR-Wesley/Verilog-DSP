`ifndef __COUNTER_SV__
`define __COUNTER_SV__

module Counter #(
    parameter int  M    = 100,
    parameter type dw_t = logic [$clog2(M) - 1 : 0]
) (
  input  logic clk,
  input  logic rst_n,
  input  logic en,
  output dw_t  cnt,
  output logic co
);

  dw_t cnt_inc;
  always_comb begin
    cnt_inc = (cnt < M - 1) ? cnt + 1'b1 : '0;
    co = en & (cnt == M - 1);
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) cnt <= '0;
    else if (en) cnt <= cnt_inc;
  end

endmodule

`endif
