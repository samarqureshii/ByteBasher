//two 7 segment bit counters to display to the user the time left on the game
module toplevel (input CLOCK_50, input [9:0] SW, output [6:0] HEX0, output [6:0] HEX1);
    wire [3:0] onesValue, tensValue;

    twoPlaceCounter #(50000000) tpc (CLOCK_50, SW[9], SW[1:0], onesValue, tensValue);
    
    hex_decoder hd_ones (onesValue, HEX0); //ones place (HEX0)
    hex_decoder hd_tens (tensValue, HEX1); //tens place (HEX1)
endmodule



module twoPlaceCounter
    #(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    input [1:0] Speed,
    output [3:0] OnesCounterValue,
    output [3:0] TensCounterValue);
    
    wire Enable;
    wire TensIncrement; // when the tens place will be incremented, and ones place gets reset back to 0
    wire dummy;

    RateDivider #(CLOCK_FREQUENCY) U0(ClockIn, Reset, Speed, Enable);
    DisplayCounter U1(ClockIn, Reset, EN, OnesCounterValue, TensIncrement);
    DisplayCounter U2(ClockIn, Reset, TensIncrement, TensCounterValue, dummy);

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
    output reg incrementTens); //increment the MSB (hex1 counter)

    always @(posedge Clock) begin
        if (Reset) begin
            CounterValue <= 4'b0000;
            IncrementNext <= 1'b0;
        end
        else if (EnableDC) begin
            if (CounterValue == 4'b1001)
            begin //hit 9 , need to reset back to 0 and increment the other display
                CounterValue <= 4'b0000;
                incrementTens <= 1'b1; 
            end
            else begin
                CounterValue <= CounterValue + 1;
                incrementTens <= 1'b0;
            end
        end
    end
endmodule
