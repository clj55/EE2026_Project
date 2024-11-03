`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 16:15:46
// Design Name: 
// Module Name: enemy_spawnfsm
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


module enemy_spawnfsm(input clk, input maxed, 
input [3:0]spawned_small, input [3:0]spawned_big,
output spawning, output reg reset_spawn, output reg spawn_type
,input paused, input reset
    );
    reg [4:0]level;
    reg [2:0]level_small[0:10]; reg [2:0]level_big[0:10];
    reg [3:0]level_count[0:10];
    reg [3:0]num_small; reg [3:0]num_big; 
    reg spawn_done;
    wire [4:0]count;
    
    
    initial begin 
      {level_small[0], level_small[1], level_small[2], level_small[3], level_small[4], level_small[5], 
      level_small[6], level_small[7], level_small[8], level_small[9],level_small[10]} 
      = {3'b000, 3'b011, 3'b001, 3'b100, 3'b100, 3'b101, 3'b101, 3'b101, 3'b101, 3'b101, 3'b101};
      
      {level_big[0], level_big[1], level_big[2], level_big[3], level_big[4], level_big[5], 
        level_big[6], level_big[7], level_big[8], level_big[9], level_big[10]} 
        = {3'b000, 3'b001, 3'b001, 3'b001, 3'b010, 3'b010, 3'b010, 3'b010, 3'b010, 3'b010, 3'b010};
      
      //time bfr activating level
      {level_count[0], level_count[1], level_count[2], level_count[3], level_count[4], level_count[5], 
      level_count[6], level_count[7], level_count[8], level_count[9], level_count[10]} 
      = {4'b0001, 4'b0010, 4'b1010, 4'b1001, 4'b1000, 4'b0111, 4'b0111, 4'b0110, 4'b0110, 4'b0101, 4'b0101};
      
      reset_spawn = 0;
      level = 0;
      num_small = 0;
      num_big = 0;
      spawn_done = 1;
      spawn_type = 0;
    end 
    
    wire counting;
    assign counting = spawn_done && (!maxed);
    assign spawning = (!spawn_done) && (!maxed);
    counter c(.clk(clk), .inc_count(counting), .count(count)
    ,.paused(paused), .reset(reset)
    );
    
    always @(posedge clk) begin 
        if (reset) begin 
            reset_spawn = 0;
            level = 0;
            num_small = 0;
            num_big = 0;
            spawn_done = 1;
            spawn_type = 0;
        end else if (!paused) begin
            if (spawned_small == 0 && spawned_big == 0)  begin // && spawned_big == 0)
                reset_spawn = 0; //once resetted disable reset
            end
            
            if (spawn_done) begin 
                if (count == level_count[level]) begin 
                    num_small <= level_small[level]; 
                    num_big = level_big[level];
                    spawn_done <= 0;
                    reset_spawn <= 1;
                    level <= level + 1;
                end
            end else begin 
                if (spawned_small < num_small) begin 
                    spawn_type <= 0;
                end 
                else if (spawned_big < num_big) begin 
                    spawn_type <= 1;
                end
                else begin 
                    spawn_done <= 1;
                end
            end
        end   
    end 
    
endmodule
