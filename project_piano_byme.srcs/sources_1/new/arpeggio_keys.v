`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 20:05:22
// Design Name: 
// Module Name: arpeggio_keys
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module arpeggio_keys (
 input wire clk,
 input wire rst,
 input wire [7:0] bitmask,
 output reg [3:0] note_id_out
);
   localparam [3:0] NOTE_REST = 4'd0;
   localparam [3:0] NOTE_A4   = 4'd1;
   localparam [3:0] NOTE_B4   = 4'd2;
   localparam [3:0] NOTE_C5   = 4'd3;
   localparam [3:0] NOTE_D5   = 4'd4;
   localparam [3:0] NOTE_E5   = 4'd5;
   localparam [3:0] NOTE_F5   = 4'd6;
   localparam [3:0] NOTE_G5   = 4'd7;
   localparam [3:0] NOTE_A5   = 4'd8;


   reg [7:0] cnt_on;
   reg [3:0] cur_state;
   reg [3:0] next_state;
   reg [23:0] slice_cnt;
   integer i;




   always@(*) begin
       cnt_on=8'd0;
     for (i = 0; i <= 7; i = i + 1) begin
       if(bitmask[i]==1) begin
           cnt_on=cnt_on+1;
     end
   end
   end




    wire slice_tick;
    localparam integer SLICE_CYCLES = 16_000_000;
   assign slice_tick = (slice_cnt == SLICE_CYCLES-1);

  


   always @(posedge clk) begin
       if (rst || (cnt_on == 0)) begin
           slice_cnt <= 18'b0;
       end else if (slice_tick) begin
           slice_cnt <= 18'b0;
       end else begin
           slice_cnt <= slice_cnt + 1'b1;
       end
   end








   always@ (posedge clk) begin
       if(rst|| !cnt_on) begin 
           cur_state<=4'd0; 
       end
       else if(!bitmask[cur_state[2:0]]) begin 
           cur_state <= next_state;
       end
       else if (cnt_on >= 2 && slice_tick) begin 
           cur_state <= next_state;
       end
   end
  
   reg [3:0] tmp;
   reg first;


  
  
   always@ (*) begin
       
        next_state=cur_state;
        first=1'b1;
        for (i = 1; i <= 8; i = i + 1) begin       
           tmp=cur_state+i;
           if(tmp>=8) tmp=tmp-8;
           if(first && bitmask[tmp[2:0]]) begin
               next_state = tmp;
               first=1'b0;
           end
        end


        end


     always @(posedge clk) begin
       if (rst || (cnt_on == 0)) begin
           note_id_out <= NOTE_REST;
       end else begin
           case (cur_state[2:0])
               0: note_id_out <= NOTE_A4; //sw0
               1: note_id_out <= NOTE_B4; //sw1
               2: note_id_out <= NOTE_C5; //sw2
               3: note_id_out <= NOTE_D5; //sw3
               4: note_id_out <= NOTE_E5; //sw4
               5: note_id_out <= NOTE_F5; //sw5
               6: note_id_out <= NOTE_G5; //sw6
               7: note_id_out <= NOTE_A5; //SW7
               default: note_id_out <= NOTE_REST;
           endcase
       end
   end


endmodule


