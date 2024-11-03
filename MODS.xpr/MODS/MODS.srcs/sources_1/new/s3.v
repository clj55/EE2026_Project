`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.10.2024 17:42:53
// Design Name: 
// Module Name: s1
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

// REPLACE ELSE COLOUR WITH BACKGROUND PLACEHOLDER 16'B1

module s3(
    input [6:0] xref, 
    input [6:0] x, 
    input [5:0] yref, 
    input [5:0] y,
    input clock, // always check, if xref, yref changes, change from frame1 to frame2 for eg
    input btnU, btnL, btnR, ystationary, faceleft,
    output reg [15:0] oled_data = 0
    );
//    reg faceleft = 0;
    wire [15:0] r1_oled, r2_oled, r3_oled, j_oled;
    reg [2:0] casenum = 0;
    s3r1 st3r1(.xref(xref), .yref(yref), .clock(clock), .oled_data(r1_oled), .x(x), .y(y), .faceleft(faceleft));
    s3r2 st3r2(.xref(xref), .yref(yref), .clock(clock), .oled_data(r2_oled), .x(x), .y(y), .faceleft(faceleft));
    s3r3 st3r3(.xref(xref), .yref(yref), .clock(clock), .oled_data(r3_oled), .x(x), .y(y), .faceleft(faceleft));
    s3j st3j(.xref(xref), .yref(yref), .clock(clock), .oled_data(j_oled), .x(x), .y(y), .faceleft(faceleft));
    reg [31:0] count = 0;
    always @ (posedge clock) begin
//            if (btnR) faceleft <= 0;
//            else if (btnL) faceleft <= 1;
            // platform @ 18 <= y <= 20, 36 <= y <= 38, 58 <= y <= 60 [index from 0 to 63]
            // on platform when:
            // yref == 10, 28, 50

            if (!ystationary) oled_data <= j_oled; // off platform. jump
            else begin
                if (!btnR && !btnL) begin
                    oled_data <= r1_oled;
                    count <= 0;
                end else begin
                    count <= (count == 44_999_999) ? 0 : count + 1;
                    if (count >= 0 && count <= 14_999_999) oled_data <= r1_oled;
                    else if (count >= 15_000_000 && count <= 29_999_999) oled_data <= r2_oled;
                    else if (count >= 30_000_000 && count <= 44_999_999) oled_data <= r3_oled;
                end
            end
    //        // logic here to determine which oleddata to display
    //        // current logic is placeholder to test sprites on my own
    //        // will edit: eg if btnR held, cycle through 3 right-moving sprites
    //        if (btnU) casenum <= (casenum == 3) ? 0 : casenum + 1;
    //        case (casenum)
    //        0: oled_data <= r1_oled;
    //        1: oled_data <= r2_oled;
    //        2: oled_data <= r3_oled;
    //        3: oled_data <= j_oled;
    //        endcase
        end


endmodule

module s3r1(
    input [6:0] xref,
    input [5:0] yref,
    input [6:0] x,
    input [5:0] y,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
    reg [31:0] pixel_index;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] purple = 16'b0110100111010110;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref) ;
            if (pixel_index == 1 || pixel_index == 6 || pixel_index == 16 || pixel_index == 23 || pixel_index == 32 || pixel_index == 47) oled_data = yellow;
            else if ((pixel_index >= 3 && pixel_index <= 5) || (pixel_index >= 10 && pixel_index <= 12) || pixel_index == 18 || pixel_index == 19 || pixel_index == 26) oled_data = purple;
            else if (pixel_index == 13 || pixel_index == 20 || (pixel_index >= 27 && pixel_index <= 30) || ((pixel_index >= 36) && (pixel_index <= 37)) || pixel_index == 58 || pixel_index == 61) oled_data = skincol;
            else if (pixel_index == 34 || pixel_index == 35 || (pixel_index >= 42 && pixel_index <= 45) || (pixel_index >= 51 && pixel_index <= 53)) oled_data = red;
            else if (pixel_index == 41 || pixel_index == 54) oled_data = grey;
            else if (pixel_index == 21) oled_data = black;
            else oled_data = placeholder;
        end else oled_data = placeholder;
    end        
endmodule

module s3r2(
    input [6:0] xref,
    input [6:0] yref,
    input [6:0] x,
    input [6:0] y,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
    reg [31:0] pixel_index;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] purple = 16'b0110100111010110;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref) ;
            if (pixel_index == 1 || pixel_index == 15 || pixel_index == 24 || pixel_index == 31 || pixel_index == 40 || pixel_index == 55) oled_data = yellow;
            else if ((pixel_index >= 3 && pixel_index <= 5) || (pixel_index >= 10 && pixel_index <= 12) || pixel_index == 19 || pixel_index == 18 || pixel_index == 26) oled_data = purple;
            else if (pixel_index == 13 || pixel_index == 20 || (pixel_index >= 26 && pixel_index <= 30) || pixel_index == 36 || pixel_index == 37 || pixel_index == 49 || pixel_index == 62) oled_data = skincol;
            else if (pixel_index == 34 || pixel_index == 35 || (pixel_index >= 43 && pixel_index <= 45) || (pixel_index >= 50 && pixel_index <= 53)) oled_data = red;
            else if (pixel_index == 42 || pixel_index == 46) oled_data = grey;
            else if (pixel_index == 21) oled_data = black;
            else oled_data = placeholder;
        end else oled_data = placeholder;
    end  
endmodule     
           
module s3r3(
    input [6:0] xref,
    input [6:0] yref,
    input [6:0] x,
    input [6:0] y,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
    reg [31:0] pixel_index;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] purple = 16'b0110100111010110;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if ((pixel_index >= 3 && pixel_index <= 5) || (pixel_index >= 10 && pixel_index <= 12) || pixel_index == 18 || pixel_index == 19 || pixel_index == 26) oled_data = purple;
            else if (pixel_index == 6 || pixel_index == 9 || pixel_index == 24 || pixel_index == 31 || pixel_index == 40 || pixel_index == 47) oled_data = yellow;
            else if (pixel_index == 13 || pixel_index == 20 || (pixel_index >= 27 && pixel_index <= 30) || pixel_index == 36 || pixel_index == 37 || pixel_index == 58 || pixel_index == 61) oled_data = skincol;
            else if (pixel_index == 34 || pixel_index == 45) oled_data = grey;
            else if (pixel_index == 35 || (pixel_index >= 42 && pixel_index <= 44) || (pixel_index >= 50 && pixel_index <= 53)) oled_data = red;
            else if (pixel_index == 21) oled_data = black;
            else oled_data = placeholder;
        end else oled_data = placeholder;
    end
endmodule

module s3j(
    input [6:0] xref,
    input [6:0] yref,
    input [6:0] x,
    input [6:0] y,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
    reg [31:0] pixel_index;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] purple = 16'b0110100111010110;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] red = 16'b1111100000000000;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if (pixel_index == 0 || pixel_index == 6 || pixel_index == 32 || pixel_index == 39 || pixel_index == 48 || pixel_index == 63) oled_data = yellow;
            else if ((pixel_index >= 3 && pixel_index <= 5) || (pixel_index >= 10 && pixel_index <= 12) || pixel_index == 19 || pixel_index == 18) oled_data = purple;
            else if (pixel_index == 13 || pixel_index == 20 || (pixel_index >= 27 && pixel_index <= 30) || pixel_index == 36 || pixel_index == 37 || pixel_index == 41 || pixel_index == 61) oled_data = skincol;
            else if (pixel_index == 17 || pixel_index == 46) oled_data = grey;
            else if (pixel_index == 26 || pixel_index == 34 || pixel_index == 35 || (pixel_index >= 42 && pixel_index <= 45) || (pixel_index >= 51 && pixel_index <= 53)) oled_data = red;
            else if (pixel_index == 21) oled_data = black;
            else oled_data = placeholder;
        end else oled_data = placeholder;
    end
endmodule
