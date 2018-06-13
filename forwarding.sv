// Forwarding unit
// Author: Jiashuo Zhang
// Data: 6/1/2016
module forwarding(IDEX_rs, IDEX_rt, EXMEM_rd, MEMWB_rd, EXMEM_RegWrite, MEMWB_RegWrite, IDEX_MemWrite, EXMEM_MemWrite, forward_A, forward_B);
	input [4:0] IDEX_rs, IDEX_rt, EXMEM_rd, MEMWB_rd;
	input			EXMEM_RegWrite, MEMWB_RegWrite, IDEX_MemWrite, EXMEM_MemWrite;
	output reg [1:0] forward_A, forward_B;
	
	always @(*) begin
		if ((EXMEM_RegWrite) && EXMEM_rd != 0 && (EXMEM_rd == IDEX_rs))
			forward_A <= 2'b10; // ALUresult
		else if (MEMWB_RegWrite && MEMWB_rd != 0 && (MEMWB_rd == IDEX_rs))
			forward_A <= 2'b01; // wData
		else
			forward_A <= 2'b00; // rData1
		
		if ((EXMEM_RegWrite) && EXMEM_rd != 0 && (EXMEM_rd == IDEX_rt))
			forward_B <= 2'b10; // ALUresult
		else if (MEMWB_RegWrite && MEMWB_rd != 0 && (MEMWB_rd == IDEX_rt))
			forward_B <= 2'b01; // wData
		else
			forward_B <= 2'b00; // rData2
	end
	
endmodule
