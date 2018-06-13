// IFID pipeline register
// Author: Jiashuo Zhang
// Data: 6/1/2016
module IFID_reg(clk, rst, in, out, IFID_write, IFflush);
	parameter WIDTH;
	input clk, rst, IFID_write, IFflush;
	input  [WIDTH - 1:0] in;
	output [WIDTH - 1:0] out;
	
	reg [WIDTH - 1:0] r;
	
	always @(posedge clk) begin
		if (rst)
			r <= 0;
		// Flush
		else if (IFflush)
			r[31:0] <= 0;
		// Stall
		else if (!IFID_write)
			r <= 0;
		else
			r <= in;
	end
	
	assign out = r;
	
endmodule