`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 17:30:50
// Design Name: 
// Module Name: enemy_main
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


module enemy_main #(parameter MAX_ENEMIES = 15, parameter ENEMY_SIZE = 8, parameter NUM_PLATFORMS = 3) 
(input clk, output [3:0] enemy_health [0:MAX_ENEMIES], input fps_clock,
output[6:0]enemy_xref [MAX_ENEMIES:0], output [6:0]enemy_yref [MAX_ENEMIES:0],
input [6:0]platform_width[0:NUM_PLATFORMS], input [6:0]platform_x[0:NUM_PLATFORMS], input [6:0]platform_y[0:NUM_PLATFORMS],
input [6:0]spawn1, input [6:0]spawn2,
input enemyprojclk, input [2:0] proj_d, input [MAX_ENEMIES:0] enemy_hit,
output [MAX_ENEMIES:0] angry 
,input paused, input reset
    );
    
    wire maxed;
 
    wire spawning; wire spawn_type; wire reset_spawn; wire [3:0] spawned_small;  wire [3:0] spawned_big; 
    enemy_spawnfsm fsm(.clk(clk), .maxed(maxed), .spawned_small(spawned_small), .spawned_big(spawned_big), 
    .spawning(spawning), .spawn_type(spawn_type), .reset_spawn(reset_spawn));
   
    enemy_maxcheck #(.MAX_NUM(MAX_ENEMIES)) maxcheck(.clk(clk), .enemies(enemy_health), .maxed(maxed));
    
    wire [1:0] enemy_spawn [0:MAX_ENEMIES];  wire [MAX_ENEMIES:0] resetted_xy; 
    enemy_spawner  #(.MAX_NUM(MAX_ENEMIES)) spawner(.clk(clk), .spawning(spawning), .spawn_type(spawn_type), .reset(reset_spawn  || reset),
    .spawned_small (spawned_small), .spawned_big (spawned_big),
    .enemies(enemy_spawn), .resetted_xy(resetted_xy)
    ,.paused(paused)
        );
    enemy_health #(.MAX_NUM(MAX_ENEMIES)) health (.clk(enemyprojclk), .healths(enemy_health), .spawner(enemy_spawn), 
    .x(enemy_xref), .y(enemy_yref),
    .proj_d(proj_d), .enemy_hit(enemy_hit), .angry(angry)
    , .reset(reset));
    
    enemy_movement #(.MAX_NUM_ENEMIES(MAX_ENEMIES), .size(ENEMY_SIZE), .NUM_PLATFORMS(NUM_PLATFORMS)) 
    move (.clk(clk), .fps_clock(fps_clock),
             .healths(enemy_health), .xref(enemy_xref), .yref(enemy_yref), .resetted_xy(resetted_xy),
             .platform_width(platform_width), .x_obs(platform_x), .y_obs(platform_y),
             .angry(angry), .paused(paused)
             );
        
   
endmodule
