`include "R22SdfDefines.sv"

module Bf2II
  import R22SdfDefines::*;
(
    input  Cplx_t x0,
    input  Cplx_t x1,
    output Cplx_t z0,
    output Cplx_t z1,
    input  wire   s,
    input  wire   scale,
    input  wire   t,
    input  wire   invexp
);

  wire Cplx_t x1rot = ~(~t & s) ? x1 : ~invexp ? '{-x1.im, x1.re} : '{x1.im, -x1.re};
  always_comb z0 = ~s ? x0 : cadd(x0, x1rot, scale);
  always_comb z1 = ~s ? x1rot : csub(x0, x1rot, scale);
  //////////////////////////////////////////
  //wire Cplx_t x1x = ~(~t & s) ? x1 : '{x1.im, x1.re};
  ////                  ~invexp  ? '{-x1.im, x1.re} : '{x1.im, -x1.re};
  //always_comb z0 = ~s ? x0    : cadd(x0, {x1x.re, (~t & s)? x1x.im : -x1x.im}, scale);
  //always_comb z1 = ~s ? x1x : csub(x0, {x1x.re, (~t & s)? x1x.im : -x1x.im}, scale);
  //
endmodule
