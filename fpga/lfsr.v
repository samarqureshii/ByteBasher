`timescale 1ns / 1ns

//non uniform mapping 

// States 001, 010, 100 map to Box 1
// States 011, 101 map to Box 2
// States 110 map to Box 3
// State 111 maps to Box 4

module lfsr(input CLOCK_50, output HEX5[6:0]); //use this to test randomization algorithm on the HEX
//feed the out of the lfsr into the hex decoder, should generate random values of 1,2,3, or 4, and display on the hex
wire [3:0] out;
hex_decoder hd_lfsr(out, HEX5);
endmodule

module lfsr_3bit (out, enable, clk, reset); //determine which of the squares the "mole" will appear in 
    output reg [2:0] out;
    input enable, clk, reset;

    wire linear_feedback;

    // feedback from XOR of bit 2 and bit 1 
    assign linear_feedback = !(out[2] ^ out[1]);

    always @(posedge clk) begin
        if (reset) 
            out <= 3'b001; // reset - why to non zero state?
        else if (enable) 
            out <= {out[1:0], linear_feedback};
    end
endmodule

module hex_decoder(c, display);
    input [3:0] c;
    output [6:0] display;
    
    assign c0 = c[0];
    assign c1 = c[1];
    assign c2 = c[2];
    assign c3 = c[3];

    assign display[0] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[1] = (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[2] = (~c3 & ~c2 & c1 & ~c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);	
    assign display[3] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0) + (c3 & ~c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[4] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0);
    assign display[5] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & ~c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[6] = (~c3 & ~c2 & ~c1 & ~c0) + (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0);
endmodule
