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



module s5(
    input [6:0] xref, 
    input [6:0] yref, 
    input [6:0] x, 
    input [6:0] y,
    input [12:0] pixel_index,
    input clock, // always check, if xref, yref changes, change from frame1 to frame2 for eg
    input btnU, btnL, btnR, ystationary, faceleft,
    output reg [15:0] oled_data = 0
    );
//    reg faceleft = 0;
    wire [15:0] r1_oled, r2_oled, r3_oled, j_oled;
    reg [2:0] casenum = 0;
    s5r1 st5r1(.xref(xref), .yref(yref), .clock(clock), .oled_data(r1_oled), 
               .x(x), .y(y), 
//               .pixel_index_in(pixel_index),
               .faceleft(faceleft));
    s5r2 st5r2(.xref(xref), .yref(yref), .clock(clock), .oled_data(r2_oled), 
               .x(x), .y(y), 
//               .pixel_index_in(pixel_index),
               .faceleft(faceleft));
    s5r3 st5r3(.xref(xref), .yref(yref), .clock(clock), .oled_data(r3_oled), 
               .x(x), .y(y), 
//               .pixel_index_in(pixel_index),
               .faceleft(faceleft));
    s5j st5j(.xref(xref), .yref(yref), .clock(clock), .oled_data(j_oled), 
               .x(x), .y(y), 
//               .pixel_index_in(pixel_index),
               .faceleft(faceleft));
    reg [31:0] count = 0;
    always @ (posedge clock) begin
//        if (btnR) faceleft <= 0;
//        else if (btnL) faceleft <= 1;
        // platform @ 18 <= y <= 20, 36 <= y <= 38, 58 <= y <= 60 [index from 0 to 63]
        // on platform when:
        // yref == 10, 28, 50
        oled_data <= r1_oled;
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

module s5r1(
    input [6:0] xref,
    input [6:0] yref,
    input [6:0] x,
    input [6:0] y,
//    input [12:0] pixel_index_in,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
//    wire [6:0]x;
//    wire [6:0]y;
//    assign x = pixel_index_in%96;
//    assign y = pixel_index_in/96;
    reg [31:0] pixel_index;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] darkblue = 16'b0101001101001111;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if (((pixel_index >= 11) && (pixel_index <= 12)) || (pixel_index >= 18 && pixel_index <= 22) || pixel_index == 29 || pixel_index == 28) oled_data = skincol;
            else if (pixel_index == 26 || pixel_index == 27 || pixel_index == 34 || pixel_index == 35 || pixel_index == 37 || ((pixel_index >= 43) && (pixel_index <= 45)) || (pixel_index >= 50) && (pixel_index <= 53)) oled_data = darkblue;
            else if (pixel_index == 36) oled_data = yellow;
            else if (pixel_index == 42 || pixel_index == 46) oled_data = grey;
            else if ((pixel_index >= 2 && pixel_index <= 4) || (pixel_index >= 9 && pixel_index <= 10) || pixel_index == 13 || pixel_index == 17 || pixel_index == 58 || pixel_index == 62) oled_data = black;
            else oled_data = placeholder;
        end
    end        
endmodule

module s5r2(
    input [6:0] xref,
    input [6:0] yref,
        input [6:0] x,
        input [6:0] y,
//    input [12:0] pixel_index_in,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
//    wire [6:0]x;
//    wire [6:0]y;
//    assign x = pixel_index_in%96;
//    assign y = pixel_index_in/96;
    reg [31:0] pixel_index;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] darkblue = 16'b0101001101001111;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if (((pixel_index >= 11) && (pixel_index <= 12)) || (pixel_index >= 18 && pixel_index <= 22)) oled_data = skincol;
            else if (pixel_index == 26 || pixel_index == 27 || pixel_index == 29 || (pixel_index >= 34 && pixel_index <= 37) || (pixel_index >= 43 && pixel_index <= 45) || (pixel_index >= 50 && pixel_index <= 53)) oled_data = darkblue;
            else if (pixel_index == 28) oled_data = yellow;
            else if (pixel_index == 38 || pixel_index == 42) oled_data = grey;
            else if ((pixel_index >= 2 && pixel_index <= 4) || (pixel_index >= 9 && pixel_index <= 10) || pixel_index == 13 || pixel_index == 17 || pixel_index == 49 || pixel_index == 61) oled_data = black;
            else oled_data = placeholder;
        end
    end        
endmodule    
           
module s5r3(
    input [6:0] xref,
    input [6:0] yref,
        input [6:0] x,
        input [6:0] y,
//    input [12:0] pixel_index_in,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
//    wire [6:0]x;
//    wire [6:0]y;
//    assign x = pixel_index_in%96;
//    assign y = pixel_index_in/96;
    reg [31:0] pixel_index;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] darkblue = 16'b0101001101001111;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if (((pixel_index >= 11) && (pixel_index <= 12)) || (pixel_index >= 18 && pixel_index <= 22) || (pixel_index >= 27 && pixel_index <= 29)) oled_data = skincol;
            else if (pixel_index == 26 || pixel_index == 35 || pixel_index == 37 || (pixel_index >= 42 && pixel_index <= 45) || (pixel_index >= 50 && pixel_index <= 53)) oled_data = darkblue;
            else if (pixel_index == 34 || pixel_index == 46) oled_data = grey;
            else if (pixel_index == 36) oled_data = yellow;
            else if ((pixel_index >= 2 && pixel_index <= 4) || (pixel_index >= 9 && pixel_index <= 10) || pixel_index == 13 || pixel_index == 17 || pixel_index == 57 || pixel_index == 61) oled_data = black;
            else oled_data = placeholder;
        end
    end        
endmodule

module s5j(
    input [6:0] xref,
    input [6:0] yref,
    input [6:0] x, [6:0]y,
//    input [12:0] pixel_index_in,
    input clock,
    input faceleft,
    output reg [15:0] oled_data = 0
    );
//    wire [6:0]x;
//    wire [6:0]y;
//    assign x = pixel_index_in%96;
//    assign y = pixel_index_in/96;
    reg [31:0] pixel_index;
    wire [15:0] skincol = 16'b1110010101101111;
    wire [15:0] grey = 16'b1001110011110011;
    wire [15:0] darkblue = 16'b0101001101001111;
    wire [15:0] yellow = 16'b1111111101100111;
    wire [15:0] black = 0;
    wire [15:0] placeholder = 1;
    always @ (posedge clock) begin 
        if (x <= xref + 7 && x >= xref && y <= yref + 7 && y >= yref) begin
            pixel_index = (faceleft) ? xref + 7 - x + 8 * (y-yref) : x - xref + 8 * (y-yref);
            if (((pixel_index >= 11) && (pixel_index <= 12)) || (pixel_index >= 18 && pixel_index <= 22) || (pixel_index >= 27 && pixel_index <= 29)) oled_data = skincol;
            else if (pixel_index == 16 || pixel_index == 46) oled_data = grey;
            else if (pixel_index == 25 || ((pixel_index >= 34) && (pixel_index <= 35)) || pixel_index == 37 || (pixel_index >= 42 && pixel_index <= 45) || (pixel_index >= 49 && pixel_index == 53)) oled_data = darkblue;
            else if (pixel_index == 36) oled_data = yellow;
            else if ((pixel_index >= 2 && pixel_index <= 4) || pixel_index == 10 || pixel_index == 13 || pixel_index == 40 || pixel_index == 61) oled_data = black;
            else oled_data = placeholder;
        end
    end        
endmodule
