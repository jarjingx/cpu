`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:19:32 05/04/2016 
// Design Name: 
// Module Name:    cu 
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
module cu(
	 input [31:0] instr,
	 output reg [10:0] signal
	 );
	 
	 always@( * )
			if( instr )
					case( instr[31:26] )
							6'b000000:	signal = { 5'b00011, instr[5:0] };		// ¼Ä´æÆ÷ÔËËã
							6'b001000:	signal = { 5'b00101, 6'b100000 };		// ADDI
							6'b001001:	signal = { 5'b00101, 6'b100001 };		// ADDIU
							6'b001100:	signal = { 5'b00101, 6'b100100 };		// ANDI
							6'b001101:	signal = { 5'b00101, 6'b100101 };		// ORI
							6'b001110:	signal = { 5'b00101, 6'b100110 };		// XORI
							6'b100011:	signal = { 5'b10101, 6'b100000 };		// LW
							6'b101011:	signal = { 5'b011x0, 6'b100000 };		// SW
							6'b001010:	signal = { 5'b00101, 6'b101010 };		// SLTI
							6'b001011:	signal = { 5'b00101, 6'b101010 };		// SLTIU
							default	:	signal = 11'b00000000000;
					endcase
			else
					signal = 11'b00000000000;

endmodule
