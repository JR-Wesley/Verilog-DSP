`ifndef _R2SDFDEFINES_SV__
`define _R2SDFDEFINES_SV__

package R2SdfDefinesPkg;
  localparam int DW = 16, FW = DW - 1;

  typedef struct {
    logic signed [DW-1:0] re;
    logic signed [DW-1:0] im;
  } Cplx;

  function automatic Cplx cmul(Cplx a, Cplx b);
    cmul.re = ((DW * 2)'(a.re) * b.re - (DW * 2)'(a.im) * b.im) >>> FW;
    cmul.im = ((DW * 2)'(a.re) * b.im + (DW * 2)'(a.im) * b.re) >>> FW;
  endfunction

  function automatic Cplx cadd(Cplx a, Cplx b, logic sc);
    cadd.re = ((DW + 1)'(a.re) + b.re) >>> sc;
    cadd.im = ((DW + 1)'(a.im) + b.im) >>> sc;
  endfunction

  function automatic Cplx csub(Cplx a, Cplx b, logic sc);
    csub.re = ((DW + 1)'(a.re) - b.re) >>> sc;
    csub.im = ((DW + 1)'(a.im) - b.im) >>> sc;
  endfunction

endpackage

`endif
