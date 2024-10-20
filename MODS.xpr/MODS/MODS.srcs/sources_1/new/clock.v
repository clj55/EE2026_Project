`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.10.2024 16:49:47
// Design Name: 
// Module Name: clock
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

module flexy_clk(input [31:0] m, input in_clk, output reg clk);
    reg [31:0] COUNT;
    initial begin 
        COUNT = 0;
        clk = 0;
    end 
    always @(posedge in_clk) begin
        COUNT <= (COUNT == m) ? 0 : COUNT + 1;
        clk <= COUNT ? clk : ~clk;
    end
endmodule
