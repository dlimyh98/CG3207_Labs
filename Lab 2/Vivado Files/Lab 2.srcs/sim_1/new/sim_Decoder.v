`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.09.2022 16:41:52
// Design Name: 
// Module Name: sim_Decoder
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


module sim_Decoder(
    );
    
    reg [3:0] Rd;
    reg [1:0] Op;
    reg [5:0] Funct;
    wire PCS;
    wire RegW;
    wire MemW;
    wire MemtoReg;
    wire ALUSrc;
    wire [1:0] ImmSrc;
    wire [1:0] RegSrc;
    wire NoWrite;
    wire [1:0] ALUControl;
    wire [1:0] FlagW;
    
    Decoder dut(Rd, Op, Funct, PCS, RegW, MemW, MemtoReg, ALUSrc, ImmSrc, RegSrc, NoWrite, ALUControl, FlagW);
    
    initial begin
        // DP Imm instruction, where Rd = PC
        Rd = 4'b1111;
        Op = 2'b00;
        Funct = 6'b100101;
        /* Expected Output
            - PCS = 1'b1
            - RegW = 1'b1
            - MemW = 1'b0
            - MemtoReg = 1'b0
            - ALUSrc = 1'b1
            - ImmSrc = 2'b00
            - RegSrc = 2'bX0
            - NoWrite = 1'b0
            - ALUControl = 2'b01
            - FlagW = 2'b11
        */
    end
    
endmodule
