`timescale 1ns / 1ns

module lfsr_top_level(CLOCK_50, reset_signal, HEX3, box);
    input CLOCK_50;
    input reset_signal,
    //input [3:0] KEY;
    output [6:0] HEX3;
    output [2:0] box; //this is the initialization signal for the VGA 

    reg [2:0] seed = 3'b001; // Initial seed value
    wire [2:0] lfsr_out;
    wire [1:0] box_mapped;
    //wire [3:0] hex_input;
    //wire reset_signal = ~KEY[0]; // Active low reset signal
    reg previous_reset_state = 1'b0; // To detect reset signal edges

    // Free-running counter for seeding
    reg [2:0] free_running_counter = 3'b000;
    always @(posedge CLOCK_50) begin
        free_running_counter <= free_running_counter + 1;
    end

    lfsr_3bit lfsr (
        .out(lfsr_out),
        .enable(enable_pulse), // Connect the enable signal from the rate divider
        .clk(CLOCK_50),
        .reset(reset_signal),
        .seed(seed)
    );
    //instantiate the rate divider 
    wire enable_pulse;
    RateDivider #(50000000) rate_divider_instance (
        .ClockIn(CLOCK_50), 
        .Reset(reset_signal),
        .Enable(enable_pulse) // This will pulse high every second
    );

    // LFSR reset and reseed logic
    always @(posedge CLOCK_50 or posedge reset_signal) begin
        if (reset_signal) begin
            // Capture the free-running counter value as a new seed on reset
            if (!previous_reset_state) begin
                seed <= free_running_counter;
            end
            previous_reset_state <= 1'b1;
        end 
        
        else begin
            previous_reset_state <= 1'b0;
        end
    end

    // Rest of the logic remains the same
    map_lfsr_to_boxes map_lfsr (.lfsr_out(lfsr_out), .box(box_mapped));
    assign lfsr_HEX = {1'b0, box_mapped};
    hex_decoder hd_lfsr(lfsr_HEX, HEX3); //test the 
endmodule

module map_lfsr_to_boxes(input [2:0] lfsr_out, output reg [2:0] box); //box is the MIF that we will flash
    always @(lfsr_out) begin
        case(lfsr_out)
            3'b001, 3'b010: box = 3'b010; // Box 2
            3'b011: box = 3'b011; // Box 3
            3'b100, 3'b101: box = 3'b100; // Box 4
            3'b110, 3'b111: box = 3'b101; // Box 5
            default: box = 3'b001; // Default case, can also be an error state
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
            // Update the LFSR only when enable is high
            out <= {out[1:0], linear_feedback};
        end
    end
endmodule



// module hex_decoder(c, display);
//     input [3:0] c;
//     output [6:0] display;
    
//     assign c0 = c[0];
//     assign c1 = c[1];
//     assign c2 = c[2];
//     assign c3 = c[3];

//     assign display[0] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
//     assign display[1] = (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
//     assign display[2] = (~c3 & ~c2 & c1 & ~c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0); 
//     assign display[3] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0) + (c3 & ~c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
//     assign display[4] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0);
//     assign display[5] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & ~c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
//     assign display[6] = (~c3 & ~c2 & ~c1 & ~c0) + (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0);
// endmodule