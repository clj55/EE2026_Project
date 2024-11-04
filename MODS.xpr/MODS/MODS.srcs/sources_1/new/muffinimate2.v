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


module muffinimate2 #(parameter NUM_PLATFORMS = 3)(
    input clk,
    [6:0]x_vect, [6:0]y_vect, [6:0]sq_width, [6:0]sq_height,
    [6:0]x_hero, [6:0]y_hero, [6:0]width_hero, [6:0]height_hero, 
    [31:0]fps, [15:0]stat_colour, [15:0]move_colour, [15:0]jump_colour, 
    [6:0] x_platform [0:NUM_PLATFORMS], [6:0] y_platform [0:NUM_PLATFORMS], [6:0] width_platform [0:NUM_PLATFORMS], [6:0] height_platform [0:NUM_PLATFORMS],
    reset, pause,
    output reg [6:0]x_var, reg [6:0]y_var, reg hit_muff
    );
    
    reg [6:0] x_increment;
    reg [6:0] y_increment;
    reg [31:0]falling;
    reg start;
    reg stop_falling;
    
    wire [11:0] rng96; 
    wire [11:0] rng64;
    LFSR_random rng1 (.CLOCK(clk), .rst(0), .n(96 - sq_width), .random(rng96));
    LFSR_random rng2 (.CLOCK(clk), .rst(0), .n(64 - sq_height), .random(rng64));

    
    initial begin
        x_var = rng96 % 88;
        y_var = rng64 % 56;
        // for some reason x_var and y_var cant take values of x_start and y_start... values must be written dirctly in this initial block
        falling = 0;
        start = 1;
        stop_falling = 0;
        hit_muff = 0;
    end
//    wire m_value;
//    m_value_calculator calc_m (.freq(fps), .m_value(m_value));

    wire fps_clock;
    flexy_clock get_fps_clock (.clk(clk), .m_value(1_249_999), .slow_clk(fps_clock));
   
   // assume time taken for y to fall through screen is 30 clock cycles (use 64 instead to account for terminal velocity)
   
   reg is_falling = 0;
   
   always @(posedge fps_clock) begin //need to implement gravity
       if (!pause) begin    
           if (reset || start || hit_muff) begin
               hit_muff = 0;
               x_var = (rng96 % 88) + 1;
               y_var = (rng64 % 56) + 1;
               if (x_var + sq_width > 95) begin
                   x_var = 44; // just spawn it to the center of the screen
               end
               falling = 0;
               x_increment = 0;
               y_increment = 0;
               start = 0;
               stop_falling = 0;
           end
           falling <= (is_falling) ? falling + 1 : 0; // falling counter will count continuously, will reset when y is stationary   
           if (reset || start || hit_muff) begin 
               y_var <= 0;
           end else if (y_var >= 103) begin //fall into pit 
               is_falling = 0;
               y_var <= 0;
           end else begin 
               is_falling = 1;
               y_increment = (falling < 64) ? 1 + falling / 3 : y_increment; 
               for (integer j = 0; j <= NUM_PLATFORMS && is_falling; j++) begin 
                   //obstacle
                   if ((x_var <= x_platform[j] + width_platform[j]) &&  (x_var + sq_width >= x_platform[j]) && (y_var + sq_width == y_platform[j])) begin 
                       is_falling = 0;
                       y_increment = 0;
                   //slowing down
                   end else if ((x_var <= x_platform[j] + width_platform[j]) &&  (x_var + sq_width >= x_platform[j]) && 
                       y_var + sq_width + y_increment >= y_platform[j] &&  y_var < y_platform[j])  begin
                       y_increment = 1;
                   end 
               end                 
               y_var <= y_var + y_increment;
               if ((x_var < x_hero + width_hero && x_var + sq_width > x_hero)&& (y_var + sq_height > y_hero && y_var < y_hero + height_hero)) begin
                   hit_muff = 1;
               // end else begin
                   // hit_muff = 0;
               end
           end 
       end
   end   
endmodule
