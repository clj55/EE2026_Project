`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 05:43:39
// Design Name: 
// Module Name: student_control
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

// s1: medicine, s2: chemistry, s3: electrical engineering, s4: math, s5: business

module student_sprites(
    input [6:0] x, [6:0]y,
//    input [12:0] pixel_index,
    input clock, btnU, btnL, btnR, ystationary, faceleft,
    input [6:0] xref_std, [6:0] yref_std, 
    input [2:0] stnum,
    output reg [15:0] pixel_data
    );
    wire [15:0] s1_oled;
    wire [15:0] s2_oled;
    wire [15:0] s3_oled;
    wire [15:0] s4_oled;
    wire [15:0] s5_oled;
    s1 draw_s1(
        .xref(xref_std), .yref(yref_std), .x(x), .y(y), .clock(clock), .btnU(btnU), .btnL(btnL), .btnR(btnR), .ystationary(ystationary), .faceleft(faceleft),
        .oled_data(s1_oled)
        );
    s2 draw_s2(
        .xref(xref_std), .yref(yref_std), .x(x), .y(y), .clock(clock), .btnU(btnU), .btnL(btnL), .btnR(btnR), .ystationary(ystationary), .faceleft(faceleft),
        .oled_data(s2_oled)
        );
    s3 draw_s3(
        .xref(xref_std), .yref(yref_std), .x(x), .y(y), .clock(clock), .btnU(btnU), .btnL(btnL), .btnR(btnR), .ystationary(ystationary), .faceleft(faceleft),
        .oled_data(s3_oled)
        );
    s4 draw_s4(
        .xref(xref_std), .yref(yref_std), .x(x), .y(y), .clock(clock), .btnU(btnU), .btnL(btnL), .btnR(btnR), .ystationary(ystationary), .faceleft(faceleft),
        .oled_data(s4_oled)
        );
    s5 draw_s5(
        .xref(xref_std), .yref(yref_std), .x(x), .y(y), .clock(clock), .btnU(btnU), .btnL(btnL), .btnR(btnR), .ystationary(ystationary), .faceleft(faceleft),
        .oled_data(s5_oled)
        );

    always @ (x, y) begin
        case (stnum)
            default: pixel_data = 16'b11111_000000_00000;
            0: pixel_data = s1_oled;
            1: pixel_data = s2_oled;
            2: pixel_data = s3_oled;
            3: pixel_data = s4_oled;
            4: pixel_data = s5_oled;
        endcase
    end
endmodule
