`timescale 1ns / 1ns
module tb_UP_Down_Game;

reg		Clk;
reg		Rst;
reg  fNum0;
reg  fNum1;
reg		fStart;

Up_Down_Game U0(Clk, Rst, fNum0, fNum1, fStart, o_Num0, o_Num1, o_Left);

always
	#10 Clk = ~Clk;

initial 
begin
	Clk		= 1;
	Rst		= 0;
	fStart	= 1;
	fNum0	= 1;
	fNum1 = 1;

	@(negedge Clk) Rst = 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	
	#100   fNum1 = 0; #20 fNum1 = 1;
	#100   fNum1 = 0; #20 fNum1 = 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	#100			fNum0	= 0;	#20 fNum0	= 1;
	
	#100   fStart	= 0;	#20 fStart = 1;
	
	#100   fNum1 = 0; #20 fNum1 = 1;
	#100   fNum1 = 0; #20 fNum1 = 1;
	#100   fStart	= 0;	#20 fStart = 1;
	
  #100
	$stop;
end
endmodule
