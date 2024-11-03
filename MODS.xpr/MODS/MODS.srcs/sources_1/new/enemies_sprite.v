`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 20:20:12
// Design Name: 
// Module Name: enemies_sprite
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

// systemverilog file

module enemies_sprite #(parameter MAX_NUM_ENEMIES = 14)(
    input [6:0] x, input [6:0] y,
    input [3:0] enemy_health [0:MAX_NUM_ENEMIES], input [MAX_NUM_ENEMIES:0] angry,
    input [6:0] xref [0:MAX_NUM_ENEMIES], input [6:0] yref [0:MAX_NUM_ENEMIES],
    output reg [15:0] oled_data
    );
    integer i;
    reg [31:0] pixel_index;
    wire [15:0] placeholder = 1;
    reg [15:0] enemycolour;
    // colours
    always @ (x, y) begin
        for (i=0; i<= MAX_NUM_ENEMIES; i = i + 1) begin
            // colour logic
            if (!angry[i]) begin
                case (enemy_health[i]) 
                    default: enemycolour = 16'hFFFF; // white
                    0: enemycolour = placeholder;
                    1: enemycolour = 16'h07E5; // green
                    2: enemycolour = 16'h2758; // marine
                    3: enemycolour = 16'h043F; // blue
                    4: enemycolour = 16'h301F; // darkblue
                    5: enemycolour = 16'hB018; // purp!
                endcase
            end else begin
                case (enemy_health[i]) 
                    1: enemycolour = 16'hE720; // dirty yellow
                    2: enemycolour = 16'hE600; // dark yellow
                    3: enemycolour = 16'hE4E0; // dark orange
                    4: enemycolour = 16'hC2A0; // brown
                    5: enemycolour = 16'hC800; // RED (but darker)
                endcase
            end
            // pixel logic
            if (x <= xref[i] + 7 && x >= xref[i] && y <= yref[i] + 7 && y >= yref[i]) begin
                pixel_index = x - xref[i] + 8 * (y-yref[i]);
                oled_data = placeholder;
                case (enemy_health[i])
                    1: // A
                    if (((pixel_index >= 2) && (pixel_index <= 5)) || ((pixel_index >= 9) && (pixel_index <= 10)) || ((pixel_index >= 13) && (pixel_index <= 14)) || pixel_index == 17 || pixel_index == 22 || pixel_index == 25 || pixel_index == 30 || ((pixel_index >= 33) && (pixel_index <= 38)) || pixel_index == 41 || pixel_index == 46 || pixel_index == 49 || pixel_index == 54 || pixel_index == 57 || pixel_index == 62)
                        oled_data = enemycolour;
                    2: // B
                    if ((pixel_index >= 2 && pixel_index <= 5) || (pixel_index == 10) || (pixel_index == 14) || (pixel_index == 18) || (pixel_index == 22) || (pixel_index >= 26 && pixel_index <= 29) || (pixel_index == 34) || (pixel_index == 38) || (pixel_index == 42) || (pixel_index == 46) || (pixel_index == 50) || (pixel_index == 54) || (pixel_index >= 58 && pixel_index <= 61))
                        oled_data = enemycolour;
                    3: // C
                    if ((pixel_index >= 2 && pixel_index <= 6) || (pixel_index == 9) || (pixel_index == 10) || (pixel_index == 17) || (pixel_index == 25) || (pixel_index == 33) || (pixel_index == 41) || (pixel_index == 49) || (pixel_index == 50) || (pixel_index >= 58 && pixel_index <= 62))
                        oled_data = enemycolour;
                    4: // D
                    if ((pixel_index >= 1 && pixel_index <= 5) || (pixel_index == 9) || (pixel_index == 13) || (pixel_index == 14) || (pixel_index == 17) || (pixel_index == 22) || (pixel_index == 25) || (pixel_index == 30) || (pixel_index == 33) || (pixel_index == 38) || (pixel_index == 41) || (pixel_index == 46) || (pixel_index == 49) || (pixel_index == 53) || (pixel_index == 54) || (pixel_index >= 57 && pixel_index <= 61))
                        oled_data = enemycolour;
                    5: // E
                    if ((pixel_index >= 1 && pixel_index <= 6) || (pixel_index == 9) || (pixel_index == 17) || (pixel_index >= 25 && pixel_index <=30) || (pixel_index == 33) || (pixel_index == 41) || (pixel_index == 49) || (pixel_index >= 57 && pixel_index <= 62))
                        oled_data = enemycolour;
                endcase
            end
        end
    end
endmodule
