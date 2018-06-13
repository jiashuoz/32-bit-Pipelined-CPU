// ALU module in dataflow level model
// Author: Jiashuo Zhang
// Data: 6/1/2016
module ALUcontrol (funct, enable, opSelect);
	input [5:0] funct;
	input [1:0] enable;
	output reg [2:0] opSelect;
	
	parameter [5:0] ADD = 6'b100000, SUB = 6'b100010, AND = 6'b100100, OR = 6'b100101;
	parameter [5:0] XOR = 6'b100110, SLT = 6'b101010, SLL = 6'b000000;
	parameter [1:0] lwsw = 2'b00 , beq = 2'b01,  alu = 2'b10, addi = 2'b11;
	
	always @(*) begin
		case(enable)
			lwsw: opSelect = 3'b001; //00 ADD
			beq:  opSelect = 3'b010; //01 SUB
			alu:	begin // 10
						case(funct)
						ADD: opSelect = 3'b001; // Add
						SUB: opSelect = 3'b010; // Sub
						AND: opSelect = 3'b011; // And
						OR:  opSelect = 3'b100; // Or
						XOR: opSelect = 3'b101; // Xor
						SLT: opSelect = 3'b110; // Set less than
						SLL: opSelect = 3'b111; // Shift left logical, also used for NOP
						default: opSelect = 3'b000;
						endcase
					end
			addi: opSelect = 3'b001; // Add Immediate
			default: opSelect = 3'b000;
		endcase
	end

endmodule