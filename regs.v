`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:15:23 03/29/2016 
// Design Name: 
// Module Name:    registerfile 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module regs(
	 input clk,
	 input rst_n,
	 input RegWrite,
	 input [4:0] a1,
	 input [4:0] a2,
	 input [4:0] a3,
	 input [31:0] wd3,
	 output reg [31:0] rd1,
	 output reg [31:0] rd2
	 );
	 
	 reg [31:0] register [31:0];
	 integer i;
	 
	 // 同步数据写入
	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					for( i = 0; i <= 31; i = i + 1 )
							register[i] <= 0;
			else
					if( RegWrite )
							register[a3] <= wd3;
					else
							register[a3] <= register[a3];

	 // 异步数据读取
	 always@( * )
			if( ~rst_n ) begin
					rd1 <= 0;
					rd2 <= 0;
			end else begin
					rd1 <= register[a1];
					rd2 <= register[a2];
			end

endmodule
