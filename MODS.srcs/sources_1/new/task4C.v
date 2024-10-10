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


module task4C (
input BASYS_CLOCK, input btnC, btnU, 
input [12:0] p_index,
output wire [15:0] oled_data, 
input enable
);      
    wire clk1; wire clk30; wire clk50;
        
    //clocks
    flexible_clk oneHzclk (.m(49_999_999), .in_clk(BASYS_CLOCK), .clk(clk1));
    flexible_clk thirtyHzclk (.m(1_666_665), .in_clk(BASYS_CLOCK), .clk(clk30));
    flexible_clk fiftyHzclk (.m(999_999), .in_clk(BASYS_CLOCK), .clk(clk50));
    
    draw_oled ddd (.clk(BASYS_CLOCK), .pixel_index(p_index), .oled_data(oled_data), .btnC(btnC), .btnU(btnU),
    .onehz(clk1), .thirtyhz(clk30), .fiftyhz(clk50), .enable(enable));
endmodule

module draw_oled(input clk, input [12:0] pixel_index, output reg [15:0] oled_data,
    input btnC, input btnU, input enable,
    input onehz, input thirtyhz, input fiftyhz);
    
    parameter BLACK_TOP = 15; 
    parameter BLACK_BOTTOM = 49;
    parameter BLACK_SIDE = 80;
    parameter SQUARE_SIZE = 15;
    parameter MAX_X = 96;
    parameter MAX_Y = 64;
        
    wire [7:0] x; wire [7:0]y; wire [15:0] else_colour;  wire [15:0]first_colour;
    wire green_first; reg start; reg [2:0]state; reg waiting; reg [1:0] wait_count; wire draw_first;
    reg increment; wire wait_done; 
    reg [7:0] x_green; reg [7:0] y_green; reg [7:0] x_red; reg [7:0]y_red; reg [7:0]in_var; 
    wire [15:0] red; wire [15:0] green; wire [15:0] black;  
    wire[7:0]outxgreen; wire[7:0]outygreen; wire[7:0]outxred; wire[7:0]outyred; wire counter_clk;
    wire green_L; wire red_L; 
    
    assign red = 16'hF800; assign green = 16'h07E0; assign black = 0;
    assign x = pixel_index % 96;
    assign  y = pixel_index / 96;    
    assign green_first = (state <= 2 || state == 7) ? 1 : 0;
    
    assign draw_first = green_first ? green_L : red_L; //switch when hit bottom right before wait 
    assign first_colour = green_first ? green : (start ? black : red); //black when bottom right 
    assign else_colour = green_first ?  (start ? black : red) : green;
    assign green_L = (x < x_green) && ((y < BLACK_TOP) || (x > BLACK_SIDE  && y < y_green));
    assign red_L = (x < x_red) && (y > BLACK_BOTTOM || (x > BLACK_SIDE && y > y_red));  
    
    assign counter_clk = (state <= 3) ? thirtyhz : fiftyhz;

    count_wait w (.enable(waiting), .clk(onehz), .wait_done(wait_done));
    incrementer greenx (.enable(!waiting && (state == 1 || state == 7)), .increment(increment), .clk(counter_clk), .in_var(x_green), .out_var(outxgreen));
    incrementer greeny (.enable(!waiting && state == 2), .increment(increment), .clk(counter_clk), .in_var(y_green), .out_var(outygreen));
    incrementer redx (.enable(!waiting && (state == 3 || state == 5)), .increment(increment), .clk(counter_clk), .in_var(x_red), .out_var(outxred));
    incrementer redy (.enable(!waiting && state == 6),  .increment(increment), .clk(counter_clk), .in_var(y_red), .out_var(outyred));
    
    initial begin 
        state = 0; //stop, green right, green down, red right, red up 
        x_green = SQUARE_SIZE; // x right
        y_green = BLACK_TOP; // y bottom
        x_red = BLACK_SIDE;  // x right
        y_red = BLACK_BOTTOM; // y top 
        wait_count = 0;
        waiting = 0;
        start = 1;
        oled_data = 0;
        increment = 1;
        in_var = x_green;
    end
    
    always @(posedge clk) begin 
       if (enable) begin
           if (waiting) begin 
            if (wait_done) begin 
                waiting <= 0;
            end
           end 
     
           else begin
                if (state == 0) begin
                    x_green <= SQUARE_SIZE;
                    y_green <= SQUARE_SIZE;
                    if (btnC) begin //wait for btnC press
                        state <= 1;
                    end
                end 
                else if (state == 1) begin // green move right
                    increment <= 1;
                    if (x_green == MAX_X) begin 
                        state <= 2;
                        waiting <= 1;
                    end 
                    else begin
                        x_green <= outxgreen;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
                    end
                end else if (state == 2) begin // green move down
                    if (y_green == MAX_Y) begin 
                        state <= 3;
                        waiting <= 1;
                        y_red <= BLACK_BOTTOM;
                        x_red <= BLACK_SIDE + 1;
                    end else begin        
                        y_green <= outygreen; //y_green + 1               
                    end
                // red first ------------------------------------------------------------------
                end else if (state == 3) begin // green move left 
                    increment <= 0;
                    if (x_red == 0) begin 
                        start <= 0;
                        state <= 4;
                        waiting <= 1;
                    end else begin  
                        x_red <= outxred; // x_red - 1 
                    end
                end else if (state == 4) begin // wait for user press btnU                  
                    x_red <= SQUARE_SIZE; //red square appear  
                    y_green <= BLACK_BOTTOM;
                    if (btnU) begin 
                        state <= 5;
                    end
                end else if (state == 5) begin // red move right
                    increment <= 1;
                    if (x_red == MAX_X) begin 
                        state <= 6;
                    end else begin  
                        x_red <= outxred; //x_red + 1
                    end
                end else if (state == 6) begin // red move up
                    increment <= 0;
                    y_green <= SQUARE_SIZE; //reset y_green
                    x_green <= BLACK_SIDE; // reset x_green
                    if (y_red == 0) begin 
                        state <= 7;
                    end else begin  
                        y_red <=  outyred; //y_red - 1
                    end
                // green first ------------------------------------------
                end else if (state == 7) begin // red move left
                    increment <= 0;
                    if (x_green == 0) begin 
                        state <= 0;
                    end else begin
                       x_green <=  outxgreen; //x_green - 1
                    end 
                end 
           end 
        
            if ((x <= BLACK_SIDE) && (y >= BLACK_TOP && y <= BLACK_BOTTOM)) begin //Black Rectangle
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
    
        else begin 
            state <= 0; //stop, green right, green down, red right, red up 
            x_green <= SQUARE_SIZE; // x right
            y_green <= BLACK_TOP; // y bottom
            x_red <= BLACK_SIDE;  // x right
            y_red <= BLACK_BOTTOM; // y top 
            wait_count <= 0;
            waiting <= 0;
            start <= 1;
            oled_data <= 0;
            increment <= 1;
            in_var = SQUARE_SIZE;
        end 
    end
    

endmodule 


module incrementer (input enable, input increment, input clk, input [7:0]in_var, output reg [7:0]out_var);
    always @(posedge clk) begin
        if (enable) begin 
            out_var <= (increment) ? in_var + 1 : in_var - 1;
        end else begin 
            out_var <= in_var;
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