`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 23:06:20
// Design Name: 
// Module Name: env_ar
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


module env_ar #(
    parameter ATTACK_STEP  = 8'd4,   
    parameter RELEASE_STEP = 8'd4
)(
    input  wire clk,
    input  wire rst,
    input  wire note_on,        
    output reg  [7:0] env       
);
    always @(posedge clk) begin
        if (rst) begin
            env <= 8'd0;
        end else begin
            if (note_on) begin
                if (env + ATTACK_STEP >= 8'd255)
                    env <= 8'd255;
                else
                    env <= env + ATTACK_STEP;
            end else begin
                if (env <= RELEASE_STEP)
                    env <= 8'd0;
                else
                    env <= env - RELEASE_STEP;
            end
        end
    end
endmodule


