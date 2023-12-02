module datapath_vga(
CLOCK_50,
SW,
KEY,

VGA_CLK,   // VGA Clock
VGA_HS, // VGA H_SYNC
VGA_VS, // VGA V_SYNC
VGA_BLANK_N, // VGA BLANK
VGA_SYNC_N, // VGA SYNC
VGA_R,   // VGA Red[9:0]
VGA_G, // VGA Green[9:0]
VGA_B   // VGA Blue[9:0]
);

input CLOCK_50; // 50 MHz
input [9:0] SW;
input [1:0] KEY;

// Declare your inputs and outputs here
// Do not change the following outputs
output VGA_CLK;   // VGA Clock
output VGA_HS; // VGA H_SYNC
output VGA_VS; // VGA V_SYNC
output VGA_BLANK_N; // VGA BLANK
output VGA_SYNC_N; // VGA SYNC
output [7:0] VGA_R;   // VGA Red [7:0] Changed from 10 to 8-bit DAC
output [7:0] VGA_G; // VGA Green [7:0]
output [7:0] VGA_B;   // VGA Blue [7:0]

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
defparam VGA.BACKGROUND_IMAGE = "start_yay.mif"; //beginning image 

// Put your code here. Your code should produce signals x,y,colour and writeEn
// for the VGA controller, in addition to any other functionality your design may require.

// which_hole hole0(
// .clock(clock),
// .reset(!resetn),
// .random_num(SW[7:4]),
// .random_x(random_x),
// .random_y(random_y));

display_hole display0(
.current_level(SW[2:0]),
.clock(CLOCK_50),
.reset(!resetn),
.colour(colour),
.x(x),
.y(y),
.cur_x(8'd60),
.cur_y(7'd45)
);

endmodule

module display_hole(current_level, clock, reset, colour, x, y, cur_x, cur_y);

    input clock;
input reset;
    reg [14:0] address;
input [7:0] cur_x;
input [6:0] cur_y;
    output reg [2:0] colour;
    output reg [7:0] x;
    output reg [6:0] y;

    reg [7:0] x_counter;
    reg [6:0] y_counter;


    wire [2:0] colour1;

    input [2:0] current_level; // write enable
reg       oDone;       // goes high when finished drawing frame
                                // must remain gigh until iPlotBox or iBlack pulsed high and then low
    reg counter_en;
    reg plot_enable;

    // 00: no plots --> shows background mif level 1
    // 01: shows level 2



mif_test M0( //ram for empty holes 
        .clock(clock),
        .address(address),
        .q(colour1)
    );

mole1_ram();
mole2_ram();
mole3_ram();
mole4_ram();
endgame_ram();


/*one M1(
        .clock(clock),
        .address(address),
        .q(colour2)
    );*/


   // datapath
//     always@(posedge clock)
//     begin
//         if (reset == 1)
//         begin
           
//             colour <= 0;
//             x <= 0;
//             y <= 0;
//         end

//         else if(plot_enable == 1) // set x, y, color values
//         begin
//             x <= x_counter;
//             y <= y_counter;
//             if(current_level == 2'b01)
//                 begin
//                 colour <= colour1;
//                 end
//             end
// else
// begin if((x_counter >= cur_x) && (x_counter <= (cur_x +4)) && (y_counter >= cur_y) && (y_counter <= (cur_y + 4)))
//             begin
//                 x <= x_counter;
//                 y <= y_counter;
//                 colour <= 2'b010; // color green within these bounds
//             end

/*
if(current_level == 3'b101)
begin
colour <= colour2;
end */

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
        //plot_char = 1'b0;


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



module mif_test (    //RAM FOR MIF
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



// module which_hole(clock, reset, random_num, random_x, random_y); //DO NOT NEED
// input clock;
// input reset;
// input [2:0] random_num;
// output reg random_x;
// output reg random_y;

// always @(posedge clock)
// begin
// if(reset)
// begin
// random_x <= 0;
// random_y <= 0;
// end
// else begin
// case(random_num)
// 3'b000: begin
// random_x <= 8'd55;
// random_y <= 7'd45;
// end
// 3'b001: begin
// random_x <= 8'd130;
// random_y <= 7'd55;
// end
// 3'b010: begin
// random_x <= 8'd55;
// random_y <= 7'd90;
// end
// 3'b100: begin
// random_x <= 8'd130;
// random_y <= 7'd90;
// end
// endcase
// end
// end
// endmodule