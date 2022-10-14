`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 10:59:44
// Design Name: 
// Module Name: MCycle
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
/* 
----------------------------------------------------------------------------------
--	(c) Shahzor Ahmad, Rajesh C Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------
*/

module MCycle

    #(parameter width = 32) // Keep this at 4 to verify your algorithms with 4 bit numbers (easier). When using MCycle as a component in ARM, generic map it to 32.
    (
        input CLK,
        input RESET, // Connect this to the reset of the ARM processor.
        input Start, // Multi-cycle Enable. The control unit should assert this when an instruction with a multi-cycle operation is detected.
        input [1:0] MCycleOp, // Multi-cycle Operation. "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division. Generated by Control unit
        input [width-1:0] Operand1, // Multiplicand / Dividend
        input [width-1:0] Operand2, // Multiplier / Divisor
        output reg [width-1:0] Result1, // LSW of Product / Quotient
        output reg [width-1:0] Result2, // MSW of Product / Remainder
        output reg Busy // Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
    );
    
// use the Busy signal to reset WE_PC to 0 in ARM.v (aka "freeze" PC). The two signals are complements of each other
// since the IDLE_PROCESS is combinational, instantaneously asserts Busy once Start is asserted
  
    parameter IDLE = 1'b0 ;  // will cause a warning which is ok to ignore - [Synth 8-2507] parameter declaration becomes local in MCycle with formal parameter declaration list...

    parameter COMPUTING = 1'b1 ; // this line will also cause the above warning
    reg state = IDLE ;
    reg n_state = IDLE ;
   
    reg done ;
    reg [1:0] sign_cases = 0;
    reg [7:0] count = 0 ; // assuming no computation takes more than 256 cycles.
    reg [2*width-1:0] temp_sum = 0 ;
    reg [2*width-1:0] shifted_op1 = 0 ;
    reg [2*width-1:0] shifted_op2 = 0 ;    
    
    /*************** Division Registers ***************/
    reg [width-1:0] quotient = 0 ;
    
    /************** Multiplication Registers ***************/
    reg signed [(2*width):0] temp_sum_booth = 0;   // temp_sum with 1 bit of extra space, for boothBit
    reg [(2*width):0] boothMultiplicand = 0;       // Multiplicand aligned to MSB of temp_sum_booth
    reg [(2*width):0] boothMultiplicand2s = 0;     // 2s complemented Multiplicand aligned to MSB of temp_sum_booth
    reg [2*width:0] temp_shifted_op1 = 0;          // used for Sequential Multiplier (unsigned)
   
    always@( state, done, Start, RESET ) begin : IDLE_PROCESS  
		// Note : This block uses non-blocking assignments to get around an unpredictable Verilog simulation behaviour.
        // default outputs
        Busy <= 1'b0 ;
        n_state <= IDLE ;
        
        // reset
        if(~RESET)
            case(state)
                IDLE: begin
                    if(Start) begin // note: a mealy machine, since output depends on current state (IDLE) & input (Start)
                        n_state <= COMPUTING ;
                        Busy <= 1'b1 ;
                    end
                end
                COMPUTING: begin
                    if(~done) begin
                        n_state <= COMPUTING ;
                        Busy <= 1'b1 ;
                    end
                end        
            endcase    
    end


    always@( posedge CLK ) begin : STATE_UPDATE_PROCESS // state updating
        state <= n_state ;    
    end

    
    always@( posedge CLK ) begin : COMPUTING_PROCESS // process which does the actual computation
        // n_state == COMPUTING and state == IDLE implies we are just transitioning into COMPUTING
        if( RESET | (n_state == COMPUTING & state == IDLE) ) begin // 2nd condition is true during the very 1st clock cycle of the multiplication
            count = 0 ;
            temp_sum = 0 ;
            quotient = 0;
            shifted_op1 = { {width{~MCycleOp[0] & Operand1[width-1]}}, Operand1 } ; // sign extend the operands  
            shifted_op2 = { {width{~MCycleOp[0] & Operand2[width-1]}}, Operand2 } ; // sign extend the operands
            
            /////////////////////////// DIVISION PREPROCESSING ///////////////////////////
            
            if (~MCycleOp[0] & MCycleOp[1]) begin     // for Signed Division Only
                // change operands to +ve if -ve
                if (Operand1[width-1] == 1) begin     
                    shifted_op1 = ~shifted_op1 + 1'b1;
                end
                if (Operand2[width-1] == 1) begin     
                    shifted_op2 = ~shifted_op2 + 1'b1;
                end
               
               if (Operand1[width-1]) begin      // Dividend is -ve
                    sign_cases[0] = 1;            // To invert remainder
                end
                
                if (Operand1[width-1] == ~Operand2[width-1]) begin     // if dividend and divisor are opp signs
                    sign_cases[1] = 1;              // To invert the quotient
                end
            end
            
            if (MCycleOp[1]) begin      // To fill LSBs of Divisor with 0s
                shifted_op2 = { shifted_op2[width - 1:0], {width{1'b0}} };
            end
            
            /////////////////////////// MULTIPLICATION PREPROCESSING ///////////////////////////
            if (~MCycleOp[1]) begin
                if (~MCycleOp[0]) begin
                    // Signed Multiplication
                    temp_sum_booth = { {(width){1'b0}}, Operand2, {1{1'b0}} };      // store Multiplier and boothBit in LSBs
                    boothMultiplicand = { Operand1, {(width+1){1'b0}} };
                    boothMultiplicand2s = { (~Operand1 + 1'b1), {(width+1){1'b0}} };
                end else begin
                    // Unsigned Multiplication
                    temp_sum_booth = { {(width+1){1'b0}}, Operand2};
                    temp_shifted_op1 = { 1'b0, Operand1, {(width){1'b0}} };
                end
            end
        end;
               
        done <= 1'b0 ;   
        
        //////////////////// Multiply (Operand1 = Multiplier, Operand2 = Multiplicand) ////////////////////
        if(~MCycleOp[1]) begin
            // if(~MCycleOp[0]) aka signed,
            //   - Booth's Algorithm takes (WIDTH) cycles to execute, only need to iterate through bits of Multiplier
            //      - guaranteed not to overflow due to additional bit at LSB
            //   - Sequential Multiplication takes (WIDTH) cycles to execute
            //      - chance of overflow, need to consider carry bit
            
            // Signed Multiplication (using Booth's Algorithm)
            if (~MCycleOp[0]) begin
                
                case (temp_sum_booth[1:0])
                    2'b00 : begin
                                temp_sum_booth = temp_sum_booth >>> 1;
                            end
                    2'b11 : begin
                                temp_sum_booth = temp_sum_booth >>> 1;
                            end
                    2'b10 : begin
                                temp_sum_booth = temp_sum_booth + boothMultiplicand2s;
                                temp_sum_booth = temp_sum_booth >>> 1;
                                
                                // if Multiplicand is the most negative number in 2s complement, then 2s complementing it again will make NO difference.
                                // Thus, use a carry flag to deal with this (ensure that after shift operation, the result is seen as POSITIVE, i.e MSB is 0)
                                if (Operand1[width-1] == 1'b1 && Operand1[width-2:0] == 0)
                                    temp_sum_booth[2*width] = 1'b0;
                            end
                    2'b01 : begin
                                temp_sum_booth = temp_sum_booth + boothMultiplicand;
                                temp_sum_booth = temp_sum_booth >>> 1;
                            end
                endcase
                
                // check if last cycle
                if(count == width-1) begin
                    temp_sum = temp_sum_booth[(2*width):1];    // remove boothBit from result
                    done <= 1'b1;
                end   
                               
                count = count + 1;
            end
            
            
            // Unsigned Multiplier (Sequential Algorithm)
            else begin
               if (temp_sum_booth[0]) begin
                        temp_sum_booth = temp_sum_booth + temp_shifted_op1;
                end
                
                temp_sum_booth = temp_sum_booth >> 1;
                
                if (count == width-1) begin // last cycle?
                    done <= 1'b1;
                    temp_sum = temp_sum_booth[(2*width-1):0];
                end
                
                count = count + 1;  
            end 
        end    
        
         ///////////////////////////////////////////// Division /////////////////////////////////////////////
        else if (MCycleOp[1]) begin     // division.
            // shifted_op1 -- Dividend / Remainder
            // shifted_op2 -- Divisor
            
            shifted_op1 = shifted_op1 - shifted_op2;
            
            if (shifted_op1[2*width-1] == 0) begin      // remainder >= 0
                quotient = {quotient[2:0], 1'b1};       // shift Quotient left with LSB = 1
            end
            else begin      // remainder < 0
                shifted_op1 = shifted_op1 + shifted_op2;     // add back the divisor
                quotient = {quotient[2:0], 1'b0};           // shift Quotient by left with LSB = 0
            end
              
            shifted_op2 = {1'b0, shifted_op2[2*width-1:1]};  // divisor shift right
            
            count = count + 1;
            
          
            if(count == width + 1) begin       // check for last cycle
                if (sign_cases[0] == 1) begin
                    shifted_op1[3:0] = ~shifted_op1[3:0] + 1'b1;
                end
                if (sign_cases[1] == 1) begin 
                    quotient = ~quotient + 1'b1;
                end
                
                temp_sum = {shifted_op1[3:0], quotient};   // remainder as MSW and quotient as LSW  
                sign_cases = 2'b0;
                done <= 1'b1;
            end
        
        end
        
        
        Result2 <= temp_sum[2*width-1 : width] ;
        Result1 <= temp_sum[width-1 : 0] ;     
    end
endmodule