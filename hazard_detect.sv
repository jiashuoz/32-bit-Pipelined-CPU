// Hazard detection unit
// Author: Jiashuo Zhang
// Data: 6/1/2016
module hazard_detect(clk, rst, IFID_rs, IFID_rt, IDEX_rt, IDEX_MemRead, PC_write, IFID_write, mux_ctrl);
	input [4:0] IFID_rs, IFID_rt, IDEX_rt;
	input 		IDEX_MemRead;
	input 		clk, rst;
	output 		PC_write, IFID_write, mux_ctrl;
	
	always @ (*) begin
		// Stall when we use after load
		if (IDEX_MemRead && ((IDEX_rt == IFID_rs) || (IDEX_rt == IFID_rt))) begin
			PC_write = 0;
			IFID_write = 0;
			mux_ctrl = 1;
		end
		else begin
			PC_write = 1;
			IFID_write = 1;
			mux_ctrl = 0;

		end
	end
	
endmodule
