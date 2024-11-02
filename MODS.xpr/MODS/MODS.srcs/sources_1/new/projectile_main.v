`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.11.2024 12:44:30
// Design Name: 
// Module Name: projectile_main
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


module projectile_main #(parameter MAX_PROJ = 2, MAX_ENEMIES = 15, ENEMY_SIZE = 8)
(input clk, //input btnC, 
 input [7:0] enemy_x[0:MAX_ENEMIES], input [7:0] enemy_y [0:MAX_ENEMIES], 
 output reg [7:0] proj_x [0:MAX_PROJ], output reg [7:0] proj_y [0:MAX_PROJ], 
 output reg [2:0] proj_h, output reg [6:0] proj_w,output reg [MAX_PROJ:0]active,
 output reg [2:0] proj_d, output reg [MAX_ENEMIES:0] enemy_hit
    );
    reg [2:0] proj_type;
    reg [MAX_ENEMIES:0] enemy_hitbfr[0:MAX_PROJ];
    integer i; integer j;
    
    initial begin 
        proj_type = 0;
        proj_h = 3; proj_d = 1; proj_w = 3;
//        active = 0;
        active = 3'b111;
        enemy_hit = 0;
        i = 0; j = 0;
        for (i = 0; i <= MAX_PROJ; i++) begin 
            enemy_hitbfr[i] = 0;
//            proj_x[i] = 0; 
//            proj_y[i] = 0;
        end 
        {proj_x[0], proj_x[1], proj_x[2]} = {8'd20, 8'd20, 8'd20};
        {proj_y[0], proj_y[1], proj_y[2]} = {8'd20, 8'd35, 8'd10}; 
        // wah i think its dropping so fast it cannot take damage fast enough LOL
    end
    
    always @(posedge clk) begin //might need to change this to a slower clock 
        enemy_hit <= 0; 
        
        for (i= 0; i <= MAX_PROJ; i++) begin 
            //reset enemyhits if not active
            if (!active[i]) begin 
                enemy_hitbfr[i] <= 0;
            end else begin //active
                
                for (j = 0; j <= MAX_ENEMIES && active[i]; j++) begin //stop when deactivated
                    if (enemy_x[j] + ENEMY_SIZE >= proj_x[i] && enemy_x[j] <= proj_x[i] + proj_w  //need to change this 
                    && enemy_y[j] + ENEMY_SIZE >= proj_y[i] && enemy_y[j] <= proj_y[i] + proj_h) begin 
                        if (proj_type <= 2) begin // math/med/biz
                            enemy_hit[j] <= 1;
                            active[i] = 0;
                        end else if (!enemy_hitbfr[i][j]) begin //enemy hasnt been hit by that mine/laser
                            enemy_hitbfr[i][j] <= 1;
                            enemy_hit[j] <= 1;
                        end
                    end
                end
           end 
        end 
    end
endmodule
