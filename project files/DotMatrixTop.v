module DotMatrixTop(i_Clk, i_Rst, i_Compare, o_DM_Col, o_DM_Row);
input   i_Clk;   // 50MHz
input   i_Rst;
input [1:0]i_Compare;
output   wire [7:0] o_DM_Col, o_DM_Row;

//reg      [ 7:0]   c_Cnt   , n_Cnt;
reg      [63:0]   c_Data   , n_Data;

wire   DM_o_fDone;   // 16ms

// <= counterclockwise rotation
parameter   SUCCESS   = {
   
   8'b10000001,
   8'b01111110,
   8'b01101010,
   8'b01011110,
   8'b01011110,
   8'b01101010,
   8'b01111110,
   8'b10000001};
   

parameter   UP   = {
   
   8'b11110111,
   8'b11110011,
   8'b11110001,
   8'b00000000,
   8'b00000000,
   8'b11110001,
   8'b11110011,
   8'b11110111};

parameter   DOWN   = {
   8'b11101111,
   8'b11001111,
   8'b10001111,
   8'b00000000,
   8'b00000000,
   8'b10001111,
   8'b11001111,
   8'b11101111};
   
parameter   FAIL   = {
   8'b00111100,
   8'b10011001,
   8'b11000011,
   8'b11100111,
   8'b11100111,
   8'b11000011,
   8'b10011001,
   8'b00111100};   

   
DotMatrix   DM0(i_Clk, i_Rst, c_Data, o_DM_Col, o_DM_Row, DM_o_fDone);

always@(posedge i_Clk, negedge i_Rst)
   if(!i_Rst) begin
      //c_Cnt   = 0;
      c_Data   = 0;
   end else begin
      //c_Cnt   = n_Cnt;
      c_Data   = n_Data;
   end

always@*
begin
   //n_Cnt   = DM_o_fDone ? c_Cnt + 1 : c_Cnt;
   case(i_Compare)
      2'h0   : n_Data = SUCCESS;
      2'h1   : n_Data = FAIL;
      2'h2 : n_Data = DOWN;
      default   : n_Data = UP;
   endcase
end

endmodule
