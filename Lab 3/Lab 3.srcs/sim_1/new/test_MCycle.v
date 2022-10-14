`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: NUS
// Engineer: Shahzor Ahmad, Rajesh C Panicker
// 
// Create Date: 27.09.2016 16:55:23
// Design Name: 
// Module Name: test_MCycle
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

module test_MCycle(

    );
    
    // DECLARE INPUT SIGNALs
    reg CLK = 0 ;
    reg RESET = 0 ;
    reg Start = 0 ;
    reg [1:0] MCycleOp = 0 ;
    reg [3:0] Operand1 = 0 ;
    reg [3:0] Operand2 = 0 ;

    // DECLARE OUTPUT SIGNALs
    wire [3:0] Result1 ;
    wire [3:0] Result2 ;
    wire Busy ;
    
    // INSTANTIATE DEVICE/UNIT UNDER TEST (DUT/UUT)
    MCycle dut( 
        CLK, 
        RESET, 
        Start, 
        MCycleOp, 
        Operand1, 
        Operand2, 
        Result1, 
        Result2, 
        Busy
        ) ;
    
    // STIMULI
    initial begin
        // hold reset state for 100 ns.
        #10 ;
        
        /************************************* MULTIPLICATION TEST CASES *************************************/
        // 00 = signed Multiply, 01 = unsigned Multiply
        // Operand1 = Multiplicand,  Operand2 = Multiplier
        
        ////////////////////// SIGNED MULTIPLICATION TESTS //////////////////////
        
        MCycleOp = 2'b00;
        
        // -1 x -1 = 1 or 8'b0000_0001
        Operand1 = 4'b1111 ;    
        Operand2 = 4'b1111 ;
        Start = 1'b1 ; // Operations will be performed back to back, if Start is asserted continuously  

        wait(Busy);   // suspend further procedural statements until condition becomes true (suspend until START == 1)
        wait(~Busy);  // suspend further procedural statements until Result is ready
        #10 ;
        Start = 1'b0 ;
        #10 ;
        
        // -7 * -7 = 49 or 8'b0011_0001
        Operand1 = 4'b1001;
        Operand2 = 4'b1001;
        Start = 1'b1;
        wait(Busy);
        wait(~Busy);
        
        // 0 x -7 = 0 or 8'b0000_0000
        Operand1 = 4'b0000;
        Operand2 = 4'b1111;
        wait(Busy);
        wait(~Busy);
    
        // -3 x 2 = -6 or 8'b1111_1010
        Operand1 = 4'b1101 ;    
        Operand2 = 4'b0010 ;
        Start = 1'b1;
        wait(Busy) ;
        wait(~Busy) ;
        
        // -5 x 4 = -20 or 8'b1110_1100;
        Operand1 = 4'b1011;
        Operand2 = 4'b0100;
        wait(Busy) ;
        wait(~Busy) ;
        
        // -8 x 7 = -56 or 8'b1100 1000
        Operand1 = 4'b1000;
        Operand2 = 4'b0111;
        wait(Busy) ;
        wait(~Busy) ;
       
        // 7 x -6 = -42 or 8'b1101 0110;
        Operand1 = 4'b0111;
        Operand2 = 4'b1010;
        wait(Busy); 
        wait(~Busy);
              
        // 1 x -8 = -8 or 8'b1111_1000;
        Operand1 = 4'b0001;
        Operand2 = 4'b1000;
        wait(Busy);
        wait(~Busy);
        
        
        ////////////////////// UNSIGNED MULTIPLICATION TESTS //////////////////////
        MCycleOp = 2'b01 ;
        
        // 15 x 15 = 225 or 8'b1110_0001
        Operand1 = 4'b1111 ;
        Operand2 = 4'b1111 ;
        Start = 1'b1 ;
        
        wait(Busy) ; 
        wait(~Busy) ;
        #10 ;
        Start = 1'b0 ;
        #10 ;
        
        
   
        /************************************* DIVISION TEST CASES *************************************/
        // 10: signed, 11: unsigned
        
        
        // -ve / +ve
        MCycleOp = 2'b10 ;      
        // -4 / 3 = -1 R -1 or 1111 R 1111
        Operand1 = 4'b1100 ;        // 0xC
        Operand2 = 4'b0011 ;        // 0x3
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        #10 ;
        Start = 1'b0 ;
        #10 ;
        
        // -ve / -ve
        MCycleOp = 2'b10 ;      
        // -6 / -4 = 1 R -2 or 0001 R 1110
        Operand1 = 4'b1010 ;        // 0xA
        Operand2 = 4'b1100 ;        // 0xC
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        #10 ;
        Start = 1'b0 ;
        #10 ;
        
        // +ve / +ve
        MCycleOp = 2'b11 ;      
        // 8 / 4 = 2 R 0 or 0010 R 0000
        Operand1 = 4'b1000 ;        // 0x8
        Operand2 = 4'b0100 ;        // 0x4
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        
        // +ve / -ve
        MCycleOp = 2'b10 ;      
        // 3 / -2 = -1 R 1 or 1111 R 0001
        Operand1 = 4'b0011 ;        // 0x3
        Operand2 = 4'b1110 ;        // 0xE
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        
        
        
        // Divide 0 (unsigned)
        MCycleOp = 2'b11 ;      
        // 0 / 5 = 0 R 0 or 0000 R 0000
        Operand1 = 4'b0000 ;        // 0x0
        Operand2 = 4'b0101 ;        // 0x5
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        
        
        // Divide 0 (signed)
        MCycleOp = 2'b10 ;      
        // 0 / -2 = 0 R 0 or 0000 R 0000 
        Operand1 = 4'b0000 ;        // 0x0
        Operand2 = 4'b1110 ;        // 0xE
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        
        // Divisor > Dividend
        MCycleOp = 2'b11 ;      
        // 4 / 8 = 0 R 4 or 0000 R 0100
        Operand1 = 4'b0100 ;        // 0x4
        Operand2 = 4'b1000 ;        // 0x8
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        // Divide by whole (signed)
        MCycleOp = 2'b10 ;      
        // -4 / -4 = 1 R 0 or 0001 R 0000
        Operand1 = 4'b1100 ;    // 0xC
        Operand2 = 4'b1100 ;    // 0xc
        Start = 1'b1 ;
        wait(Busy) ; 
        wait(~Busy) ; 
        Start = 1'b0 ;
        
        
        
        
    end
     
    // GENERATE CLOCK       
    always begin 
        #5 CLK = ~CLK ; 
        // invert CLK every 5 time units 
    end
    
endmodule