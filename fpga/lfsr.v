`timescale 1ns / 1ns

//non uniform mapping 

// States 001, 010, 100 map to Box 1
// States 011, 101 map to Box 2
// States 110 map to Box 3
// State 111 maps to Box 4

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
