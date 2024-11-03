`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.11.2024 12:24:22
// Design Name: 
// Module Name: projectile_types
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

module laser (
    input clk, active,
    [6:0]char_x, [6:0]char_y, [6:0]char_xvect, [6:0]sq_width, [6:0]sq_height,
    output reg [6:0] proj_x, output reg [6:0] proj_y,  reg [6:0]proj_w, reg[6:0]proj_h
    );
    
    initial begin
        proj_w = 0;
        proj_h = 6;
        proj_x = 127;
        proj_y = 0;
    end
    
    wire [6:0]launchpt_x = char_x + sq_width/2;
    wire [6:0]launchpt_y = char_y + ((sq_height - proj_h) / 2);
    
    always @ (posedge clk) begin
        if (!active) begin
            proj_x = 127;
            proj_w = 0;
        end else begin 
            proj_y = launchpt_y;
            if (char_xvect == 1) begin // shoot right
                proj_x = launchpt_x;
                proj_w = 95 - proj_x;
            end else if (char_xvect == 127) begin
                proj_x = 0;
                proj_w = launchpt_x;
            end
        end
    end
endmodule

module parab_shot #(parameter MAX_PROJ = 2) (
    input clk, btnD, [MAX_PROJ:0]active,
    [6:0]char_x, [6:0]char_y, [6:0]char_xvect, [6:0]sq_width, [6:0]sq_height,
    output reg [6:0] proj_x [0:MAX_PROJ], output reg [6:0] proj_y [0:MAX_PROJ],  reg [6:0]proj_w, reg[6:0]proj_h
    );

    // shoot either left or right dependning on directin of movement of player (x_vect, y_vect)
    // starts from centre of player sprite 
    // shoots with constant velocity (constant x_increment)

    wire [6:0] launchpt_x_left;
    wire [6:0] launchpt_x_right;
    wire [6:0] launchpt_y;
    reg [6:0] x_increment [0:MAX_PROJ];
    reg [6:0] y_increment [0:MAX_PROJ];
    reg [31:0]jumping [0:MAX_PROJ];
    reg [31:0]falling [0:MAX_PROJ];
    parameter jump_time = 12;
    
    initial begin
        proj_w = 8;
        proj_h = 3;
        for (integer i = 0; i <= MAX_PROJ; i++) begin
            x_increment[i] = 0;
            y_increment[i] = 0;
            jumping[i] = 0;
            falling[i] = 0;
            proj_x[i] = 127;
            proj_y[i] = 0;
        end
        
    end

    assign launchpt_x_left = char_x + 1;
    assign launchpt_x_right = char_x + sq_width - 1;
    assign launchpt_y = char_y + ((sq_height - proj_h) / 2);
    
    always @ (posedge clk) begin
        for (integer i = 0; i <= MAX_PROJ; i++) begin
            if (active[i] == 0) begin
                jumping[i] = jump_time; 
                falling[i] = 0;
                x_increment[i] = 0;
                y_increment[i] = 0;
                proj_x[i] <= 127;
            end else if (proj_x[i] == 127) begin // first launched
                x_increment[i] = char_xvect;
                if (char_xvect == 1) begin // facing right, launch from right
                    proj_x[i] <= launchpt_x_right; // starting point for projectile
                end else if (char_xvect == 127) begin // facing left, launch from left
                    proj_x[i] <= launchpt_x_left; // starting point for projectile
                end
                proj_y[i] <= launchpt_y;                
            end else begin
                if (jumping[i] > 0) begin
                    y_increment[i] = 127 - jumping[i] / 3 + 1;
                end else if (falling[i] < 64) begin
                    y_increment[i] = 1 + falling[i] / 3; 
                end
                jumping[i] = (jumping[i] > 0) ? jumping[i] - 1 : 0; // count down to 0
                falling[i] = (jumping[i] > 0) ? 0 : falling[i] + 1; // falling counter will count continuously, will reset when y is stationary 
             
                proj_x[i] <= proj_x[i]+ x_increment[i];
                proj_y[i] <= proj_y[i] + y_increment[i];
            end 
        end 
    end
endmodule

module double_shot #(parameter MAX_PROJ = 2) (
    input clk, [MAX_PROJ:0] active,
    [6:0]char_x, [6:0]char_y, [6:0]sq_width, [6:0]sq_height, 
    output reg [6:0] proj_x [0:MAX_PROJ], output reg [6:0] proj_y [0:MAX_PROJ], 
    output reg [6:0] proj_h, output reg [6:0] proj_w
);
   wire [6:0] launchpt_x;
   wire [6:0] launchpt_y;
   reg [6:0] x_increment [0:MAX_PROJ];
   integer i;
   initial begin    
       for (i = 0; i <= MAX_PROJ; i++) begin 
          proj_x[i] = 127;
          proj_y[i] = 0; 
          x_increment[i] = 0;
       end 
       proj_w = 3;
       proj_h = 3;
   end
   
   assign launchpt_x = char_x + (sq_width/2) - 1;
   assign launchpt_y = char_y + ((sq_height - proj_h) / 2);
   
    always @ (posedge clk) begin
        for (i = 0; i <= MAX_PROJ; i++) begin 
            if (active[i] == 0) begin //active i and max_proj - 1 (max proj must be even)
                proj_x[i] <= 127;
            end else if (proj_x[i] == 127) begin //if proj was not activated 
                proj_x[i] <= launchpt_x;
                proj_y[i] <= launchpt_y;
            end else begin    
                proj_x[i] <= (i <= 2) ? proj_x[i] + 1 :  proj_x[i] - 1;
            end
        end
    end
endmodule 

//clk runs at 624_999
module single_shot #(parameter MAX_PROJ = 2) (
    input clk, [MAX_PROJ:0] active,
    [6:0]char_x, [6:0]char_y, [6:0]char_xvect, [6:0]sq_width, [6:0]sq_height, 
    output reg [6:0] proj_x [0:MAX_PROJ], output reg [6:0] proj_y [0:MAX_PROJ], 
    output reg [6:0] proj_h, output reg [6:0] proj_w
    );

    // shoot either left or right dependning on directin of movement of player (x_vect, y_vect)
    // starts from centre of player sprite 
    // shoots with constant velocity (constant x_increment)

    wire [6:0] launchpt_x_left;
    wire [6:0] launchpt_x_right;
    wire [6:0] launchpt_y;
    reg [6:0] x_increment [0:MAX_PROJ];
    integer i;
    
    initial begin
        
        for (i = 0; i <= MAX_PROJ; i++) begin 
           proj_x[i] = 127;
           proj_y[i] = 0; 
           x_increment[i] = 0;
        end 
        proj_w = 8;
        proj_h = 3;
    end
   
    assign launchpt_x_left = char_x + 1;
    assign launchpt_x_right = char_x + sq_width - 1;
    assign launchpt_y = char_y + ((sq_height - proj_h) / 2);

    
    always @ (posedge clk) begin
        for (i = 0; i <= MAX_PROJ; i++) begin 
            if (active[i] == 0) begin
                proj_x[i] = 127;
                x_increment[i] = 0;
             end else if (proj_x[i] == 127) begin //if proj was not activated 
                x_increment[i] = char_xvect;
                if (char_xvect == 1) begin // facing right, launch from right
                    proj_x[i] <= launchpt_x_right; // starting point for projectile
                end else if (char_xvect == 127) begin // facing left, launch from left
                    proj_x[i] <= launchpt_x_left; // starting point for projectile
                end
                proj_y[i] <= launchpt_y;
            end else begin    
                proj_x[i] <= proj_x[i] + x_increment[i];
            end
        end 
    end
endmodule

