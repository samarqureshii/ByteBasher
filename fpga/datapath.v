module Datapath(
    input reset,
    input start_game, // Signal to start the game
    input hit_detected, // Signal from FSM when a hit is detected
    input [2:0] sensor_input, // Input from read_sensor()
    input [2:0] lfsr_output, // Output from LFSR module
    output reg [10:0] score, // Score output to FSM
    output reg [3:0] game_timer, // Game timer
    output reg [1:0] difficulty_level, // Difficulty level
    output [2:0] lfsr_random_value,
    output [1:0] box_address,
    input [2:0] GPIO_1,
    input CLOCK_50,
    input [6:0] HEX0,
    input [3:0] KEY,

    input AUD_ADCDAT, 
    inout AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT,
    output AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK,
    input audio_en  // enable signal for audio

    output reg play_sound //if high, then that means hit detected and 
    // Additional outputs for VGA, audio, etc.
);

// reg [9:3] LEDR_reg;
// assign LEDR = LEDR_reg;

wire [1:0] box_address_wire;  // Internal wire to connect to read_sensor
assign box_address = box_address_wire;
//reg play_sound; //control signal to assert when we should start playing the sound 
// Internal registers
reg [1:0] current_box;
reg [3:0] counter; // 4-bit counter for game timer
//reg reset_signal;
//reg [2:0] seed;
reg hit_led;

wire [2:0] lfsr_address;
lfsr_top_level lfsr_top (
    .CLOCK_50(CLOCK_50),
    .KEY(KEY),
    .HEX0(HEX0),
    .lfsr_address(lfsr_address)  // Connect the output to lfsr_address wire
);

assign lfsr_random_value = lfsr_address;

read_sensor sensor(
    .GPIO_1(GPIO_1),
    .LEDR(LEDR),
    .box_address(box_address_wire)
);


audio_main audio_unit (
    .CLOCK_50(CLOCK_50), 
    .KEY(KEY), 
    .AUD_ADCDAT(AUD_ADCDAT), 
    .AUD_BCLK(AUD_BCLK), 
    .AUD_ADCLRCK(AUD_ADCLRCK), 
    .AUD_DACLRCK(AUD_DACLRCK), 
    .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
    .AUD_XCK(AUD_XCK), 
    .AUD_DACDAT(AUD_DACDAT), 
    .FPGA_I2C_SCLK(FPGA_I2C_SCLK), 
    .audio_en(audio_en), 
    .play_sound(play_sound),
    .SW(4'b0) // Assuming SW is not used in Datapath, set to a default value
);


// Game logic
always @(posedge CLOCK_50 or posedge reset) begin
    if (reset) begin
        score <= 0;
        counter <= 0;
        game_timer <= 0;
        difficulty_level <= 1;
        hit_led <= 0;
        play_sound = 1'b0;
        //LEDR_reg[9] <= 1'b0;
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
        if (lfsr_random_value == box_address) begin
            hit_led <= 1; // Turn on LED 
            //LEDR_reg[9] <= 1'b1;
            play_sound = 1'b1;
            score <= score + difficulty_level; // Increment score based on difficulty
        end else begin
            hit_led <= 0; // Turn off LED
            //LEDR_reg[9] <= 1'b0;
            play_sound = 1'b0;
            score <= (score > 0) ? score - 1 : 0; // Decrement score if wrong hit
        end
    end
end

// Additional logic for VGA, audio, etc.

endmodule
