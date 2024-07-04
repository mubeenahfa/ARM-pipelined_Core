module constant_generator (
output onebitgnd,
output [31:0] gndword,
output [31:0] fourword,
output [3:0] nibblefourteen,
output [3:0] nibblefifteen
);
assign onebitgnd = 1'b0;
assign gndword = 32'b0;
assign fourword = 32'b0000_0000_0000_0000_0000_0000_0000_0100;
assign nibblefourteen = 4'b1110;
assign nibblefifteen = 4'b1111; 
endmodule
