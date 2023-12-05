`timescale 1ns / 1ns

`timescale 1ns / 1ns

module lfsr_top_level(CLOCK_50, reset_signal, HEX3, box);
    input CLOCK_50;
    input reset_signal;
    output [6:0] HEX3;
    output [2:0] box;

    reg [2:0] seed = 3'b001;
    wire [2:0] lfsr_out;
    reg previous_reset_state = 1'b0;
    reg [2:0] free_running_counter = 3'b000;

    always @(posedge CLOCK_50) begin
        free_running_counter <= free_running_counter + 1;
    end

    lfsr_3bit lfsr (
        .out(lfsr_out),
        .enable(enable_pulse),
        .clk(CLOCK_50),
        .reset(reset_signal),
        .seed(seed)
    );

    wire enable_pulse;
    RateDivider #(50000000) rate_divider_instance (
        .ClockIn(CLOCK_50), 
        .Reset(reset_signal),
        .Enable(enable_pulse)
    );

    always @(posedge CLOCK_50 or posedge reset_signal) begin
        if (reset_signal) begin
            if (!previous_reset_state) begin
                seed <= free_running_counter;
            end
            previous_reset_state <= 1'b1;
        end else begin
            previous_reset_state <= 1'b0;
        end
    end

    // Directly display LFSR output on HEX3
    hex_decoder hd_lfsr({1'b0, lfsr_out}, HEX3);

    map_lfsr_to_boxes map_lfsr (.lfsr_out(lfsr_out), .box(box));
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