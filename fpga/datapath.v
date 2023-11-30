module datapath (
    input go, clock, reset,
    input [2:0] box_address, // input from ultrasonic sensors ( 3 bit binary value)
    output audio_en,
    output reg [8:0] board_out,
    output reg ld_level_draw_comp,
    output reg [10:0] score // Score output
);

    reg [9:0] level_draw_counter;
    reg [2:0] difficulty; // Track difficulty level
    reg [9:0] random_number;
    wire [8:0] ram_out;
    wire [4:0] address;
    reg hit; // flag to indicate hit
    reg [3:0] populated_box; // last populated box

    // randomization for box population
    lfsr L0 (.out(random_number), .enable(go), .clk(clock), .reset(reset));

    // RAM for storing game patterns
    pattern_ram pr0 (.address(address), .clock(clock), .wren(1'b0), .q(ram_out));

    // score and difficulty logic
    always @ (posedge clock) begin
        if (reset) begin
            // Reset logic
            score <= 0;
            difficulty <= 3'b001; // initial difficulty
            hit <= 0;
        end
        else begin
            // update score based on hit and difficulty
            if (hit) begin
                if (box_address == populated_box)
                    score <= score + (1 << difficulty); // Increase score
                else
                    score <= score > (1 << difficulty) ? score - (1 << difficulty) : 0; // Decrease score
            end

            // difficulty adjustment based on time
            if (level_draw_counter >= 20_000_000)
                difficulty <= 3'b010; // level 2
            else if (level_draw_counter >= 40_000_000)
                difficulty <= 3'b100; // level 3

            // xox population logic based on LFSR
            case (random_number[3:0])
                4'b0001: populated_box <= 3'b001; // Box 1
                4'b0010: populated_box <= 3'b010; // Box 2
                4'b1000: populated_box <= 3'b100; // Box 4
                4'b0100: populated_box <= 3'b101; // Box 5
                default: populated_box <= 3'b000; // No box
            endcase

            // update board_out based on RAM content
            board_out <= ram_out;
        end
    end

    // logic to load patterns into RAM based on game state
    always @(*) begin
        case (state)
            // Different addresses for different game states
            // Example: address = <appropriate value based on game state>;
            // ...
        endcase
    end
endmodule
