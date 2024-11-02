`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 20:36:56
// Design Name: 
// Module Name: draw_sim
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


module draw_sim(

    );
    reg clk;
    wire [7:0]JB;
    draw dut (.clk(clk), .JB(JB));
    initial begin 
        clk = 0;
    end 
    always begin 
        #5; clk = ~clk;
    end 
endmodule
