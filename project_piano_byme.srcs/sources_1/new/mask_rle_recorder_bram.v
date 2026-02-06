`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.01.2026 22:06:06
// Design Name: 
// Module Name: mask_rle_recorder_bram
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


module mask_rle_recorder_bram (
    input  wire        clk,
    input  wire        rst,
    input  wire        clear,
    input  wire        rec_en,
    input  wire        sample_tick,
    input  wire [7:0]  mask_in,
    input  wire [11:0] rd_addr,
    output reg  [7:0]  rd_mask,
    output reg  [15:0] rd_dur,

    output reg  [12:0] rec_len  
);
    localparam [11:0] DEPTH_M1 = 12'd4095;

 
    wire [7:0]  rd_mask_w;
    wire [15:0] rd_dur_w;
    reg         we;
    reg [11:0]  waddr;
    reg [7:0]   wmask;
    reg [15:0]  wdur;

    ram_dp #(.AW(12), .DW(8)) u_mask_ram (
        .clk  (clk),
        .we   (we),
        .waddr(waddr),
        .wdata(wmask),
        .raddr(rd_addr),
        .rdata(rd_mask_w)
    );

    ram_dp #(.AW(12), .DW(16)) u_dur_ram (
        .clk  (clk),
        .we   (we),
        .waddr(waddr),
        .wdata(wdur),
        .raddr(rd_addr),
        .rdata(rd_dur_w)
    );

    
    always @(posedge clk) begin
        rd_mask <= rd_mask_w;
        rd_dur  <= rd_dur_w;
    end

    reg [11:0] wr_ptr;
    reg [7:0]  cur_mask;
    reg [15:0] cur_dur;
    reg        rec_en_prev;

    
    task automatic flush_segment;
        begin
          
            we    <= 1'b1;
            waddr <= wr_ptr;
            wmask <= cur_mask;
            wdur  <= cur_dur;

            
            if (wr_ptr == DEPTH_M1) begin
                wr_ptr  <= 12'd0;
                rec_len <= 13'd4096; // full
            end else begin
                wr_ptr  <= wr_ptr + 12'd1;
              
                if (rec_len < {1'b0,(wr_ptr + 12'd1)})
                    rec_len <= {1'b0,(wr_ptr + 12'd1)};
            end
        end
    endtask

    always @(posedge clk) begin
        if (rst || clear) begin
            wr_ptr      <= 12'd0;
            rec_len     <= 13'd0;
            cur_mask    <= 8'd0;
            cur_dur     <= 16'd0;
            rec_en_prev <= 1'b0;
            we          <= 1'b0;
            waddr       <= 12'd0;
            wmask       <= 8'd0;
            wdur        <= 16'd0;
        end else begin
            // default: no write
            we <= 1'b0;
            // stop recording -> flush last segment
            if (rec_en_prev && !rec_en) begin
                if (cur_dur != 16'd0) begin
                    flush_segment();
                end
                cur_dur <= 16'd0;
            end

            // while recording, update on each tick
            if (rec_en && sample_tick) begin
                if (cur_dur == 16'd0) begin
                    cur_mask <= mask_in;
                    cur_dur  <= 16'd1;
                end else if (mask_in == cur_mask) begin
                    cur_dur <= cur_dur + 16'd1;
                end else begin
                    // flush old segment, then start new
                    flush_segment();
                    cur_mask <= mask_in;
                    cur_dur  <= 16'd1;
                end
            end

            rec_en_prev <= rec_en;
        end
    end
endmodule


