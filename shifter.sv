// Barrel shifter
module shifter(A, ctrl, out);
	input  [31:0] A;
	input  [4:0] ctrl;
	output [31:0] out;
	
	wire   [31:0] out5, out4, out3, out2; // Out3 shift 3-bit, Out2 shift 2-bit
	
	assign out5 = ctrl==5 ? {A[26:0]   , 5'b0} : A[31:0];
	assign out4 = ctrl==4 ? {out5[27:0], 4'b0} : out5[31:0];
	assign out3 = ctrl==3 ? {out4[28:0], 3'b0} : out4[31:0]; //3 bit
	assign out2 = ctrl==2 ? {out3[29:0], 2'b0} : out3[31:0]; // 2 bit
	assign out  = ctrl==1 ? {out2[30:0], 1'b0} : out2[31:0]; // 1 bit

endmodule