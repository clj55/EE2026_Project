`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.10.2024 22:50:49
// Design Name: 
// Module Name: draw_grp_number
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


module draw_grp_number(
    input clk, [12:0]pixel_index,
    output reg [15:0] oled_data
    );
    wire [6:0] x;
    wire [6:0] y;
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    always @ (posedge clk) 
        begin
            // draw the OLED screen to show '10'
            // border of 10px
            // space between digits: 15px
            // width of each white line: 15px   
            if (x >= 10 && x < 10 + 15 && y >= 10 && y < 53) begin // number '1' in '10'
                oled_data = 16'b11111_111111_11111;
            end else if (x >= 10 + 15 + 15 && x < 10 + 15 + 15 + 45 && y >= 10 && y < 53) begin // white rectangloe for '0'
                if (x >= 10 + 15 + 15 + 15 && x < 10 + 15 + 15 + 15 + 15 && y >= 10 + 15 && y < 53 - 15) begin // middle of '0' is black colour
                    oled_data = 0;
                end else begin
                    oled_data = 16'b11111_111111_11111;; 
                end
            end else begin
                oled_data = 0;
            end
        end
           
endmodule
