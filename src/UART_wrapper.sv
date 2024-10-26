/* 
    Author          : Abhinav Nandwani
    Filename        : UART_wrapper.sv
    Description     : 
*/

`default_nettype none
module UART_wrapper(
	input wire clk, //sync inputs 
	input wire rst_n,
	input wire RX,
	output wire TX,

	input wire clr_cmd_rdy, //indicating data is "consumed" by user
	output reg cmd_rdy, //flag to indicate the 16 bits are ready to be consumed
	output wire [15:0] cmd,
	
	input wire resp_trmt,
	input wire [7:0] resp_tx_data,
	output wire resp_tx_done
	);
	
	logic byte_mux;
	logic rx_rdy,clr_rx_rdy;
	logic [7:0] flopped_byte, bytee;
	
	//// instantiate UART ////
	UART iUART(
		.clk(clk),
		.rst_n(rst_n),
		.RX(RX),.TX(TX),
		.rx_rdy(rx_rdy),
		.clr_rx_rdy(clr_rx_rdy),
		.rx_data(bytee),
		.trmt(resp_trmt),
		.tx_data(resp_tx_data),
		.tx_done(resp_tx_done)
		);
	
	assign cmd = {flopped_byte,bytee};
	
	//// flop to retain byte ////
	always_ff@(posedge clk, negedge rst_n)
		if(!rst_n)
			flopped_byte <=1'b0;
		else if (byte_mux)
			flopped_byte <= bytee;
	
	//// FSM for control logic ////
	typedef enum reg{IDLE,BYTE2} state_t;
	state_t state, nxt_state;
	
	// state flop with non blocking //
	always_ff@(posedge clk, negedge rst_n)
		if(!rst_n)
			state <= IDLE;
		else
			state <= nxt_state;
	
	// next state and output comb logic //
	always_comb begin
		// default outputs //
		cmd_rdy = 0;
		clr_rx_rdy = 0;
		byte_mux = 0;
		nxt_state = state;
		
		case (state)
		
			BYTE2: if(rx_rdy) begin
					clr_rx_rdy = 1'b1;
					cmd_rdy = 1'b1;
					nxt_state = IDLE;
					end
			// default state : BYTE1 //
			default: if (rx_rdy) begin
						clr_rx_rdy = 1'b1;
						byte_mux = 1'b1;
					end 
		endcase
	end

endmodule
`default_nettype wire
					
