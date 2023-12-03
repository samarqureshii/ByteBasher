`timescale 1ns / 1ns

`timescale 1ns / 1ns

module lfsr_top_level(
    input CLOCK_50,
    input [3:0] KEY,
    output [6:0] HEX0,
    output reg [2:0] lfsr_address // Changed to reg
);

    // Define a simple counter
    reg [2:0] counter = 3'b000;
    
    // Define the lookup table with random values between 1 and 4
    reg [2:0] lut [0:7]; // Declaration of the lookup table

    // Initialization of the lookup table
    initial begin
        lut[0] = 3'b001;
        lut[1] = 3'b010;
        lut[2] = 3'b011;
        lut[3] = 3'b100;
        lut[4] = 3'b001;
        lut[5] = 3'b011;
        lut[6] = 3'b010;
        lut[7] = 3'b100;
    end
    // Counter logic
    always @(posedge CLOCK_50) begin
        if (~KEY[0]) // Reset condition
            counter <= 3'b000;
        else
            counter <= counter + 1'b1;
    end

    // Update the lfsr_address from the lookup table
    always @(posedge CLOCK_50) begin
        lfsr_address <= lut[counter];
    end

    // Hex display logic (remains the same)
    wire [3:0] hex_input = {1'b0, lfsr_address};
    hex_decoder_lfsr hd_lfsr(hex_input, HEX0);

endmodule

// ... (Other modules remain the same)


module map_lfsr_to_boxes(input [2:0] lfsr_out, output reg [2:0] box);
    always @(lfsr_out) begin
        case(lfsr_out)
            // Mapping the 3-bit LFSR output to 3-bit box values
            3'b001, 3'b010: box = 3'b001; // Box 1
            3'b011:         box = 3'b010; // Box 2
            3'b100, 3'b101: box = 3'b011; // Box 3
            3'b110, 3'b111: box = 3'b100; // Box 4
            default:        box = 3'b001; // Default case
        endcase
    end
endmodule



// Modify lfsr_3bit module to accept a seed input
module lfsr_3bit (out, enable, clk, reset, seed);
    output reg [2:0] out;
    input enable, clk, reset;
    input [2:0] seed;
    wire linear_feedback;

    // Feedback from XOR of bit 2 and bit 0 (positions 2 and 0 for a 3-bit LFSR)
    assign linear_feedback = !(out[2] ^ out[0]);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            out <= seed; // Initialize with seed at reset
        end else if (enable) begin
            out <= {out[1:0], linear_feedback};
        end
    end
endmodule

module hex_decoder_lfsr(c, display);
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
