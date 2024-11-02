`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.11.2024 16:44:54
// Design Name: 
// Module Name: random_generator
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

module LCG(input clk, input [31:0]max, output reg[31:0]n);
     initial begin
        n = 0;
     end
     always @(posedge clk) begin 
     //maybe put a button then when pressed it 
     //increments it too LOL so based off users random too
        n <= (n == max) ? 0 : n + 1;
     end 
endmodule