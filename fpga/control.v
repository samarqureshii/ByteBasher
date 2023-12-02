module Control();
    localparam S_INIT = 3'd0,
               S_LOBBY = 3'd1,
               S_START_GAME = 3'd2,
               S_ACTIVE_GAME = 3'd3,
               S_HIT_DETECTED = 3'd4,
               S_GAME_OVER = 3'd5,
               S_RESET = 3'd6;

    reg [2:0] current_state, next_state;
    reg [1:0] difficulty;
    output reg [10:0] score;
    // more control enable signals here 

    always @(*) begin
        case(current_state)
            S_LOBBY: begin
                //initialize stats and everything 
                // transition to S_START_GAME when start HIGH from KEY0
                if (iStart) //if iStart is enabled (controlled by KEY0)
                    next_state = S_START_GAME;
                    difficulty = b'01;
                else //keep waiting in the lobby
                //MIF in this state should be the lobby
                //audio in this state should be the mario sound 
                    next_state = S_LOBBY;
            end

            S_ACTIVE_GAME: begin
                //check for game hit, or check 
                //once the counter hits 20, assert a control signal that 
                if (box_address!=4b'0000) //if the binary read from the Arduino is not 0
                    next_state = S_HIT_DETECTED;
                else if (counter == d'60) //once the counter hits 60
                    next_state = S_GAME_OVER;
                else 
                    next_state = S_ACTIVE_GAME;
            end
            S_HIT_DETECTED: begin
                //play audio sound
                hit_detected = b'1;
                next_state = S_ACTIVE_GAME;
            end
            S_GAME_OVER: begin
                // display game over screen, final score, etc.
                // transition to S_RESET or S_LOBBY based on user input
                next_state = S_LOBBY; // or S_RESET based on user choice
            end
            S_RESET: begin // reset all control signals
                counter = d'0;
                next_state = S_LOBBY;
            end
            default: begin
                next_state = S_LOBBY;
            end
        endcase
    end

    // Sequential logic for state transition
    always @(posedge clk or posedge reset) begin
        if (reset) 
            current_state <= S_RESET;
        else 
            current_state <= next_state;
    end



endmodule
