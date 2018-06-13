// General pipeline register
// Author: Jiashuo Zhang
// Data: 6/1/2016
module register(clk, rst, in, out);
	parameter WIDTH;
	input clk, rst;
	input  [WIDTH - 1:0] in;
	output [WIDTH - 1:0] out;
	
	reg [WIDTH - 1:0] r;
	
	always @(posedge clk) begin
		if (rst)
			r <= 0;
		else
			r <= in;
	end
	
	assign out = r;
	
endmodule