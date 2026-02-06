`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2026 21:44:51
// Design Name: 
// Module Name: note_rle_player_restartable
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


module mask_rle_player_restartable (
    input  wire        clk,
    input  wire        rst,
    input  wire        clear,

    input  wire        play_en,
    input  wire        loop,
    input  wire        sample_tick,

    input  wire [12:0] rec_len,    

    output reg  [11:0] rd_addr,
    input  wire [7:0]  rd_mask,
    input  wire [15:0] rd_dur,

    output reg  [7:0]  mask_out
);
    reg [11:0] seg_ptr;   
    reg [15:0] dur_left;
    reg [7:0]  cur_mask;

    reg play_en_prev;
    reg playing;

    localparam S_IDLE  = 2'd0;
    localparam S_FETCH = 2'd1;
    localparam S_LOAD  = 2'd2;
    localparam S_PLAY  = 2'd3;
    reg [1:0] state;
    wire [11:0] last_addr = rec_len[11:0] - 12'd1; 

    always @(posedge clk) begin
        if (rst || clear) begin
            rd_addr      <= 12'd0;
            seg_ptr      <= 12'd0;
            dur_left     <= 16'd0;
            cur_mask     <= 8'd0;
            mask_out     <= 8'd0;

            play_en_prev <= 1'b0;
            playing      <= 1'b0;
            state        <= S_IDLE;
        end else begin
            mask_out <= playing ? cur_mask : 8'd0;


            if (!play_en_prev && play_en) begin
                if (rec_len != 13'd0) begin
                    playing  <= 1'b1;
                    seg_ptr  <= 12'd0;
                    dur_left <= 16'd0;
                    state    <= S_FETCH;
                end else begin
                    playing <= 1'b0;
                    state   <= S_IDLE;
                end
            end


            if (play_en_prev && !play_en) begin
                playing  <= 1'b0;
                dur_left <= 16'd0;
                state    <= S_IDLE;
            end

            if (playing && sample_tick) begin
                case (state)
                    S_FETCH: begin
                        // Request data for current seg_ptr
                        rd_addr <= seg_ptr;
                        state   <= S_LOAD;
                    end

                    S_LOAD: begin
                        // Data for rd_addr is now valid
                        cur_mask <= rd_mask;
                        dur_left <= (rd_dur == 16'd0) ? 16'd1 : rd_dur;
                        state    <= S_PLAY;
                    end

                    S_PLAY: begin
                        if (dur_left > 16'd1) begin
                            dur_left <= dur_left - 16'd1;
                        end else begin
                            dur_left <= 16'd0;

                            if (seg_ptr >= last_addr) begin
                                if (loop) begin
                                    seg_ptr <= 12'd0;
                                    state   <= S_FETCH;
                                end else begin
                                    playing <= 1'b0;
                                    state   <= S_IDLE;
                                end
                            end else begin
                                seg_ptr <= seg_ptr + 12'd1;
                                state   <= S_FETCH;
                            end
                        end
                    end

                    default: state <= S_IDLE;
                endcase
            end

            play_en_prev <= play_en;
        end
    end
endmodule

