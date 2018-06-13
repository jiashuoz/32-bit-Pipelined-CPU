// 8 to 1 mux
module mux8_1 (d, sel, out); 
	output out;
	input [7:0] d;
	input [2:0] sel;
	// LSB of input corresponds to the 000 selection line
	// MSB corresponds to the 111 selection line
	assign out = (~sel[2] & ~sel[1] & ~sel[0] & d[0])
				  | (~sel[2] & ~sel[1] &  sel[0] & d[1])
				  | (~sel[2] &  sel[1] & ~sel[0] & d[2])
				  | (~sel[2] &  sel[1] &  sel[0] & d[3])
				  | ( sel[2] & ~sel[1] & ~sel[0] & d[4])
				  | ( sel[2] & ~sel[1] &  sel[0] & d[5])
				  | ( sel[2] &  sel[1] & ~sel[0] & d[6])
				  | ( sel[2] &  sel[1] &  sel[0] & d[7]);
endmodule
