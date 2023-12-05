   module Datapath(
        input resetn,
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
        output [6:0] HEX0,
        output [6:0] HEX1,
        output [6:0] HEX2,
        output [6:0] HEX3,
        output [6:0] HEX4,
        output [6:0] HEX5,
        input [3:0] KEY,
        input [9:0] SW,
        output [9:0] LEDR,

        input AUD_ADCDAT, 
        inout AUD_BCLK, AUD_ADCLRCK, AUD_DACLRCK, FPGA_I2C_SDAT,
        output AUD_XCK, AUD_DACDAT, FPGA_I2C_SCLK,
        input audio_en,  // enable signal for audio
        

        output reg play_sound, //if high, then that means hit detected and 
        output reg lobby_sound, //if high (on the lobby mif,), we play the mario sound 
        // Additional outputs for VGA, audio, etc.

        output VGA_CLK, 
        output VGA_HS,
        output VGA_VS,
        output VGA_BLANK_N,
        output VGA_SYNC_N,
        output [7:0] VGA_R,  
        output [7:0] VGA_G, 
        output [7:0] VGA_B
    );

wire led;
assign LEDR[9] = led;
reg [3:0] score;
reg done_signal;

reg use_lfsr; //control signal for whether or not we are using the LFSR value or if we are using the switch value 

wire [2:0] lfsr_box_output;
wire [6:0] lfsr_hex_output;


lfsr_top_level lfsr_instance (
    .CLOCK_50(CLOCK_50),
    .reset_signal(resetn),
    .HEX3(lfsr_hex_output),
    .box(lfsr_box_output)
);

    // wire [2:0] LEDR_internal;  // Internal wire for LEDR output from read_sensor
    // //assign LEDR_internal = LEDR;
    // wire [6:0] HEX1_internal;  // Internal wire for HEX1 output from read_sensor
    // //assign HEX1_internal = HEX1;


    // reg [9:3] LEDR_reg;
    // assign LEDR = LEDR_reg;

    //wire [2:0] box_address_wire;  // Internal wire to connect to read_sensor
    //assign box_address = box_address_wire;
    //reg play_sound; //control signal to assert when we should start playing the sound 

    // Internal registers
    reg [1:0] current_box;
    reg [3:0] counter; // 4-bit counter for game timer

    // wire [2:0] incremented_box_address;
    // assign incremented_box_address = box_address + 1;


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
    read_sensor arduino_GPIO (.input_signal(GPIO_1), .output_signal(LEDR[2:0]), .box_addr(box_address), .hex_display(HEX1));

    counter counter_unit (
        .CLOCK_50(CLOCK_50), 
        .SW(SW[9:8]), 
        .HEX4(HEX4), 
        .HEX5(HEX5),
        .done(done_signal) // Connect the done signal
    );


wire audio_in_available;
wire [31:0] left_channel_audio_in;
wire [31:0] right_channel_audio_in;
wire read_audio_in;
wire [5:0] audio_from_ram;
wire audio_out_allowed;
wire [31:0] left_channel_audio_out;
wire [31:0] right_channel_audio_out;
wire write_audio_out;
wire [17:0] address_count;


reg [17:0] addr_count, soundstart, soundend;
reg [10:0] clock_count;
localparam winstart = 18'd0,
 winend = 18'd16395,
 moostart = 18'd16396,
 mooend = 18'd66982,
 detectstart = 18'd66983, 
 detectend = 18'd83254,
 cheerstart = 18'd83255,
 cheerend = 18'd137138;
 
always @(posedge CLOCK_50) begin
if(play_sound == 1'b1 )begin //if we have the correct hit 

        soundstart <= winstart;
        soundend <= winend;

        // Existing logic to cycle through audio addresses
        if (clock_count == 11'd1200) begin
            if (addr_count == soundend) begin 
                addr_count <= soundstart;
            end else if ((addr_count >= soundstart) && (addr_count < soundend)) begin
                addr_count <= addr_count + 1'b1;
                clock_count <= 0;
            end else addr_count <= soundstart;
        end else clock_count <= clock_count + 1;
    end

else begin //when play sound is not 1
        // Reset address count when play_sound is inactive
        addr_count <= 18'b0;
        clock_count <= 11'b0;
    end 

    if(~resetn) begin
        addr_count <= 18'b0;
        clock_count <= 11'b0;
    end
end


assign address_count = addr_count;


assign read_audio_in = audio_in_available & audio_out_allowed;
assign left_channel_audio_out = {audio_from_ram, 26'b0};
assign right_channel_audio_out = 32'b0;
assign write_audio_out = audio_in_available & audio_out_allowed;

 
win_rom ram(.address(address_count), .clock(CLOCK_50), .q(audio_from_ram));

Audio_Controller Audio_Controller (
.CLOCK_50 (CLOCK_50),
.reset (~resetn),
.clear_audio_in_memory (),
.read_audio_in (read_audio_in),
.clear_audio_out_memory (),
.left_channel_audio_out (left_channel_audio_out),
.right_channel_audio_out (right_channel_audio_out),
.write_audio_out (audio_en),
.AUD_ADCDAT (AUD_ADCDAT),
.AUD_BCLK (AUD_BCLK),
.AUD_ADCLRCK (AUD_ADCLRCK),
.AUD_DACLRCK (AUD_DACLRCK),
.audio_in_available (audio_in_available),
.left_channel_audio_in (left_channel_audio_in),
.right_channel_audio_in (right_channel_audio_in),
.audio_out_allowed (audio_out_allowed),
.AUD_XCK (AUD_XCK),
.AUD_DACDAT (AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
.FPGA_I2C_SCLK (FPGA_I2C_SCLK),
.FPGA_I2C_SDAT (FPGA_I2C_SDAT),
.CLOCK_50 (CLOCK_50),
.reset (~resetn)
);

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
        //.level_select(SW), // Here, SW is mapped to level_select
        .level_select(lfsr_box_output), //hopefully, the LFSR maps correctly to the VGA
        .resetn(KEY[0]), // Assuming KEY[0] is your reset
        .use_lfsr(use_lfsr),
        .VGA_CLK(VGA_CLK),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

    //testing the current MIF status 
    wire [3:0] hex_input2;
    assign hex_input2 = {1'b0, SW};
    hex_decoder decoder2(hex_input2, HEX0);

    //mif control signal is dependent on the switch
    // input [2:0] mif_control_signal;
    // assign mif_control_signal = SW;

    // //input [2:0] mif_control_signal;

    // // counter counter_instance (
    // //         .CLOCK_50(CLOCK_50), 
    // //         .SW({2'b00, control_SW}),  // Assuming only two switches are used for control
    // //         .HEX4(HEX4), 
    // //         .HEX5(HEX5),
    // //         .game_timer(game_timer)
    // //     );


    hex_decoder decoder(score, HEX2);

    // // Game logic
    always @(posedge CLOCK_50 or posedge resetn) begin
        if (resetn) begin
            // Reset logic
            score <= 0;
            led = 1;
            use_lfsr <= 0;
            play_sound <= 1'b0;
            // Other reset states as needed
        end 
        
        else begin
            // When SW input is 001, start using LFSR values
            if (SW[2:0] == 3'b001) begin
                use_lfsr <= 1;
            end

            // Check if sensor input matches the LFSR box
            if (GPIO_1 == SW) begin
                led = 1;
                play_sound <= 1'b1;
                // Increment score logic here, if applicable
            end 
            
            else begin
                led <= 0;
                play_sound <= 1'b0;
                // Decrement score logic here, if applicable
            end

            // When counter is done, switch to 110 and stop using LFSR
            if (done_signal) begin
                use_lfsr <= 0;
            end
        end
    end

    

    // Additional logic for VGA, audio, etc.

    endmodule

    