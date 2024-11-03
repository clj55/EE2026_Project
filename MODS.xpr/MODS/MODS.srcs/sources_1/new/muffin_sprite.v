`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 19:13:28
// Design Name: 
// Module Name: muffin_sprite
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


module muffin_sprite (
    input [6:0] x, y, xref, yref,
    input clock,
    output reg [15:0] oled_data
    );
    reg [31:0] pixel_index;
    wire [15:0] white = 16'b1111111111111111;
    wire [15:0] darkred = 16'b1110000100001100;
    wire [15:0] black = 0;
    wire [15:0] brown = 16'h9A20;
    wire [15:0] yellow = 16'b1111111110101011;
    wire [15:0] placeholder = 1;
    always @ (x, y) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = x - xref + 8 * (y-yref);
            if (((pixel_index >= 20) && (pixel_index <= 22)) || pixel_index == 25 || ((pixel_index >= 28) && (pixel_index <= 30)) || pixel_index == 33 || ((pixel_index >= 36) && (pixel_index <= 38)) || (pixel_index >= 42) && (pixel_index <= 43)) oled_data = white;
            else if (pixel_index == 26 || pixel_index == 27 || pixel_index == 34 || pixel_index == 35) oled_data = darkred;
            else if (pixel_index == 41 || pixel_index == 44) oled_data = yellow;
            else if ((pixel_index >= 11 && pixel_index <= 19) || pixel_index == 23 || pixel_index == 24 || pixel_index == 31 || pixel_index == 32 || pixel_index == 39 || pixel_index == 40 || (pixel_index >= 45 && pixel_index <=52)) oled_data = brown;
            else oled_data = placeholder;
        end
    end          
endmodule
