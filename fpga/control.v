module Control();
    localparam S_INIT = 3'd0,
               S_LOBBY = 3'd1,
               S_START_GAME = 3'd2,
               S_ACTIVE_GAME = 3'd3,
               S_HIT_DETECTED = 3'd4,
               S_GAME_OVER = 3'd5,
               S_RESET = 3'd6;

    reg [2:0] current_state, next_state;
    // more control enable signals here 

    always @(*) begin
        case(current_state)
            S_INIT: begin
                //initialize stats and everyghing(basically like a natural reset)
                next_state = S_LOBBY;
            end
            S_LOBBY: begin
                // flash welcome screen, game instructions
                // transition to S_START_GAME when start HIGH from KEY0
                if (start) 
                    next_state = S_START_GAME;
                else 
                    next_state = S_LOBBY;
            end
            S_START_GAME: begin
                // transition to the screen with the 2 by 2 grid 
                next_state = S_ACTIVE_GAME;
            end
            S_ACTIVE_GAME: begin
                //check for game hit, or check 
                if (hit_detected) 
                    next_state = S_HIT_DETECTED;
                else if (counter == d'60) //once the counter hits 60
                    next_state = S_GAME_OVER;
                else 
                    next_state = S_ACTIVE_GAME;
            end
            S_HIT_DETECTED: begin

                next_state = S_ACTIVE_GAME;
            end
            S_GAME_OVER: begin
                // display game over screen, final score, etc.
                // transition to S_RESET or S_LOBBY based on user input
                next_state = S_LOBBY; // or S_RESET based on user choice
            end
            S_RESET: begin //
                next_state = S_INIT;
            end
            default: begin
                next_state = S_INIT;
            end
        endcase
    end

    // Sequential logic for state transition
    always @(posedge clk or posedge reset) begin
        if (reset) 
            current_state <= S_INIT;
        else 
            current_state <= next_state;
    end

    // Add other logic as needed for each state

endmodule
