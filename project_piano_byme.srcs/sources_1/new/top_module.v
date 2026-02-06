`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 20:04:53
// Design Name: 
// Module Name: top_module
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

module top_module (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] bitmask,

    input  wire       rec_en,
    input  wire       play_en,
    input  wire       mode_play,
    input  wire       clear,
    input  wire       loop,

    output wire       sound
);

    localparam [19:0] TICK_CYCLES = 20'd1_000_000;
    reg  [19:0] tick_cnt;
    wire sample_tick = (tick_cnt == (TICK_CYCLES - 20'd1));

    always @(posedge clk) begin
        if (rst) tick_cnt <= 20'd0;
        else if (sample_tick) tick_cnt <= 20'd0;
        else tick_cnt <= tick_cnt + 20'd1;
    end

    wire play_db, mode_db, rec_db, clear_db;

    debounce u_db_play  (.clk(clk), .rst(rst), .noisy(play_en),   .db_level(play_db));
    debounce u_db_mode  (.clk(clk), .rst(rst), .noisy(mode_play), .db_level(mode_db));
    debounce u_db_rec   (.clk(clk), .rst(rst), .noisy(rec_en),    .db_level(rec_db));
    debounce u_db_clear (.clk(clk), .rst(rst), .noisy(clear),     .db_level(clear_db));

    wire [12:0] rec_len;
    wire [11:0] rd_addr;
    wire [7:0]  rd_mask;
    wire [15:0] rd_dur;
    wire [7:0]  play_mask;

    mask_rle_recorder_bram u_rec (
        .clk(clk),
        .rst(rst),
        .clear(clear_db),

        .rec_en(rec_db),
        .sample_tick(sample_tick),
        .mask_in(bitmask),

        .rd_addr(rd_addr),
        .rd_mask(rd_mask),
        .rd_dur(rd_dur),

        .rec_len(rec_len)
    );

    mask_rle_player_restartable u_play (
        .clk(clk),
        .rst(rst),
        .clear(clear_db),

        .play_en(play_db),
        .loop(loop),
        .sample_tick(sample_tick),

        .rec_len(rec_len),

        .rd_addr(rd_addr),
        .rd_mask(rd_mask),
        .rd_dur(rd_dur),

        .mask_out(play_mask)
    );

    localparam integer SONG_DEPTH = 2048;
    localparam integer SONG_AW    = 11;

    wire [SONG_AW-1:0] song_addr;
    wire [63:0]        song_word;
    wire [31:0]        song_note_div;
    wire               song_playing;

    song_rom64 #(
        .DEPTH(SONG_DEPTH),
        .ADDR_W(SONG_AW),
        .MEMFILE("song.mem")
    ) u_songrom (
        .clk(clk),
        .addr(song_addr),
        .data(song_word)
    );

    song_player_div #(
        .DEPTH(SONG_DEPTH),
        .ADDR_W(SONG_AW)
    ) u_songplay (
        .clk(clk),
        .rst(rst),
        .clear(clear_db),

        .song_en(play_db),
        .loop(loop),
        .sample_tick(sample_tick),

        .rom_addr(song_addr),
        .rom_data(song_word),

        .note_div_out(song_note_div),
        .playing(song_playing)
    );

    wire use_rec = (!mode_db) && play_db && (rec_len != 13'd0);

    wire [7:0] bitmask_sel =
        use_rec ? play_mask :
                  bitmask;

    wire [3:0] note_id;

    arpeggio_keys u_arpg (
        .clk(clk),
        .rst(rst),
        .bitmask(bitmask_sel),
        .note_id_out(note_id)
    );

    wire [31:0] note_div_live;

    note_lookup u_lookup (
        .note_id(note_id),
        .note_div(note_div_live)
    );

    
    wire use_song = mode_db && play_db && song_playing;
    wire [31:0] note_div_final = use_song ? song_note_div : note_div_live;

 
    tone_gen u_gen (
        .note_div(note_div_final),
        .clk(clk),
        .rst(rst),
        .sound(sound)
    );

endmodule





