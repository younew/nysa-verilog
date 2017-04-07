/*
Distributed under the MIT license.
Copyright (c) 2015 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
 * Author: Dave McCoy (dave.mccoy@cospandesign.com)
 * Description:
 *  Tranlates data from a Ping Pong FIFO to an AXI Stream
 *
 * Changes:     Who?  What?
 *  04/06/2017: DFM   Initial check in.
 *  04/06/2017: DFM   Added count so that the 'last' will not be strobed until
*                    all is sent.
 */

module adapter_ppfifo_2_axi_stream #(
  parameter                       DATA_WIDTH = 32,
  parameter                       STROBE_WIDTH = DATA_WIDTH / 8,
  parameter                       USE_KEEP = 0

)(
  input                           rst,

  //Ping Poing FIFO Read Interface
  input                           i_ppfifo_clk,
  input                           i_ppfifo_rdy,
  output  reg                     o_ppfifo_act,
  input       [23:0]              i_ppfifo_size,
  input       [DATA_WIDTH - 1:0]  i_ppfifo_data,
  //output  reg                     o_ppfifo_stb,
  output                          o_ppfifo_stb,

  //AXI Stream Output
  input       [23:0]              i_total_out_size,
  output                          o_axi_clk,
  input                           i_axi_ready,
  //output  reg [31:0]              o_axi_data,
  output      [DATA_WIDTH - 1:0]  o_axi_data,
  output      [STROBE_WIDTH - 1:0]o_axi_keep,
  //output  reg                     o_axi_last,
  output                          o_axi_last,
  output  reg                     o_axi_valid
);

//local parameters
localparam      IDLE        = 0;
localparam      READY       = 1;
localparam      RELEASE     = 2;

//registes/wires
wire                      clk;
reg     [23:0]            r_count;
reg     [3:0]             state;
reg     [23:0]            r_total_count;
//submodules
//asynchronous logic
assign  o_axi_clk       = i_ppfifo_clk;
assign  clk             = i_ppfifo_clk;
assign  o_axi_keep      = ((1 << STROBE_WIDTH) - 1);
assign  o_axi_data      = i_ppfifo_data;
assign  o_ppfifo_stb    = (i_axi_ready & o_axi_valid);
assign  o_axi_last      = ((r_total_count + 1) == i_total_out_size) &&
                          i_axi_ready &&
                          o_axi_valid;
//synchronous logic

always @ (posedge clk) begin
  //o_ppfifo_stb          <=  0;
  o_axi_valid           <=  0;
  //o_axi_last            <=  0;

  if (rst) begin
    state               <=  IDLE;
    //o_axi_data          <=  0;
    o_ppfifo_act        <=  0;
    r_count             <=  0;
    r_total_count       <=  0;
  end
  else begin
    case (state)
      IDLE: begin
        o_ppfifo_act    <=  0;
        if (i_ppfifo_rdy && !o_ppfifo_act) begin
          r_count       <=  0;
          o_ppfifo_act  <=  1;
          state         <=  READY;
        end
      end
      READY: begin
        if (r_count < i_ppfifo_size) begin
          o_axi_valid         <=  1;
          if (i_axi_ready && o_axi_valid) begin
            r_count         <= r_count + 1;
            if ((r_count + 1) >= i_ppfifo_size) begin
              o_axi_valid     <=  0;
            end
          end
        end
        else begin
          o_ppfifo_act      <=  0;
          state             <=  RELEASE;
        end
      end
      RELEASE: begin
        state               <=  IDLE;
      end
      default: begin
      end
    endcase
    if (o_axi_valid && i_axi_ready) begin
      r_total_count         <=  r_total_count + 1;
    end
    if (o_axi_last) begin
      r_total_count         <=  0;
    end
  end
end

endmodule
