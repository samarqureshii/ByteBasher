module fill (
    input CLOCK_50, //clock
    input [2:0] level_select, //SW
    input resetn, //KEY
	input use_lfsr,

    output VGA_CLK, 
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_SYNC_N,
    output [7:0] VGA_R,   
    output [7:0] VGA_G,   
    output [7:0] VGA_B   
);

    // Continuous assignment for mif_control_signal

//wire resetn;
//assign resetn = KEY[0];

// Create the colour, x, y and writeEn wires that are inputs to the controller.

// wire [2:0] colour;
// wire [7:0] x;
// wire [6:0] y;
assign writeEn = 1;

// Create an Instance of a VGA controller - there can be only one!
// Define the number of colour and addresses as well as the initial background
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
// start screen background
defparam VGA.BACKGROUND_IMAGE = "start_yay.mif";

// Put your code here. Your code should produce signals x,y,colour and writeEn
// for the VGA controller, in addition to any other functionality your design may require.

display_game game(
.current_level(level_select),
.use_lfsr(use_lfsr),
.clock(CLOCK_50),
.reset(!resetn),
.colour(colour),
.x(x),
.y(y));

endmodule

module display_game(
    input [2:0] current_level, // LFSR or switch controlled level
    input use_lfsr, // Signal to use LFSR or switch input
    input clock, 
    input reset, 
    output reg [2:0] colour, 
    output reg [7:0] x, 
    output reg [6:0] y
);

// input clock;
// input reset;
reg [14:0] address;
// output reg [2:0] colour;
// output reg [7:0] x;
// output reg [6:0] y;

reg [7:0] x_counter;
reg [6:0] y_counter;

//input [2:0] current_level;
reg oDone;    
reg counter_en;
reg plot_enable;

wire [2:0] colour0, colour1, colour2, colour3, colour4, colour5;


// rom instantiation
start_rom r0 (.clock(clock), .address(address), .q(colour0)); //empty grid 000
rom_one r1 (.clock(clock), .address(address), .q(colour1)); // mole in location 001
rom_two r2 (.clock(clock), .address(address), .q(colour2)); //mole in location 010
rom_three r3 (.clock(clock), .address(address), .q(colour3)); //mole in location 011
rom_four r4 (.clock(clock), .address(address), .q(colour4)); //mole in location 100
rom_end r5 (.clock(clock), .address(address), .q(colour5)); // game over screen 


// ROM selector logic
    always @(posedge clock) begin
        if (reset) begin
            colour <= colour0; // Reset to colour0
        end 
		
		else begin
            if (use_lfsr) begin
                // Use LFSR value
                case (current_level)
                    3'b010: colour <= colour1;
                    3'b011: colour <= colour2;
                    3'b100: colour <= colour3;
                    3'b101: colour <= colour4;
                    default: colour <= colour0; // Default or other cases
                endcase
            end 
			
			else begin
                // Use switch value
                case (current_level)
                    3'b001: colour <= colour1; // Controlled by switch
                    3'b110: colour <= colour5; // Controlled by switch
                    default: colour <= colour0; // Default or other cases
                endcase
            end
        end
    end

// datapath
always@(posedge clock)
begin
 if (reset == 1)
 begin
x <= 0;
y <= 0;
 end
 else if(plot_enable == 1) // set x, y
 begin
x <= x_counter;
y <= y_counter;

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
// if(writeEn)
// begin
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
// end
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
if(current_level == 3'b000)  plot_enable = 1'b0;
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


module start_rom (    
address,
clock,
q);
  
input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "static.mif",
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

module rom_one (
address,
clock,
q);

input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "../rom_one.mif",
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

module rom_two (
address,
clock,
q);

input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "../rom_two.mif",
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

module rom_three (
address,
clock,
q);

input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "../rom_three.mif",
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

module rom_four (
address,
clock,
q);

input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "../rom_four.mif",
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

module rom_end (
address,
clock,
q);

input [14:0]  address;
input  clock;
output [2:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
tri1  clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

wire [2:0] sub_wire0;
wire [2:0] q = sub_wire0[2:0];

altsyncram altsyncram_component (
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
altsyncram_component.init_file = "../rom_end.mif",
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