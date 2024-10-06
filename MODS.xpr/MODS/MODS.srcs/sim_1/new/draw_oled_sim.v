`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2024 12:19:41
// Design Name: 
// Module Name: draw_oled_sim
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


module draw_oled_sim(
    );
    reg BASYS_CLOCK; reg [12:0] p_index; reg btnC; reg btnU;
    wire oled_data; wire clk1; wire clk30; wire clk50;
    flexible_clk oneHzclk (.m(499_999), .in_clk(BASYS_CLOCK), .clk(clk1));
    flexible_clk thirtyHzclk (.m(33_333), .in_clk(BASYS_CLOCK), .clk(clk30));
    flexible_clk fiftyHzclk (.m(9_999), .in_clk(BASYS_CLOCK), .clk(clk50));
    
    draw_oled ddd (.clk(BASYS_CLOCK), .pixel_index(p_index), .oled_data(oled_data), .btnC(btnC), .btnU(btnU),
        .onehz(clk1), .thirtyhz(clk30), .fiftyhz(clk50));
    initial begin 
        BASYS_CLOCK = 0;
        btnC = 0; btnU = 0; p_index = 0;
        
        #33000; btnC = 1;
    end
    always begin
        #5; BASYS_CLOCK <= ~BASYS_CLOCK;
        p_index <= (p_index == 6413) ? 0 : p_index + 1;
    end
endmodule
