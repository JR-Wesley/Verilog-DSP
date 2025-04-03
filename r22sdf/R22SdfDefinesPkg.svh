`ifndef __R22SDFDEFINES_SVH__
`define __R22SDFDEFINES_SVH__

package R22SdfDefinesPkg;
  localparam unsigned DW = 16, FW = DW - 1;

  // define a type struct: complex
  typedef struct {
    logic signed [DW - 1 : 0] re;
    logic signed [DW - 1 : 0] im;
  } cplx_t;

  function automatic cplx_t cmul(cplx_t a, cplx_t b);
    cmul.re = ((DW * 2)'(a.re) * b.re - (DW * 2)'(a.im) * b.im) >>> FW;
    cmul.im = ((DW * 2)'(a.re) * b.im + (DW * 2)'(a.im) * b.re) >>> FW;
  endfunction

  function automatic cplx_t cadd(cplx_t a, cplx_t b, logic sc);
    cadd.re = ((DW + 1)'(a.re) + b.re) >>> sc;
    cadd.im = ((DW + 1)'(a.im) + b.im) >>> sc;
  endfunction

  function automatic cplx_t csub(cplx_t a, cplx_t b, logic sc);
    csub.re = ((DW + 1)'(a.re) - b.re) >>> sc;
    csub.im = ((DW + 1)'(a.im) - b.im) >>> sc;
  endfunction

endpackage

`endif
