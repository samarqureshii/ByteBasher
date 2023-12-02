`timescale 1ns / 1ns

module lfsr_top_level(
    input CLOCK_50,
    input [3:0] KEY,
    output [6:0] HEX0,
    output [2:0] lfsr_address  // Add this output port
);


    reg [2:0] seed = 3'b001; // Initial seed value
    wire [2:0] lfsr_out;
    wire [2:0] box_mapped;  // Changed to 3-bit
    wire [3:0] hex_input;
    wire reset_signal = ~KEY[0]; // Active low reset signal
    reg previous_reset_state = 1'b0; // To detect reset signal edges

    // Free-running counter for seeding
    reg [2:0] free_running_counter = 3'b000;
    always @(posedge CLOCK_50) begin
        free_running_counter <= free_running_counter + 1;
    end

    lfsr_3bit lfsr (
        .out(lfsr_out),
        .enable(1'b1),
        .clk(CLOCK_50),
        .reset(reset_signal),
        .seed(seed)
    );

    // LFSR reset and reseed logic
    always @(posedge CLOCK_50 or posedge reset_signal) begin
        if (reset_signal) begin
            // Capture the free-running counter value as a new seed on reset
            if (!previous_reset_state) begin
                seed <= free_running_counter;
            end
            previous_reset_state <= 1'b1;
        end else begin
            previous_reset_state <= 1'b0;
        end
    end

    // Rest of the logic remains the same
    // Modified map_lfsr_to_boxes instantiation
    map_lfsr_to_boxes map_lfsr (.lfsr_out(lfsr_out), .box(box_mapped));
    assign lfsr_address = box_mapped;
    assign hex_input = {1'b0, box_mapped};  // Adjusted for 3-bit box_mapped
    hex_decoder hd_lfsr(hex_input, HEX0);
endmodule

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
