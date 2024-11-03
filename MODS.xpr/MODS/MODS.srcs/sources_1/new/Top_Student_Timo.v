`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////

// systemverilog file

module Top_Student_Timo (
    input clk,
    output [7:0] JB,
    input btnU, btnL, btnR, btnC, btnD, 
    input [15:0] sw
);
    wire frame_begin;
    wire [12:0] pixel_index;
    wire sending_pixels;
    wire sample_pixel;
    wire [15:0] pixel_data;
    
    wire clk_6p25M;
    flexy_clk clk6p25M (clk, 7, clk_6p25M);
    
    wire [6:0]x;
    wire [6:0]y;
    assign x = pixel_index%96;
    assign y = pixel_index/96;
    
    // update with e3-e5 assuming 5 enemies
    // update with xref_muffin and yref_muffin
    wire [6:0] yref_std;
    wire [6:0] xref_std;
//    wire [6:0]yref_std;
    reg [6:0] xref_e[0:14];
    reg [6:0] yref_e[0:14];
    wire [6:0] xref_muffin, yref_muffin;
    reg [2:0] enemy_health [0:14];
    reg [14:0] angry;
    reg [2:0] stnum; // decide which sprite to show. eg case(0): medicine, case(1): ... etc
    // placeholder test values begin
    integer i;
    assign xref_std = 36;
    assign yref_std = 36;
    assign xref_muffin = 48;
    assign yref_muffin = 36;
    reg faceleft;
    reg vertical_movement;
    always @ (posedge clk) begin
        if (btnR) faceleft <= 0;
        else if (btnL) faceleft <= 1;
        if (btnC) stnum <= (stnum == 4) ? 0 : stnum + 1;
        if (sw[1]) vertical_movement = 1; else vertical_movement = 0;
        for (i = 0; i <= 14; i += 1) begin
            xref_e[i] = 10*(i%8);
            yref_e[i] = (i <= 7) ? 1 : 10;
            enemy_health[i] = i % 6;
            angry[i] = (i <= 7) ? 1 : 0;
        end
    end
    // placeholder test values end
    pixel_control pixycont (
        .x(x), .y(y), 
//        .pixel_index(pixel_index),        
        .clock(clk), .btnU(btnU), .btnL(btnL), .btnR(btnR),
        .xref_std(xref_std), .yref_std(yref_std), .stnum(stnum), .faceleft(faceleft), .vertical_movement(vertical_movement),
        .xref_e(xref_e), .yref_e(yref_e), .enemy_health(enemy_health), .angry(angry),
        .xref_muffin(xref_muffin), .yref_muffin(yref_muffin),
        .pixel_data(pixel_data)
        );
//        module pixel_control(
//            input [6:0] x, [6:0] y,
//            input clock, btnU, btnL, btnR,
//            input [6:0] xref_std, input [6:0] yref_std, 
//            input faceleft, input vertical_movement, // y stationary: vert_movement == 1
//            input [6:0] xref_e [0:14], input [6:0] yref_e [0:14], input [2:0] enemy_health [0:14], input [14:0] angry,
//            input [6:0] xref_muffin, [6:0] yref_muffin,
//            input [2:0] stnum,
//            output reg [15:0] pixel_data
//            );
    
Oled_Display oleddisp (
    .clk(clk_6p25M), 
    .reset(0), // ground
    .frame_begin(frame_begin), 
    .sending_pixels(sending_pixels),
    .sample_pixel(sample_pixel), 
    .pixel_index(pixel_index), 
    .pixel_data(pixel_data),
    .cs(JB[0]), 
    .sdin(JB[1]), 
    .sclk(JB[3]), 
    .d_cn(JB[4]), 
    .resn(JB[5]), 
    .vccen(JB[6]),
    .pmoden(JB[7]) 
    );


endmodule