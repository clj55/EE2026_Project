`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 15:53:02
// Design Name: 
// Module Name: enemy_sim
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


module enemy_sim(
    );
    reg clk;
    enemy_main dut (.clk(clk));
    initial begin 
        clk = 0;
    end 
    always begin 
        #5; clk = ~clk;
    end 
    
endmodule
