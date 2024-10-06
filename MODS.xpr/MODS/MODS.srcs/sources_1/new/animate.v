`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2024 18:04:11
// Design Name: 
// Module Name: animate
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


module animate(
    input clk, [6:0]x_start, [6:0]y_start, [6:0]x_vect, [6:0]y_vect, [6:0]sq_width, [6:0]sq_height, [31:0]fps, [15:0]stat_colour, [15:0]move_colour,
    output reg [6:0]x_var, reg [6:0]y_var, reg [15:0]center_sq_colour
    );
    
    reg [6:0] x_increment;
    reg [6:0] y_increment;
    
    initial begin
        x_var = x_start;
        y_var = y_start;
        center_sq_colour = 16'b11111_000000_00000;
    end
//    wire m_value;
//    m_value_calculator calc_m (.freq(fps), .m_value(m_value));
    wire fps_clock;
    flexy_clock get_fps_clock (.clk(clk), .m_value(2_499_999), .slow_clk(fps_clock));
    always @ (posedge fps_clock) begin
        x_increment = x_vect; 
        y_increment = y_vect;
        
        // REFINE THE COLLISIONS! 
        
        // check for collisions with boundaries of screen
        if (x_var == 0 && x_vect == 127) begin // check position (x_var) as well as direvtion vector (x_vect)
            x_increment = 0;
        end else if (x_var + sq_width - 1 == 95 && x_vect == 1) begin
            x_increment = 0;
        end else if (x_var + sq_width - 1 == 35 && (y_var + sq_height > 20 && y_var < 20 + 25) && x_vect == 1) begin // left bound of red square
            x_increment = 0;
        end else if (x_var - 1 == 35 + 25 && (y_var + sq_height > 20 && y_var < 20 + 25) && x_vect == 127) begin // right bound of red square
            x_increment = 0;
        end
        if (y_var == 0 && y_vect == 127) begin
            y_increment = 0;
        end else if (y_var + sq_height - 1 == 63 && y_vect == 1) begin
            y_increment = 0;
        end else if (y_var + sq_height == 20 && (x_var + sq_width - 1 > 35 && x_var < 35 + 25) && y_vect == 1) begin // upper bound of red square
            y_increment = 0;
        end else if (y_var == 20 + 25 && (x_var + sq_width - 1 > 35 && x_var < 35 + 25) && y_vect == 127) begin // lower bound of red square
            y_increment = 0;
        
        end
        
        if (x_increment == 0 && y_increment == 0) begin
           center_sq_colour = stat_colour;
//            center_sq_colour = 16'b11111_000000_00000; 
        end else begin
            center_sq_colour = move_colour;
//            center_sq_colour = 16'b11111_000111_00000;
        end
        
        x_var <= x_var + x_increment;
        y_var <= y_var + y_increment;
    end
    
endmodule
