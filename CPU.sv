// Pipelined CPU
// Author: Jiashuo Zhang, Hongting Wang, Fanya Weng
// Data: 6/1/2016
module CPU(CLOCK_50, SW, LEDR);
	output [9:0] LEDR;
	input  [9:0] SW;
	input CLOCK_50; // 50MHz clock.
	wire rst;
	assign rst = SW[8];
	
	wire [31:0] instr_out, instruction, pcOut, incrPC, branchPC, extended, resultALU,wData, rData1, rData2, B, pcIn, A, B_0, dataExtended;
	wire RegDst, Branch, Jump, JR, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, PC_write, IFID_write, mux_ctrl, PCSrc, Z, IFflush, IDflush, EXflush, V, C, N;
	wire [4:0] ws1, ws2, shamt;
	wire [1:0] ALUOp;
	wire [63:0] IFID_out; 
	wire [153:0] IDEX_out;
	wire [145:0] EXMEM_out;
	wire [70:0] MEMWB_out;
	wire [1:0] WB;		
	wire [2:0] M;		
	wire [3:0] EX;
	wire [8:0] controlSignals;
	wire [4:0] controlSignals_EX;
	wire [1:0] J_JR, J_JR_EX, forward_A, forward_B;
	wire [15:0] sramData;
	wire [2:0] opSelect;

	instructionMemory instMem (.address(pcOut[6:0]), .instruction(instr_out));

	pc pCounter (.clk(CLOCK_50), .rst, .pcOut(pcOut), .pcIn(pcIn), .PC_write);

	// Pipeline registers
	IFID_reg #(64)  IF_ID (.clk(CLOCK_50), .rst, .in({incrPC, instr_out}), .out(IFID_out), .IFID_write, .IFflush);

	register #(154) ID_EX (.clk(CLOCK_50), .rst, .in({J_JR, IFID_out[25:21], controlSignals, IFID_out[63:32], rData1, rData2, extended, IFID_out[20:16], IFID_out[15:11]}), .out(IDEX_out));

	register #(146) EX_MEM (.clk(CLOCK_50), .rst, .in({IDEX_out[41:10], J_JR_EX, IDEX_out[151:147], controlSignals_EX, branchPC, Z, resultALU, B_0, ws1}), .out(EXMEM_out));
	
	register #(71) MEM_WB (.clk(CLOCK_50), .rst, .in({EXMEM_out[106:105] , dataExtended, EXMEM_out[68:37], EXMEM_out[4:0]}), .out(MEMWB_out));
	
	// Control Unit
	control ctrl (.Opcode(IFID_out[31:26]), .funct(IFID_out[5:0]), 
				  .RegDst, .ALUOp, .ALUSrc, .Branch, .MemRead, .MemWrite, .MemtoReg, .RegWrite, .Jump, .JR,
				  .branchCheck(PCSrc), .JumpCheck(EXMEM_out[113]), .JRCheck(EXMEM_out[112]), .IFflush, .IDflush, .EXflush);

	// Adders increment PC and branch PC
	CLU add1 (.A(pcOut), .B(1), .sum(incrPC));
	CLU add2 (.A(IDEX_out[137:106]), .B(IDEX_out[41:10]), .sum(branchPC));
	
	// Sign Extenders
	signExtender se (IFID_out[15:0], extended);
	SignExtend_SRAM signExt (.sramAddress(EXMEM_out[47:37]), .sramData(sramData), .dataExtended);

	// Data memory
	SRAM sram(.clk(CLOCK_50), .address(EXMEM_out[47:37]), .data(sramData), .we(EXMEM_out[102]), .re(EXMEM_out[103]));

	// Register file
	GPR regfile (.clk(CLOCK_50), .rst, .rs1(IFID_out[25:21]), .rs2(IFID_out[20:16]), .ws(MEMWB_out[4:0]), .we(MEMWB_out[70]), .wData, .rData1, .rData2);
	
	ALUcontrol aluCtrl (.funct(IDEX_out[15:10]), .enable(IDEX_out[140:139]), .opSelect(opSelect));
	
	// ALU
	ALU_rtl alu (.A(A), .B(B), .ctrl(opSelect), .shamt(IDEX_out[20:16]), .out(resultALU), .Z, .V, .C, .N);
	
	// Forwarding unit
	forwarding f(.IDEX_rs(IDEX_out[151:147]), .IDEX_rt(IDEX_out[9:5]), .EXMEM_rd(EXMEM_out[4:0]), .MEMWB_rd(MEMWB_out[4:0]), 
						.EXMEM_RegWrite(EXMEM_out[106]), .MEMWB_RegWrite(MEMWB_out[70]), 
						.IDEX_MemWrite(IDEX_out[142]), .EXMEM_MemWrite(EXMEM_out[102]),
						.forward_A, .forward_B);

	hazard_detect hdu (.clk(CLOCK_50), .rst, .IFID_rs(IFID_out[25:21]), .IFID_rt(IFID_out[20:16]), .IDEX_rt(IDEX_out[9:5]), .IDEX_MemRead(IDEX_out[143]), .PC_write, .IFID_write, .mux_ctrl);

	// Write back control signals
	assign WB = {RegWrite, MemtoReg};

	// Memory control signals
	assign M  = {Branch, MemRead, MemWrite};

	// Execution control signals
	assign EX = {RegDst, ALUOp, ALUSrc};

	// Flush signals in IDEX
	assign controlSignals = (mux_ctrl || IDflush) ? 0 : {WB, M, EX};

	// Flush signals in EXMEM
	assign controlSignals_EX = EXflush ? 0 : IDEX_out[146:142];

	// Flush Jump and JumpRegister in IDEX and EXMEM
	assign J_JR = (mux_ctrl || IDflush) ? 0 : {Jump, JR};
	assign J_JR_EX = EXflush ? 0 : IDEX_out[153:152];

	// Write address for register file for EXMEM
	assign ws1 = IDEX_out[141] ? IDEX_out[4:0] : IDEX_out[9:5];

	// Branch & Zero
	assign PCSrc = EXMEM_out[104] & EXMEM_out[69]; 

	// Pick write address for Register File
	assign wData = MEMWB_out[69] ? MEMWB_out[36:5] : MEMWB_out[68:37];

	// Data bidirectional bus
	assign sramData = EXMEM_out[102] & ~EXMEM_out[103] ? EXMEM_out[20:5] : 16'bz;

	// Source B after forwarding selection
	assign B = IDEX_out[138] ? IDEX_out[41:10] : B_0;

	// Forwarding muxes
	always @(*) begin
		case (forward_A)
			2'b00: A = IDEX_out[105:74];
			2'b01: A = wData;
			2'b10: A = EXMEM_out[68:37];
			default: A = 32'b0;
		endcase
		
		case (forward_B)
			2'b00: B_0 = IDEX_out[73:42];
			2'b01: B_0 = wData;
			2'b10: B_0 = EXMEM_out[68:37];
			default: A = 32'b0;
		endcase
	end

	// Update program counter
	always@(*) begin
		if (EXMEM_out[112]) 				// JR
			pcIn[6:0] = EXMEM_out[68:37];
		else if (EXMEM_out[113])			// J
			pcIn[6:0] = EXMEM_out[145:114];
		else if (PCSrc)						// Branch
			pcIn[6:0] = EXMEM_out[101:70];
		else								// Increment PC by 1
			pcIn[6:0] = incrPC[6:0];
	end

endmodule
