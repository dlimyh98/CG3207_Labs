`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// This module should contain the corresponding Memory data generated from Hex2ROM
// and choose the memory data to be displayed based on enable signal  
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////


module Get_MEM(
    input clk,					// fundamental clock 100MHz
	input enable,				// enable signal to read the next content
	output wire [31:0] data,    // 32 bits memory contents for 7-segments display
    output wire upper_lower);   // 1-bit signal rerequied for LEDs, indicating which half of the Memory data is displaying on LEDs
    
// declare INSTR_MEM and DATA_CONST_MEM
reg [31:0] INSTR_MEM [0:127];       // 128 * 32 bit array
reg [31:0] DATA_CONST_MEM [0:127];
reg [8:0] i;                        // indices of INSTR_MEM and DATA_CONST_MEM


// addr [0:0] = MUX for upper/lower 16 bits of INSTR_MEM[x] / DATA_CONST_MEM[x]
// addr [7:1] = address for both ROMs (INSTR_MEM[x] & DATA_CONST_MEM[x])
// addr [8:8] = INSTR_MEM[x] or DATA_CONST_MEM[x] selected for output
reg [8:0] addr = 9'b0;

// drive OUTPUT WIRE with REG
reg [31:0] data_toSend = 32'b0;
assign data = data_toSend;

reg [0:0] is_readINSTR = 1'b1;
reg [0:0] can_sendNew = 1'b1;

reg [0:0] is_sendMSB = 1'b0;
assign upper_lower = is_sendMSB;


initial begin
	////////////////////////////////////////////////////////////////
    // Instruction Memory
    ////////////////////////////////////////////////////////////////
			INSTR_MEM[0] = 32'hE59F11F8; 
			INSTR_MEM[1] = 32'hE59F21F8; 
			INSTR_MEM[2] = 32'hE59F3214; 
			INSTR_MEM[3] = 32'hE5924000; 
			INSTR_MEM[4] = 32'hE5814000; 
			INSTR_MEM[5] = 32'hE2533001; 
			INSTR_MEM[6] = 32'h1AFFFFFD; 
			INSTR_MEM[7] = 32'hE1A0100F; 
			INSTR_MEM[8] = 32'hE59F0204; 
			INSTR_MEM[9] = 32'hE58F57D4; 
			INSTR_MEM[10] = 32'hE59F57D0; 
			INSTR_MEM[11] = 32'hE59F21F4; 
			INSTR_MEM[12] = 32'hE5820000; 
			INSTR_MEM[13] = 32'hE5820004; 
			INSTR_MEM[14] = 32'hEAFFFFFE; 
			for(i = 15; i < 128; i = i+1) begin 
				INSTR_MEM[i] = 32'h0; 
			end

	////////////////////////////////////////////////////////////////
    // Data (Constant) Memory
    ////////////////////////////////////////////////////////////////
			DATA_CONST_MEM[0] = 32'h00000C00; 
			DATA_CONST_MEM[1] = 32'h00000C04; 
			DATA_CONST_MEM[2] = 32'h00000C08; 
			DATA_CONST_MEM[3] = 32'h00000C0C; 
			DATA_CONST_MEM[4] = 32'h00000C10; 
			DATA_CONST_MEM[5] = 32'h00000C14; 
			DATA_CONST_MEM[6] = 32'h00000C18; 
			DATA_CONST_MEM[7] = 32'h00000000; 
			DATA_CONST_MEM[8] = 32'h000000FF; 
			DATA_CONST_MEM[9] = 32'h00000002; 
			DATA_CONST_MEM[10] = 32'h00000800; 
			DATA_CONST_MEM[11] = 32'hABCD1234; 
			DATA_CONST_MEM[12] = 32'h65570A0D; 
			DATA_CONST_MEM[13] = 32'h6D6F636C; 
			DATA_CONST_MEM[14] = 32'h6F742065; 
			DATA_CONST_MEM[15] = 32'h33474320; 
			DATA_CONST_MEM[16] = 32'h2E373032; 
			DATA_CONST_MEM[17] = 32'h000A0D2E; 
			DATA_CONST_MEM[18] = 32'h00000230; 
			for(i = 19; i < 128; i = i+1) begin 
				DATA_CONST_MEM[i] = 32'h0; 
			end
end


always @ (posedge clk) begin
    if (enable) begin
        is_sendMSB <= ~is_sendMSB;      // toggle between sending MSB or LSB
        can_sendNew <= ~can_sendNew;    // every 2 enable cycles, we send new data
        
        // check if can send next memory location
        if (can_sendNew) begin
            addr [7:1] <= addr [7:1] + 1;
            
            if (addr[7:1] == 127) begin
                addr [7:1] <= 0;
                is_readINSTR <= ~is_readINSTR;
            end
        
            if (is_readINSTR) begin
                data_toSend <= INSTR_MEM[addr[7:1]];
            end else if (!is_readINSTR) begin
                data_toSend <= DATA_CONST_MEM[addr[7:1]];
            end
        end
    end
end

	
endmodule