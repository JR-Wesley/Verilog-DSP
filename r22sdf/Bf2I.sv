`include "R22SdfDefines.sv"

module Bf2I
  import R22SdfDefines::*;
(
    input  Cplx_t x0,
    input  Cplx_t x1,
    output Cplx_t z0,
    output Cplx_t z1,
    input  wire   s,
    input  wire   scale
);
  always_comb z0 = ~s ? x0 : cadd(x0, x1, scale);
  always_comb z1 = ~s ? x1 : csub(x0, x1, scale);
endmodule
