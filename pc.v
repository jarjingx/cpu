`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:55:38 05/04/2016 
// Design Name: 
// Module Name:    pc 
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
module pc(
	 input clk,
	 input rst_n,
	 input stall,
	 input [31:0] instr,
	 input [31:0] ALUResult,
	 input [5:0] ALUState,
	 output reg [31:0] pc
	 );
	 
	 reg [31:0] bpc, jpc;
	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					pc = 0;
			else 
					if( instr[31:26] == 6'b000100 && ALUState[5] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000001 && instr[20:16] == 5'b00001 && ALUState[4] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000111 && ALUState[3] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000110 && ALUState[2] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000001 && instr[20:16] == 5'b00000 && ALUState[1] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000101 && ALUState[0] == 1 ) pc = bpc;
					else if( instr[31:26] == 6'b000010 ) pc = { pc[31:26], instr[25:0] };
					else if( instr[31:26] == 6'b000000 && instr[5:0] == 6'b001000 ) pc = ALUResult;
					else if( stall ) pc = pc;
					else pc = pc + 1;
	
	 always@( * )
			bpc = pc + { instr[15]? 16'HFFFF: 16'H0000, instr[15:0] };

endmodule
