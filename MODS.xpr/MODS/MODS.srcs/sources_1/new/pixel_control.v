`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2024 16:52:02
// Design Name: 
// Module Name: pixel_control
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

module pixel_control(
    input [6:0] x, [6:0] y,
    input clock, btnU, btnL, btnR,
    input [6:0] xref_std, input [6:0] yref_std, 
    input faceleft, input vertical_movement, // y stationary: vert_movement == 1
    input [6:0] xref_e [0:14], input [6:0] yref_e [0:14], input [2:0] enemy_health [0:14], input [14:0] angry,
    input [6:0] xref_muffin, [6:0] yref_muffin,
    input [2:0] stnum,
    output reg [15:0] pixel_data
    );
    parameter MAX_ENEMIES = 14; 
    reg [12:0] pixel_index;
    wire [15:0] s_oled;
    wire [15:0] m_oled;
    wire [15:0] e_oled;
    integer i;
    student_sprites studcont(
        .x(x), .y(y), .xref_std(xref_std), .yref_std(yref_std), .clock(clock), 
        .btnU(btnU), .btnL(btnL), .btnR(btnR), .stnum(stnum), .ystationary(vertical_movement), .faceleft(faceleft),
        .pixel_data(s_oled)
        ); // 1 stationary, 2 walking, 3 jumping
    muffin_sprite mooooooooofinnnnnnnn(
        .x(x), .y(y), .clock(clock), .xref(xref_muffin), .yref(yref_muffin), 
        .oled_data(m_oled)
        );
    enemies_sprite#(.MAX_NUM_ENEMIES(MAX_ENEMIES)) eeeeenemies ( 
        .enemy_health(enemy_health), .angry(angry),
        .x(x), .y(y), .xref(xref_e), .yref(yref_e), .oled_data(e_oled));
        
        reg [15:0] memory [0:6143]; // memory for a 96x64 image
        initial begin
        $readmemh("landscape3.mem", memory);
        end
    // add module for drawing enemies taking in 15 pairs of xref,yref (edit: array)
        // within module for drawing enemies, include indiv draw_enemy modules
    always @ (posedge clock) begin   
        pixel_index = x + 96 * y;
        pixel_data <= memory[pixel_index]; 
        if (x <= xref_std + 7 && x >= xref_std && y <= yref_std + 7 && y >= yref_std) begin
            if (s_oled != 1) pixel_data <= s_oled;
            else pixel_data <= memory[pixel_index]; 
        end 
        if (x <= xref_muffin + 7 && x >= xref_muffin && y <= yref_muffin + 7 && y >= yref_muffin) begin
            if (m_oled != 1) pixel_data <= m_oled;
            else pixel_data <= memory[pixel_index]; 
        end 
        for (i=0; i<= MAX_ENEMIES; i = i + 1) begin
            if (x <= xref_e[i] + 7 && x >= xref_e[i] && y <= yref_e[i] + 7 && y >= yref_e[i]) begin
                if (e_oled != 1) pixel_data <= e_oled;
                else pixel_data <= memory[pixel_index]; 
            end
        end
    end
    //               repeat as many times as necessary, each new statement higher priority than previous (ie overwriting if needed)
    
endmodule
