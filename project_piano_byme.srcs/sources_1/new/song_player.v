`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 20:40:03
// Design Name: 
// Module Name: song_player
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


module song_player_div #(
    parameter integer DEPTH  = 2048,
    parameter integer ADDR_W = 11
)(
    input  wire              clk,
    input  wire              rst,
    input  wire              clear,

    input  wire              song_en,
    input  wire              loop,
    input  wire              sample_tick,  

    output reg  [ADDR_W-1:0] rom_addr,
    input  wire [63:0]       rom_data,     

    output reg  [31:0]       note_div_out,
    output reg               playing
);
    // Event format (64-bit):
    // [63:32] note_div (0 => rest)
    // [31:16] dur_ticks (unit = sample_tick)
    // [15:0]  cmd (0xFFFF => END)

    localparam S_IDLE  = 2'd0;
    localparam S_FETCH = 2'd1;
    localparam S_LOAD  = 2'd2;
    localparam S_PLAY  = 2'd3;

    reg [1:0] state;

    reg [63:0] ev_reg;     // latched event
    wire [31:0] ev_div = ev_reg[63:32];
    wire [15:0] ev_dur = ev_reg[31:16];
    wire [15:0] ev_cmd = ev_reg[15:0];

    reg [15:0] dur_left;
    reg        song_en_prev;

    always @(posedge clk) begin
        if (rst || clear) begin
            rom_addr     <= {ADDR_W{1'b0}};
            note_div_out <= 32'd0;
            playing      <= 1'b0;
            dur_left     <= 16'd0;
            song_en_prev <= 1'b0;
            state        <= S_IDLE;
            ev_reg       <= 64'd0;
        end else begin
            // rising edge song_en => restart
            if (!song_en_prev && song_en) begin
                rom_addr     <= {ADDR_W{1'b0}};
                note_div_out <= 32'd0;
                dur_left     <= 16'd0;
                playing      <= 1'b1;
                state        <= S_FETCH;
            end

            // falling edge song_en => stop
            if (song_en_prev && !song_en) begin
                playing      <= 1'b0;
                note_div_out <= 32'd0;
                dur_left     <= 16'd0;
                state        <= S_IDLE;
            end

            if (playing && sample_tick) begin
                case (state)
                    S_FETCH: begin
                        // rom_addr is already set; wait 1 cycle for rom_data to become valid
                        state <= S_LOAD;
                    end

                    S_LOAD: begin
                        // now rom_data corresponds to current rom_addr
                        ev_reg <= rom_data;
                        state  <= S_PLAY;
                    end

                    S_PLAY: begin
                        if (dur_left == 16'd0) begin
                            // start/handle current event
                            if (ev_cmd == 16'hFFFF) begin
                                // END
                                if (loop) begin
                                    rom_addr     <= {ADDR_W{1'b0}};
                                    note_div_out <= 32'd0;
                                    dur_left     <= 16'd0;
                                    state        <= S_FETCH;
                                end else begin
                                    playing      <= 1'b0;
                                    note_div_out <= 32'd0;
                                    dur_left     <= 16'd0;
                                    state        <= S_IDLE;
                                end
                            end else begin
                                note_div_out <= ev_div;
                                dur_left     <= (ev_dur == 16'd0) ? 16'd1 : ev_dur;
                            end
                        end else if (dur_left > 16'd1) begin
                            dur_left <= dur_left - 16'd1;
                        end else begin
                            // event done => next address
                            dur_left <= 16'd0;
                            rom_addr <= rom_addr + {{(ADDR_W-1){1'b0}},1'b1};
                            state    <= S_FETCH;
                        end
                    end

                    default: state <= S_IDLE;
                endcase
            end

            song_en_prev <= song_en;
        end
    end
endmodule



