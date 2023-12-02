//
// This is the template for Part 2 of Lab 7.
//
// Paul Chow
// November 2021
//

module part2(
            /*************INPUTS************/
            reset, //active low synchronous reset 
            iPlotBox, //When pulsed (goes high then low), it triggers the circuit to start drawing the square with the specified colour at the specified coordinates 
            q, //colour that the square will be (001, 010, or 100 for RGB)
            //when high, the value present on iXY_Coord is loaded into the x coordinate register, 
            //if it stays high, the value on iXY_Coord will continue to be laoded into the X register with every clock cycle
            address, //Specify the X and Y coordinates where the 4 by 4 pixel square will be drawn on the display
            clock, //clock input

            /*************OUTPUTS************/
            x_counter, //outputs carry the current x and y pixel coordinates to the VGA adapter, indicating where to draw on the screen
            y_counter,
            colour, //output provides the colour value for the current pixel to be drawn and is sent to the VGA adapter 
            oPlot, //control signal that acts as a write enable. when High, the VGA adapter will draw the pixel at the coordinate (oX, oY)
            oDone); //output signal that indicates that the circuit has completed the task 
               //set high after the circuit has finished drawing a box or clearing the screen. remains high until iPlotBox or iBlack is pulsed again 
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   input wire reset, iPlotBox;
   input wire [2:0] q;
   input wire [14:0] address;
   input wire 	    clock;
   output wire [7:0] x_counter;         // VGA pixel coordinates
   output wire [6:0] y_counter;

   output wire [2:0] colour;     // VGA pixel colour (0-7)
   output wire 	     oPlot;       // Pixel draw enable
   output wire       oDone;       // goes high when finished drawing frame

   //instantiate Control and Datapath modules 
   wire loadD, plot;
   wire [14:0] counter;

   
   Control C1 (
   .clock(clock),
   .reset(reset),
   .iPlotBox(iPlotBox),
   .counter(counter),   
   .loadD(loadD),
   .done(oDone),
   .plot(plot));

// Instantiate Datapath module
Datapath D1 (
   .clock(clock),
   .reset(reset),
   .ControlD(loadD),
   .x_counter(x_counter),
   .y_counter(y_counter),
   .colour(colour),
   .counter(counter));

endmodule // part2


//FSM to control which state we need to be in and assert the control signal to datapath 
module Control(
   input clock,
   input reset,
   input iPlotBox,
   input [14:0] counter, //15 bit counter

   //outputs to datapath and VGA
   output reg loadD, //start drawing
   output reg done, //must be high until we pulse iPlotBox or iBlack
   output reg plot //output to VGA
   );

   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;

   // internal registers for current and next states. must be 3 bits wide because we have 7 different states in the FSM
   reg [2:0] current;
   reg [2:0] next;

   //state parameters. need to also account for waiting time in between each state.
   localparam 
               S_DRAW = 3'd0,
               S_DRAW_WAIT = 3'd1,
               S_CLEAR = 3'd2;

   always @ (posedge clock) begin
   if (!reset) begin // active low reset
      current <= S_DRAW; // back to start
      loadD <= 0;
      done <= 0;
      plot <= 0;
   end 

   else begin
      current <= next; 
   end
   end

   always @ (*) begin // State table 
      // reset all control signals at the beginning of each state transition so they dont stay high

      loadD = 0;
      plot = 0;
      
      case (current)
         S_DRAW: begin // if counter hits 1111, then we know we are done drawing the box
            loadD = 1; // assert loadD to start drawing
            plot = 1; // assert plot to enable drawing on VGA
            next = (counter == 19200) ? S_DRAW_WAIT : current;
         end

         S_DRAW_WAIT: begin // either after we have drawn or cleared the screen, we have to wait for the x to be loaded again
            done = 1; // assert done to indicate completion
            (next == S_DRAW_WAIT) // Assert done after clearing is complete
         end

         default: begin
            next = S_DRAW;
         end
      endcase 
   end
endmodule



// Datapath module to handle drawing and clearing operations
module Datapath(
    input clock,
    input reset,
    input [14:0] address, // initial X and Y coord
    input ControlD, // control when to draw and output the x/y registers
    output reg [7:0] x_counter, //x coord
    output reg [6:0] y_counter, //y coord
    output reg [2:0] colour, //colour
    output reg [14:0] counter //internal counter
);


    reg [2:0] colour; // 001, 010, 100

    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;

    always @(posedge Clock) begin
        if (!reset) begin
            // Reset logic
            colour <= 3'b0;
            counter <= 14'b0;
            x_counter <= 8'b0;
            y_counter <= 7'b0;
        end 
       
		if (ControlD) begin
			if (address < 19200) begin 
            	address <= address + 1; 
            	x <= x_counter;
            	y <= y_counter;

            	if(x_counter == 160 && y_counter == 120) begin
                	x_counter <= 0;
                	y_counter <= 0;
            	end
				else
           		begin
                if(x_counter < 160) begin
                	x_counter <= x_counter + 1;
                end
            else begin
                x_counter <= 0;
                y_counter <= y_counter + 1;
            end
            end           
        	end
            end 
 
            else begin
                counter <= 0;
            end
			
			if(current_level == 2'b00)
        	begin
			colour <= colour0;
        	end
	
        	else if(current_level == 2'b01)
       		begin
            colour <= avani_col;
        	end
        	else if(current_level == 2'b10)
        	begin
            colour <= colour2;
        	end
        end
    end


endmodule