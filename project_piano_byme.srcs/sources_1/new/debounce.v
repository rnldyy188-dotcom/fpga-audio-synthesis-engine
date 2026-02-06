`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 21:45:02
// Design Name: 
// Module Name: debounce
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


module debounce #(
    parameter integer CNT_MAX = 2_000_000  // 20ms @100MHz
)(
    input  wire clk,
    input  wire rst,
    input  wire noisy,
    output reg  db_level
);
    reg [20:0] cnt;        
    reg        sync0, sync1;

    always @(posedge clk) begin
        if (rst) begin
            sync0 <= 1'b0;
            sync1 <= 1'b0;
        end else begin
            sync0 <= noisy;
            sync1 <= sync0;
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            db_level <= 1'b0;
            cnt      <= 21'd0;
        end else begin
            if (sync1 == db_level) begin
                cnt <= 21'd0; // already stable at current output
            end else begin
                if (cnt >= CNT_MAX[20:0]) begin
                    db_level <= sync1;
                    cnt      <= 21'd0;
                end else begin
                    cnt <= cnt + 21'd1;
                end
            end
        end
    end
endmodule
