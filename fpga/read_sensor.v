`timescale 1ns / 1ns

module read_sensor(GPIO_1, LEDR, box_address);
    input [2:0] GPIO_1;  // Declare GPIO_1 as a 3-bit input
    output [2:0] LEDR;  
    output[2:0] box_address;

    // first three LEDs to the GPIO inputs so we know the binary value
    assign LEDR[0] = GPIO_1[0];
    assign LEDR[1] = GPIO_1[1];
    assign LEDR[2] = GPIO_1[2];

    assign box_address = GPIO_1;

endmodule
