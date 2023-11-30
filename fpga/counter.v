//two 7 segment bit counters to display to the user the time left on the game
module counter (
    input CLOCK_50, 
    input [9:0] SW, 
    output [6:0] HEX0, 
    output [6:0] HEX1
); 
    wire [3:0] onesValue, tensValue;
    
    // Pass SW[1:0] to the counter_m module to reset the counters
    counter_m #(50000000) tpc (CLOCK_50, SW[1:0], onesValue, tensValue);
    
    hex_decoder hd_ones (onesValue, HEX0);
    hex_decoder hd_tens (tensValue, HEX1);
endmodule


module counter_m
    #(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    output [3:0] OnesCounterValue,
    output [3:0] TensCounterValue);

    wire Enable;
    wire TensIncrement;
    wire Reached60;

    // when SW[1:0] is high, we want to reset the counter back to 0 
    wire resetCounters = |Reset;

    RateDivider #(CLOCK_FREQUENCY) U0(ClockIn, resetCounters, Enable);
    DisplayCounter onesCounter (ClockIn, resetCounters, Enable, OnesCounterValue, TensIncrement, /* Reached60 unused */);
    DisplayCounter tensCounter (ClockIn, resetCounters, TensIncrement, TensCounterValue, /* TensIncrement unused */, Reached60); 

endmodule



module RateDivider #(parameter FREQUENCY = 50000000) (
    input ClockIn, 
    input Reset,
    output reg enable);

    reg [26:0] downCount; //prob should use the log function

    always @(posedge ClockIn) begin
        if(Reset || downCount == 0) begin
            enable <= 1'b1;
            downCount <= FREQUENCY - 1; // count down from 50 000 000 for 1 second
        end 
        else begin
            downCount <= downCount - 1;
            enable <= 0;
        end
    end
endmodule



module DisplayCounter (
    input CLOCK,
    input RESET,
    input EnableDC,
    output reg [3:0] CounterValue,
    output reg TensIncrement,
    output reg Reached60
);
    reg [3:0] nextCounterValue;

    always @* begin
        if (CounterValue == 4'b1001) begin // reached 9
            nextCounterValue = 4'b0000;
            TensIncrement = 1'b1;
        end else begin
            nextCounterValue = CounterValue + 1;
            TensIncrement = 1'b0;
        end

        // Determine if 60 is reached in the tens counter
        Reached60 = (CounterValue == 4'b0110);
    end

    always @(posedge CLOCK) begin
        if (RESET || Reached60) begin
            CounterValue <= 4'b0000;
        end
        else if (EnableDC) begin
            CounterValue <= nextCounterValue;
        end
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

