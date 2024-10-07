`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2024 12:27:47 AM
// Design Name: 
// Module Name: main
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


module main(
    input CLOCK,
    input [15:0] sw,
    output reg [15:0] led,
    output reg [6:0] seg,
    output reg [3:0] an,
    input btnC, btnL, btnR, btnU, btnD,
    output [7:0] JB
    );
    
    wire clk1000, clk2, clk10, clk5, clk6, clk625;
    
    flexible_clock clk1000hz (CLOCK, 49_999, clk1000);
    flexible_clock clk2hz (CLOCK, 24_999_999, clk2);
    flexible_clock clk10hz (CLOCK, 4_999_999, clk10);
    flexible_clock clk5hz (CLOCK, 9_999_999, clk5);
    flexible_clock clk6hz (CLOCK, 8_333_332, clk6);
    
    wire sending_pixels;
    wire sample_pixel;
    wire frame_begin;
    wire [12:0] pixel_index;
    reg [15:0] oled_data;
    
    wire [15:0] oled_data1;
    wire [15:0] oled_data2;
    wire [15:0] oled_data3;
    wire [15:0] oled_data4;
    
    reg seg_state = 0;
    reg activity_state = 0;
    
    Oled_Display display (.clk(clk625), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
     .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), 
     .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]));
           
    
    Top_Student sk (CLOCK, sw[4], btnC, btnU, pixel_index, oled_data1); 
    task4B tim (CLOCK, btnC, btnU, btnD, pixel_index, oled_data2); 
    task4C claire (CLOCK, btnC, btnU, pixel_index, oled_data3); 
    task4D kashfy (CLOCK, btnC, btnL, btnR, btnD, btnU, sw[4:0], pixel_index, oled_data4); 

    flexible_clock clk6p25m (CLOCK, 7, clk625);
    
   
    always @ (posedge CLOCK) 
    begin
        led[15:0] <= sw[15:0];
        
        if (sw == 16'b0001_0001_1000_1111)
        begin
        // SK
            led[0] <= clk2;
            led[1] <= clk2;
            led[2] <= clk2;
            led[3] <= clk2;
            led[7] <= clk2;
            led[8] <= clk2;
            
            oled_data <= oled_data1;
            activity_state <= 1;
        
        end else if (sw == 16'b0010_0010_1001_0111)
        begin
        // Timo
            led[0] <= clk10;
            led[1] <= clk10;
            led[2] <= clk10;
            led[4] <= clk10;
            led[7] <= clk10;
            led[9] <= clk10;
            
            oled_data <= oled_data2;
            activity_state <= 1;

        end else if (sw == 16'b0100_0001_0001_0101)
        begin
        // Claire
            led[0] <= clk5;
            led[2] <= clk5;
            led[4] <= clk5;
            led[8] <= clk5;
            
            oled_data <= oled_data3;
            activity_state <= 1;
            
        end else if (sw == 16'b1000_0000_1011_0101)
        begin
        // Kashfy
            led[0] <= clk6;
            led[2] <= clk6;
            led[4] <= clk6;
            led[5] <= clk6;
            led[7] <= clk6;
            
            oled_data <= oled_data4;
            activity_state <= 1;
            
        end else begin
            oled_data <= 16'b0000000000000000;
            activity_state <= 0;
        end
    end
    
    always @ (posedge clk1000)
    begin
    // no task going on; display group number which idk lmao
        if (activity_state == 0) begin
            if (seg_state == 0) begin
                an <= 4'b1101;
                seg <= 7'b1000000;  
                seg_state <= 1;             
            end else if (seg_state == 1) begin
                an <= 4'b1110;
                seg <= 7'b0011001;
                seg_state <= 0;
            end
        end else begin
            an <= 4'b1111;
            seg <= 7'b1111111;
        end    
    end
    
endmodule
