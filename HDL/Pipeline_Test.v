module Pipeline_Test (
input clk, reset,


output [31:0] fetchPC
);
wire [3:0] ra1ew,ra1dw,ra2ew,ra2dw,wa3ew,wa3mw,wa3ww,aluflagsw,alucontrolew;
wire branchtakenew, pcsrcdw, pcsrcew, pcsrcmw, pcsrcww;
wire regwriteww,regwritemw, memtoregew;
wire [1:0]forwardaew, forwardbew, immsrcw, shcontrolw;
wire ldrstallw, pcwrpendingfw, stallfw, stalldw, flushdw, flushew;
wire [2:0] regsrcw;
wire [4:0] shamtw;
wire [31:0] instout;
wire memwritem, alusrcew,memtoregw,blselw,blww; 


hazard hazard_unit(
        .RA1E(ra1ew),
        .RA1D(ra1dw),
        .RA2E(ra2ew),
        .RA2D(ra2dw),
        .WA3E(wa3ew),
        .WA3M(wa3mw),
        .WA3W(wa3ww),
        .RegWriteM(regwritemw),
        .RegWriteW(regwriteww),
        .MemtoRegE(memtoregew),
        .BranchE(BranchE), //not done
        .PCSrcD(pcsrcdw),
        .PCSrcE(pcsrcew),
        .PCSrcM(pcsrcmw),
        .PCSrcW(pcsrcww),
        .BranchTakenE(branchtakenew),
        //outputs below
		  .ForwardAE(forwardaew),
        .ForwardBE(forwardbew),
        .StallF(stallfw),
        .StallD(stalldw),
        .FlushD(flushdw),
        .FlushE(flushew)
    );
	 
controller my_controller(
        .reset(reset),
        .clk(clk),
        .Op(instout[27:26]),
        .Funct(instout[25:20]),
        .Rd(instout[15:12]),
        .Src2(instout[11:0]),
        .Cond(instout[31:28]),
        .CO(aluflagsw[3]),
        .OVF(aluflagsw[2]),
        .N(aluflagsw[1]),
        .Z(aluflagsw[0]),
		  //------------
        .ImmSrc_d(immsrcw),
        .ShiftControl_e(shcontrolw),
        .RegSrc_d(regsrcw),
        .ALUControl_e(alucontrolew), 
        .shamt_e(shamtw),
        .ALUSrc_e(alusrcew),
        .CarryIN(CarryIN), //later
        .RegWrite_w(regwriteww),
        .MemWrite_m(memwritem),
        .MemtoReg_w(memtoregw),
		  
        .branchtakene(branchtakenew),
        .PCSrc_w(pcsrcww),
        .PCSrc_mp(pcsrcmw),
        .PCSrc_ep(pcsrcew),
        .PCSrc_dp(pcsrcdw),
        .RegWrite_mp(regwritemw),
        .MemtoReg_ep(memtoregew),
		  .blsel(blselw),
		  .blwritep(blww)
    );
	
datapath my_datapath (
        .pcsrcw(pcsrcww),
        .branchtakene(branchtakenew),
        .clk(clk),
        .stallf(stallfw),
        .stalld(stalldw),
        .flushd(flushdw),
        .regwritew(regwriteww),
		  
        .blsel(blselw), //later
		  
        .flushe(flushew),
        .reset(reset),
        .forwardae(forwardaew),
        .forwardbe(forwardbew),
        .alusrce(alusrcew),
        .wemwritem(memwritem),
        .memtoregw(memtoregw),
        .regsrcd({regsrcw[1],regsrcw[0]}), //check this later
        .immsrcd(immsrcw),
        .shcontrol(shcontrolw),
        .debugsselect(debugsselect),
        .alucontrole(alucontrolew),
        .debugoutwire(debugoutwire),
        .shamt(shamtw),
        .aluflags(aluflagsw),
		  //hazard unit stuff
        .ra1ep(ra1ew),
        .ra2ep(ra2ew),
        .ra1dp(ra1dw),
        .ra2dp(ra2dw),
        .wa3ep(wa3ew),
        .wa3mp(wa3mw),
        .wa3wp(wa3ww),
		  .instrout(instout),
		  .pcout(fetchPC),
		  .blwritewire(blww)
    );



endmodule
