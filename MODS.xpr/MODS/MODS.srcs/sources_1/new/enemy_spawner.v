`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 17:14:19
// Design Name: 
// Module Name: enemy_spawner
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


module enemy_spawner #(parameter MAX_NUM = 15) (input clk, input spawning, input spawn_type, input reset,
output reg [3:0] spawned_small, output reg [3:0] spawned_big, 
output reg [1:0] enemies [0:MAX_NUM],input [MAX_NUM:0] resetted_xy,
input paused
    );
    
    wire spawnhz;
    flexy_clk spawnclk(clk, 99_999_999, spawnhz); //99_999_999
    integer j = 0;
    initial begin 
        spawned_small = 0;
        spawned_big = 0;
        for (integer i = 0; i <= MAX_NUM; i = i + 1) begin 
            enemies[i] = 0;
        end
        
    end
    
    always @(posedge spawnhz) begin 
        if (reset) begin 
            spawned_small <= 0;
            spawned_big <= 0;
            for (integer i = 0; i <= MAX_NUM; i = i + 1) begin 
                enemies[i] = 0;
            end
        end else if (!paused) begin 
            if (spawning) begin 
            //healths[j] != 0 should be true when resetted_xy = 1
                for (integer i = 0; i <= MAX_NUM && resetted_xy[j] == 0; i = i + 1) begin 
                    j = (j == MAX_NUM) ? 0 : j + 1;
                end
                if (spawn_type == 0) begin 
                    if (enemies[j][0] == 0) begin 
                        enemies[j][1] <= ~enemies[j][1];
                    end else begin 
                        enemies[j][0] <= ~enemies[j][0];
                    end
                    spawned_small <= spawned_small + 1;
                end
                else begin 
                    if (enemies[j][0] == 1) begin 
                        enemies[j][1] <= ~enemies[j][1];
                    end else begin 
                        enemies[j][0] <= ~enemies[j][0];
                    end
                    spawned_big <= spawned_big + 1;
                end
            end
        end
    end 
    
endmodule
