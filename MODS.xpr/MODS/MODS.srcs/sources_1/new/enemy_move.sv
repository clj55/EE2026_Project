`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.10.2024 18:47:37
// Design Name: 
// Module Name: enemy_move
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




module enemy_movement #(parameter MAX_NUM_ENEMIES = 15, parameter size = 8, parameter NUM_PLATFORMS = 3)
(input clk, input fps_clock, input[3:0]healths [0: MAX_NUM_ENEMIES], 
input [6:0] platform_width[0:NUM_PLATFORMS], input [6:0] x_obs [0:NUM_PLATFORMS], input [6:0] y_obs [0:NUM_PLATFORMS],
output reg [6:0] xref [0: MAX_NUM_ENEMIES]  , output reg [6:0] yref [0: MAX_NUM_ENEMIES],
output [MAX_NUM_ENEMIES:0]resetted_xy, output reg [MAX_NUM_ENEMIES:0]angry
,input paused, reset
);
        
    localparam spawn1 = 15; // x coordinate
    localparam spawn2 = 80; // x coordinate
    wire normalhz; wire fasthz;
    reg [0:MAX_NUM_ENEMIES] direction; //0: left 1: right
    reg [6:0] y_increment [0:MAX_NUM_ENEMIES];
    reg [31:0]falling [0:MAX_NUM_ENEMIES];
    reg [0:MAX_NUM_ENEMIES] is_falling = 0; //0 is true
    reg [1:0] x_inc;
    
    flexy_clk walk_clk (clk, 6_999_999, normalhz); //6_999_999
    integer i; integer j;

    initial begin 
        j = 0;
        for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
           xref[i] <= 15;  // spawn location
           yref[i] <= 0;
           falling[i] <= 0;
           y_increment[i] <= 0;
        end 
        x_inc = 1;
        direction = 0;
        angry = 0;
    end
    
    reg [MAX_NUM_ENEMIES:0] resettedy = 0;
    reg [MAX_NUM_ENEMIES:0] resettedx = 0;
    assign resetted_xy = resettedy & resettedx;
    wire spawnchooser; wire directionchooser;
    LFSR_random #(.LFSR(23)) spawnrand(.CLOCK(clk), .n(2), .rst(0), .random(spawnchooser));
    LFSR_random #(.LFSR(43)) dirrand(.CLOCK(clk), .n(2), .rst(0), .random(directionchooser));
    
    always @(posedge fps_clock) begin //need to implement gravity
        if (reset) begin 
            for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
               yref[i] <= 0;
               falling[i] <= 0;
               y_increment[i] <= 0;
            end 
            angry = 0;
        end else if (!paused) begin      
            for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
                falling[i] <= (is_falling[i]) ? falling[i] + 1 : 0; // falling counter will count continuously, will reset when y is stationary   
                if (healths[i] == 0) begin 
                    yref[i] <= 0;
                    resettedy[i] <= 1;
                    angry[i] <= 0;
                end else if (yref[i] >= 103) begin //fall into pit 
                    is_falling[i] = 0;
                    yref[i] <= 0;
                    angry[i] <= 1; 
                end else begin 
                    resettedy[i] <= 0;
                    is_falling[i] = 1;
                    y_increment[i] = (falling[i] < 64) ? 1 + falling[i] / 3 : y_increment[i]; 
                    for (j = 0; j <= NUM_PLATFORMS && is_falling[i]; j++) begin 
                        //obstacle
                        if ((xref[i] <= x_obs[j] + platform_width[j]) &&  (xref[i] + size >= x_obs[j]) && (yref[i] + size == y_obs[j])) begin 
                            is_falling[i] = 0;
                            y_increment[i] = 0;
                        //slowing down
                        end else if ((xref[i] <= x_obs[j] + platform_width[j]) &&  (xref[i] + size >= x_obs[j]) && 
                            yref[i] + size + y_increment[i] >= y_obs[j] &&  yref[i] < y_obs[j])  begin
                            y_increment[i] = 1;
                        end 
                    end                 
                    yref[i] <= yref[i] + y_increment[i];
               end 
            end  
       end
    end   
    
    always @(posedge normalhz) begin 
        if (reset) begin 
            for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
                xref[i] <= 15;  // spawn location
            end
            x_inc = 1;
        end else if (!paused) begin
            for (i = 0; i <= MAX_NUM_ENEMIES; i = i + 1) begin
                if (healths[i] == 0) begin //reset xy if dead
                    xref[i] <= (spawnchooser) ? spawn1 : spawn2; 
                    direction[i] <= (directionchooser) ? 0 : 1;
                    resettedx[i] <= 1;
                end else if (yref[i] >= 64) begin  //fall into pit 
                    xref[i] <= (spawnchooser) ? spawn1 : spawn2; 
                    direction[i] <= (directionchooser) ? 0 : 1;
                end else begin //normal move left and right
                    resettedx[i] <= 0;
                    if (xref[i] >= 95 - size) begin
                        direction[i] = 0;
                    end else if (xref[i] <= 1) begin
                        direction[i] = 1;
                    end
                    x_inc = (angry[i]) ? 2 : 1;
                    if (direction[i] == 1) begin
                        xref[i] <= xref[i] + x_inc;
                    end else begin 
                        xref[i] <= xref[i] - x_inc;
                    end
                end 
            end
        end
    end 
    

endmodule
