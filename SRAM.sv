// SRAM module to store data and instructions
// Author: Jiashuo Zhang
// Data: 5/1/2016
module SRAM(clk, address, data, we, re);
	input [10:0] address;
	input  		 we, re;
	input  		 clk;
	inout [15:0] data;
	
	reg	 [15:0] mem [2047:0];
	
	initial
	begin
		$readmemh("dataSet.dat", mem);
	end
	assign data = re & !we ? mem[address] : 16'hzzzz; // Read re = 1
	always @(posedge clk) begin
		if (!re & we) begin			//write  we = 1
			mem[address] <= data;	//data as input
		end
	end
	
endmodule

//module SigGen(clk, address, data, we, re);
//	output reg [10:0] address;
//	output reg we, re;
//	output reg clk;
//	inout [15:0] data;
//	
//	// Set up the clock.
//	parameter CLOCK_PERIOD=100;
//	initial begin
//		clk <= 0;
//	forever #(CLOCK_PERIOD/2) clk <= ~clk;
//	end
//	
//	reg [15:0] dataGen;
//	assign data = re ? 16'hzzzz : dataGen;
//	
//	initial begin
//		we <= 0;
//		re <= 1;
//		address <= 0;		@(posedge clk);
//		address <= 1;		@(posedge clk);
//		address <= 2;		@(posedge clk);
//		address <= 3;		@(posedge clk);
//		address <= 4;		@(posedge clk);
//		we <= 1;
//		re <= 0;
//		address <= 0;
//		dataGen <= 1;		@(posedge clk);
//		address <= 1;		@(posedge clk);
//		we <= 0;
//		re <= 1;
//		address <= 0;		@(posedge clk);
//		address <= 1;		@(posedge clk);
//		address <= 2;		@(posedge clk);
//		address <= 3;		@(posedge clk);
//		address <= 4;		@(posedge clk);
//		$stop;
//	end
//	
//endmodule
//
//module SRAM_testbench();
//	wire clk, we, re;
//	wire [10:0] address;
//	wire [15:0] data;
//	
//	SRAM dut(clk, address, data, we, re);
//	SigGen sg(clk, address, data, we, re);
//	
//endmodule
