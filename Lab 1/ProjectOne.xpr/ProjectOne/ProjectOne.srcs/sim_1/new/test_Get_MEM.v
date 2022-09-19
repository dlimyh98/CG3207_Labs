`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.09.2022 10:45:45
// Design Name: 
// Module Name: test_Get_MEM
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


module test_Get_MEM(
    );
    
    reg clk;
    reg enable;
    wire [31:0] data;
    wire upper_lower;
    wire [15:0] led;
    
    //wire [15:0] msbData;
    //assign msbData[15:0] = data[31:16];
    
    Get_MEM dut1 (clk, enable, data, upper_lower);
    LED_Control dut2 (clk, upper_lower, data, led);
    
    initial begin
        clk = 0;
        enable = 0;
    end
    
    always begin
        #10 clk = ~clk;
    end
    
    always begin
        #110 enable = 1;
        #10 enable = 0;
    end
endmodule
