`ifndef __SLOW_MULT_SV__
`define __SLOW_MULT_SV__

`include "./Counter.sv"

module SlowMult #(
    parameter int W = 16
) (
  input  logic                 clk,
  input  logic                 rst_n,
  input  logic [    W - 1 : 0] multiplicand,
  input  logic [    W - 1 : 0] multiplier,
  input  logic                 start,
  output logic [W * 2 - 1 : 0] product,
  output logic                 valid,
  output logic                 busy
);

  logic bit_co;
  Counter #(
      .M(W)
  ) bitCnt (
    .clk  (clk),
    .rst_n((rst_n & ~start) | busy),
    .en   (busy),
    .cnt  (),
    .co   (bit_co)
  );

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) busy <= '0;
    else if (start) busy <= '1;
    else if (bit_co) busy <= '0;
  end

  logic [W - 1 : 0] mer;
  logic [W * 2 - 2 : 0] mcand;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      mcand <= '0;
      mer <= '0;
    end else if (start) begin
      mcand <= multiplicand;
      mer <= multiplier;
    end else if (busy) begin
      mcand <= mcand << 1;
      mer <= mer >> 1;
    end
  end

  logic [W * 2 - 2 : 0] sum;
  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
      sum <= '0;
    end else if (start) begin
      sum <= '0;
    end else if (busy) begin
      sum <= sum + (mer[0] ? mcand : '0);
    end
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) product <= '0;
    else if (bit_co) product <= sum + (mer[0] ? mcand : '0);
  end

  always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) valid <= '0;
    else valid <= bit_co;
  end

endmodule

`endif
