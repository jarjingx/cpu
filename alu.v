`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:02:28 05/04/2016 
// Design Name: 
// Module Name:    alu 
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
module alu(
	 input [5:0] Op,
	 input [31:0] SrcA,
	 input [31:0] SrcB,
	 input [4:0] num,
	 output reg [31:0] ALUResult,
	 output reg [5:0] ALUState
	 );
	 
	 always@( * )
			case( Op )
					6'b100000:	ALUResult = SrcA + SrcB;			// ���ż�
					6'b100001:	ALUResult = SrcA + SrcB;			// �޷��ż�
					6'b100100:	ALUResult = SrcA & SrcB;			// ��
					6'b100111:	ALUResult = ~( SrcA | SrcB );		// ���
					6'b100101:	ALUResult = SrcA | SrcB;			// ��
					6'b100010:	ALUResult = SrcA - SrcB;			// ���ż�
					6'b100011:	ALUResult = SrcA - SrcB;			// �޷��ż�
					6'b000000:	ALUResult = SrcB << num;			// �߼�����
					6'b000100:	ALUResult = SrcB << SrcA[4:0];	// �߼��ɱ�����
					6'b000010:	ALUResult = SrcB >> num;			// �߼�����
					6'b000110:	ALUResult = SrcB >> SrcA[4:0];	// �߼��ɱ�����
					6'b000011:	ALUResult = SrcB[31]? ~( ( ~SrcB ) >> num ): SrcB >> num;					// ��������
					6'b000111:	ALUResult = SrcB[31]? ~( ( ~SrcB ) >> SrcA[4:0] ): SrcB >> SrcA[4:0];	// �����ɱ�����
					6'b101010:	ALUResult = SrcA < SrcB? 1: 0;	// С����1
					default:		ALUResult = SrcA + SrcB;
			endcase
	 
	 always@( * ) begin
			ALUState = 6'b000000;
			if( SrcA - SrcB == 0 ) 	ALUState[5] = 1;
			if( SrcA >= 0 ) 			ALUState[4] = 1;
			if( SrcA >  0 ) 			ALUState[3] = 1;
			if( SrcA <= 0 ) 			ALUState[2] = 1;
			if( SrcA <  0 ) 			ALUState[1] = 1;
			if( SrcA - SrcB != 0 ) 	ALUState[0] = 1;
	 end
			
endmodule
