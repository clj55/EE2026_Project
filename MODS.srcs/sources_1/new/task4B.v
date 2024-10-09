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


module task4B (
    input clock,
    input btnc, btnu, btnd, 
    input [12:0] pixel_index,
    input reset,
    output wire [15:0] oled_data
    );
    
    // task b
    taskb b(
        .pixel_index(pixel_index), 
        .btnc(btnc), .btnu(btnu), .btnd(btnd),
        .clock(clock), .reset(reset), .pixel_data(oled_data)
        );
    
endmodule

module taskb(
    input [12:0] pixel_index,
    input btnc, btnu, btnd, 
    input clock, reset,
    output reg [15:0] pixel_data
    );
    wire [6:0] x;
    wire [5:0] y;
    convert conv (.pixel_index(pixel_index), .x(x), .y(y));
    wire slowclock1k;
       
    //clock
    flexible_clock clk1k (.CLOCK(clock), .m(49999), .reg_clock(slowclock1k));
    
    reg [31:0] count = 0;
    reg [1:0] btncstate = 0;
    reg [1:0] btnustate = 0;
    reg [1:0] btndstate = 0;
    reg btncpress = 0;
    reg btnupress = 0;
    reg btndpress = 0;

    always @ (posedge slowclock1k) begin
        count <= (count != 32'hFFFFFFFF) ? count + 1 : count;
        if (count >= 200) begin
            if (btnc || btnu || btnd) begin
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
            end
            if (btnc == 0 && btncpress == 1) begin
                btncpress <= 0;
                count = 0;
            end
            if (btnu == 0 && btnupress == 1) begin
                btnupress <= 0;
                count = 0;
            end
            if (btnd == 0 && btndpress == 1) begin
                btndpress <= 0;
                count = 0;
            end
            if (btnc || btnu || btnd) count <= 0;
        end   
        if (reset) begin // reset all squares to white if reset flag is enabled
            btncstate <= 0;
            btnustate <= 0;
            btndstate <= 0;
        end
    end
    
    always @ (posedge clock) begin
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