`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 20:06:13
// Design Name: 
// Module Name: tone_gen
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


module tone_gen (
    input  wire [31:0] note_div,
    input  wire        clk,
    input  wire        rst,
    output reg         sound
);
    reg [31:0] cnt;
    reg        sq;

    // envelope
    wire [7:0] env;
    env_ar u_env (
        .clk(clk),
        .rst(rst),
        .note_on(note_div != 32'd0),
        .env(env)
    );

    // square wave generator
    always @(posedge clk) begin
        if (rst || note_div == 32'd0) begin
            cnt <= 32'd0;
            sq  <= 1'b0;
        end else if (cnt >= note_div - 1) begin
            cnt <= 32'd0;
            sq  <= ~sq;
        end else begin
            cnt <= cnt + 1;
        end
    end

    // amplitude gating (simple PWM-ish)
    always @(posedge clk) begin
        sound <= (env != 8'd0) ? sq : 1'b0;
    end
endmodule



