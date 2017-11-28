`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:57:22 05/04/2016 
// Design Name: 
// Module Name:    cpu 
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
module cpu(
	 input clk,
	 input rst_n
	 );

	 reg stall;
	 reg [10:0] signal_ID, signal_EX, signal_ME, signal_WB;
	 reg [31:0] instr_IF, instr_ID, instr_EX, instr_ME, instr_WB;
	 reg [31:0] ans_EX, ans_ME, ans_WB, rd2_EX, rd2_ME, rm_ME, rm_WB, oprand1, oprand2;
	 
	 wire [31:0] instr, ans, pc, rd1, rd2, rm;
	 wire [5:0] ALUState;
	 wire [4:0] rs_EX, rt_EX, rt_ME, rt_WB, rd_ME, rd_WB;
	 wire [10:0] signal;
	 
	 // 需要使用的控制信号
	 wire [5:0] op_EX;												// signal[5:0]
	 wire RegWrite_ME, RegWrite_WB;								// signal[6]
	 wire RegDst_ME, RegDst_WB;									// signal[7]
	 wire ALUSrc_EX;													// signal[8]
	 wire MemWrite_ME;												// signal[9]
	 wire MemToReg_EX, MemToReg_ME, MemToReg_WB;				// signal[10]
	 
	 // 控制信号关联
	 assign op_EX 			= signal_EX[5:0];
	 assign RegWrite_ME 	= signal_ME[6];
	 assign RegWrite_WB 	= signal_WB[6];
	 assign RegDst_ME 	= signal_ME[7];
	 assign RegDst_WB 	= signal_WB[7];
	 assign ALUSrc_EX 	= signal_EX[8];
	 assign MemWrite_ME	= signal_ME[9];
	 assign MemToReg_EX	= signal_EX[10];
	 assign MemToReg_ME	= signal_ME[10];
	 assign MemToReg_WB	= signal_WB[10];
	 
//=======================================================================================
// 流水线初始化 与 流水线流动 （ 流水线中各段在时钟下降沿进行转移 ）
	 always@( negedge clk, negedge rst_n )
			if( ~rst_n ) begin
			
					//	控制信号流水线初始化
					signal_EX	<= 	0;
					signal_ME	<= 	0;
					signal_WB	<= 	0;
					
					// 指令流水线初始化
					instr_ID 	<= 	0;
					instr_EX 	<= 	0;
					instr_ME 	<= 	0;
					instr_WB 	<= 	0;
					
					// 运算器结果流水线初始化
					ans_ME		<=		0;
					ans_WB		<=		0;
					
					// 寄存器读取流水线初始化
					rd2_ME		<= 	0;
					
					// 内存读取流水线初始化
					rm_WB			<= 	0;
					
			end else begin
			
					// 控制信号流水线转移
					signal_WB 	<= 	signal_ME;
					signal_ME 	<= 	signal_EX;
					signal_EX 	<= 	signal_ID;
			
					// 指令流水线转移
					instr_WB 	<= 	instr_ME;
					instr_ME 	<= 	instr_EX;
					instr_EX 	<= 	instr_ID;
					instr_ID 	<= 	instr_IF;
					
					// 运算器结果流水线转移
					ans_ME		<=		ans_EX;
					ans_WB		<=		ans_ME;
					
					// 寄存器读取流水线转移
					rd2_ME		<=		rd2_EX;
					
					// 内存读取流水线转移
					rm_WB			<= 	rm_ME;
			end
//=======================================================================================

//=======================================================================================
// 控制信号流水线装载
	 
	 cu CU(
			.instr( instr_ID ),
			.signal( signal )
	 );
	 
	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					signal_ID <= 0;
			else
					signal_ID <= signal;
	 
//=======================================================================================
	 
//=======================================================================================
// 指令流水线装载
	 tram Tram(
			.clk( clk ),
			.we( 0 ),
			.a( pc[5:0] ),
			.d( 0 ),
			.spo( instr )
	 );
	 
	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					instr_IF <= 0;
			else if( stall )
					instr_IF <= 0;
			else
					instr_IF <= instr;
//=======================================================================================
	 
//=======================================================================================
// 运算结果流水线装载
	 alu ALU(
			.Op( op_EX ),
			.SrcA( oprand1 ),
			.SrcB( oprand2 ),
			.num( instr_EX[10:6] ),
			.ALUResult( ans ),
			.ALUState( ALUState )
	 );

	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					ans_EX <= 0;
			else
					ans_EX <= ans;
					
// 运算器操作数选择
	 always@( * ) begin
			oprand1 = rd1;
			oprand2 = rd2;
			if( RegWrite_WB ) begin
					if( rs_EX == rt_WB && ~RegDst_WB || rs_EX == rd_WB && RegDst_WB ) oprand1 = ans_WB;
					if( rt_EX == rt_WB && ~RegDst_WB || rt_EX == rd_WB && RegDst_WB ) oprand2 = ans_WB;
			end
			if( RegWrite_ME ) begin
					if( rs_EX == rt_ME && ~RegDst_ME || rs_EX == rd_ME && RegDst_ME ) oprand1 = ans_ME;
					if( rt_EX == rt_ME && ~RegDst_ME || rt_EX == rd_ME && RegDst_ME ) oprand2 = ans_ME;
			end
			if( ALUSrc_EX )
					oprand2 = instr_EX[15]? { 16'HFFFF, instr_EX[15:0] }: { 16'H0000, instr_EX[15:0] };
	 end
//=======================================================================================
	 
//=======================================================================================
// 寄存器读取结果装载，寄存器读取与写回 
	 assign rs_EX = instr_EX[25:21];
	 assign rt_EX = instr_EX[20:16];
	 assign rt_ME = instr_ME[20:16];
	 assign rt_WB = instr_WB[20:16];
	 assign rd_ME = instr_ME[15:11];
	 assign rd_WB = instr_WB[15:11];
	 
	 regs Regs(
			.clk( clk ),
			.rst_n( rst_n ),
			.RegWrite( RegWrite_WB ),
			.a1( rs_EX ),
			.a2( rt_EX ),
			.a3( RegDst_WB? rd_WB: rt_WB ),
			.wd3( MemToReg_WB? rm_WB: ans_WB ),
			.rd1( rd1 ),
			.rd2( rd2 )
	 );

	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					rd2_EX = 0;
			else begin
					rd2_EX = rd2;
					if( RegWrite_WB && ( rt_EX == rt_WB && ~RegDst_WB || rt_EX == rd_WB && RegDst_WB ) ) rd2_EX = ans_WB;
					if( RegWrite_ME && ( rt_EX == rt_ME && ~RegDst_ME || rt_EX == rd_ME && RegDst_ME ) ) rd2_EX = ans_ME;
			end
//=======================================================================================

//=======================================================================================
// 内存读取结果装载，内存读取与写回
	 dram Dram(
			.clk( clk ),
			.we( MemWrite_ME ),
			.a( ans_ME[4:0] ),
			.d( rd2_ME ),
			.spo( rm )
	 );
	 
	 always@( posedge clk, negedge rst_n )
			if( ~rst_n )
					rm_ME <= 0;
			else
					rm_ME <= rm;
//=======================================================================================

//=======================================================================================
// 其余部件连接
	 pc PC(
			.clk( clk ),
			.rst_n( rst_n ),
			.stall( stall ),
			.instr( instr_EX ),
			.ALUResult( ans ),
			.ALUState( ALUState ),
			.pc( pc )
	 );
	 
	 always@( * ) begin
			stall = 0;
			if( instr_IF[31:26] == 6'b100011 || instr_ID[31:26] == 6'b100011 || instr_EX[31:26] == 6'b100011 ) stall = 1;
			if( instr_IF[31:26] == 6'b000100 || instr_ID[31:26] == 6'b000100 || instr_EX[31:26] == 6'b000100 ) stall = 1;
			if( instr_IF[31:26] == 6'b000001 || instr_ID[31:26] == 6'b000001 || instr_EX[31:26] == 6'b000001 ) stall = 1;
			if( instr_IF[31:26] == 6'b000111 || instr_ID[31:26] == 6'b000111 || instr_EX[31:26] == 6'b000111 ) stall = 1;
			if( instr_IF[31:26] == 6'b000110 || instr_ID[31:26] == 6'b000110 || instr_EX[31:26] == 6'b000110 ) stall = 1;
			if( instr_IF[31:26] == 6'b000101 || instr_ID[31:26] == 6'b000101 || instr_EX[31:26] == 6'b000101 ) stall = 1;
			if( instr_IF[31:26] == 6'b000010 || instr_ID[31:26] == 6'b000010 || instr_EX[31:26] == 6'b000010 ) stall = 1;
			if( instr_IF[31:26] == 6'b000000 && instr_IF[5:0] == 6'b001000 ) stall = 1;
			if( instr_ID[31:26] == 6'b000000 && instr_ID[5:0] == 6'b001000 ) stall = 1;
			if( instr_EX[31:26] == 6'b000000 && instr_EX[5:0] == 6'b001000 ) stall = 1;
	 end
//=======================================================================================

endmodule
