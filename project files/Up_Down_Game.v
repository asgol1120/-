module Up_Down_Game(i_Clk, i_Rst, i_Num0, i_Num1, i_Start, o_Num0, o_Num1, o_Left, o_DM_Col, o_DM_Row);

input   i_Clk;
input   i_Rst;
input i_Num0;
input i_Num1;
input i_Start;

output   wire [6:0] o_Num0; 
output   wire [6:0] o_Num1;
output   wire [6:0] o_Left;
output wire [7:0] o_DM_Col, o_DM_Row;

//regs.
reg [1:0] c_State, n_State;
reg [1:0] c_Compare, n_Compare; //00 ok, 10 up, 11 down
reg [2:0] c_Left, n_Left;
reg [3:0] c_Num0, n_Num0; //1 inputnum
reg [2:0] c_Num1, n_Num1; //10? 
reg [3:0] c_RandomNum0, n_RandomNum0; //?? 1? ?? ?
reg [2:0] c_RandomNum1, n_RandomNum1; //?? 10? ?? ?

reg            c_fNum0,   n_fNum0;
reg            c_fNum1,   n_fNum1;
reg            c_fStart,   n_fStart;

wire fNum0, fNum1, fStart;

// In/out of submoduels
//Dot
wire [1:0] DOT_i_Data;
wire [7:0] DOT_o_DM_Col;
wire [7:0] DOT_o_DM_Row;
//LFSR
wire LFSR0_o_fRdy;
wire LFSR1_o_fRdy;
wire [3:0] LFSR0_o_Num;
wire [2:0] LFSR1_o_Num;

// State
parameter   IDLE   = 2'h0;
parameter   INPUT_COMPARE   = 2'h1;
parameter   FAIL   = 2'h2;
parameter   SUCCESS   = 2'h3;

//updown
parameter MATCH = 2'b00;
parameter UP = 2'b11;
parameter DOWN = 2'b10;
parameter DEFEAT = 2'b01; 


assign   fStart   = !i_Start && c_fStart;
assign   fNum0   = !i_Num0 && c_fNum0;
assign   fNum1   = !i_Num1 && c_fNum1;
assign LFSR_i_fStop = fNum0 || fNum1;
assign LFSR_i_fShuffle = c_State == IDLE;
assign DOT_i_Data = c_Compare;
assign o_DM_Col = (c_State == FAIL || c_State == SUCCESS)?DOT_o_DM_Col:8'b11111111;
assign o_DM_Row = (c_State == FAIL || c_State == SUCCESS)?DOT_o_DM_Row:8'b11111111;

//submodule
FND   FND0(c_Num0,   o_Num0);
FND   FND1(c_Num1,   o_Num1);
FND   FND2(c_Left,   o_Left); //left
DotMatrixTop DOT0(i_Clk, i_Rst, DOT_i_Data, DOT_o_DM_Col, DOT_o_DM_Row);
LFSR LFSR0(i_Clk, i_Rst, LFSR_i_fShuffle, LFSR_i_fStop, 10, LFSR0_o_fRdy, LFSR0_o_Num);
LFSR1 LFSR1(i_Clk, i_Rst, LFSR_i_fShuffle, LFSR_i_fStop, 5, LFSR1_o_fRdy, LFSR1_o_Num);

always@(posedge i_Clk or negedge i_Rst)
  if(!i_Rst) begin
    c_State = IDLE;
    c_Compare = 0;
    c_Left = 5;
    c_Num0 = 0;
    c_Num1 = 0;
    c_RandomNum0 = n_RandomNum0;
    c_RandomNum1 = n_RandomNum1;
    c_fNum0 = 1;
    c_fNum1 = 1;
    c_fStart = 1;
  end else begin
    c_State = n_State;
    c_Compare = n_Compare;
    c_Left = n_Left;
    c_Num0 = n_Num0;
    c_Num1 = n_Num1;
    c_RandomNum0 = n_RandomNum0;
    c_RandomNum1 = n_RandomNum1;
    c_fNum0 = n_fNum0;
    c_fNum1 = n_fNum1;
    c_fStart = n_fStart;
  end
  
  always@*begin
  n_State = c_State;
  n_Compare = c_Compare;
  n_Left = c_Left;
  n_Num0 = c_Num0;
  n_Num1 = c_Num1;
  n_RandomNum0 = c_RandomNum0;
  n_RandomNum1 = c_RandomNum1;
  
  n_fNum0 = i_Num0;
  n_fNum1 = i_Num1;
  n_fStart = i_Start;
  
  case(c_State)
    IDLE: begin
      n_Left = 5;
      if(LFSR0_o_fRdy) n_RandomNum0 = LFSR0_o_Num;
      if(LFSR1_o_fRdy) n_RandomNum1 = LFSR1_o_Num;
      if(n_RandomNum0 == LFSR0_o_Num && n_RandomNum1 == LFSR1_o_Num) n_State = INPUT_COMPARE;

    end

    INPUT_COMPARE: begin
      
      if(c_Num0 == c_RandomNum0 && c_Num1 == c_RandomNum1) n_Compare = MATCH;
      else if (c_Num0 + c_Num1 * 10 > c_RandomNum0 + c_RandomNum1 * 10) n_Compare = DOWN;
      else n_Compare = UP;
        
      
      
      if(fNum0)begin
        n_Num0 = c_Num0 +1;
        if(n_Num0 == 10) n_Num0 = 0;
        end
      else n_Num0 = c_Num0;
        
      if(fNum1)begin
        n_Num1 = c_Num1 +1;
        if(n_Num1 == 6) n_Num1 = 0;
        end
      else n_Num1 = c_Num1; 
        
      if(fStart)begin  
        n_Left = c_Left - 1;
        if(c_Compare[1]) n_State = FAIL;
        else n_State = SUCCESS;
      end        
    end
    
    FAIL: begin
      if (c_Left == 0) begin
        n_Compare = DEFEAT;
        if(fStart) n_State = IDLE;
        end
      if (c_Left != 0) begin
        if(fStart) n_State = INPUT_COMPARE;
        end 
      
    end
    
    SUCCESS: begin
      if(fStart) n_State = IDLE;
        
    end
  endcase
end
    
endmodule