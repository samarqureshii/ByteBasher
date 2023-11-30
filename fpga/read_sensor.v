`timescale 1ns / 1ns

module read_sensor(GPIO_1, LEDR);
    input [2:0] GPIO_1;  // Declare GPIO_1 as a 3-bit input
    output [9:0] LEDR;  

    // first three LEDs to the GPIO inputs so we know the binary value
    assign LEDR[0] = GPIO_1[0];
    assign LEDR[1] = GPIO_1[1];
    assign LEDR[2] = GPIO_1[2];

    // remaining LEDs are turned off
    assign LEDR[9:3] = 7'b0;
endmodule
