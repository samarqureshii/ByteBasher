//two 7 segment bit counters to display to the user the time left on the game
module counter (input CLOCK_50, input [9:0] SW, output [6:0] HEX0, output [6:0] HEX1); //this is just to test the counter on its own 
    wire [3:0] onesValue, tensValue;
    counter_m #(50000000) tpc (CLOCK_50, SW[9], SW[1:0], onesValue, tensValue);
    
    hex_decoder hd_ones (onesValue, HEX0); //ones place (HEX0)
    hex_decoder hd_tens (tensValue, HEX1); //tens place (HEX1)
endmodule



module counter_m
    #(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    input [1:0] Speed,
    output [3:0] OnesCounterValue,
    output [3:0] TensCounterValue);
    
    wire Enable;
    wire TensIncrement;
    wire Reached60; // Signal to indicate if 60 is reached

    RateDivider #(CLOCK_FREQUENCY) U0(ClockIn, Reset, Enable);

    // Display counter for the ones place
    DisplayCounter U1(
        .Clock(ClockIn), 
        .Reset(Reset), 
        .EnableDC(Enable), 
        .CounterValue(OnesCounterValue), 
        .TensIncrement(TensIncrement), 
        .Reached60() // Not used in the ones counter
    );

    // Display counter for the tens place
    DisplayCounter U2(
        .Clock(ClockIn), 
        .Reset(Reset), 
        .EnableDC(TensIncrement), 
        .CounterValue(TensCounterValue), 
        .TensIncrement(), // Not used in the tens counter
        .Reached60(Reached60) // Connected to check if 60 is reached
    );

endmodule


module RateDivider #(parameter FREQUENCY = 50000000) (
    input ClockIn, 
    input Reset,
    output reg Enable);

    reg [26:0] downCount; //prob should use the log function

    always @(posedge ClockIn) begin
        if(Reset || downCount == 0) begin
            Enable <= 1'b1;
            downCount <= FREQUENCY - 1; // count down from 50 000 000 for 1 second
        end 
        else begin
            downCount <= downCount - 1;
            Enable <= 0;
        end
    end
endmodule



module DisplayCounter (
    input Clock,
    input Reset,
    input EnableDC,
    output reg [3:0] CounterValue,
    output reg TensIncrement,
    output reg Reached60); // new signal to indicate if 60 is reached

    always @(posedge Clock) begin
        if (Reset) begin
            CounterValue <= 4'b0000;
            TensIncrement <= 1'b0;
            Reached60 <= 1'b0;
        end else if (EnableDC && !Reached60) begin // check if 60 is not yet reached
            if (CounterValue == 4'b1001) begin
                CounterValue <= 4'b0000;
                TensIncrement <= 1'b1;
            end else begin
                CounterValue <= CounterValue + 1;
                TensIncrement <= 1'b0;
            end
        end
    end

    // logic to set Reached60 when the total count reaches 60
    always @(posedge TensIncrement) begin
        if (CounterValue == 4'b0110) Reached60 <= 1'b1; // When tens place is 6
    end
endmodule


module hex_decoder(c, display);
    input [3:0] c;
    output [6:0] display;
    
    assign c0 = c[0];
    assign c1 = c[1];
    assign c2 = c[2];
    assign c3 = c[3];

    assign display[0] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[1] = (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & ~c0) + (c3 & ~c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[2] = (~c3 & ~c2 & c1 & ~c0) + (c3 & c2 & ~c1 & ~c0) + (c3 & c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);	
    assign display[3] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0) + (c3 & ~c2 & c1 & ~c0) + (c3 & c2 & c1 & c0);
    assign display[4] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & ~c1 & ~c0) + (~c3 & c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & ~c2 & ~c1 & c0);
    assign display[5] = (~c3 & ~c2 & ~c1 & c0) + (~c3 & ~c2 & c1 & ~c0) + (~c3 & ~c2 & c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & c0);
    assign display[6] = (~c3 & ~c2 & ~c1 & ~c0) + (~c3 & ~c2 & ~c1 & c0) + (~c3 & c2 & c1 & c0) + (c3 & c2 & ~c1 & ~c0);
endmodule