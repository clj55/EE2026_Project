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


module projectile_main #(parameter MAX_PROJ = 5, MAX_ENEMIES = 15, ENEMY_SIZE = 8, 
NUM_PLATFORMS = 3)
(input clk, input btnD, input reset, input fps_clock, input paused,
input [6:0]char_x, [6:0]char_y, [6:0]char_xvect, 
[6:0] char_width, [6:0]char_height, [2:0]proj_type,
 input [6:0]platform_x[0:NUM_PLATFORMS], [6:0]platform_y[0:NUM_PLATFORMS], 
 [6:0]platform_h[0:NUM_PLATFORMS], [6:0]platform_w[0:NUM_PLATFORMS],
 input [6:0] enemy_x[0:MAX_ENEMIES], input [6:0] enemy_y [0:MAX_ENEMIES], 
 output reg [6:0] proj_x [0:MAX_PROJ], output reg [6:0] proj_y [0:MAX_PROJ], 
 output reg [6:0] proj_h, output reg [6:0] proj_w, output reg [MAX_PROJ:0]active,
 output reg [2:0] proj_d, output reg [MAX_ENEMIES:0] enemy_hit
    );
    parameter lasercountmax = 20;
    
    reg [MAX_ENEMIES:0] enemy_hitbfr[0:MAX_PROJ];
    integer cooldowncount; integer cooldown; 
    reg [31:0] lasercount; reg [3:0]mine_i; reg [MAX_PROJ:0]setmine; wire mine_setted;
    integer i; integer j; integer k;
    
    initial begin
        proj_h = 3; proj_d = 1; proj_w = 3;
        active = 0;
        enemy_hit = 0;
        i = 0; j = 0; k = 0;
        for (i = 0; i <= MAX_PROJ; i++) begin 
            enemy_hitbfr[i] = 0;
            proj_x[i] = 127; 
            proj_y[i] = 0;
        end 
        cooldown = 0; cooldowncount = 0;
        lasercount = 0; 
        mine_i = 0; setmine = 0;
        // wah i think its dropping so fast it cannot take damage fast enough LOL
    end
    
    always @(posedge clk) begin 
        enemy_hit <= 0; 
        cooldowncount = (cooldowncount == cooldown) ? cooldown : cooldowncount + 1;
        if (reset) begin //reset if game reset or character changes so in top level do (game reset || touchmuff)
            active = 0;
            mine_i = 0; setmine = 0;
            cooldowncount = cooldown;
            for (i = 0; i <= MAX_PROJ; i++) begin
                enemy_hitbfr[i] = 0;
            end
        end
        if (!paused) begin
            if (proj_type <= 2) begin // math/med/biz
                for (i = 0; i <= MAX_PROJ; i++) begin
                    if (!active[i]) begin
                       if (btnD && cooldowncount == cooldown) begin //activate when attack button press, debounces also 
                           active[i] = 1;
                           if (proj_type == 1) begin //dualshot
                                active[MAX_PROJ - i] = 1;
                           end
                           cooldowncount = 0;
                        end
                    end else begin
                        //out of screen except upper bound 
                        if (proj_x[i] == 0 ||  //left bound of screen
                        proj_x[i] + proj_w - 1 == 95 //right bound of screen
                        || (proj_y[i] >= 64 && proj_y[i] <= 90)) begin //bottom of screen 
                          active[i] = 0;
                        end
                        
                        //hit platform only check for arrows (med/math)
                        if (proj_type <= 1) begin 
                            for (k = 0; k <= NUM_PLATFORMS && active[i]; k++) begin 
                                if (proj_x[i] + proj_w == platform_x[k] && (proj_y[i] + proj_h > platform_y[k]
                                && proj_y[i] < platform_y[k] + proj_h)) begin //left of platform 
                                  active[i] = 0;
                                end else if (proj_x[i] == platform_x[k] + platform_w[k] 
                                && (proj_y[i] + proj_h > platform_y[k] && proj_y[i] < platform_y[k] + platform_h[k])) begin 
                                  active[i] = 0;
                                end
                            end 
                        end
                        
                        // hit enemy 
                        for (j = 0; j <= MAX_ENEMIES && active[i]; j++) begin //stop when deactivated
                            if (enemy_x[j] + ENEMY_SIZE >= proj_x[i] && enemy_x[j] <= proj_x[i] + proj_w  
                            && enemy_y[j] + ENEMY_SIZE >= proj_y[i] && enemy_y[j] <= proj_y[i] + proj_h) begin 
                                enemy_hit[j] <= 1;
                                active[i] = 0;
                            end
                        end                    
                    end
                end 
            end else if (proj_type == 3) begin  //laser (only one at a time
                if (active == 0) begin //reset enemyhits if not active
                    enemy_hitbfr[0] <= 0;
                    if (btnD && cooldowncount == cooldown) begin //activate when attack button press
                        active = 1; //0th index
                        cooldowncount = 0;
                        lasercount = 0;
                    end 
                end else begin //active only uses 0th index 
                    lasercount = lasercount + 1;
                    if (lasercount == lasercountmax) begin 
                        active = 0;
                    end 
                    for (j = 0; j <= MAX_ENEMIES; j++) begin 
                        if (enemy_x[j] + ENEMY_SIZE >= proj_x[0] && enemy_x[j] <= proj_x[0] + proj_w  //need to change this 
                        && enemy_y[j] + ENEMY_SIZE >= proj_y[0] && enemy_y[j] <= proj_y[0] + proj_h) begin 
                            if (!enemy_hitbfr[0][j]) begin //enemy hasnt been hit by that mine/laser
                                enemy_hitbfr[0][j] <= 1;
                                enemy_hit[j] <= 1;
                            end
                        end
                    end
                end
            end else begin //poison bottle
                if (mine_setted) begin
                    setmine = 0;
                end
    
                if (btnD && cooldowncount == cooldown) begin //reset enemyhits if new mine placed
                    for (integer l = 0; l <= MAX_PROJ && active[mine_i]; l++) begin 
                        mine_i = (mine_i == MAX_PROJ) ? 0 : mine_i + 1;
                    end 
                    active[mine_i] = 1;
                    cooldowncount = 0;
                    setmine[mine_i] = 1; //trigger poison module to reset location of poison
                end 
                    
                for (i= 0; i <= MAX_PROJ; i++) begin 
                    if (active[i]) begin
                        for (j = 0; j <= MAX_ENEMIES && active[i]; j++) begin //stop when deactivated
                            if (enemy_x[j] + ENEMY_SIZE >= proj_x[i] && enemy_x[j] <= proj_x[i] + proj_w  
                            && enemy_y[j] + ENEMY_SIZE >= proj_y[i] && enemy_y[j] <= proj_y[i] + proj_h) begin 
                                enemy_hit[j] <= 1;
                                active[i] = 0;
                            end
                        end
                    end
                end
             end
        end 
    end
    
    wire [MAX_PROJ:0] active0 = (proj_type == 0) ? active : 0;
    wire [MAX_PROJ:0] active1 = (proj_type == 1) ? active : 0;
    wire [MAX_PROJ:0] active2 = (proj_type == 2) ? active : 0;
    wire laseractive = (proj_type == 3) ? active[0] : 0;
    wire [MAX_PROJ:0] active4 = (proj_type == 4) ? active : 0;

    wire [6:0] proj_x0 [0:MAX_PROJ]; wire [6:0] proj_y0 [0:MAX_PROJ]; wire [6:0] proj_w0; wire [6:0] proj_h0;
    wire [6:0] proj_x1 [0:MAX_PROJ]; wire [6:0] proj_y1 [0:MAX_PROJ]; wire [6:0] proj_w1; wire [6:0] proj_h1;
    wire [6:0] proj_x2 [0:MAX_PROJ]; wire [6:0] proj_y2 [0:MAX_PROJ]; wire [6:0] proj_w2; wire [6:0] proj_h2;
    wire [6:0] laser_x; wire [6:0] laser_y; wire [6:0] laser_w; wire [6:0] laser_h;
    wire [6:0] proj_x4 [0:MAX_PROJ]; wire [6:0] proj_y4 [0:MAX_PROJ]; wire [6:0] proj_w4; wire [6:0] proj_h4;
    
    always @(posedge clk) begin 
        case (proj_type) 
            0: begin 
                proj_x = proj_x0;
                proj_y = proj_y0;
                proj_w = proj_w0;
                proj_h = proj_h0;
                proj_d = 2;
                cooldown = 20; //2
//                80; // number of 0.0125s
            end
            1: begin 
                proj_x = proj_x1;
                proj_y = proj_y1;
                proj_w = proj_w1;
                proj_h = proj_h1;
                proj_d = 2;
                cooldown = 20; //2
//                80; // number of 0.0125s
            end
            2: begin 
                proj_x = proj_x2;
                proj_y = proj_y2;
                proj_w = proj_w2;
                proj_h = proj_h2;
                proj_d = 2;
                cooldown = 20; //2
//                80; // number of 0.0125s
            end
            3: begin 
                proj_x[0] = laser_x;
                proj_y[0] = laser_y;
                proj_w = laser_w;
                proj_h = laser_h;
                proj_d = 1;
                cooldown = 50; //2
//                50; // number of 0.0125s
            end
            4: begin 
                proj_x = proj_x4;
                proj_y = proj_y4;
                proj_w = proj_w4;
                proj_h = proj_h4;
                proj_d = 7;
                cooldown = 50; //2
    //                100; // number of 0.0125s
            end
        endcase
    end 
    
    single_shot #(.MAX_PROJ(MAX_PROJ)) med  (.clk(clk), .active(active0), .paused(paused),
        .char_x(char_x), .char_y(char_y), .char_xvect(char_xvect), .sq_width(char_width), .sq_height(char_height),
        .proj_x(proj_x0), .proj_y(proj_y0), .proj_w(proj_w0), .proj_h(proj_h0)
    );
    
     double_shot #(.MAX_PROJ(MAX_PROJ))math(.clk(clk), .active(active1), .paused(paused),
        .char_x(char_x), .char_y(char_y), .sq_width(char_width), .sq_height(char_height),
        .proj_x(proj_x1), .proj_y(proj_y1), .proj_w(proj_w1), .proj_h(proj_h1)
    );
    
    parab_shot #(.MAX_PROJ(MAX_PROJ)) biz (.clk(fps_clock), .active(active2), .paused(paused),
    .char_x(char_x), .char_y(char_y), .char_xvect(char_xvect), .sq_width(char_width), .sq_height(char_height),
    .proj_x(proj_x2), .proj_y(proj_y2), .proj_w(proj_w2), .proj_h(proj_h2)
    );
    
    laser ee (.clk(clk), .active(laseractive), 
        .char_x(char_x), .char_y(char_y), .char_xvect(char_xvect), .sq_width(char_width), .sq_height(char_height),
        .proj_x(laser_x), .proj_y(laser_y), .proj_w(laser_w), .proj_h(laser_h)
    );
    
    mine #(.MAX_PROJ(MAX_PROJ), .NUM_PLATFORMS(NUM_PLATFORMS)) chem (
        .clk(fps_clock), .active(active4), .setmine(setmine), .mine_setted(mine_setted),
        .platform_x(platform_x), .platform_y(platform_y), .platform_w(platform_w),
        .char_x(char_x), .char_y(char_y), .sq_width(char_width), .sq_height(char_height),
        .proj_x(proj_x4), .proj_y(proj_y4), .proj_w(proj_w4), .proj_h(proj_h4)
        );

    
    
endmodule