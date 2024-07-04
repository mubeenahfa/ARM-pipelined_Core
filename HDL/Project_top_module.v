
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE1_SOC(

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);

wire [31:0] reg_out, PC;
hexto7seg hex_0 (.hexn(HEX0),.hex(reg_out[3:0]));
hexto7seg hex_1 (.hexn(HEX1),.hex(reg_out[7:4]));
hexto7seg hex_2 (.hexn(HEX2),.hex(reg_out[11:8]));
hexto7seg hex_3 (.hexn(HEX3),.hex(reg_out[15:12]));

hexto7seg hex_4 (.hexn(HEX4),.hex(PC[3:0]));
hexto7seg hex_5 (.hexn(HEX5),.hex(PC[7:4]));


top inst1(
    .clk(~KEY[0]),
    .reset(~KEY[1]),
    .debug_reg_select(SW[3:0]),
    .debug_reg_out(reg_out),
    .fetchPC(PC),
    .fsm_state(LEDR[3:0])
);

endmodule
