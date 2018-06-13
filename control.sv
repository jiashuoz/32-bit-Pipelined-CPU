// Main control module for CPU
// Author: Jiashuo Zhang
// Data: 4/29/2016
module control(Opcode, funct, RegDst, Branch, Jump, JR,MemRead, MemtoReg, ALUOp, MemWrite, ALUSrc, RegWrite, 
					branchCheck, JumpCheck, JRCheck, IFflush, IDflush, EXflush);
	input [5:0] Opcode, funct;
	input branchCheck, JumpCheck, JRCheck;
	output RegDst, Branch, Jump, JR, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	output [1:0] ALUOp;
	output reg IFflush, IDflush, EXflush;
	
	reg RegDst, Branch, Jump, JR, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	reg [1:0] ALUOp;
	
	parameter ADDI =  6'd8, R = 6'd0, LW = 6'd35, SW = 6'd43, J = 6'd2, BEQ = 6'd4, JumpR = 6'd8;
	
	// Specify signals to set up different datapaths
	always @(*) begin
		if (branchCheck|| JumpCheck || JRCheck) begin
			IFflush = 1;
			IDflush = 1;
			EXflush = 1;
		end else begin
			IFflush = 0;
			IDflush = 0;
			EXflush = 0;
			case (Opcode)
				// Immediate
				ADDI: begin
					 RegDst = 0;
					 Branch = 0; Jump = 0; JR = 0;
					 MemRead = 0; MemtoReg = 1; MemWrite = 0;
					 ALUSrc = 1;
					 RegWrite = 1;
					 ALUOp = 2'b11;
					 end
				// R type instruction including JumpRegister
				R: begin
					if (funct == JumpR) begin
						RegDst = 0;
						Branch = 0; Jump = 0; JR = 1;
						MemRead = 0; MemtoReg = 1; MemWrite = 0; 
						ALUSrc = 0; 
						RegWrite = 0; 
						ALUOp = 2'b11;
					end else begin
						RegDst = 1;
						Branch = 0; Jump = 0; JR = 0;
						MemRead = 0; MemtoReg = 1; MemWrite = 0;
						ALUSrc = 0;
						RegWrite = 1;
						ALUOp = 2'b10;
					end
					end
				// Load word from SRAM to register
				LW: begin
					 RegDst = 0;
					 Branch = 0; Jump = 0; JR = 0;
					 MemRead = 1; MemtoReg = 0; MemWrite = 0;
					 ALUSrc = 1;
					 RegWrite = 1;
					 ALUOp = 2'b00;
					 end
				// Store word from register back to memory
				SW: begin
					 RegDst = 0;
					 Branch = 0; Jump = 0; JR = 0;
					 MemRead = 0; MemtoReg = 0; MemWrite = 1;
					 ALUSrc = 1;
					 RegWrite = 0;
					 ALUOp = 2'b00;
					 end
				// Jump
				J : begin
					 RegDst = 0;
					 Branch = 0; Jump = 1; JR = 0;
					 MemRead = 0; MemtoReg = 0; MemWrite = 0;
					 ALUSrc = 0;
					 RegWrite = 0;
					 ALUOp = 2'b11;
					 end
				// Branch equal
				BEQ:begin
					 RegDst = 0;
					 Branch = 1; Jump = 0; JR = 0;
					 MemRead = 0; MemtoReg = 0; MemWrite = 0;
					 ALUSrc = 0;
					 RegWrite = 0;
					 ALUOp = 2'b01;
					 end
				default: begin
					 RegDst = 1'bx;
					 Branch = 1'bx; Jump = 1'bx; JR = 1'bx;
					 MemRead = 1'bx; MemtoReg = 1'bx; MemWrite = 1'bx;
					 ALUSrc = 1'bx;
					 RegWrite = 1'bx;
					 ALUOp = 2'bxx; end
			endcase
		end
	end
	
endmodule
