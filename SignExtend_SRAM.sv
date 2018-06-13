// Sign Extender for data memory
// Author: Jiashuo Zhang
// Data: 6/1/2016
module SignExtend_SRAM(sramAddress, sramData, dataExtended);
	input [10:0] sramAddress;
	input [15:0] sramData;
	output [31:0] dataExtended;
	
	reg [31:0] dataExtended;
	always @(*) begin
		if (sramAddress < 5)
			dataExtended = {{16{sramData[15]}}, sramData};
		else if (sramAddress < 9)
			dataExtended = {16'b0, sramData}; 
	end
	
endmodule
