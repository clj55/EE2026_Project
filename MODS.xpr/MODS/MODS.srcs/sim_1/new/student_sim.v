`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.10.2024 14:20:08
// Design Name: 
// Module Name: student_sim
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


module student_sim(
    );
    reg clk;
    Top_Student dut (clk);
    
    initial begin 
        clk = 0;
    end 
    always begin 
        #5; clk = ~clk;
    end 
endmodule
