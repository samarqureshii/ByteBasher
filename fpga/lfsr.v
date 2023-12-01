`timescale 1ns / 1ns

module lfsr_top_level(CLOCK_50, KEY, HEX0);
    input CLOCK_50;
    input [3:0] KEY;
    output [6:0] HEX0;

    wire [2:0] lfsr_out;
    wire [1:0] box_mapped;
    wire [3:0] hex_input;
    wire reset_signal = ~KEY[0]; // invert active low 

    lfsr_3bit lfsr (.out(lfsr_out), .enable(1'b1), .clk(CLOCK_50), .reset(reset_signal));
    map_lfsr_to_boxes map_lfsr (.lfsr_out(lfsr_out), .box(box_mapped));

    // map the 2-bit box output to a 4-bit input for the hex decoder
    assign hex_input = {2'b00, box_mapped}; // zero-padding to fit the hex decoder input

    hex_decoder hd_lfsr(hex_input, HEX0);
endmodule


module map_lfsr_to_boxes(input [2:0] lfsr_out, output reg [1:0] box);
    always @(lfsr_out) begin
        case(lfsr_out)
            3'b001, 3'b010: box = 2'b00; // Box 1
            3'b011: box = 2'b01; // Box 2
            3'b100, 3'b101: box = 2'b10; // Box 3
            3'b110, 3'b111: box = 2'b11; // Box 4
            default: box = 2'b00; // Default case, can also be an error state
        endcase
    end
endmodule

module lfsr_3bit (out, enable, clk, reset); 
    output reg [2:0] out;
    input enable, clk, reset;
    wire linear_feedback;

    // Feedback from XOR of bit 2 and bit 0 (positions 2 and 0 for a 3-bit LFSR)
    assign linear_feedback = !(out[2] ^ out[0]);

    always @(posedge clk) begin
        if (reset) 
            out <= 3'b001; // Non-zero initial state
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
