/* 
    Author          : Abhinav Nandwani
    Filename        : SPI_mnrch.sv
    Description     : 
*/
`default_nettype none
module SPI_mnrch(
    input clk,
    input rst_n,
	input MISO, // bit sent BY serf to monarch
	input [15:0] cmd, // the command to be sent to serf 
	input snd // high for 1 clk to initiate transaction. 
    output SS_n,
    output SCLK,
    output MOSI, // bit sent BY monarch to serf 
    output [15:0] resp, // the response received from serf 
    output done // asserted on completion of transaction, stays high until next transaction
	
);
	// control signals
	logic init; //init signifies start of transaction
	logic shft;	// shft high for 1 clk signifies 1 SCLK has passed and new bits can be transmitted.
					  
	logic [15:0] shft_reg;
	//// shift register for cmd and resp ////
	always@(posedge clk, negedge rst_n) begin
		if (!rst_n)
			shft_reg <= 0;
		else if (init) //load shift reg with cmd if start of new transaction
			shft_reg <= cmd;
		else if (shft) // shift right with MISO if ongoing transaction
			shft_reg <= {shft_reg[14:0],MISO};
	end
	
	
	//// SCLK generator ////
	logic full,ld_SCLK;
	logic [4:0] SCLK_div; // reg that counts clk until 1 SCLK has passed. 
	assign SCLK = SCLK_div[4]; // if MSB of reg is 1, high half cycle, if 0, low half cycle. 
	assign shft = (SCLK_div == 5'b10001) ? 1'b1;1'b0;
	assign full = &SCLK_div;
	always@(posedge clk, negedge rst_n) begin
		if(rst_n)
			SCLK_div <= 0;
		else if (ld_SCLK) // TODO add comments 
			SCLK_div <= 5'b10111;
		else 
			SCLK_div <= SCLK_div +1'b1;
	end
	
	//// bit counter ////
	logic [4:0] bit_cntr;
	logic done16;
	assign done16 = (bit_cntr == 5'b10000) ? 1'b1:1'b0;
	always@(posedge clk, negedge rst_n)	begin
		if (!rst_n)
			bit_cntr <= 0;
		else if(init)
			bit_cntr <= 0;
		else if(shift)
			bit_cntr <= bit_cntr + 1'b1;
	end
	
	//// FSM for control ////
	
	typedef enum reg [1:0] {IDLE, TRANSMITTING, BACK_PORCH} state_t;
	state_t state, nxt_state;
	
	// state flop
	always@(posedge clk, negedge rst_n)
		if (!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	// always comb block for next state and output logic 
	always_comb begin
	
		// default outputs //
		ld_SCLK = 1'b1;
		set_done = 1'b0;
		init = 1'b0;
		nxt_state = state;
		
		case (state)
		
		TRANSMITTING: begin
						if(done16) nxt_state = BACK_PORCH;
						ld_SCLK = 1'b0;
					end
		
		BACK_PORCH: if(full) begin
						set_done = 1'b1;
						nxt_state = IDLE;
					end
		
		default: if(snd) begin 
					nxt_state = TRANSMITTING;
					init = 1'b1;
				end
endmodule
`default_nettype wire
