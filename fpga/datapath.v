    module Datapath(
        input reset,
        input start_game, // Signal to start the game
        input hit_detected, // Signal from FSM when a hit is detected
        input [2:0] sensor_input, // Input from read_sensor()
        //input [2:0] lfsr_output, // Output from LFSR module
        //output reg [10:0] score, // Score output to FSM
        //output reg [3:0] game_timer, // Game timer
        //output reg [1:0] difficulty_level, // Difficulty level
        //output [2:0] lfsr_random_value, //straight from the LFSR
        output [2:0] box_address, //straight from the Arduino
        input [2:0] GPIO_1,
        input CLOCK_50,
        //output [6:0] HEX0,
        output [6:0] HEX1, 
        input [3:0] KEY,
        output [3:0] SW,

        input AUD_ADCDAT, 
        inout AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT,
        output AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK,
        input audio_en,  // enable signal for audio
        
        input [2:0] mif_control_signal,

        output reg play_sound, //if high, then that means hit detected and 
        output reg lobby_sound //if high (on the lobby mif,), we play the mario sound 
        // Additional outputs for VGA, audio, etc.
    );

    wire [2:0] LEDR_internal;  // Internal wire for LEDR output from read_sensor
    //assign LEDR_internal = LEDR;
    wire [6:0] HEX1_internal;  // Internal wire for HEX1 output from read_sensor
    //assign HEX1_internal = HEX1;


    // reg [9:3] LEDR_reg;
    // assign LEDR = LEDR_reg;

    //wire [2:0] box_address_wire;  // Internal wire to connect to read_sensor
    //assign box_address = box_address_wire;
    //reg play_sound; //control signal to assert when we should start playing the sound 

    // Internal registers
    reg [1:0] current_box;
    reg [3:0] counter; // 4-bit counter for game timer

    wire [2:0] incremented_box_address;
    assign incremented_box_address = box_address + 1;


    //reg reset_signal;
    //reg [2:0] seed;
    // reg hit_led;

    // wire [2:0] lfsr_address;
    // Instantiate lfsr_top_level
    // lfsr_top_level lfsr_instance (
    //     .CLOCK_50(CLOCK_50),
    //     .KEY(KEY),
    //     .HEX0(HEX0),
    //     .lfsr_address(lfsr_address)
    // );

    // assign lfsr_random_value = lfsr_address;
    read_sensor arduino_GPIO (.input_signal(GPIO_1), .output_signal(LEDR), .box_addr(box_address), .hex_display(HEX1));



    // audio_main audio_unit1( //audio controller for 
    //     .CLOCK_50(CLOCK_50), 
    //     .KEY(KEY), 
    //     .AUD_ADCDAT(AUD_ADCDAT), 
    //     .AUD_BCLK(AUD_BCLK), 
    //     .AUD_ADCLRCK(AUD_ADCLRCK), 
    //     .AUD_DACLRCK(AUD_DACLRCK), 
    //     .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
    //     .AUD_XCK(AUD_XCK), 
    //     .AUD_DACDAT(AUD_DACDAT), 
    //     .FPGA_I2C_SCLK(FPGA_I2C_SCLK), 
    //     .audio_en(audio_en), 
    //     .play_sound(play_sound),
    //     .SW(4'b0) // Assuming SW is not used in Datapath, set to a default value
    // );

    // audio_start audio_unit2 (
    //         .CLOCK_50(CLOCK_50),
    //         .KEY(KEY),
    //         .AUD_ADCDAT(AUD_ADCDAT),
    //         .AUD_BCLK(AUD_BCLK),
    //         .AUD_ADCLRCK(AUD_ADCLRCK),
    //         .AUD_DACLRCK(AUD_DACLRCK),
    //         .FPGA_I2C_SDAT(FPGA_I2C_SDAT),
    //         .AUD_XCK(AUD_XCK),
    //         .AUD_DACDAT(AUD_DACDAT),
    //         .FPGA_I2C_SCLK(FPGA_I2C_SCLK),
    //         .SW(SW),
    //         .lobby_sound(lobby_sound)
    //     );


    fill annie (
        .CLOCK_50(CLOCK_50),
        .level_select(SW), // Here, SW is mapped to level_select
        .resetn(KEY[0]), // Assuming KEY[0] is your reset
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

    // //input [2:0] mif_control_signal;

    // // counter counter_instance (
    // //         .CLOCK_50(CLOCK_50), 
    // //         .SW({2'b00, control_SW}),  // Assuming only two switches are used for control
    // //         .HEX4(HEX4), 
    // //         .HEX5(HEX5),
    // //         .game_timer(game_timer)
    // //     );


    // // Game logic
    // always @(posedge CLOCK_50 or posedge reset) begin
    //     if (reset) begin //when we click KEY[0], transition to the reset state 
    //         score <= 0;
    //         //counter <= 0;
    //         game_timer <= 6'd0; // Reset game_timer for next game
    //         //game_over = 1'b0; 
    //         //difficulty_level <= 1;
    //         lobby_sound<= 1'b0;
    //         play_sound <= 1'b0; //if we register a hit and the mif_control_signal matches 
    //         incremented_box_address <= 3'b000; 
    //         //LEDR_reg[9] <= 1'b0;
    //         // Reset other states
    //     end 
    //     else if (mif_control_signal == 3'b0000) begin //lobby screen (play the start sound)
    //         lobby_sound <= 1'b1;
    //     end

    //     else if (mif_control_signal != 3'b000) begin //game actually starts 
    //         lobby_sound <= 1'b0;
    //         //game_timer <= game_timer + 1;
    //         // if (counter >= 6'd60) begin
    //         //     game_over = 1'b1; 
                
    //         // end
    //         // Check if sensor input matches the LFSR box
    //         if (box_address == mif_control_signal) begin //if the current mif matches the box address
    //             //hit_led <= 1; // Turn on LED 
    //             //LEDR_reg[9] <= 1'b1;
    //             play_sound <= 1'b1;
    //             score <= score + 1; // Increment score 
    //         end else begin
    //             //hit_led <= 0; // Turn off LED
    //             //LEDR_reg[9] <= 1'b0;
    //             play_sound <= 1'b0;
    //             //score <= (score > 0) ? score - 1 : 0; // Decrement score if wrong hit
    //         end
    //     end
    // end

    // Additional logic for VGA, audio, etc.

    endmodule