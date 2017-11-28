`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:11:08 05/27/2016
// Design Name:   cpu
// Module Name:   C:/Xilinx/lab/cpu/test.v
// Project Name:  cpu
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module test;

	// Inputs
	reg clk;
	reg rst_n;

	// Instantiate the Unit Under Test (UUT)
	cpu uut (
		.clk(clk), 
		.rst_n(rst_n)
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	initial begin
		rst_n = 0;
		#100;
		rst_n = 1;
	end

endmodule

