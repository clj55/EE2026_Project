`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//
//  FILL IN THE FOLLOWING INFORMATION:
//  STUDENT A NAME: 
//  STUDENT B NAME:
//  STUDENT C NAME: 
//  STUDENT D NAME:  
//
//////////////////////////////////////////////////////////////////////////////////


module Top_Student (input BASYS_CLOCK);      
    wire sixp25Mhz;
    flexible_clk sixp25MHzclk (.m(7), .in_clk(BASYS_CLOCK), .clk(sixp25Mhz));
endmodule

module flexible_clk(input [31:0] m, input in_clk, output reg clk);
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