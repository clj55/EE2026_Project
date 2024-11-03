`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 18:16:22
// Design Name: 
// Module Name: enemy_health
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


module enemy_health #(parameter MAX_NUM = 15, parameter MAX_PROJ = 3)
(input clk, output reg [3:0] healths [0:MAX_NUM],
input [1:0] spawner [0:MAX_NUM],
input [6:0]x [0: MAX_NUM], input [6:0]y[0: MAX_NUM],
input [2:0] proj_d, input [MAX_NUM:0]enemy_hit, input [MAX_NUM:0]angry
,input reset, paused
    );
    reg [1:0] spawn_tracker [0:MAX_NUM]; reg [MAX_NUM:0]alrangry;
    integer i = 0;
    initial begin 
        alrangry = 0;
        for (integer i = 0; i <= MAX_NUM; i = i + 1) begin 
            spawn_tracker[i] = 0;
            healths[i] = 0;
        end
    end
    always @(posedge clk) begin  
        if (reset) begin 
            alrangry = 0;
            for (integer i = 0; i <= MAX_NUM; i = i + 1) begin 
                spawn_tracker[i] = 0;
                healths[i] = 0;
            end
        end else if (!paused) begin
            for (i = 0; i <= MAX_NUM; i++) begin 
                if (spawn_tracker[i] != spawner[i]) begin 
                    healths[i] <= (spawner[i][0]) ? 5 : 3; //big: 1 small : 0
                    spawn_tracker[i] <= spawner[i];
                    alrangry[i] <= 0;
                    
                end else begin      
                    if (enemy_hit[i]) begin // check projectile hit 
                        healths[i] = (healths[i] < proj_d) ? 0 : healths[i] - proj_d;
                    end 
                    if (angry[i] && !alrangry[i]) begin 
                        alrangry[i] <= 1;
                        healths[i] = (healths[i] + 2 >= 5) ? 5 : healths[i] + 2;
                    end              
                end
            end
        end
    end
    
endmodule
