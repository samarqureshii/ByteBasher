/** TESTING TRANSITION FROM LOBBY TO GAME START WITH MIF CHANGE **/
module topLevel( 
    input CLOCK_50,  // System clock
    input KEY0,      // Start button
    input reset,     // System reset
    // ... other inputs ...
    output [8:0] board_out  // Ootput to display
);
    wire [2:0] state;
    input wire iStart = KEY0; 

    // Instantiate Control module
    Control ctrl (
        .clk(CLOCK_50), 
        .reset(reset), 
        .iStart(iStart), 
        .state(state)
    );

    // Instantiate datapath module
    datapath dp (
        .clk(CLOCK_50), 
        .reset(reset), 
        .go(iStart),  // Assuming 'go' is the game start signal
        .state(state), 
        .board_out(board_out)
        // ... other connections ...
    );

    // ... additional top-level logic ...
endmodule
