`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.11.2024 00:53:47
// Design Name: 
// Module Name: main
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


module main(
    input clk, btnC, btnL, btnR, btnD, btnU, [4:0]sw,  
    output [7:0]JC, [2:0]led, [6:0]seg, [3:0]an
    );
    
    
wire frame_begin, sending_pixels, sample_pixels;
wire [12:0] pixel_index;

wire [15:0] oled_data;
reg [15:0] oled_data_reg;

initial begin
    oled_data_reg = 0;
end    

parameter NUM_PLATFORMS = 4;    
parameter MAX_ENEMIES = 14;
parameter ENEMY_SIZE = 8; //all of this should be the number you want -1
parameter MAX_PROJ = 5;


wire [6:0] x;
wire [6:0] y;
wire [6:0] x_var;
wire [6:0] y_var;
//wire [6:0] x_var2;
//wire [6:0] y_var2;
wire [6:0] x_muff;
wire [6:0] y_muff;
//wire [6:0] x_proj1;
//wire [6:0] y_proj1;
//wire [6:0] x_proj2;
//wire [6:0] y_proj2;
wire [6:0] platform_x [0:NUM_PLATFORMS];
assign platform_x[0] = 0; assign platform_x[1] = 32; assign platform_x[2] = 74; assign platform_x[3] = 35;  
wire [6:0] platform_y [0:NUM_PLATFORMS];
assign platform_y[0] = 36; assign platform_y[1] = 18; assign platform_y[2] = 36; assign platform_y[3] = 58;
wire [6:0] platform_width [0:NUM_PLATFORMS];
assign platform_width[0] = 28; assign platform_width[1] = 32; assign platform_width[2] = 21; assign platform_width[3] = 32;
wire [6:0] platform_height [0:NUM_PLATFORMS];
assign platform_height[0] = 3; assign platform_height[1] = 3; assign platform_height[2] = 3; assign platform_height[3] = 3;


reg [6:0]enemy_spawn1 = 15; // x coordinate
reg [6:0]enemy_spawn2 = 80; // x coordinate
//wire [6:0]platform_width; wire [6:0]platform_height; 
//wire [6:0]platform_x[0:NUM_PLATFORMS]; wire [6:0]platform_y[0:NUM_PLATFORMS]; 
//assign platform_width = 30; assign platform_height = 3;
//assign {platform_x[0], platform_x[1], platform_x[2], platform_x[3], platform_x[4]} = {7'd0,7'd60,7'd30,7'd0, 7'd60} ;
//assign {platform_y[0], platform_y[1], platform_y[2], platform_y[3], platform_y[4]} = {7'd20,7'd20,7'd40,7'd60,7'd60} ;

wire reset;

assign reset = btnC;

assign x = pixel_index % 96;
assign y = pixel_index / 96;

// use pushbuttons to choose direction
wire [6:0]x_vect;
wire [6:0]y_vect;
wire is_y_stat;
wire facing;
direction_mux choose_direction (.clk(clk), .btnC(btnC), .btnL(btnL), .btnR(btnR), .btnD(btnD), .btnU(btnU), .is_y_stat(is_y_stat), .x_vect(x_vect), .y_vect(y_vect), .facing(facing));


wire [15:0]center_sq_colour;
wire [6:0] x_spawn = 48;
wire [6:0] y_spawn = 0;
wire [3:0] hitbox_size = 8; 
wire [3:0] sprite_no;



wire enemyprojclk;
flexy_clk interactionclk (clk, 624_999, enemyprojclk); //624_999
wire fps_clock;
flexy_clock get_fps_clock (.clk(clk), .m_value(1_249_999), .slow_clk(fps_clock)); //1_249_999


wire [2:0]enemies [MAX_ENEMIES:0]; wire [6:0]enemy_xref [MAX_ENEMIES:0]; wire [6:0]enemy_yref [MAX_ENEMIES:0];
wire [2:0] proj_d; wire [MAX_ENEMIES:0] enemy_hit;
wire [6:0] proj_x [0:MAX_PROJ]; wire [6:0] proj_y [0:MAX_PROJ]; 
wire [2:0] proj_h; wire [6:0] proj_w; wire [MAX_PROJ:0]active_proj;
// projectile logic
projectile_main #(.MAX_PROJ(MAX_PROJ), .MAX_ENEMIES(MAX_ENEMIES), .NUM_PLATFORMS(NUM_PLATFORMS), .ENEMY_SIZE(ENEMY_SIZE))  projectiles
    (.clk(enemyprojclk), .btnD(btnD), .reset(btnC), .fps_clock(fps_clock),
    .char_x(10), .char_y(5), .char_xvect(1), .char_width(8), .char_height(8), .char_no(0),
    .platform_x(platform_x), .platform_y(platform_y), .platform_h(platform_height), .platform_w(platform_width),
    .enemy_x(enemy_xref), .enemy_y(enemy_yref), .enemy_hit(enemy_hit), .proj_d(proj_d),
      .proj_x(proj_x), .proj_y(proj_y), .proj_h(proj_h), .proj_w(proj_w), 
      .active(active_proj));

wire [MAX_ENEMIES:0] angry;
// enemy logic
enemy_main #(.MAX_ENEMIES(MAX_ENEMIES), .ENEMY_SIZE(ENEMY_SIZE), .NUM_PLATFORMS(NUM_PLATFORMS)) em(
    .clk(clk), .enemy_health(enemies), .enemy_xref(enemy_xref), .enemy_yref(enemy_yref),
    .platform_width(platform_width), .platform_x(platform_x), .platform_y(platform_y), 
    .spawn1(enemy_spawn1), .spawn2(enemy_spawn2),
    .enemyprojclk(enemyprojclk), .proj_d(proj_d), .enemy_hit(enemy_hit),
    .angry(angry)
//    ,.rando_sig(btnC)
    );



// track damage of player (3 lives)
wire hero_hit;
wire hit_muff;
wire [31:0] muff_count;
wire [2:0]char_no;
hero_damage(.clk(clk), .hit(hero_hit), .reset(reset), .LED(led));
touch_muff(.clk(clk), .hit_muff(hit_muff), .start_muff(0), .reset(reset), .char_no(char_no), .muff_count(muff_count));

// seven seg display to count muffins collected
seven_seg_display2 display (.n(muff_count), .CLOCK(clk), .an(an), .seg(seg));





// player character logic
animate animate_hero (.clk(clk), 
        .x_start(84), .y_start(0), .x_vect(x_vect), .y_vect(y_vect), .sq_width(hitbox_size), .sq_height(hitbox_size),
        .enemy_xref(enemy_xref), .enemy_yref(enemy_yref),
        .x_platform(platform_x), .y_platform(platform_y), .width_platform(platform_width), .height_platform(platform_height), 
        .reset(reset),
        .x_var(x_var), .y_var(y_var), .center_sq_colour(center_sq_colour), .is_y_stat(is_y_stat), .sprite_no(sprite_no), .hero_hit(hero_hit));
        
wire proj_move;
wire proj_hit_enemy;
wire [6:0]proj_width;
wire [6:0]proj_height;

// muffin logic
muffinimate2 animate_muffin (.clk(clk),
        .x_start(40), .y_start(0), .x_vect(0), .y_vect(1), .sq_width(hitbox_size), .sq_height(hitbox_size), 
        .x_hero(x_var), .y_hero(y_var), .width_hero(8), .height_hero(8),
        .x_platform(platform_x), .y_platform(platform_y), .width_platform(platform_width), .height_platform(platform_height), 
        .reset(reset),
        .x_var(x_muff), .y_var(y_muff), .center_sq_colour(center_sq_colour), .hit_muff(hit_muff));


// Timothy's drawing module

pixel_control pixycont (
        .x(x), .y(y), 
        .clock(clk), .btnU(btnU), .btnL(btnL), .btnR(btnR),
        .xref_std(x_var), .yref_std(y_var), .stnum(char_no), .faceleft(facing), .vertical_movement(is_y_stat),
        .xref_e(enemy_xref), .yref_e(enemy_yref), .enemy_health(enemies), .angry(angry),
        .xref_muffin(x_muff), .yref_muffin(y_muff),
        .pixel_data(oled_data)
        );




wire clk6p25m;
flexy_clock clk_6p25MHz (.clk(clk), .m_value(7), .slow_clk(clk6p25m));
// 3.A1: instantiate Oled_Display
Oled_Display Q3A1 (.clk(clk6p25m), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
  .sample_pixel(sample_pixels) , .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JC[0]), .sdin(JC[1]), 
  .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]));

    
endmodule



// EVERYTHING BELOW IS CLAIRE'S MODULES

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
input [2:0] enemies [0:MAX_NUM_ENEMIES], input [MAX_NUM_ENEMIES:0]angry,
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
                        1: oled_data <= 16'h07E0; //green
                        2: oled_data <= 16'h07EA; //greenish blue?
                        3: oled_data <= 16'h07E0; //blue
                        4: oled_data <= 16'hA81F; //bluish purple ?
                        5: oled_data <= 16'hF81F; //purple
                        default: oled_data <= 16'hFFFF;
                    endcase
                end else begin 
                    case (enemies[i])
                        1: oled_data <= 16'hF800; //red
                        2: oled_data <= 16'hFD40; //orange
                        3: oled_data <= 16'hFD4F; //dark yellow??
                        4: oled_data <= 16'h07E0; //yellow
                        5: oled_data <= 16'hA7E0; //yellowish green??
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

