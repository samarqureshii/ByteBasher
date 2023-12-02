module Datapath(
    input clk,
    input reset,
    input start_game, // Signal to start the game
    input hit_detected, // Signal from FSM when a hit is detected
    input [2:0] sensor_input, // Input from read_sensor()
    input [2:0] lfsr_output, // Output from LFSR module
    output reg [10:0] score, // Score output to FSM
    output reg [1:0] box_address, // Address of the current box
    output reg [3:0] game_timer, // Game timer
    output reg [1:0] difficulty_level // Difficulty level
    output [2:0] lfsr_random_value
    input [2:0] GPIO_1,
    input CLOCK_50,
    input [6:0] HEX0,
    input [3:0] KEY,
    output[9:0] LEDR
    // Additional outputs for VGA, audio, etc.
);

// Internal registers
reg [1:0] current_box;
reg [3:0] counter; // 4-bit counter for game timer
wire [2:0] lfsr_out;
wire [2:0] box_mapped; // Changed to 3 bits
//reg reset_signal;
//reg [2:0] seed;
reg hit_led;

wire [2:0] lfsr_address;
lfsr_top_level lfsr_top (
    .CLOCK_50(clk),
    .KEY(KEY),
    .HEX0(HEX0),
    .lfsr_address(lfsr_address)  // Connect the output to lfsr_address wire
);

assign lfsr_random_value = lfsr_address;

read_sensor sensor(
    .GPIO_1(GPIO_1),
    .LEDR(LEDR),
    .box_address(box_address)
);

// Game logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        score <= 0;
        counter <= 0;
        game_timer <= 0;
        difficulty_level <= 1;
        hit_led <= 0;
        LEDR[9] <= 1'b0;
        // Reset other states
    end else if (start_game) begin
        game_timer <= game_timer + 1;
        if (game_timer >= 60) begin

            game_timer <= 0; // Reset game_timer for next game
        end

        // Update difficulty based on game_timer
        if (game_timer < 20) difficulty_level <= 1;
        else if (game_timer < 40) 
            difficulty_level <= 2;
        else 
            difficulty_level <= 3;

        // Check if sensor input matches the LFSR box
        if (lfsr_address == sensor_input) begin
            hit_led <= 1; // Turn on LED 
            LEDR[9] <= 1'b1;
            score <= score + difficulty_level; // Increment score based on difficulty
        end else begin
            hit_led <= 0; // Turn off LED
            LEDR[9] <= 1'b0;
            score <= (score > 0) ? score - 1 : 0; // Decrement score if wrong hit
        end
    end
end

// Additional logic for VGA, audio, etc.

endmodule
