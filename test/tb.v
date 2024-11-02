`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  /// Init registers 
  reg resetn;
  reg clk;
  reg ena = 1;

  reg [3:0] opcode;
  wire [15:0] out_res; // disregard the first bit
  wire [7:0] uio_oe;
   wire [7:0] uio_in;
  
  tt_um_control_block uut(
     // Include power ports for the Gate Level test:
      `ifdef GL_TEST
            .VPWR(1'b1),
            .VGND(1'b0),
      `endif
     
    .clk(clk), 
    .rst_n(resetn),
    .ui_in({4'b0000, opcode}),
    .uo_out(out_res[15:8]),
    .uio_out(out_res[7:0]),
    .uio_oe(uio_oe),
    .ena(ena),
    .uio_in(uio_in)
  );

endmodule
