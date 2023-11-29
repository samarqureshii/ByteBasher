`timescale 1ns / 1ns

module input_receiver(GPIO_0, GPIO_1, GPIO_2, LEDR);
    input [0:0] GPIO_0;  
    input [0:0] GPIO_1; 
    input [0:0] GPIO_2;  
    output [9:0] LEDR;  

    // first three LEDs to the GPIO inputs so we know the binary value
    assign LEDR[0] = GPIO_0[0];
    assign LEDR[1] = GPIO_1[0];
    assign LEDR[2] = GPIO_2[0];

    // remaining LEDs are turned off
    assign LEDR[9:3] = 7'b0;
endmodule
