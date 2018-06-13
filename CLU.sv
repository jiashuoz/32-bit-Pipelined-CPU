// Carry Lookahead Unit
// Author: Jiashuo Zhang
// Data: 4/29/2016
module CLU(A, B, sum, C);
	input [31:0] A, B;
	output [31:0] sum;
	output C;
	
	wire [7:0] Cout, Pout, Gout;
	assign C = Cout[7];
	
	// Construct 32-bit CarryLookahead adder using 8 4-bit CLA
	CLA_4bit carryLookAhead0 (A[3:0],   B[3:0],   1'b0,    sum[3:0],   Cout[0], Pout[0], Gout[0]);
	CLA_4bit carryLookAhead1 (A[7:4],   B[7:4],   Cout[0], sum[7:4],   Cout[1], Pout[1], Gout[1]);
	CLA_4bit carryLookAhead2 (A[11:8],  B[11:8],  Cout[1], sum[11:8],  Cout[2], Pout[2], Gout[2]);
	CLA_4bit carryLookAhead3 (A[15:12], B[15:12], Cout[2], sum[15:12], Cout[3], Pout[3], Gout[3]);
	CLA_4bit carryLookAhead4 (A[19:16], B[19:16], Cout[3], sum[19:16], Cout[4], Pout[4], Gout[4]);
	CLA_4bit carryLookAhead5 (A[23:20], B[23:20], Cout[4], sum[23:20], Cout[5], Pout[5], Gout[5]);
	CLA_4bit carryLookAhead6 (A[27:24], B[27:24], Cout[5], sum[27:24], Cout[6], Pout[6], Gout[6]);
	CLA_4bit carryLookAhead7 (A[31:28], B[31:28], Cout[6], sum[31:28], Cout[7], Pout[7], Gout[7]);
endmodule

// 4-bit CarryLookahead adder
module CLA_4bit(A, B, Cin, sum, Cout, Pout, Gout);
	input  [3:0] A, B; // Input
	input  Cin;			// carryOut in
	output [3:0] sum; // Sum
	output Cout;
	output Pout, Gout; // carryOutout, Propagate out, Generate out
	
	wire [3:0] G, P, carryOut;
	
	assign G = A & B; // carryOut Generator
	assign P = A ^ B; // carryOut Propagator
	// First carryOut bit
	assign carryOut[0] = G[0] | (P[0] & Cin);
	
	// Second carryOut bit
	assign carryOut[1] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & Cin);
	
	// Third carryOut bit
	assign carryOut[2] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & Cin);
	
	// Last carryOut bit
	assign carryOut[3] = G[3] | (P[3] & G[2]) | 
									(P[3] & P[2] & G[1]) | 
									(P[3] & P[2] & P[1] & G[0]) | 
									(P[3] & P[2] & P[1] & P[0] & Cin);	
	assign Cout = carryOut[3];
	assign sum = P ^ {carryOut[2:0], Cin};
	assign Pout = P[3] & P[2] & P[1] & P[0];
	assign Gout = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]);

endmodule
