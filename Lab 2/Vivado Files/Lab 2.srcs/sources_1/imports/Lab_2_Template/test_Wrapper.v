`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
--	(c) Thao Nguyen and Rajesh Panicker
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
module test_Wrapper #(
	   parameter N_LEDs_OUT	= 8,					
	   parameter N_DIPs		= 16,
	   parameter N_PBs		= 3 
	)
	(
	);
	
	// Signals for the Unit Under Test (UUT)
	reg  [N_DIPs-1:0] DIP = 0;		
	//reg  [N_PBs-1:0] PB = 0;			
	//wire [N_LEDs_OUT-1:0] LED_OUT;
	wire [6:0] LED_PC;			
	wire [31:0] SEVENSEGHEX;	
	//wire [7:0] CONSOLE_OUT;
	//reg  CONSOLE_OUT_ready = 0;
	//wire CONSOLE_OUT_valid;
	//reg  [7:0] CONSOLE_IN = 0;
	//reg  CONSOLE_IN_valid = 0;
	//wire CONSOLE_IN_ack;
	//reg  RESET = 0;					
	reg  CLK_undiv = 0;				
	
	// Instantiate UUT
	Wrapper dut(.DIP(DIP), .LED_PC(LED_PC), .SEVENSEGHEX(SEVENSEGHEX), .CLK(CLK_undiv)) ;
	
	// GENERATE CLOCK       
    always          
    begin
       #5 CLK_undiv = ~CLK_undiv ; // invert clk every 5 time units 
    end
    
    // Stimuli
    // one complete cycle to display on SEVENSEG = 31 instructions (5+300ns)
    initial begin
        DIP = 16'b0000_0000_1001_1101;  // Result = 0x00000000
        //#300;
        //DIP = 16'b0000_0101_1101_1011;  // DIPS_SIMUL in Keil, Result = 0x00000040
        //#300;
        //DIP = 16'b1010_0001_1000_1000;  // Result = 0x000000E0
        //#300;
        //DIP = 16'b0000_0000_0000_0000;
        //#300;
        //DIP = 16'b0000_0101_1101_1011;
        //#300;
        //DIP = 16'b1010_0001_1000_1000;
    end
    
	// UART Stimuli
    /*initial
    begin
		RESET = 1; #10; RESET = 0; //hold reset state for 10 ns.
		CONSOLE_OUT_ready = 1'h1; // ok to keep it high continously in the testbench. In reality, it will be high only if UART is ready to send a data to PC
        CONSOLE_IN = 8'h50;// 'P'. Will be read and ignored by the processor
        CONSOLE_IN_valid = 1'h1;
        wait(CONSOLE_IN_ack);
        wait(~CONSOLE_IN_ack);
        CONSOLE_IN_valid = 1'h0;
        #105;
        CONSOLE_IN = 8'h41;// 'A'
        CONSOLE_IN_valid = 1'h1;
        wait(CONSOLE_IN_ack);
        wait(~CONSOLE_IN_ack);
		CONSOLE_IN_valid = 1'h0;
        #105;
        CONSOLE_IN = 8'h0D;// '\r'
        CONSOLE_IN_valid = 1'h1;
        wait(CONSOLE_IN_ack); // should print "Welcome to CG3207" following this.
        wait(~CONSOLE_IN_ack);
        CONSOLE_IN_valid = 1'h0;
		//insert rest of the stimuli here
    end*/    
    
endmodule
