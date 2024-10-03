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
    input CLOCK,
    input sw4,
    input btnC, btnU,
    output [7:0] JB
);

    reg [15:0] oled_data = 0;
    wire clk625, clk1000;
    wire frame_begin;
    wire sending_pixels;
    wire sample_pixel;
    wire [12:0] pixel_index;    
    wire [7:0] x, y;
    reg btnU_pressed = 0;
    reg [4:0] state = 0;
    
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
    
    always @ (posedge CLOCK) 
    begin 

        if (state == 0) 
        begin
            if (~btnU_pressed)
            begin
                oled_data <= 16'b0000000000000000;
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // orange circle middle
                begin
                    oled_data <= 16'b1111110000000000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 1) 
        begin
            if (~btnU_pressed)
            begin
                if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // green circle inside
                begin
                    oled_data <= 16'b0000011111100000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // orange circle middle
                begin
                    oled_data <= 16'b1111110000000000;
                end else if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // green circle inside
                begin
                    oled_data <= 16'b0000011111100000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 2)
        begin 
            if (~btnU_pressed)
            begin
                if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // orange circle inside
                begin
                    oled_data <= 16'b1111110000000000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // orange circle middle
                begin
                    oled_data <= 16'b1111110000000000;
                end else if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // orange circle inside
                begin
                    oled_data <= 16'b1111110000000000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 3) 
        begin 
            if (~btnU_pressed)
            begin
                if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // red circle inside
                begin
                    oled_data <= 16'b1111100000000000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // orange circle middle
                begin
                    oled_data <= 16'b1111110000000000;
                end else if ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 4 * 4) 
                // red circle inside
                begin
                    oled_data <= 16'b1111100000000000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 4) 
        begin 
            if (~btnU_pressed)
            begin
                if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // green square inside
                begin
                    oled_data <= 16'b0000011111100000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // white circle middle
                begin
                    oled_data <= 16'b1111111111111111;
                end else if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // green square inside
                begin
                    oled_data <= 16'b0000011111100000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 5) 
        begin 
            if (~btnU_pressed)
            begin
                if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // orange square inside
                begin
                    oled_data <= 16'b1111110000000000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // white circle middle
                begin
                    oled_data <= 16'b1111111111111111;
                end else if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // orange square inside
                begin
                    oled_data <= 16'b1111110000000000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end else if (state == 6) 
        begin 
            if (~btnU_pressed)
            begin
                if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // red square inside
                begin
                    oled_data <= 16'b1111100000000000;
                end else 
                begin
                    oled_data <= 16'b0000000000000000;
                end
            end else
            begin
                if (((x - 48) * (x - 48) + (y - 32) * (y - 32) >= 15 * 15) && ((x - 48) * (x - 48) + (y - 32) * (y - 32) <= 18 * 18))
                // white circle middle
                begin
                    oled_data <= 16'b1111111111111111;
                end else if (x >= 44 && x <= 52 && y >= 28 && y <= 36)
                // red square inside
                begin
                    oled_data <= 16'b1111100000000000;
                end else begin
                    oled_data <= 16'b0000000000000000;
                end
            end
        end
        
        if ((x >= 2 && x <= 93 && y >= 2 && y <= 61) && ~(x >= 4 && x <= 91 && y >= 4 && y <= 59)) 
        // red rectangle outside
        begin
            oled_data <= 16'b1111100000000000;
        end
    end
    
    flexible_clock clk1000hz (CLOCK, 49_999, clk1000);
    reg [31:0] counter = 0;
    
    always @ (posedge clk1000)
    begin
        if (counter != 32'hFFFFFFFF) counter <= counter + 1;
        // if counter >= 5000, and buttons are not pressed
        
        if (counter >= 200 && (btnC || btnU))
        begin
            if (btnU) btnU_pressed = 1;
        
            // state == 0 -> no green solid circle
            if (btnC && state == 0) state <= 1; // green solid circle
            else if (btnC && state == 1) state <= 2; // orange solid circle
            else if (btnC && state == 2) state <= 3; // red solid circle
            else if (btnC && state == 3) state <= 4; // green solid square
            else if (btnC && state == 4) state <= 5; // orange solid sqaure
            else if (btnC && state == 5) state <= 6; // red solid square
            else if (btnC && state == 6) state <= 1; // restart; green solid circle
        end 
        
        if (btnU || btnC) counter <= 0;
    end
    
    flexible_clock clk6p25m (CLOCK, 7, clk625);
            
    Oled_Display display (.clk(clk625), .reset(0), .frame_begin(frame_begin), .sending_pixels(sending_pixels),
  .sample_pixel(sample_pixel), .pixel_index(pixel_index), .pixel_data(oled_data), .cs(JB[0]), .sdin(JB[1]), 
  .sclk(JB[3]), .d_cn(JB[4]), .resn(JB[5]), .vccen(JB[6]), .pmoden(JB[7]));

endmodule