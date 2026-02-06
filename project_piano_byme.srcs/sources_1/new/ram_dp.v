`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.02.2026 23:05:22
// Design Name: 
// Module Name: ram_dp
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

module ram_dp #(
    parameter integer AW = 12,
    parameter integer DW = 8
)(
    input  wire              clk,

    // Write port
    input  wire              we,
    input  wire [AW-1:0]     waddr,
    input  wire [DW-1:0]     wdata,

    // Read port
    input  wire [AW-1:0]     raddr,
    output reg  [DW-1:0]     rdata
);
    reg [DW-1:0] mem [0:(1<<AW)-1];

    always @(posedge clk) begin
        if (we) mem[waddr] <= wdata;
        rdata <= mem[raddr]; // sync read (1-cycle latency)
    end
endmodule
