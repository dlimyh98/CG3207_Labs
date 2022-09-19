//////////////////////////////////////////////////////////////////////////////////
// This module is to generate an enable signal for different display frequency based on pushbuttons
// Fill in the blank to complete this module 
// (c) Gu Jing, ECE, NUS
//////////////////////////////////////////////////////////////////////////////////

module Clock_Enable(
	input clk,			// fundamental clock 1MHz
	input btnU,			// button BTNU for 4Hz speed
	input btnC,			// button BTNC for pause
	output reg enable);	// output signal used to enable the reading of next memory data

reg [31:0] Hz1_flipCount = 32'h2FAF080;
reg [31:0] Hz4_flipCount = 32'h1312D0;
reg [31:0] Hz1_counter; 
reg [31:0] Hz4_counter;
reg [0:0] clock_control;
reg [0:0] pause_control;

reg [0:0] button_previous;
wire button_edge;


// Synchronous edge detection scheme (rather than @posedge button)
assign button_edge = btnU & ~button_previous;


initial begin
    Hz1_counter = 32'b0;
    Hz4_counter = 32'b0;
    clock_control = 1'b0;     // set OUTPUT enable to 1Hz
    enable = 1'b0;            // important for simulation purposes (otherwise get X)
    button_previous = 1'b0;
end

always @ (posedge clk) begin
    // only count if btnC not pressed
    if (!btnC) begin
    
        // clock_control REG dependent on btnU INPUT
        button_previous <= btnU;
        if (button_edge) begin
            clock_control <= 1'b1;
        end else begin
            clock_control <= 1'b0;
        end
    
        // toggle between 1Hz OR 4Hz enable OUTPUT
        if (clock_control) begin
            Hz1_counter <= 32'b0;
            Hz4_counter <= (Hz4_counter == Hz4_flipCount) ? 0 : Hz4_counter + 1;
            enable <= (Hz4_counter == Hz4_flipCount) ? 1'b1 : 1'b0;
        end else begin
            Hz4_counter <= 32'b0;
            Hz1_counter <= (Hz1_counter == Hz1_flipCount) ? 0 : Hz1_counter + 1;
            enable <= (Hz1_counter == Hz1_flipCount) ? 1'b1 : 1'b0;
        end
    end else begin
        enable <= 0;
    end
end

endmodule