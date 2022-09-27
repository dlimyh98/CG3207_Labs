`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.08.2022 18:21:53
// Design Name: 
// Module Name: test_Clock_Enable
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


module test_Clock_Enable(
    );
    
    // DECLARE INPUT SIGNALS
    reg clk;
    reg btnU;
    reg btnC;
    
    // DECLARE OUTPUT SIGNALS
    wire enable;
    
    Clock_Enable dut (clk, btnU, btnC, enable);
    
    initial begin
        clk = 0;
        btnU = 0;
        btnC = 0;
    end
    
    always begin
        #10 clk = ~clk;
    end
endmodule
