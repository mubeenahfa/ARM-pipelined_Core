module datapath (
input pcsrcw, branchtakene, clk,stallf,stalld,flushd,regwritew, blsel,flushe, reset,

input alusrce, wemwritem,memtoregw,blwritewire,
input [1:0] regsrcd, immsrcd, shcontrol, forwardae, forwardbe,
input [3:0] debugsselect, alucontrole,
output[31:0] debugoutwire,
input [4:0] shamt,
output [3:0] aluflags,
output [3:0] ra1ep,ra2ep,ra1dp,ra2dp,
output [3:0] wa3ep,wa3mp,wa3wp,
output [31:0] instrout,pcout
);
wire [31:0] bwpcmux, wirefpin, pcf,inmemtodec, pcadderout, instruction,rd1wire,rd2wire,extwire,srcae,fourwordwire;
wire [3:0] ra1wire, ra2wire, a3inwire,wa3e, wa3m,wa3w, nibblefourteenwire,nibblefifteenwire ;
wire [31:0] scrbepremux, extregout,srcbeout, alubin, aluresulte, pcplusd,pcpluse, pcplusm,datamema,datamemd,datamemout;
wire [31:0] pcpluswb, readdataw, resultw,aluoutw, d3inwire,srcbepremux,rd1regout,rd2regout; 
wire onebitgndwire;
//--------------------------------outputs for hazard control unit---------------
 assign ra1dp = ra1wire;
 assign ra2dp = ra2wire;

 assign wa3ep = wa3e;
 assign wa3mp = wa3m;
 assign wa3wp = wa3w; 
 


//------------------------------------------------------------------------------

assign instrout = instruction;
assign pcout = pcf;

Mux_2to1 #(32) pcfirstmux (
    .select(1'b0),
    .input_0(pcadderout),
    .input_1(resultw), 
    .output_value(bwpcmux)
);
Mux_2to1 #(32) pcsecmux (
    .select(branchtakene),
    .input_0(bwpcmux),
    .input_1(aluresulte), 
    .output_value(wirefpin)
);
Register_rsten #(32) fetchpipeline (
    .clk(clk),
    .reset(reset),
    .we(~stallf),
    .DATA(wirefpin),
    .OUT(pcf)
);
Instruction_memory #(4,32) instruction_memory_instance (
    .ADDR(pcf),
    .RD(inmemtodec)
	 
);

Adder #(32) adder_pc (
    .DATA_A(pcf),
    .DATA_B(fourwordwire),
    .OUT(pcadderout)
);



//--------------------Decode stage starts here----------------------------------
Register_rsten #(32) decpipeline (
    .clk(clk),
    .reset(flushd || reset),	
    .we(~stalld),
    .DATA(inmemtodec),
    .OUT(instruction)
	 
);
Register_rsten #(32) decpipelinetwo	 (
    .clk(clk),
    .reset(flushd || reset),	
    .we(~stalld),
    .DATA(pcf+4),
    .OUT(pcplusd)
	 
);
//-------pipeline registers done---------------

Mux_2to1 #(4) ra1mux (
    .select(regsrcd[0]), 
    .input_0(instruction[19:16]),
    .input_1(nibblefifteenwire), 
    .output_value(ra1wire)
);
Mux_2to1 #(4) ra2mux (
    .select(regsrcd[1]),
    .input_0(instruction[3:0]),
    .input_1(instruction[15:12]), 
    .output_value(ra2wire)
);

Register_file #(32) reg_file_dp (
    .clk(clk),
    .write_enable(regwritew || blwritewire),
    .reset(reset),
    .Source_select_0(ra1wire),
    .Source_select_1(ra2wire),
    .Debug_Source_select(debugsselect), 
    .Destination_select(a3inwire), 
    .DATA(d3inwire),
    .Reg_15(pcadderout),
    .out_0(rd1wire),
    .out_1(rd2wire),
    .Debug_out(debugoutwire)
);

Mux_2to1 #(4) a3mux (
    .select(blsel),
    .input_0(wa3w),
    .input_1(nibblefourteenwire), 
    .output_value(a3inwire)
);

Mux_2to1 #(32) d3mux (
    .select(blsel),
    .input_0(resultw),
    .input_1(pcpluse),//originially pcpluswb 
    .output_value(d3inwire)
);
Extender extender_instance (
    .Extended_data(extwire),
    .DATA(instruction[23:0]),
    .select(immsrcd)
);
//--------------------------Execute pipeline registers below---------------------------

Register_reset #(32) expipeline	 (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(rd1wire),
    .OUT(rd1regout)
	 
);
Register_reset #(32) expipelinetwo (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(rd2wire),
    .OUT(rd2regout)
	 
);
Register_reset #(4) expipelinethree (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(instruction[15:12]),
    .OUT(wa3e)
	 
);
Register_reset #(32) expipelinefour (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(extwire),
    .OUT(extregout)
	 
);

Register_reset #(32) expipelinefive (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(pcplusd),
    .OUT(pcpluse)
	 
);
Register_reset #(32) expipelinesix (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(ra1wire),
    .OUT(ra1ep)
	 
);
Register_reset #(32) expipelineseven (
    .clk(clk),
    .reset(flushe || reset),	
    .DATA(ra2wire),
    .OUT(ra2ep)
	 
);


//----------------------------execute pipeline registers done -----------------------
Mux_4to1 #(32) rd1regmux 
	(
        .input_0(rd1regout),
        .input_1(resultw),
		  .input_2(datamema),
		  .input_3(rd1regout),
        .select(forwardae),
        .output_value(srcae)
    );
Mux_4to1 #(32) rd2regmux 
	(
        .input_0(rd2regout),
        .input_1(resultw),
		  .input_2(datamema),
		  .input_3(rd2regout),
        .select(forwardbe),
        .output_value(srcbepremux)
    );
Mux_2to1 #(32) bemux (
    .select(alusrce),
    .input_0(srcbepremux),
    .input_1(extregout), 
    .output_value(srcbeout)
	 );
shifter #(32) shifter_instance (
    .control(shcontrol),
    .shamt(shamt),
    .DATA(srcbeout),
    .OUT(alubin)
);
ALU #(32) My_ALU 
	(
		.control(alucontrole),
		.CI(onebitgndwire),
		.DATA_A(srcae),
		.DATA_B(alubin),
		.OUT(aluresulte),
		.CO(aluflags[3]),
		.OVF(aluflags[2]),
		.N(aluflags[1]), 
		.Z(aluflags[0])
	);
//-----------------------------------------Memory Reg array below------------------
Register_reset #(32) mempipeline (
    .clk(clk),
    .reset(reset),	
    .DATA(aluresulte),
    .OUT(datamema)
	 
);
Register_reset #(32) mempipelinetwo (
    .clk(clk),
    .reset(reset),	
    .DATA(rd2regout),
    .OUT(datamemd)
	 
);
Register_reset #(32) mempipelinethree (
    .clk(clk),
    .reset(reset),	
    .DATA(wa3e),
    .OUT(wa3m)
	 
);
Register_reset #(32) mempipelinefour (
    .clk(clk),
    .reset(reset),	
    .DATA(pcpluse),
    .OUT(pcplusm)
);

//-----------------------------------Memory reg done------------------------
Memory #(4,32) Data_Memory
(
	.clk(clk),
	.WE(wemwritem),
	.ADDR(datamema),	
	.WD(datamemd),
	.RD(datamemout) 
);

//--------------------------------Write-back pipeline registers-----------------------
Register_reset #(32) wbpipeline (
    .clk(clk),
    .reset(reset),	
    .DATA(datamemout),
    .OUT(readdataw)
	 
);
Register_reset #(32) wbpipelinetwo (
    .clk(clk),
    .reset(reset),	
    .DATA(datamema),
    .OUT(aluoutw)
	 
);
Register_reset #(32) wbpipelinethree (
    .clk(clk),
    .reset(reset),	
    .DATA(wa3m),
    .OUT(wa3w)
	 
);
Register_reset #(32) wbpipelinefour (
    .clk(clk),
    .reset(reset),	
    .DATA(pcplusm),
    .OUT(pcpluswb)
);
//------------------------------register declarations done--------------------------
Mux_2to1 #(32) lastmux (
    .select(memtoregw),
    .input_0(aluoutw),
	 .input_1(readdataw),
    .output_value(resultw)
);
constant_generator constant_gen (
    .onebitgnd(onebitgndwire),
    .fourword(fourwordwire),
    .nibblefourteen(nibblefourteenwire),
    .nibblefifteen(nibblefifteenwire)
);

endmodule
