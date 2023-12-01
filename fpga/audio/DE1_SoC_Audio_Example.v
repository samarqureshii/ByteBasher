module DE1_SoC_Audio_Example (
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
);

input				CLOCK_50;
input		[3:0]	KEY;
input		[3:0]	SW;

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

always @(posedge CLOCK_50)begin
	
	if (clock_count == 11'd1200) begin
		if (addr_count == 14'd16383) begin 
			addr_count <= 14'b0;
			end
		else addr_count <= addr_count + 1'b1;
		clock_count <= 0;
	end
	else clock_count <= clock_count + 1;
	
	if(~KEY[0]) begin
		addr_count<= 14'b0;
		clock_count <= 11'b0;
	end
end
wire [13:0] address_count;
assign address_count = addr_count;


assign read_audio_in			= audio_in_available & audio_out_allowed;
assign left_channel_audio_out = {audio_from_ram, 26'b0};
assign right_channel_audio_out = 32'b0;
assign write_audio_out			= audio_in_available & audio_out_allowed;

 //my 32 bit RAM module for the gameover MIF sound
gameover ram(.address(address_count), .clock(CLOCK_50), .q(audio_from_ram), .wren(1'b0));

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