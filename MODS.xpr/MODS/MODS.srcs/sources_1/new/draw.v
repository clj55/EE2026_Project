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


module draw(input clk, output [7:0] JB, input btnD, input btnC
);
    parameter MAX_ENEMIES = 3; parameter ENEMY_SIZE = 8; parameter NUM_PLATFORMS = 4; //all of this should be the number you want -1
    parameter MAX_PROJ = 5;
    wire sending_pixels; wire sample_pixel; wire frame_begin; wire [12:0] pixel_index; 
    reg [15:0] oled_data = 16'b1111111111111111;
    
    wire clk625; 
    flexy_clk clk6p25m (clk, 7, clk625);
    Oled_Display display (.clk(clk625), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
.sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), 
.sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7])); 
    
    reg [6:0]enemy_spawn1 = 15; // x coordinate
    reg [6:0]enemy_spawn2 = 80; // x coordinate
    wire [6:0]platform_width; wire [6:0]platform_height; 
    wire [6:0]platform_x[0:NUM_PLATFORMS]; wire [6:0]platform_y[0:NUM_PLATFORMS]; 
    assign platform_width = 30; assign platform_height = 3;
    assign {platform_x[0], platform_x[1], platform_x[2], platform_x[3], platform_x[4]} = {7'd0,7'd60,7'd30,7'd0, 7'd60} ;
    assign {platform_y[0], platform_y[1], platform_y[2], platform_y[3], platform_y[4]} = {7'd20,7'd20,7'd40,7'd60,7'd60} ;
    
    wire [15:0]oled_data_map;
    draw_map #(.NUM_PLATFORMS(NUM_PLATFORMS))bg (.p_index(pixel_index), .oled_data(oled_data_map), 
    .platform_width(platform_width), .platform_height(platform_height), .platform_x(platform_x),  .platform_y(platform_y));
    
    wire enemyprojclk;
    flexy_clk interactionclk (clk, 624_999, enemyprojclk); //624_999
    wire fps_clock;
    flexy_clock get_fps_clock (.clk(clk), .m_value(1_249_999), .slow_clk(fps_clock)); //1_249_999
    
    wire [3:0]enemies [MAX_ENEMIES:0]; wire [6:0]enemy_xref [MAX_ENEMIES:0]; wire [6:0]enemy_yref [MAX_ENEMIES:0];
    wire [2:0] proj_d; wire [MAX_ENEMIES:0] enemy_hit;
    
    wire [6:0] proj_x [0:MAX_PROJ]; wire [6:0] proj_y [0:MAX_PROJ]; 
    wire [2:0] proj_h; wire [6:0] proj_w; wire [MAX_PROJ:0]active_proj;
    projectile_main #(.MAX_PROJ(MAX_PROJ), .MAX_ENEMIES(MAX_ENEMIES), .NUM_PLATFORMS(NUM_PLATFORMS), .ENEMY_SIZE(ENEMY_SIZE))  projectiles
    (.clk(enemyprojclk), .btnD(btnD), .reset(btnC), .fps_clock(fps_clock),
    .char_x(45), .char_y(5), .char_xvect(1), .char_width(8), .char_height(8), .char_no(0),
    .platform_x(platform_x), .platform_y(platform_y), .platform_h(platform_height), .platform_w(platform_width),
    .enemy_x(enemy_xref), .enemy_y(enemy_yref), .enemy_hit(enemy_hit), .proj_d(proj_d),
      .proj_x(proj_x), .proj_y(proj_y), .proj_h(proj_h), .proj_w(proj_w), 
      .active(active_proj));
    
    wire [MAX_ENEMIES:0] angry;
    enemy_main #(.MAX_ENEMIES(MAX_ENEMIES), .ENEMY_SIZE(ENEMY_SIZE), .NUM_PLATFORMS(NUM_PLATFORMS)) em(
    .clk(clk), .enemy_health(enemies), .enemy_xref(enemy_xref), .enemy_yref(enemy_yref),
    .platform_width(platform_width), .platform_x(platform_x), .platform_y(platform_y), 
    .spawn1(enemy_spawn1), .spawn2(enemy_spawn2),
    .enemyprojclk(enemyprojclk), .proj_d(proj_d), .enemy_hit(enemy_hit),
    .angry(angry)
//    ,.rando_sig(btnC)
    );
    
    wire [15:0]oled_data_enemy;
    draw_enemy #(.MAX_NUM_ENEMIES(MAX_ENEMIES), .size(ENEMY_SIZE)) drawe (.p_index(pixel_index), 
    .enemies(enemies), .angry(angry),
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
input [6:0] xref [0:MAX_NUM] , input [6:0] yref [0:MAX_NUM],
input [2:0] h, input [6:0] w,
output reg [15:0] oled_data);
    integer i;
    wire [6:0]x = p_index % 96;
    wire [6:0]y = p_index / 96;
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
input [3:0] enemies [0:MAX_NUM_ENEMIES], input [MAX_NUM_ENEMIES:0]angry,
input [6:0] xref [0:MAX_NUM_ENEMIES], input [6:0] yref [0:MAX_NUM_ENEMIES],
output reg [15:0] oled_data);
    integer i;
    wire [6:0]x = p_index % 96;
    wire [6:0]y = p_index / 96;
    initial begin 
        oled_data = 1;
    end
    always @(p_index) begin 
     oled_data <= 1;
     for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
        if (enemies[i] != 0) begin
            if (x >= (xref[i]) && x < (xref[i] + size) && y >= (yref[i]) && y < (yref[i] + size)) begin  // Set all elements to the same value
                if (!angry[i]) begin
                    case (enemies[i]) 
                        1: oled_data = 16'h07E5; // green
                        2: oled_data = 16'h2758; // marine
                        3: oled_data = 16'h043F; // blue
                        4: oled_data = 16'h301F; // darkblue
                        5: oled_data = 16'hB018; // purp!
                        6: oled_data <= 16'b1111100000000000;  //red
                        7: oled_data <= 16'b1111111111100000;  //yellow
                        default: oled_data <= 16'hFFFF;
                    endcase
                end else begin 
                    case (enemies[i])
                        1: oled_data = 16'hE720; // dirty yellow
                        2: oled_data = 16'hE600; // dark yellow
                        3: oled_data = 16'hE4E0; // dark orange
                        4: oled_data = 16'hC2A0; // brown
                        5: oled_data = 16'hC800; // RED (but darker)
                        6: oled_data <= 16'b1111100000000000; //purple
                        7: oled_data <= 16'b1111111111100000;  //yellow
                        default: oled_data<= 16'hFFFF;
                    endcase
                end
             end
        end 
     end
    end 
endmodule 

module draw_map #(parameter NUM_PLATFORMS = 3) (input [12:0] p_index, 
input [6:0]platform_width, input [6:0] platform_height,
input [6:0]platform_x[0:NUM_PLATFORMS],  input[6:0]platform_y[0:NUM_PLATFORMS],
output reg [15:0] oled_data);
    wire [6:0] x; wire [6:0] y;
    assign x = p_index % 96;
    assign y = p_index / 96;
    always @(p_index) begin 
        oled_data <= 0;
        for (integer j = 0; j <= NUM_PLATFORMS; j++) begin
            if ((y >= platform_y[j] && y <= platform_y[j] + platform_height) && (x >= platform_x[j] && x <= platform_x[j] + platform_width)) begin
                oled_data <= 16'b1111100000000000; 
            end
        end
    end
endmodule

