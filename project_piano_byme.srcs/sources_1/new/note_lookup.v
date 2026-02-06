`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.01.2026 20:05:54
// Design Name: 
// Module Name: note_lookup
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


module note_lookup (
   input  wire [3:0]  note_id,
   output reg  [31:0] note_div
);
   always @(*) begin
      case (note_id)
          4'd1: note_div = 32'd113_636; // A4  440.00 Hz
          4'd2: note_div = 32'd101_238; // B4  493.88 Hz
          4'd3: note_div = 32'd90_193;  // C#5 554.37 Hz
          4'd4: note_div = 32'd85_131;  // D5  587.33 Hz
          4'd5: note_div = 32'd75_843;  // E5  659.26 Hz
          4'd6: note_div = 32'd67_569;  // F#5 739.99 Hz
          4'd7: note_div = 32'd60_197;  // G#5 830.61 Hz
          4'd8: note_div = 32'd56_818;  // A5  880.00 Hz
          default: note_div = 32'd0;
      endcase
  end
endmodule

