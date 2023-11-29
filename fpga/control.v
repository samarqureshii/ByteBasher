module Control()
localparam = S_INIT = 3'd0, //known, constant state
            S_LOBBY  = 3'd1, //display welcome screen and game instructions (static mif)
            S_START_GAME = 3'd2,//user clicks a button on FPGA and start up sequence transition to active game. get all the counter/registers/control signals ready atp
            S_ACTIVE_GAME = 3'd3,//constantly waiting on input from the 
            S_HIT_DETECTED  = 3'd4,//when the enable signal from the arduino is anything but 4'b0000
            S_GAME_OVER = 3'd5, // when the counter hits time3, transition to S_LOBBY (or S_RESET atp)
            S_RESET = 3'd6; //reset everything, counter, enable signals, registers, etc etc 

reg [2:0] current, next;

always @ (*) begin //state table 
    case(current)
        S_INIT: begin
        end

        S_LOBBY: begin
        end

        S_START_GAME: begin
        end
    endcase
end

endmodule   