`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/03/2024 03:24:26 PM
// Design Name: 
// Module Name: flexible_clock
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


module flexible_clock(
    input [31:0] CLOCK,
    input [31:0] m,
    output reg reg_clock = 0
);

    reg [31:0] count = 0;

    always @ (posedge CLOCK) 
    begin
        count <= (count == m) ? 0 : count + 1;
        reg_clock <= (count == m) ? ~reg_clock : reg_clock; 
    end
endmodule
