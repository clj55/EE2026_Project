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
    input clock,
    input btnc, btnu, btnd, 
    output [7:0] jb
    );
   
    // variables
    wire frame_begin;
    wire [12:0] pixel_index;
    wire sending_pixels;
    wire sample_pixel;
    wire [15:0] oled_data;
    wire slowclock6p25m; 
    
    // oled   
    flexy_clock clk6p25m (.clock(clock), .number(7), .slowclock(slowclock6p25m));     
    Oled_Display oleddisp (
        .clk(slowclock6p25m), 
        .reset(0), // ground
        .frame_begin(frame_begin), 
        .sending_pixels(sending_pixels),
        .sample_pixel(sample_pixel), 
        .pixel_index(pixel_index), 
        .pixel_data(oled_data),
        .cs(jb[0]), 
        .sdin(jb[1]), 
        .sclk(jb[3]), 
        .d_cn(jb[4]), 
        .resn(jb[5]), 
        .vccen(jb[6]),
        .pmoden(jb[7]) 
        );    
    
    // task b
    taskb b(
        .pixel_index(pixel_index), 
        .btnc(btnc), .btnu(btnu), .btnd(btnd),
        .clock(clock), .pixel_data(oled_data)
        );
    
endmodule

module flexy_clock(
    input clock,
    input [31:0] number,
    output reg slowclock = 0
    );
    reg [31:0] count = 0;
    always @ (posedge clock) begin
        count <= (count == number) ? 0 : count + 1;
        slowclock <= (count == 0) ? ~slowclock : slowclock;
    end
endmodule

module taskb(
    input [12:0] pixel_index,
    input btnc, btnu, btnd, 
    input clock,
    output reg [15:0] pixel_data
    );
    wire [6:0] x;
    wire [5:0] y;
    convert conv (.pixel_index(pixel_index), .x(x), .y(y));
    wire slowclock1k;
       
    //clock
    flexy_clock clk1k (.clock(clock), .number(49999), .slowclock(slowclock1k));
    
    reg [31:0] count = 0;
    reg [1:0] btncstate = 0;
    reg [1:0] btnustate = 0;
    reg [1:0] btndstate = 0;
    reg btncpress = 0;
    reg btnupress = 0;
    reg btndpress = 0;

    always @ (posedge slowclock1k) begin
        if ((btnc || btnu || btnd) && count == 0) count <= 1;
        count <= ((count > 0) && (count < 200)) ? count + 1 : count;
        if (count == 200) begin
            if (!btnc && !btnu && !btnd) begin
                count <= 0;          
            end
        end 
    end
    
    always @ (posedge clock) begin
        if (count == 200) begin
            if (btnc == 1 && btncpress == 0) begin
                btncstate <= (btncstate == 3) ? 0 : btncstate + 1;
                btncpress <= 1;
            end
            if (btnu == 1 && btnupress == 0) begin
                btnustate <= (btnustate == 3) ? 0 : btnustate + 1;
                btnupress <= 1;
            end
            if (btnd == 1 && btndpress == 0) begin
                btndstate <= (btndstate == 3) ? 0 : btndstate + 1;
                btndpress <= 1;
            end
            if (!btnc && !btnu && !btnd) begin     
                btncpress <= 0;
                btnupress <= 0;
                btndpress <= 0;      
            end
        end   
        if (x>=43 && x<=52) begin
            if (y>=6 && y<=15) begin
                case (btnustate)
                    0: pixel_data <= 16'b11111_111111_11111;
                    1: pixel_data <= 16'b11111_000000_00000;
                    2: pixel_data <= 16'b00000_111111_00000;
                    3: pixel_data <= 16'b00000_000000_11111;
                endcase
            end
            else if (y>=20 && y<=29) begin
                case (btncstate)
                    0: pixel_data <= 16'b11111_111111_11111;
                    1: pixel_data <= 16'b11111_000000_00000;
                    2: pixel_data <= 16'b00000_111111_00000;
                    3: pixel_data <= 16'b00000_000000_11111;
                endcase
            end
            else if (y>=34 && y<=43) begin
                case (btndstate)
                    0: pixel_data <= 16'b11111_111111_11111;
                    1: pixel_data <= 16'b11111_000000_00000;
                    2: pixel_data <= 16'b00000_111111_00000;
                    3: pixel_data <= 16'b00000_000000_11111;
                endcase
            end
            else if (y>=48 && y<=57) begin
                if (btncstate == 2 && btndstate == 2 && btnustate == 2) begin
                    pixel_data <= 16'b11111_000000_00000;
                end else pixel_data <= 16'b11111_111111_11111;
            end else pixel_data <= 0;
        end else pixel_data <= 0;
    end
    
endmodule   

module convert(
    input [12:0] pixel_index,
    output [6:0] x, [5:0] y
    );
    assign x = pixel_index % 96;
    assign y = pixel_index / 96;
endmodule