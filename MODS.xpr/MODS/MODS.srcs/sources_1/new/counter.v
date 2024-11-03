`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 15:46:29
// Design Name: 
// Module Name: counter
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


module counter(input clk, input inc_count, output reg [4:0]count
,input paused, input reset
);
    wire onehz;
    flexy_clk secondsclk (clk, 49_999_999, onehz); //49_999_999
    initial begin 
        count = 0;
    end 
    
    always @(posedge onehz) begin 
        if (reset) begin
            count = 0;
        end else if (!paused) begin 
            count <= (inc_count) ? count + 1: 0; 
        end
    end 
endmodule
