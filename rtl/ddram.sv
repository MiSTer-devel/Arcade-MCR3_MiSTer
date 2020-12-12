//
// ddram.v
//
// DE10-nano DDR3 memory interface for Arcade
//
// Copyright (c) 2020 Sorgelig
//
//
// This source file is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version. 
//
// This source file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of 
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License 
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// ------------------------------------------
//

module ddram
(
	input         CLK_VIDEO,
	input         CE_PIXEL,

	input   [7:0] VGA_R,
	input   [7:0] VGA_G,
	input   [7:0] VGA_B,
	input         VGA_HS,
	input         VGA_VS,
	input         VGA_DE,

	input         rotate_ccw,
	input         no_rotate,

	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,

	// side slow channel
	input  [24:0] s_addr,
	input         s_rd,
	input         s_wr,
	output [63:0] s_dout,
	input  [63:0] s_din,
	input   [7:0] s_be,
	output reg    s_ack,

	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,
	output        DDRAM_RD,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY
);

screen_rotate screen_rotate
(
	.CLK_VIDEO(CLK_VIDEO),
	.CE_PIXEL(CE_PIXEL),

	.VGA_R(VGA_R),
	.VGA_G(VGA_G),
	.VGA_B(VGA_B),
	.VGA_HS(VGA_HS),
	.VGA_VS(VGA_VS),
	.VGA_DE(VGA_DE),

	.rotate_ccw(rotate_ccw),
	.no_rotate(no_rotate),

	.FB_EN(FB_EN),
	.FB_FORMAT(FB_FORMAT),
	.FB_WIDTH(FB_WIDTH),
	.FB_HEIGHT(FB_HEIGHT),
	.FB_BASE(FB_BASE),
	.FB_STRIDE(FB_STRIDE),
	.FB_VBL(FB_VBL),
	.FB_LL(FB_LL),

	.DDRAM_CLK(DDRAM_CLK),
	.DDRAM_BUSY(DDRAM_BUSY),
	.DDRAM_ADDR(f_addr),
	.DDRAM_DIN(f_data),
	.DDRAM_BE(f_be),
	.DDRAM_WE(f_wr)
);

wire [28:0] f_addr;
wire [63:0] f_data;
wire  [7:0] f_be;
wire        f_wr;

parameter MEM_BASE    = 4'd3;  // buffer at 0x30000000

assign DDRAM_BURSTCNT = DDRAM_WE ? 8'd1 : ram_bc;
assign DDRAM_ADDR     = s_act ? {MEM_BASE, ram_addr} : f_addr;
assign DDRAM_BE       = s_act ? ram_be : f_be;
assign DDRAM_DIN      = s_act ? ram_data : f_data;
assign DDRAM_WE       = ram_wr | f_wr;
assign DDRAM_RD       = ram_rd;

reg        s_act;
reg [63:0] s_c1_r, s_c2_r, s_dout_r;
assign     s_dout = s_dout_r;

reg [24:0] ram_addr, s_addr_r;
reg [63:0] ram_data;
reg        ram_wr;
reg        ram_rd;
reg  [7:0] ram_be;
reg  [1:0] ram_bc = 0;

always @(posedge CLK_VIDEO) begin
	reg        old_de, old_hs;
	reg        s_wr1, s_wr2, s_rd1, s_rd2;
	reg [24:0] cache_addr = {25{1'b1}}, next_caddr;
	reg        next_ack;
	reg [11:0] pcnt;
	reg [11:0] hbl;

	ram_wr <= 0;
	ram_rd <= 0;

	s_wr1 <= s_wr;
	s_rd1 <= s_rd;

	if(s_rd1 ^ s_rd2) begin
		s_addr_r <= s_addr;
		if(cache_addr == s_addr) begin
			s_ack    <= ~s_ack;
			s_rd2    <= s_rd1;
			s_dout_r <= s_c1_r;
		end
		else if((cache_addr+1'd1) == s_addr && !ram_bc) begin
			s_ack    <= ~s_ack;
			s_rd2    <= s_rd1;
			s_dout_r <= s_c2_r;
		end
	end

	if(CE_PIXEL) begin
		old_hs <= VGA_HS;
		old_de <= VGA_DE;

		if(old_de & ~VGA_DE) hbl <= pcnt + 1'd1;

		pcnt <= pcnt + 1'd1;
		if(~old_hs & VGA_HS) pcnt <= 0;

		if(~VGA_DE && hbl && (hbl == pcnt || hbl[11:1] == pcnt) && !ram_bc) begin
			if(s_wr1 ^ s_wr2) begin
				cache_addr <= {25{1'b1}};
				ram_addr   <= s_addr;
				ram_data   <= s_dout;
				ram_wr     <= 1;
				ram_be     <= s_be;
				s_ack      <= ~s_ack;
				s_wr2      <= s_wr1;
			end
			else if((cache_addr+1'd1) == s_addr_r) begin
				s_c1_r     <= s_c2_r;
				cache_addr <= s_addr_r;
				next_caddr <= s_addr_r;
				ram_addr   <= s_addr_r + 1'd1;
				ram_bc     <= 1;
				ram_rd     <= 1;
				ram_be     <= 8'hFF;
			end
			else if(cache_addr != s_addr_r) begin
				ram_addr   <= s_addr_r;
				next_caddr <= s_addr_r;
				ram_rd     <= 1;
				ram_bc     <= 2;
				ram_be     <= 8'hFF;
			end
		end

		s_act <= ~VGA_DE;
	end

	if(DDRAM_DOUT_READY && ram_bc) begin
		if(ram_bc == 2) s_c1_r     <= DDRAM_DOUT;
		if(ram_bc == 1) s_c2_r     <= DDRAM_DOUT;
		if(ram_bc == 1) cache_addr <= next_caddr;
		ram_bc <= ram_bc - 1'd1;
	end
end

endmodule
