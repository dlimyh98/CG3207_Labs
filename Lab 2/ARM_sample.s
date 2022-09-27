;----------------------------------------------------------------------------------
;--	License terms :
;--	You are free to use this code as long as you
;--		(i) DO NOT post it on any public repository;
;--		(ii) use it only for educational purposes;
;--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
;--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
;--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
;--		(vi) retain this notice in this file or any files derived from this.
;----------------------------------------------------------------------------------

	AREA    MYCODE, CODE, READONLY, ALIGN=9 ; 2^9 = 512 bytes (enough space for 128 words). Each section is aligned to an address divisible by 512.
   	  ENTRY
	  
; ------- <code memory (ROM mapped to Instruction Memory) begins>
; Total number of instructions should not exceed 127 (126 excluding the last line 'halt B halt').
; Program adds SHIFT_AMOUNT twice to R7 and show bits [8:4] on 7-seg

		LDR R5, LEDS
		LDR R6, DIPS
		LDR R7, SEVENSEG
		
		LDR R4, INPUT_ARRAY_addr
		STR R5, [R4]
		STR R6, [R4, #4]
		STR R7, [R4, #8]
		
		ADD R4, R4, #8
		
		LDR R1, [R4, #-8]       ; R1 = address of LEDS (0x00000C00)
		LDR R2, [R4, #-4]       ; R2 = address of DIPS (0x00000C04)
		STR R15, PC_ADDRESS		; since PC points 4 bytes (2 instructions) forward due to prefetching (pipelining)
		LDR R3, [R4]		    ; R3 = address of SEVENSEG (0x00000C18)
		LDR R4, SHIFT_AMOUNT    ; R4 = 0xCC = 0b1100_1100
		

main_loop
		LDR R5, DELAY_VAL	 ; R5 = number of loop iterations (2)
		LDR R7, [R2]		 ; R7 = DIPS, use this if manually flipping switches onboard
		;LDR R7, DIPS_SIMUL  ; use this to simulate DIPS (0x05DB = 0b0000_0101_1101_1011)
		LDR R8, ZERO         ; use as Src2 for CMN

; assert that NZCV flags all initialized to 0		
delay_loop
        ADD R7, R7, R4, LSR #2     ; R7 = R7 + (R4 >> 2)
								   ; first iteration  : R4 >> 2 = 0b0011_0011 (R7 should be 0x33), C flag set to 0
								   ; second iteration : R4 >> 2 = 0b0011_0011 (R7 should be 0x66), C flag set to 0

        SUBS R5, R5, #1           ; decrement loop counter
                                  ; assert that C flag always set to 1 (subtraction never produces borrow)
                                  ; Z flag set to 1 iff R7 = 0, otherwise 0

        ANDEQS R7, R7, #0x00F0    ; R7 = R7 AND #0x00F0, execute iff Z = 1 (no support for Immediate Shifting yet)
								  ; if executed,
                                  ; - C flags remain UNCHANGED (still C = 1)
								  ;   if calculating Src2 involves shifting (where bit shifted out is 0), then C flag would be set to 0
								  ; - Z flag set accordingly
								  ; - [3:0] of 7-SEG should be 0

        CMP R5, #0                ; Z flag set to 1 iff R5 == 0 (CMP is equivalent to SUBS discarding result)
		BNE delay_loop	          ; Run loop by number of iterations in R5
        CMN R5, R8                ; C flag set to 0 iff R5 == 0 (CMN is equivalent to ADDS discarding result, set to 0 since addition DOESNT produce carry)
        BCS delay_loop
		
display_results
        STR R7, [R3]         ; display R7 on SEVENSEG (should display 0x40 if DIPS_SIMUL used)
		LDR R15, PC_ADDRESS	 ; B main_loop
halt	
		B    halt           ; infinite loop to halt computation. // A program should not "terminate" without an operating system to return control to
							; keep halt	B halt as the last line of your code.
; ------- <\code memory (ROM mapped to Instruction Memory) ends>


	AREA    CONSTANTS, DATA, READONLY, ALIGN=9 
; ------- <constant memory (ROM mapped to Data Memory) begins>
; All constants should be declared in this section. This section is read only (Only LDR, no STR).
; Total number of constants should not exceed 128 (124 excluding the 4 used for peripheral pointers).
; If a variable is accessed multiple times, it is better to store the address in a register and use it rather than load it repeatedly.

;Peripheral pointers
LEDS
		DCD 0x00000C00		; Address of LEDs. //volatile unsigned int * const LEDS = (unsigned int*)0x00000C00;  
DIPS
		DCD 0x00000C04		; Address of DIP switches. //volatile unsigned int * const DIPS = (unsigned int*)0x00000C04;
PBS
		DCD 0x00000C08		; Address of Push Buttons. Optionally used in Lab 2 and later
CONSOLE
		DCD 0x00000C0C		; Address of UART. Optionally used in Lab 2 and later
CONSOLE_IN_valid
		DCD 0x00000C10		; Address of UART. Optionally used in Lab 2 and later
CONSOLE_OUT_ready
		DCD 0x00000C14		; Address of UART. Optionally used in Lab 2 and later
SEVENSEG
		DCD 0x00000C18		; Address of 7-Segment LEDs. Optionally used in Lab 2 and later

; Rest of the constants should be declared below.
ZERO
		DCD 0x00000000		; constant 0
SHIFT_AMOUNT
        DCD 0xCC
DIPS_SIMUL
        DCD 0x000005DB
LSB_MASK
		DCD 0x000000FF		; constant 0xFF
DELAY_VAL
		DCD 0x00000002		; delay time.
variable1_addr
		DCD variable1		; address of variable1. Required since we are avoiding pseudo-instructions // unsigned int * const variable1_addr = &variable1;
INPUT_ARRAY_addr
		DCD INPUT_ARRAY
PC_ADDRESS_addr
		DCD PC_ADDRESS
constant1
		DCD 0xABCD1234		; // const unsigned int constant1 = 0xABCD1234;
string1   
		DCB  "\r\nWelcome to CG3207..\r\n",0	; // unsigned char string1[] = "Hello World!"; // assembler will issue a warning if the string size is not a multiple of 4, but the warning is safe to ignore
stringptr
		DCD string1			;
		
; ------- <constant memory (ROM mapped to Data Memory) ends>	


	AREA   VARIABLES, DATA, READWRITE, ALIGN=9
; ------- <variable memory (RAM mapped to Data Memory) begins>
; All variables should be declared in this section. This section is read-write.
; Total number of variables should not exceed 128. 
; No initialization possible in this region. In other words, you should write to a location before you can read from it (i.e., write to a location using STR before reading using LDR).

variable1
		DCD 0x00000000		;  // unsigned int variable1;
INPUT_ARRAY
		DCD 0x0C00, 0x0C04, 0x0C18
PC_ADDRESS
		DCD 0x00000000
; ------- <variable memory (RAM mapped to Data Memory) ends>	

		END	
		
;const int*x ;         // x is a non-constant pointer to constant data
;int const*x ;         // x is a non-constant pointer to constant data 
;int*constx ;          // x is a constant pointer to non-constant data