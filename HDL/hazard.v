module hazard(
    input wire [3:0] RA1E, RA1D, RA2E, RA2D, WA3E, WA3M, WA3W, 
    input wire RegWriteM, RegWriteW, MemtoRegE, BranchE,
    input wire PCSrcD, PCSrcE, PCSrcM, PCSrcW, 
	 input BranchTakenE,
    output reg [1:0] ForwardAE, ForwardBE, 

    output reg StallF, StallD, FlushD, FlushE
);

/*
wire Match_1E_M = (RA1E == WA3M);
wire Match_1E_W = (RA1E == WA3W);
wire Match_2E_M = (RA2E == WA3M);
wire Match_2E_W = (RA2E == WA3W);
reg Match_12D_E;
reg LDRstall, PCWrPendingF;


always @(*) begin
    if (Match_1E_M && RegWriteM)
        ForwardAE = 2'b10;
    else if (Match_1E_W && RegWriteW)
        ForwardAE = 2'b01;
    else
        ForwardAE = 2'b00;

    if (Match_2E_M && RegWriteM)
        ForwardBE = 2'b10;
    else if (Match_2E_W && RegWriteW)
        ForwardBE = 2'b01;
    else
        ForwardBE = 2'b00;
end


always @(*) begin

    Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E);
    LDRstall = Match_12D_E && MemtoRegE;



    PCWrPendingF =PCSrcE ;//|| PCSrcM; // PCSrcD || 
    StallF = LDRstall || PCWrPendingF; 
    
    StallD = LDRstall;
    FlushD = PCWrPendingF; //|| PCSrcW || BranchTakenE; 
    FlushE = LDRstall || BranchTakenE;
end
*/
reg Match_1E_M ;
reg Match_1E_W;
reg Match_2E_M ;
reg Match_2E_W;
reg Match_12D_E;
reg LDRstall; 
reg PCWrPendingF; 

initial begin 
	FlushD = 0 ;
	FlushE = 0 ;
	Match_1E_M = 0 ;
	Match_1E_W = 0 ;
	Match_2E_M = 0 ;
	Match_2E_W = 0 ;
	Match_12D_E = 0 ;
	LDRstall = 0 ;
	PCWrPendingF = 0 ;
	StallF = 0 ;
	StallD = 0 ;
end

always @(*) begin
	Match_1E_M = (RA1E == WA3M) ;
	Match_1E_W = (RA1E == WA3W) ;
	if (Match_1E_M && RegWriteM) ForwardAE = 2'b10; // SrcAE = ALUOutM
	else if (Match_1E_W && RegWriteW) ForwardAE = 2'b01; // SrcAE = ResultW
	else ForwardAE = 2'b00; // SrcAE from regfile
	
	Match_2E_M = (RA2E == WA3M) ;
	Match_2E_W = (RA2E == WA3W) ;
	if (Match_2E_M && RegWriteM) ForwardBE = 2'b10; // SrcBE = ALUOutM
	else if (Match_2E_W && RegWriteW) ForwardBE = 2'b01; // SrcBE = ResultW
	else ForwardBE = 2'b00; // SrcBE from regfile(SrcBE is selected from ExtImmE and regfile with another MUX)

	Match_12D_E = (RA1D == WA3E) || (RA2D == WA3E) ;
	LDRstall = Match_12D_E && MemtoRegE ;
	
	PCWrPendingF = (PCSrcD || PCSrcE || PCSrcM) ;
    StallF = (LDRstall || PCWrPendingF) ; 
    StallD = LDRstall ;
	FlushD = (PCWrPendingF || PCSrcW || BranchTakenE) ; 
	FlushE = (LDRstall || BranchTakenE ) ;
end


  
endmodule