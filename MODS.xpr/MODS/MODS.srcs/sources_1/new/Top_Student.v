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


module Top_Student (
input BASYS_CLOCK, input btnC, btnU, 
output [7:0]JC,
inout PS2Clk, inout PS2Data
);      
    wire clk6p25m; wire clk1; wire clk30; wire clk50;
    wire [15:0] oled_data; // 5b: R, 6b: G, 5b: B
    wire fb; wire [12:0] p_index; wire send_p; wire sample_p;
    
    //clocks
    flexible_clk sixp25MHzclk (.m(7), .in_clk(BASYS_CLOCK), .clk(clk6p25m));
    flexible_clk oneHzclk (.m(49_999_999), .in_clk(BASYS_CLOCK), .clk(clk1));
    flexible_clk thirtyHzclk (.m(1_666_665), .in_clk(BASYS_CLOCK), .clk(clk30));
    flexible_clk fiftyHzclk (.m(999_999), .in_clk(BASYS_CLOCK), .clk(clk50));
    
    //Display, Mouse
    Oled_Display oled (.clk(clk6p25m), .pixel_data(oled_data), .reset(0), 
    .frame_begin(fb), .pixel_index(p_index), .sending_pixels(send_p), .sample_pixel(sample_p),
    .cs(JC[0]), .sdin(JC[1]), .sclk(JC[3]), .d_cn(JC[4]), .resn(JC[5]), .vccen(JC[6]), .pmoden(JC[7]));
//    MouseCtl mouse(.clk (BASYS_CLOCK), .ps2_clk(PS2Clk), .ps2_data(PS2data), 
//    .value(23), .setx(50), .sety(50), .setmax_x(95), .setmax_y(63));

    //custom
    draw_oled ddd (.clk(BASYS_CLOCK), .pixel_index(p_index), .oled_data(oled_data), .btnC(btnC), .btnU(btnU),
    .onehz(clk1), .thirtyhz(clk30), .fiftyhz(clk50));
endmodule

module draw_oled(input clk, input [12:0] pixel_index, output reg [15:0] oled_data,
    input btnC, input btnU,
    input onehz, input thirtyhz, input fiftyhz);
    
    parameter BLACK_TOP = 14; 
    parameter BLACK_BOTTOM = 49;
    parameter SQUARE_SIZE = 14;
    
    wire [7:0] x; wire [7:0]y; wire [15:0] else_colour;  wire [15:0]first_colour;
    reg green_first; reg start; reg [2:0]state; reg waiting; reg [1:0] wait_count; wire draw_first;
    reg increment; wire wait_done; 
    reg [7:0] x_green; reg [7:0] y_green; reg [7:0] x_red; reg [7:0]y_red; reg [7:0]in_var; 
    wire [15:0] red; wire [15:0] green; wire [15:0] black;  
    wire[7:0]outxgreen; wire[7:0]outygreen; wire[7:0]outxred; wire[7:0]outyred; wire counter_clk;
    wire green_L; wire red_L; 
    
    assign red = 16'hF800; assign green = 16'h07E0; assign black = 0;
    assign x = pixel_index % 96;
    assign  y = pixel_index / 96;    
    
    assign draw_first = green_first ? green_L : red_L;
    assign first_colour = green_first ? green : ((start) ? black : red);
    assign else_colour = start ?  black : (green_first ? red : green);
    assign green_L = ((x <= x_green) && (y <= y_green));
    assign red_L = ((x <= x_red) && (y >= y_red));  
    
    assign counter_clk = (state <= 3) ? thirtyhz : fiftyhz;

    count_wait w (.enable(waiting), .clk(onehz), .wait_done(wait_done));
    incrementer greenx (.enable(!waiting && (state == 1 || state == 6)), .increment(increment), .clk(counter_clk), .in_var(x_green), .out_var(outxgreen));
    incrementer greeny (.enable(!waiting && state == 2), .increment(increment), .clk(counter_clk), .in_var(y_green), .out_var(outygreen));
    incrementer redx (.enable(!waiting && (state == 3 || state == 4)), .increment(increment), .clk(counter_clk), .in_var(x_red), .out_var(outxred));
    incrementer redy (.enable(!waiting && state == 5),  .increment(increment), .clk(counter_clk), .in_var(y_red), .out_var(outyred));
    
    initial begin 
        state = 0; //stop, green right, green down, red right, red up 
        x_green = SQUARE_SIZE; // x right
        y_green = BLACK_TOP; // y bottom
        x_red = 95;  // x right
        y_red = BLACK_BOTTOM; // y top 
        wait_count = 0;
        waiting = 0;
        start = 1;
        oled_data = 0;
        green_first = 1;
        increment = 1;
        in_var = x_green;
    end
    
    always @(posedge clk) begin 
       if (waiting) begin 
        if (wait_done) begin 
            waiting <= 0;
        end
       end 
 
       else begin
            if (state == 0) begin
                x_green <= 14;
                y_green <= 14;
                green_first <= 1;
                if (btnC) begin //wait for btnC press
                    state <= 1;
                end
            end 
            else if (state == 1) begin // green move right
                increment <= 1;
                if (x_green == 95) begin 
                    state <= 2;
                    waiting <= 1;
                end 
                else begin
                    x_green <= outxgreen;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                end
            end else if (state == 2) begin // green move down
                if (y_green == 63) begin 
                    state <= 3;
                    waiting <= 1;
                    green_first <= 0;
                end else begin        
                    y_green <= outygreen; //y_green + 1               
                end
            // red first ------------------------------------------------------------------
            end else if (state == 3) begin // green move left 
                increment <= 0;
                if (x_red == 0) begin 
                    state <= 7;
                    waiting <= 1;
                    x_red <= 14; //red square appear
                    y_red <= BLACK_BOTTOM;
                    y_green <= BLACK_BOTTOM;
                    start <= 0;
                end else begin  
                    x_red <= outxred; // x_red - 1 
                end
            end else if (state == 7 && btnU) begin // wait for user press btnU
                state <= 4;       
            end else if (state == 4) begin // red move right
                increment <= 1;
                if (x_red == 95) begin 
                    state <= 5;
                end else begin  
                    x_red <= outxred; //x_red + 1
                end
            end else if (state == 5) begin // red move up
                increment <= 0;
                if (y_red == 0) begin 
                    state <= 6;
                    y_green <= 14;
                end else begin  
                    y_red <=  outyred; //y_red - 1
                end
            end else if (state == 6) begin // red move left
                if (x_green == 0) begin 
                    state <= 0;
                end else begin
                   x_green <=  outxgreen; //x_green - 1
                end 
            end 
       end 
    end
    
    
    always @(posedge clk) begin 
        if ((x<=80) && (y >= 15 && y <= 48)) begin //Black Rectangle
            oled_data <= 0;
        end
        
        else if (draw_first) begin 
            oled_data <= first_colour;
        end
        else begin 
            oled_data <= else_colour;
//              oled_data <= 16'h07E0;
        end
    end 
    

endmodule 


module incrementer (input enable, input increment, input clk, input [7:0]in_var, output reg [7:0]out_var);
    always @(posedge clk) begin
        if (enable) begin 
            out_var <= (increment) ? in_var + 1 : in_var - 1;
        end
    end
endmodule

module count_wait (input enable, input clk, output reg wait_done);
    reg [1:0]wait_count = 0;
    always @(posedge clk) begin 
        if (enable) begin 
            wait_count <= wait_count + 1;
            wait_done <= (wait_count == 2) ? 1 : 0;
        end else begin 
            wait_count <= 0;
            wait_done <= 0;
        end
    end 
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