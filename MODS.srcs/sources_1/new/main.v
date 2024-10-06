`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2024 12:27:47 AM
// Design Name: 
// Module Name: main
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


module main(
    input CLOCK,
    input [15:0] sw,
    output reg [15:0] led,
    input [6:0] seg,
    input [3:0] an,
    input btnC, btnL, btnR, btnU, btnD,
    output [7:0] JB
    );
    
    wire clk1000, clk2, clk10, clk5, clk6;
    
    flexible_clock clk1000hz (CLOCK, 49_999, clk1000);
    flexible_clock clk2hz (CLOCK, 24_999_999, clk2);
    flexible_clock clk10hz (CLOCK, 4_999_999, clk10);
    flexible_clock clk5hz (CLOCK, 9_999_999, clk5);
    flexible_clock clk6hz (CLOCK, 8_333_332, clk6);
    
    always @ (posedge CLOCK) 
    begin
        led[15:0] <= sw[15:0];
        
        if (sw[0] && sw[1] && sw[2] && sw[3] && sw[7] && sw[8] && sw[12])
        begin
        // SK
            led[0] <= clk2;
            led[1] <= clk2;
            led[2] <= clk2;
            led[3] <= clk2;
            led[7] <= clk2;
            led[8] <= clk2;
        
        end else if (sw[0] && sw[1] && sw[2] && sw[4] && sw[7] && sw[9] && sw[13])
        begin
        // Timo
            led[0] <= clk10;
            led[1] <= clk10;
            led[2] <= clk10;
            led[4] <= clk10;
            led[7] <= clk10;
            led[9] <= clk10;
            
        end else if (sw[0] && sw[2] && sw[4] && sw[8] && sw[14])  
        begin
        // Claire
            led[0] <= clk5;
            led[2] <= clk5;
            led[4] <= clk5;
            led[8] <= clk5;
            
        end else if (sw[0] && sw[2] && sw[4] && sw[5] && sw[7] && sw[15])
        begin
        // Kashfy
            led[0] <= clk6;
            led[2] <= clk6;
            led[4] <= clk6;
            led[5] <= clk6;
            led[7] <= clk6;

        end else
        begin
        // no task going on; display group number which idk lmao
            
        end
    end
    
endmodule
