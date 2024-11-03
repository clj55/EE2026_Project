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
    reg clk; reg btnC; reg btnD;
    wire [7:0]JB;
    draw dut (.clk(clk), .JB(JB), .btnC(btnC), .btnD(btnD));
    initial begin 
        clk = 0;
        btnC = 1;
        btnD = 0;
        #200; btnC = 0;
        #5000; btnD = 1;
        #20; btnD = 0;
        #5000; btnD = 1;
        #20; btnD = 0;
//        #500; btnC = 1;
//        #500; btnC = 0;
    end 
    always begin 
        #5; clk = ~clk;
    end 
endmodule
