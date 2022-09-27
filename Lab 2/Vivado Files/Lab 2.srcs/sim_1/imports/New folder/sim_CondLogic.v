`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/15/2022 04:25:53 PM
// Design Name: 
// Module Name: sim_CondLogic
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


module sim_CondLogic(

    );
    
    reg CLK = 0;
    reg PCS = 0;
    reg RegW = 0;
    reg NoWrite = 0; 
    reg MemW = 0;
    reg [1:0] FlagW = 0;
    reg [3:0] Cond = 0;
    reg [3:0] ALUFlags = 0;
    wire PCSrc ;
    wire RegWrite ;
    wire MemWrite ;
    
    CondLogic dut(CLK, PCS, RegW, NoWrite, MemW, FlagW, Cond, ALUFlags, PCSrc, RegWrite, MemWrite);
    
    initial begin
        #5; // for a STR instruc
        PCS = 0;
        RegW = 0;
        NoWrite = 0;
        MemW = 1;
        FlagW = 2'b0;
        Cond = 4'b1110;
        ALUFlags = 4'b0;
        #10;
        // for ADDEQS instruc
        PCS = 0;
        RegW = 1;
        NoWrite = 0;
        MemW = 0;
        FlagW = 2'b11;
        Cond = 4'b0000;
        ALUFlags = 4'b1111;
    end
    
    always begin
       #5 CLK = ~CLK ; // invert clk every 5 time units 
    end
    
    
    
    
endmodule
