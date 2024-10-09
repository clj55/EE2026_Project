`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.10.2024 15:21:11
// Design Name: 
// Module Name: task4D
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


module task4D(
    input clk, btnC, btnL, btnR, btnD, btnU, [15:0]sw,  
    input [12:0] pixel_index,
    output wire [15:0] oled_data
);
// 3.A3: oled_data initialisation
reg [15:0] oled_data_reg;
// for x and y coordinates of OLED
wire [6:0] x;
wire [6:0] y;
wire [6:0] x_var;
wire [6:0] y_var;
wire [6:0] x_var_default;
wire [6:0] y_var_default;

//assign x_var_default = 0;
//assign y_var_default = 0;

//assign x_var = (sw == 16'b1000_0000_1011_0101) ? 0 : x_var;
//assign y_var = (sw == 16'b1000_0000_1011_0101) ? 0 : y_var;  

//reg [15:0] oled_colour;

initial begin
    oled_data_reg = 0;
//    oled_colour = 16'b00000_111111_00000;
end

//assign oled_data = oled_data_reg;

// convert pixel_index to coordinates
assign x = pixel_index % 96;
assign y = pixel_index / 96;

/*            
3.A2: instantiate clock divider module
    inputs: basys clock, m_value (the count limit of the clock)
    output: 6.25 MHz wire
*/




// use pushbuttons to choose direction
wire [6:0]x_vect;
wire [6:0]y_vect;
direction_mux choose_direction (.clk(clk), .btnC(btnC), .btnL(btnL), .btnR(btnR), .btnD(btnD), .btnU(btnU), .x_vect(x_vect), .y_vect(y_vect));

// animate the movement of the square
wire [15:0]center_sq_colour;
animate(.clk(clk), .x_start(0), .y_start(0), .x_vect(x_vect), .y_vect(y_vect), .sq_width(7), .sq_height(7), .fps(20), 
        .stat_colour(16'b11111_000000_00000), .move_colour(16'b11100_001111_00000), .x_var(x_var), .y_var(y_var), .center_sq_colour(center_sq_colour));

// draw the squares
make_square draw_sq (.clk(clk), .x(x), .y(y), 
        .x_val(x_var), .y_val(y_var), .sq_width(7),.sq_height(7), .sq_colour(16'b00000_111111_00000),
        .x_val2(36), .y_val2(20), .sq_width2(25),.sq_height2(25), .sq_colour2(center_sq_colour), 
        .bg_colour(0), .oled_data(oled_data));
endmodule