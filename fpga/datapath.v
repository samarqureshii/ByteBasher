module Datapath(
    input clk,
    input reset,
    input start_game, // Signal to start the game
    input hit_detected, // Signal from FSM when a hit is detected
    input [1:0] sensor_input, // Input from read_sensor()
    input [2:0] lfsr_output, // Output from LFSR module
    output reg [10:0] score, // Score output to FSM
    output reg [1:0] box_address, // Address of the current box
    output reg [3:0] game_timer, // Game timer
    output reg [1:0] difficulty_level // Difficulty level
    // Additional outputs for VGA, audio, etc.
);

// Internal registers
reg [1:0] current_box;
reg [3:0] counter; // 4-bit counter for game timer

// LFSR Mapping
map_lfsr_to_boxes lfsr_mapping (.lfsr_out(lfsr_output), .box(current_box));

//instantiate ram for MIF switching 

// Game logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        score <= 0;
        counter <= 0;
        box_address <= 2'b00;
        difficulty_level <= 1;
        // Reset other states
    end else if (start_game) begin
        counter <= counter + 1;
        if (counter >= 60) begin
            counter <= 0; // Reset counter for next game
        end

        // Update difficulty based on counter
        if (counter < 20) difficulty_level <= 1;
        else if (counter < 40) difficulty_level <= 2;
        else difficulty_level <= 3;

        box_address <= current_box; // Update box address from LFSR

        // Update score based on hit detection and difficulty
        if (hit_detected) begin
            if (sensor_input == box_address) begin
                score <= score + difficulty_level; // Increment score based on difficulty
            end else begin
                score <= (score > 0) ? score - 1 : 0; // Decrement score if wrong hit
            end
        end
    end
end

// Additional logic for VGA, audio, etc.

endmodule
