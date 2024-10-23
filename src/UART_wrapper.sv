module UART_wrapper(clk,rst_n,RX,TX,rx_rdy,clr_rx_rdy,rx_data,trmt,resp,tx_done,clr_cmd_rdy,cmd_rdy);

	input clk,rst_n,clr_cmd_rdy,trmt;
	input [7:0] resp;
	
	output [15:0] cmd;
	
	logic byte_mux;
	logic [7:0] flopped_byte, bytee;
	
	//// instantiate UART ////
	UART iUART(.clk(clk),.rst_n(rst_n),.RX(RX),.TX(TX),.rx_rdy(rx_rdy),.clr_rx_rdy(clr_rx_rdy),.rx_data(bytee),.trmt(trmt),.tx_data(resp),.tx_done(tx_done));
	
	assign cmd = {flopped_byte,bytee};
	
	//// flop to retain byte ////
	always_ff@(posedge clk, negedge rst_n)
		if(!rst_n)
			flopped_byte <=1'b0;
		else if (byte_mux)
			flopped_byte <= bytee;
	
	//// FSM for control logic ////
	typedef enum reg{BYTE1,BYTE2} state_t;
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
		
		case (state)
		
			BYTE2: if(rx_rdy) begin
					clr_rx_rdy = 1'b1;
					cmd_rdy = 1'b1;
					end
			// default state : BYTE1 //
			default: if (rx_rdy) begin
						clr_rx_rdy = 1'b1;
						byte_mux = 1'b1;
					end 
		endcase
	end

endmodule
					
