`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2022 20:51:43
// Design Name: 
// Module Name: LED_Control
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LED_Control(
    input clk,
    input upper_lower,
    input [31:0] data,
    output reg [15:0] led = 16'b0
    );
    
always @ (posedge clk) begin
    if (upper_lower) begin     // display 16 MSB
        led [15:0] <= data[31:16];
    end else begin             // display 16 LSB
        led [15:0] <= data[15:0];
    end
end
    
endmodule
