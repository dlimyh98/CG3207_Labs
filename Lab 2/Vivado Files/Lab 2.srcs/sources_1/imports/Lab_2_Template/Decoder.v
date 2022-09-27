`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Shahzor Ahmad and Rajesh Panicker  
-- 
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module Decoder(
    input [3:0] Rd,
    input [1:0] Op,
    input [5:0] Funct,
    output reg PCS = 1'b0,
    output reg RegW = 1'b0,
    output reg MemW = 1'b0,
    output reg MemtoReg = 1'b0,
    output reg ALUSrc = 1'b0,
    output reg [1:0] ImmSrc = 2'b00,
    output reg [1:0] RegSrc = 2'b00,
    output reg NoWrite = 1'b0,
    output reg [1:0] ALUControl = 2'b00,
    output reg [1:0] FlagW = 2'b00
    );
    
    wire [1:0] ALUOp;
    wire Branch;
    reg [1:0] ALUOp_toSend = 2'b00;
    reg Branch_toSend = 1'b0;
    assign ALUOp = ALUOp_toSend;
    assign Branch = Branch_toSend;
   
    
    // Main Decoder Logic
    // Input = Op, Funct[5] (I bit), Funct[0] (DP S bit, Memory L bit), Funct[3] (Memory U bit)
    // Output = RegW, MemW, MemtoReg, ALUSrc, ImmSrc, RegSrc
    always @ (Op, Funct[5], Funct[0], Funct[3]) begin
        case (Op)
            2'b00 : begin
                        // assert must be DP Imm or DP Reg (with immediate shift)
                        {Branch_toSend, MemtoReg, MemW} = 3'b000;
                        RegW = 1'b1;
                        ALUOp_toSend = 2'b11;
                        
                        if (Funct[5] == 0) begin
                            // assert DP Reg
                            ALUSrc = 1'b0;
                            {ImmSrc, RegSrc} = 4'b0000;   // ImmSrc == XX for DP Reg
                        end else begin
                            // assert DP Imm
                            ALUSrc = 1'b1;
                            {ImmSrc, RegSrc} = 4'b0000;   // RegSrc == X0 for DP Imm
                        end
                    end
                    
            2'b01 : begin
                        // assert must be STR or LDR (positive/negative immediate offset)
                        Branch_toSend = 1'b0;
                        {MemtoReg, ALUSrc} = 2'b11;   // MemtoReg == X for STR
                        ImmSrc = 2'b01;
                        RegSrc = 2'b10;               // RegSrc == X0 for LDR
                        
                        if (Funct[3] == 0) ALUOp_toSend = 2'b01;    // U-Bit == 0 means subtract unsigned offset
                            else ALUOp_toSend = 2'b00;              // U-Bit == 1 means add unsigned offset
                        
                        if (Funct[0] == 0) begin
                            // assert STR
                            MemW = 1'b1;
                            RegW = 1'b0;
                        end else begin
                            // assert LDR
                            MemW = 1'b0;
                            RegW = 1'b1;
                        end
                    end
                    
            2'b10 : begin
                        // assert must be Branch
                        {MemtoReg, MemW, RegW} = 3'b000;
                        ALUOp_toSend = 2'b00;
                        {Branch_toSend, ALUSrc} = 2'b11;
                        ImmSrc = 2'b10;
                        RegSrc = 2'b01;
                    end
                    
            2'b11 : begin
                        // assert must be invalid command (all output signals X)
                        {Branch_toSend, MemtoReg, MemW, ALUSrc, RegW, ALUOp_toSend} = 6'b000000;
                        {ImmSrc, RegSrc} = 2'b00;
                    end                                      
        endcase
    end
    
    
    // PC Logic
    // Input = Branch. RegW, Rd[3:0]
    // Output = PCS
    always @ (Branch, RegW, Rd[3:0]) begin
        if (Branch == 1'b0) begin
            if (Rd == 4'd15 && RegW == 1'b1) PCS = 1'b1; // PC is Rd for some instruction
            else PCS = 1'b0;                             // PC is not Rd for some instruction
        end else begin
            PCS = 1'b1;
        end
    end
    
    
    // ALU Decoder Logic
    // Input = ALUOp, Funct[4:0] (Funt[5] is I bit)
    // Output = ALUControl[1:0] and FlagW[1:0]
    always @ (ALUOp, Funct[4:0]) begin
        case (ALUOp)
            2'b00 : begin
                        // assert must be positive offset STR/LDR (with unsigned offset)
                        // assert must be B (with signed offset)
                        ALUControl = 2'b00;
                        FlagW = 2'b00;
                        NoWrite = 1'b0;
                    end
                    
            2'b01 : begin
                        // assert must be negative offset STR/LDR (with unsigned offset)
                        ALUControl = 2'b01;
                        FlagW = 2'b00;
                        NoWrite = 1'b0;
                    end
                    
            2'b11 : begin
                        // assert must be DP instructions (positive/negative offset)
                        FlagW = Funct[0] ? 2'b11 : 2'b00;
                        NoWrite = 1'b0;
                        
                        case (Funct[4:1])   // Funct[4:1] == cmd (DP) or PUBW (Memory)
                            4'b0100 : begin // ADD or ADDS (set NZCV flags)
                                          ALUControl = 2'b00;
                                          FlagW = (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                                      end
                            4'b0010 : begin // SUB or SUBS (set NZCV flags)
                                          ALUControl = 2'b01; 
                                          FlagW = (Funct[0] == 1'b1) ? 2'b11 : 2'b00;
                                      end
                            4'b0000 : begin // AND or ANDS (for now doesn't affect C flag)
                                          ALUControl = 2'b10;
                                          FlagW = (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                                      end              
                            4'b1100 : begin // ORR or ORRS (for now doesn't affect C flag)
                                          ALUControl = 2'b11;
                                          FlagW = (Funct[0] == 1'b1) ? 2'b10 : 2'b00;
                                      end
                            4'b1010 : begin // CMP (set NZCV flags automatically)
                                ALUControl = 2'b01;
                                FlagW = 2'b11;
                                NoWrite = 1'b1;
                            end
                            4'b1011 : begin // CMN (set NZCV flags automatically)
                                ALUControl = 2'b00;
                                FlagW = 2'b11;
                                NoWrite = 1'b1;
                            end       
                            default : begin // undefined signals
                                ALUControl = 2'b00;
                                FlagW = 2'b00;
                                NoWrite = 1'b0;
                            end
                        endcase
                    end
                    
            2'b10 : begin
                        // assert undefined
                        {ALUControl, FlagW, NoWrite} = 2'b00;
                    end
        endcase            
    end
    
endmodule