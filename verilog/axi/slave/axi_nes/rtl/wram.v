/***************************************************************************************************
** fpga_nes/hw/src/wram.v
*
*  Copyright (c) 2012, Brian Bennett
*  All rights reserved.
*
*  Redistribution and use in source and binary forms, with or without modification, are permitted
*  provided that the following conditions are met:
*
*  1. Redistributions of source code must retain the above copyright notice, this list of conditions
*     and the following disclaimer.
*  2. Redistributions in binary form must reproduce the above copyright notice, this list of
*     conditions and the following disclaimer in the documentation and/or other materials provided
*     with the distribution.
*
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
*  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
*  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
*  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
*  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
*  WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*
*  Work RAM module; implements 2KB of on-board WRAM as fpga block RAM.
***************************************************************************************************/
`timescale 1ps / 1ps

module wram(
  input         clk_in,   // system clock
  input         en_in,    // chip enable
  input         r_nw_in,  // read/write select (read: 0, write: 1)
  input  [10:0] a_in,     // memory address
  input  [ 7:0] d_in,     // data input
  output [ 7:0] d_out     // data output
);

wire       wram_bram_we;
wire [7:0] wram_bram_dout;

single_port_ram_sync #(.ADDR_WIDTH(11),
                       .DATA_WIDTH(8)) wram_bram(
  .clk(clk_in),
  .we(wram_bram_we),
  .addr_a(a_in),
  .din_a(d_in),
  .dout_a(wram_bram_dout)
);

assign wram_bram_we = (en_in) ? ~r_nw_in       : 1'b0;
assign d_out        = (en_in) ? wram_bram_dout : 8'h00;

endmodule

