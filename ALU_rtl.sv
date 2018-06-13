// ALU module in dataflow level model
// Author: Jiashuo Zhang
// Data: 4/29/2016
module ALU_rtl(A, B, ctrl, shamt, out, Z, V, C, N);
	input  [31:0] A, B;
	input  [2:0]  ctrl; 
	input  [4:0] shamt;
	output [31:0] out;
	output Z, V, C, N; //Z-Zero, V-Overflow, C-Carryout, N-Negative
	
	wire [31:0] out0, out1, out2, out3, out4, out5, out6, out7; // Different operation lines
	wire carryAdd, carrySub;
	wire overflowSub; // Determine subtraction overflow
	
	assign out0 = 32'bz;
	// Add operation: Carry Lookahead Control Unit
	CLU cluAdd(.A, .B, .sum(out1), .C(carryAdd));
	// Sub operation
	CLU cluSub(.A, .B(~B + 1'b1), .sum(out2), .C(carrySub));
	
	assign out3 = A & B; // AND
	assign out4 = A | B; // OR
	assign out5 = A ^ B; // XOR
	assign out6 = A < B ? 32'b1 : 32'b0; // Set Less Than
	
	// Shift Left
	shifter shft(.A, .ctrl(shamt), .out(out7));
	// Pick Operation
	genvar i;
	generate
		for (i=0; i<=31; i=i+1) begin : pickOperation
			mux8_1 m8 ({out7[i], out6[i], out5[i], out4[i], out3[i], out2[i], out1[i], out0[i]}, ctrl, out[i]); end
	endgenerate
	
	assign overflowSub = ~A[31] & B[31] & out[31] | A[31] & ~B[31] & ~out[31]; // Check subtraction overflow
	assign Z = (out==32'b0) ? 1'b1 : 1'b0;							// Zero 
	assign V = ctrl==2 & overflowSub | ctrl==1 & A[31] & B[31] & ~out[31] | ctrl==1 & ~A[31] & ~B[31] & out[31];	// Overflow
	assign C = ctrl==2 & carrySub | ctrl==1 & carryAdd;		// Carry out
	assign N = out[31];													// Negative
endmodule

