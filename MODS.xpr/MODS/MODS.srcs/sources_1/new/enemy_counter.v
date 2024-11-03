`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 18:07:25
// Design Name: 
// Module Name: enemy_counter
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


module enemy_maxcheck #(parameter MAX_NUM = 15) (input clk, input [3:0] enemies [0:MAX_NUM], output reg maxed);
    initial begin 
        maxed = 0;
    end
        
    always @(posedge clk) begin 
        maxed <= 1;
        for (integer i = 0; i <= MAX_NUM; i++) begin 
            if (enemies[i] == 0) begin 
                maxed <= 0;
            end
        end
    end 
endmodule
