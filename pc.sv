// Program counter
// Author: Jiashuo Zhang
// Data: 6/1/2016
module pc(clk, rst, pcOut, pcIn, PC_write);
	output	[31:0]	pcOut;
	input		[31:0]	pcIn;
	input		clk, rst, PC_write;
	
	reg		[31:0]	pc;
	
	assign pcOut = pc;
	
	always@ (posedge clk)
	begin
		if (rst)
			pc <= 0;
		// Stall
		else if (!PC_write)
			pc <= pc;
		else
			pc <= pcIn;
	end
	
endmodule
