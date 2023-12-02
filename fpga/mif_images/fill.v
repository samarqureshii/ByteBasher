// Part 2 skeleton

module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		SW,
		KEY,// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input	[9:0] SW;
	input [1:0] KEY;	
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	assign writeEn = 1;
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
		.resetn(resetn),
		.clock(CLOCK_50),
		.colour(colour),
		.x(x),
		.y(y),
		.plot(writeEn),
		/* Signals for the DAC to drive the monitor. */
		.VGA_R(VGA_R),
		.VGA_G(VGA_G),
		.VGA_B(VGA_B),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK_N),
		.VGA_SYNC(VGA_SYNC_N),
		.VGA_CLK(VGA_CLK));
	defparam VGA.RESOLUTION = "160x120";
	defparam VGA.MONOCHROME = "FALSE";
	defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
	defparam VGA.BACKGROUND_IMAGE = "level1.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.
	display_maze maze(
		.current_level(SW[1:0]),
		.clock(CLOCK_50),
		.reset(!resetn),
		.colour(colour),
		.x(x),
		.y(y));
	
	// 00 at SW prints bg level1
	// 01 at SW prints level2
		

endmodule

module display_maze(current_level, clock, reset, colour, x, y);

    input clock;
	input reset;
    reg [14:0] address;
    output reg [2:0] colour;
    output reg [8:0] x;
    output reg [7:0] y;

    reg [8:0] x_counter; 
    reg [7:0] y_counter;

	
    wire [2:0] colour1; // for level 1

    input [1:0] current_level; // write enable 
	 reg       oDone;       // goes high when finished drawing frame
                                // must remain gigh until iPlotBox or iBlack pulsed high and then low
    reg counter_en;
    reg plot_enable;


    // 00: no plots --> shows background mif level 1
    // 01: shows level 2



	level2 lvl2(
        .clock(clock),
        .address(address),
        .q(colour1)
    );

    // datapath
    always@(posedge clock)
    begin
        if (reset == 1)
        begin
            
            colour <= 0;
            x <= 0;
            y <= 0;
        end
        else if(plot_enable == 1) // set x, y, color values
        begin
            x <= x_counter;
            y <= y_counter;
            if(current_level == 2'b01)
                begin
		        colour <= colour1;
                end
        end
    end

    always@(posedge clock)
    begin
        if(reset == 1)
        begin
            x_counter <= 0;
            y_counter <= 0;
            address <= 0;
        end
        else 
        begin
            if(counter_en)
            begin
                // counter full
                if(address == 15'd19199)
                begin
                    address <= 0;
                    x_counter <= 0;
                    y_counter <= 0;
                end
                else
                begin
                    address <= address + 1;
                    if(x_counter == 9'd159)
                    begin
                        x_counter <= 0;
                        y_counter <= y_counter + 1;
                    end
                    else // x needs to be incremented
                    begin
                        x_counter <= x_counter + 1;
                    end
                end
            end
        end
    end

    // controlpath
    reg [2:0] curr_state, next_state;
    localparam START = 3'd0, WAIT_DRAW = 3'd1, DRAW = 3'd2, DONE = 3'd3;
    always@(*)
    begin
        case(curr_state)
        
            START: begin
                if(plot_enable)
                    next_state = WAIT_DRAW;
                else
                    next_state = START;
            end

            WAIT_DRAW: next_state = DRAW;

            DRAW: next_state = (address == 15'd19199) ? DONE: DRAW;

            DONE: 
            begin
                
                next_state = START;
                
            end
            default: next_state = START; 
        
        endcase
    end

    always@(*)
    begin
        counter_en = 1'b0;
        plot_enable = 1'b1;
        oDone = 1'b0;
    

    case(curr_state)
	START:
begin
if(current_level == 2'b00)  plot_enable = 1'b0;
 oDone = 1'b0;
end
    DRAW:
    begin
        counter_en = 1'b1;
        plot_enable = 1'b1;
    end
    DONE: oDone = 1'b1;
    endcase
    end

    always@(posedge clock)
    begin
        if(reset)
        curr_state <= START;
        else
        curr_state <= next_state;
    end
endmodule

module level2 (
	address,
	clock,
	q);

	input	[14:0]  address;
	input	  clock;
	output	[2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
	tri1	  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

	wire [2:0] sub_wire0;
	wire [2:0] q = sub_wire0[2:0];

	altsyncram	altsyncram_component (
				.address_a (address),
				.clock0 (clock),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.address_b (1'b1),
				.addressstall_a (1'b0),
				.addressstall_b (1'b0),
				.byteena_a (1'b1),
				.byteena_b (1'b1),
				.clock1 (1'b1),
				.clocken0 (1'b1),
				.clocken1 (1'b1),
				.clocken2 (1'b1),
				.clocken3 (1'b1),
				.data_a ({3{1'b1}}),
				.data_b (1'b1),
				.eccstatus (),
				.q_b (),
				.rden_a (1'b1),
				.rden_b (1'b1),
				.wren_a (1'b0),
				.wren_b (1'b0));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.clock_enable_input_a = "BYPASS",
		altsyncram_component.clock_enable_output_a = "BYPASS",
		altsyncram_component.init_file = "W:/maze_bg_friday/level2.mif",
		altsyncram_component.intended_device_family = "Cyclone V",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 19200,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "UNREGISTERED",
		altsyncram_component.widthad_a = 15,
		altsyncram_component.width_a = 3,
		altsyncram_component.width_byteena_a = 1;


endmodule
