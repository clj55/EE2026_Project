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


module enemy_main #(parameter MAX_ENEMIES = 15, parameter ENEMY_SIZE = 8 ) 
(input clk, output [2:0] enemy_health [0:MAX_ENEMIES], 
output[7:0]enemy_xref [MAX_ENEMIES:0], output [7:0]enemy_yref [MAX_ENEMIES:0],
input [7:0]platform_width, input [7:0]platform_x, input [7:0]platform_y,
input [7:0]spawn1, input [7:0]spawn2,
input enemyprojclk, input [2:0] proj_d, input [MAX_ENEMIES:0] enemy_hit
    );
    wire maxed;
 
    wire spawning; wire spawn_type; wire reset_spawn; wire [3:0] spawned_small;  wire [3:0] spawned_big; 
    enemy_spawnfsm fsm(.clk(clk), .maxed(maxed), .spawned_small(spawned_small), .spawned_big(spawned_big), 
    .spawning(spawning), .spawn_type(spawn_type), .reset_spawn(reset_spawn));
   
    enemy_maxcheck #(.MAX_NUM(MAX_ENEMIES)) maxcheck(.clk(clk), .enemies(enemy_health), .maxed(maxed));
    
    wire [1:0] enemy_spawn [0:MAX_ENEMIES]; 
    enemy_spawner  #(.MAX_NUM(MAX_ENEMIES)) spawner(.clk(clk), .spawning(spawning), .spawn_type(spawn_type), .reset(reset_spawn),
    .spawned_small (spawned_small), .spawned_big (spawned_big),
    .enemies(enemy_spawn), .healths(enemy_health)
    //,output [3:0] spawned_big, input paused
        );
    
    wire [MAX_ENEMIES:0] reset_xy; 
    enemy_health #(.MAX_NUM(MAX_ENEMIES)) health (.clk(enemyprojclk), .healths(enemy_health), .spawner(enemy_spawn), 
    .reset_xy(reset_xy), .x(enemy_xref), .y(enemy_yref),
    .proj_d(proj_d), .enemy_hit(enemy_hit));
    
    enemy_movement #(.MAX_NUM_ENEMIES(MAX_ENEMIES), .size(ENEMY_SIZE)) move (.clk(clk), .spawn1(spawn1),  .spawn2(spawn2), 
             .activated_enemy(enemy_health), .xref(enemy_xref), .yref(enemy_yref), .reset_xy(reset_xy),
             .platform_width(platform_width), .x_obs(platform_x), .y_obs(platform_y));
        
  
        
        
        
endmodule
