`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 20:21:41
// Design Name: 
// Module Name: draw
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


module draw(input clk, output [7:0] JB
);
    parameter MAX_ENEMIES = 15; parameter ENEMY_SIZE = 8;
    parameter MAX_PROJ = 2;
    wire sending_pixels; wire sample_pixel; wire frame_begin; wire [12:0] pixel_index; 
    reg [15:0] oled_data = 16'b1111111111111111;
    
    wire clk625; 
    flexy_clk clk6p25m (clk, 7, clk625);
    Oled_Display display (.clk(clk625), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
.sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), 
.sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])); 
    
    reg [7:0]enemy_spawn1 = 15; // x coordinate
    reg [7:0]enemy_spawn2 = 80; // x coordinate
    wire [7:0]platform_width; wire [7:0]platform_x; wire [7:0]platform_y; 
    assign platform_width = 25;
    assign platform_x = 15;
    assign platform_y = 40;
    
    wire [15:0]oled_data_map;
    draw_map bg(.p_index(pixel_index), .oled_data(oled_data_map), 
    .platform_width(platform_width), .platform_x(platform_x),  .platform_y(platform_y));
    
    wire enemyprojclk;
    flexy_clk interactionclk (clk, 624_999, enemyprojclk); 
    
    wire [2:0]enemies [MAX_ENEMIES:0]; wire [7:0]enemy_xref [MAX_ENEMIES:0]; wire [7:0]enemy_yref [MAX_ENEMIES:0];
    wire [2:0] proj_d; wire [MAX_ENEMIES:0] enemy_hit;
    
    wire [7:0] proj_x [0:MAX_PROJ]; wire [7:0] proj_y [0:MAX_PROJ]; 
    wire [2:0] proj_h; wire [6:0] proj_w; wire [MAX_PROJ:0]active_proj;
    projectile_main #(.MAX_PROJ(MAX_PROJ), .MAX_ENEMIES(MAX_ENEMIES))  projectiles
    (.clk(enemyprojclk), .enemy_x(enemy_xref), .enemy_y(enemy_yref),
      .proj_x(proj_x), .proj_y(proj_y), .proj_h(proj_h), .proj_w(proj_w), 
      .active(active_proj), .proj_d(proj_d), .enemy_hit(enemy_hit));
    
    enemy_main #(.MAX_ENEMIES(MAX_ENEMIES), .ENEMY_SIZE(ENEMY_SIZE)) em(
    .clk(clk), .enemy_health(enemies), .enemy_xref(enemy_xref), .enemy_yref(enemy_yref),
    .platform_width(platform_width), .platform_x(platform_x), .platform_y(platform_y), 
    .spawn1(enemy_spawn1), .spawn2(enemy_spawn2),
    .enemyprojclk(enemyprojclk), .proj_d(proj_d), .enemy_hit(enemy_hit));
    
    wire [15:0]oled_data_enemy;
    draw_enemy #(.MAX_NUM_ENEMIES(MAX_ENEMIES), .size(ENEMY_SIZE)) drawe (.p_index(pixel_index), .activated_enemy(enemies), 
            .xref(enemy_xref), .yref(enemy_yref), .oled_data(oled_data_enemy));
    
    wire [15:0]oled_data_proj;
    draw_proj #(.MAX_NUM(MAX_PROJ)) drawp (.p_index(pixel_index), .active_proj(active_proj), 
            .xref(proj_x), .yref(proj_y), .oled_data(oled_data_proj), 
            .h(proj_h), .w(proj_w));
    
    
    always @(pixel_index) begin 
        oled_data <= oled_data_map;
        if (oled_data_enemy != 1) begin 
            oled_data <= oled_data_enemy;
        end
        if (oled_data_proj != 1) begin 
            oled_data <= oled_data_proj;
        end 
//        oled_data <= 16'b0000000000011111;   
    end
endmodule


module draw_proj #(parameter MAX_NUM = 5)(input [12:0] p_index, 
input [MAX_NUM:0] active_proj, 
input [7:0] xref [0:MAX_NUM] , input [7:0] yref [0:MAX_NUM],
input [2:0] h, input [6:0] w,
output reg [15:0] oled_data);
    integer i;
    wire [7:0]x = p_index % 96;
    wire [7:0]y = p_index / 96;
    initial begin 
        oled_data = 1;
    end
    always @(p_index) begin 
     oled_data <= 1;
     for (i = 0; i <= MAX_NUM; i = i + 1) begin
        if (active_proj[i]) begin
            if (x >= (xref[i]) && x < (xref[i] + w) && y >= (yref[i]) && y < (yref[i] + h)) begin  // Set all elements to the same value
                oled_data<= 16'hFFFF;
            end
        end 
     end
    end 
endmodule 


module draw_enemy #(parameter MAX_NUM_ENEMIES = 15, parameter size = 8)(input [12:0] p_index, 
input [2:0] activated_enemy [0:MAX_NUM_ENEMIES], 
input [7:0] xref [0:MAX_NUM_ENEMIES] , input [7:0] yref [0:MAX_NUM_ENEMIES] ,
output reg [15:0] oled_data);
    integer i;
    wire [7:0]x = p_index % 96;
    wire [7:0]y = p_index / 96;
    initial begin 
        oled_data = 1;
    end
    always @(p_index) begin 
     oled_data <= 1;
     for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
        if (activated_enemy[i] != 0) begin
            if (x >= (xref[i]) && x < (xref[i] + size) && y >= (yref[i]) && y < (yref[i] + size)) begin  // Set all elements to the same value
                if (activated_enemy[i] == 1) begin
                    oled_data <= 16'hF800; //red
                end else if (activated_enemy[i] == 2) begin 
                    oled_data <= 16'hFFE0; //yellow
                end else if (activated_enemy[i] == 3) begin 
                    oled_data <= 16'h07E0; //green
                end else if (activated_enemy[i] == 4) begin 
                    oled_data <= 16'h1F; //blue
                end else if (activated_enemy[i] >= 5) begin
                    oled_data <= 16'hF81F;
                end
             end
        end 
     end
    end 
endmodule 

module draw_map(input [12:0] p_index, input [7:0]platform_width, input [7:0]platform_x,  input[7:0]platform_y,
output reg [15:0] oled_data);
    wire [7:0] x; wire [7:0] y;
    assign x = p_index % 96;
    assign y = p_index / 96;
    always @(p_index) begin 
        oled_data <= 0;
        if ((y >= platform_y && y <= platform_y + 3) && (x >= platform_x && x <= platform_x + platform_width)) begin
            oled_data <= 16'b1111100000000000; 
        end
    end
endmodule

