`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.11.2024 06:58:07
// Design Name: 
// Module Name: main_sim
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


module main_sim(
    );
    reg clk; reg btnC = 0; reg btnD = 0; reg btnU = 0; reg btnL = 0; reg btnR = 0;
    wire [7:0]JC;
    main dut (.clk(clk), .JC(JC), .btnC(btnC), 
    .btnD(btnD), .btnR(btnR), .btnU(btnU), .btnL(btnL));
    initial begin 
        clk = 0;
//        btnC = 1;
    #200; btnD = 1; btnL = 1;
    end 
    always begin 
        #5; clk = ~clk;
    end 
endmodule

