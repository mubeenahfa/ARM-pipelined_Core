module controller(
	input reset,
	input clk,
	input [1:0] Op,
	input [5:0] Funct,
	input [3:0] Rd,
	input [11:0] Src2,
	input [3:0] Cond,
	input CO, OVF, N, Z,
	
	output [1:0] ImmSrc_d, ShiftControl_e,
	output [2:0] RegSrc_d,
	output [3:0] ALUControl_e,
	output [4:0] shamt_e,
	output ALUSrc_e, CarryIN, RegWrite_w, MemWrite_m, MemtoReg_w,branchtakene,
	output PCSrc_w,PCSrc_mp,PCSrc_ep,PCSrc_dp, RegWrite_mp,MemtoReg_ep,blsel,blwritep
);
//--------------setting outputs for hazard unit-----------------
assign  PCSrc_mp = PCSrc_m;
assign  PCSrc_ep = PCSrc_e;
assign  PCSrc_dp = PCSrc_d;
assign  RegWrite_mp = RegWrite_m;
assign MemtoReg_ep = MemtoReg_e;
assign blwritep = blwritee;





// Decode Stage ********************
wire [1:0] FlagWrite, FlagWrite_raw, ShiftControl_d,blseld;
wire PCSrc_raw, RegWrite_raw, MemWrite_raw;
wire PCSrc_d, RegWrite_d, MemWrite_d, ALUSrc_d, MemtoReg_d, FlagWrite_d, branch_d; 
wire PCSrc_e, RegWrite_e, MemWrite_e,MemtoReg_e,FlagWrite_e, branch_e; 
wire PCSrc_m, RegWrite_m, MemtoReg_m;
wire [3:0]  ALUControl_d,cond_e;
wire [4:0]  shamt_d;
wire blwrited, blwritee;

/*
Control_unit control_unit_sc(.Op(Op),.Funct(Funct),.Rd(Rd),.Src2(Src2),.PCSrc(PCSrc_raw),.RegWrite(RegWrite_raw),
.MemWrite(MemWrite_raw),.ALUSrc(ALUSrc),.MemtoReg(MemtoReg),
.ALUControl(ALUControl),.FlagWrite(FlagWrite_raw),.RegSrc(RegSrc),.ImmSrc(ImmSrc),
.ShiftControl(ShiftControl),.shamt(shamt));
*/
Control_unit control_unit_sc(.Op(Op),.Funct(Funct),.Rd(Rd),.Src2(Src2),.PCSrc(PCSrc_d),.RegWrite(RegWrite_d),
.MemWrite(MemWrite_d),.ALUSrc(ALUSrc_d),.MemtoReg(MemtoReg_d),
.ALUControl(ALUControl_d),.FlagWrite(FlagWrite_d),.RegSrc(RegSrc_d),.ImmSrc(ImmSrc_d),.branch(branch_d),
.ShiftControl(ShiftControl_d),.shamt(shamt_d),.blsel(blseld),.blwrite(blwrited));

//----------------------------------execute pipeline registers------------------------------------

Register_reset #(1) PCSe(.clk(clk), .reset(reset),.DATA(PCSrc_d),.OUT(PCSrc_e));
Register_reset #(1) RegWe(.clk(clk), .reset(reset),.DATA(RegWrite_d),.OUT(RegWrite_e));
Register_reset #(1) memwritee(.clk(clk), .reset(reset),.DATA(MemWrite_d),.OUT(MemWrite_e));
Register_reset #(1) Alusrce(.clk(clk), .reset(reset),.DATA(ALUSrc_d),.OUT(ALUSrc_e));
Register_reset #(1) memtorege(.clk(clk), .reset(reset),.DATA(MemtoReg_d),.OUT(MemtoReg_e));
Register_reset #(5) shamte(.clk(clk), .reset(reset),.DATA(shamt_d),.OUT(shamt_e));
Register_reset #(2) shift_ctrle(.clk(clk), .reset(reset),.DATA(ShiftControl_d),.OUT(ShiftControl_e));
Register_reset #(2) flagwritee(.clk(clk), .reset(reset),.DATA(FlagWrite_d),.OUT(FlagWrite_e));
Register_reset #(4) Alue(.clk(clk), .reset(reset),.DATA(ALUControl_d),.OUT(ALUControl_e));
Register_reset #(1) branche(.clk(clk), .reset(reset),.DATA(branch_d),.OUT(branch_e));
Register_reset #(4) conde(.clk(clk), .reset(reset),.DATA(Cond),.OUT(cond_e));
Register_reset #(1) blwriteer(.clk(clk), .reset(reset),.DATA(blwrited),.OUT(blwritee));
Register_reset #(1) blseller(.clk(clk), .reset(reset),.DATA(blseld),.OUT(blsel));
//----------------------------------execute reg done----------------------------------------------

Conditional_unit conditional_unit_sc(.clk(clk),.Cond(cond_e),.ALUFlags({CO,OVF,N,Z}),.FlagWrite(FlagWrite_e),.CarryIn(CarryIN),.CondEx(CondEx));
/*
assign PCSrc_out = PCSrc_e & CondEx;
assign RegWrite_out = RegWrite_e & CondEx;
assign MemWrite_out = MemWrite_e & CondEx;
*/
assign branchtakene = branch_e & CondEx;
/*
assign FlagWrite_out[0] = FlagWrite_e[0] & CondEx;
assign FlagWrite_out[1] = FlagWrite_e[1] & CondEx;
*/



//----------------------------------MEMORY pipeline registers------------------------------------

Register_reset #(1) PCSm(.clk(clk), .reset(reset),.DATA(PCSrc_e & CondEx),.OUT(PCSrc_m));
Register_reset #(1) RegWm(.clk(clk), .reset(reset),.DATA(RegWrite_e & CondEx ),.OUT(RegWrite_m));//condex removed from regwrite e
Register_reset #(1) memwritem(.clk(clk), .reset(reset),.DATA(MemWrite_e & CondEx),.OUT(MemWrite_m));
Register_reset #(1) memtoregm(.clk(clk), .reset(reset),.DATA(MemtoReg_e),.OUT(MemtoReg_m));


//----------------------------------memory reg done----------------------------------------------

//----------------------------------writeback pipeline registers------------------------------------
Register_reset #(1) PCSw(.clk(clk), .reset(reset),.DATA(PCSrc_m),.OUT(PCSrc_w));
Register_reset #(1) RegWw(.clk(clk), .reset(reset),.DATA(RegWrite_m),.OUT(RegWrite_w));
Register_reset #(1) memtoregw(.clk(clk), .reset(reset),.DATA(MemtoReg_m),.OUT(MemtoReg_w));


//----------------------------------writeback reg done----------------------------------------------

endmodule


