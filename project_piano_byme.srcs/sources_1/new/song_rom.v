`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2026 20:39:41
// Design Name: 
// Module Name: song_rom
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


module song_rom64 #(
    parameter DEPTH   = 2048,
    parameter ADDR_W  = 11,
    parameter MEMFILE = "song.mem"
)(
    input  wire              clk,
    input  wire [ADDR_W-1:0] addr,
    output reg  [63:0]       data
);
    reg [63:0] rom [0:DEPTH-1];

    initial begin
        $readmemh(MEMFILE, rom);
    end

    always @(posedge clk) begin
        data <= rom[addr];   // sync read: 1-cycle latency
    end
endmodule





