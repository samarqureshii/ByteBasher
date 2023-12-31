module audio_start ( //audio to start playing in the lobby 
	CLOCK_50,
	KEY,
	AUD_ADCDAT,

	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	FPGA_I2C_SDAT,

	AUD_XCK,
	AUD_DACDAT,

	FPGA_I2C_SCLK,
	SW,
    lobby_sound
);

input				CLOCK_50;
input		[3:0]	KEY;
input		[3:0]	SW;
input lobby_sound;

input				AUD_ADCDAT;

inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;
inout				FPGA_I2C_SDAT;
output				AUD_XCK;
output				AUD_DACDAT;
output				FPGA_I2C_SCLK;


wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;
wire [5:0]	audio_from_ram;
wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

reg [18:0] delay_cnt;
wire [18:0] delay;
reg [13:0] addr_count;
reg [10:0] clock_count;
reg snd;


reg [22:0] beatCountMario;
reg [9:0] addressMario; 
													
// sound_rom r1(.address(addressMario), .clock(CLOCK_50), .q(delay));
mario_rom r1(.address(addressMario), .clock(CLOCK_50), .q(delay));
 
always @(posedge CLOCK_50) begin
    if (lobby_sound == 1'b1) begin
        // Logic for handling beatCountMario and addressMario
        if (beatCountMario == 23'd2500000) begin
            beatCountMario <= 23'b0;
            if (addressMario < 10'd999) begin
                addressMario <= addressMario + 1;
            end else begin
                addressMario <= 0;
            end

            // Logic for snd and delay_cnt
            if (delay_cnt == delay) begin
                delay_cnt <= 0;
                snd <= !snd;
            end else begin
                delay_cnt <= delay_cnt + 1;
            end
        end 
        
        else begin
            beatCountMario <= beatCountMario + 1;
        end
        
    end 
    
    else begin
        // Reset logic if lobby_sound is not asserted
        addressMario <= 0;
        beatCountMario <= 0;
        snd <= 0;
        delay_cnt <= 0; // Reset the delay counter as well
    end
end


wire [31:0] sound = snd ? 32'd100000000 : -32'd100000000;

assign read_audio_in			= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= left_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

Audio_Controller Audio_Controller (
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0]),
	.clear_audio_in_memory	(),
	.read_audio_in				(read_audio_in),
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(1'b1),
	.AUD_ADCDAT					(AUD_ADCDAT),
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),
	.audio_out_allowed			(audio_out_allowed),
	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT)

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.FPGA_I2C_SCLK					(FPGA_I2C_SCLK),
	.FPGA_I2C_SDAT					(FPGA_I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(~KEY[0])
);
endmodule