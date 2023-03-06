module LFSR(i_Clk, i_Rst, i_fShuffle, i_fStop, i_Max, o_fRdy, o_Num);

parameter	N = 4;
input					i_Clk, i_Rst, i_fShuffle, i_fStop;
input			[N-1:0]	i_Max;
output	wire			o_fRdy;
output	wire	[N-1:0]	o_Num;

/* registers */
reg		[1:0]	c_State,n_State;
reg		[N-1:0]	c_LFSR,	n_LFSR;		// Text - left  32 bits

parameter	IDLE	= 2'b00,
			SHUFFLE	= 2'b10,
			WAIT_RDY= 2'b11,
			READY	= 2'b01;

/* registers */
always@(posedge i_Clk or negedge i_Rst)
	if(!i_Rst) begin
		c_State	= IDLE;
		c_LFSR	= 1;
	end else begin	
		c_State	= n_State;
		c_LFSR	= n_LFSR;
	end	

assign	fShuffle= c_State == SHUFFLE || c_State == WAIT_RDY;
assign	fRdy	= n_LFSR <= i_Max;
assign	o_fRdy	= c_State == READY;
assign	o_Num	= c_LFSR == i_Max ? 0 : c_LFSR;

/* finite state machine */
always@*
begin
	n_LFSR	= fShuffle	? {c_LFSR, c_LFSR[N-1] ^ c_LFSR[0]} : c_LFSR;

	n_State	= c_State;
	case(c_State)
		IDLE 	: if(i_fShuffle)	n_State = SHUFFLE;
		SHUFFLE	: if(i_fStop)
					if(fRdy)		n_State = READY;
					else			n_State = WAIT_RDY;
		WAIT_RDY: if(fRdy)			n_State = READY;
		READY	: if(i_fShuffle)	n_State = SHUFFLE;
	endcase
end

endmodule