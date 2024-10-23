module UART_tx(clk,rst_n,TX,trmt,tx_data,tx_done);

	input clk,rst_n,trmt;
	input [7:0] tx_data;
	output TX;
	output logic tx_done;
	
	

	
	logic [3:0] bit_cnt;
	logic [11:0] baud_cnt;
	logic [8:0] tx_shift_reg;
	logic shift;
	logic set_done,init,transmitting;
	

	
	// trmt asserted high indicates 
	
	always_ff@(posedge clk)
		
		if (init) 
			bit_cnt <= 0;
		else if(shift) 
			bit_cnt <= bit_cnt +1;
	
	
	//CYCLE COUNTER
	assign shift = (baud_cnt == 2604) ? 1'b1:1'b0;
	always_ff@(posedge clk)
		
		// init has priority over shift
		if (init)
			baud_cnt <= 0;
		else if(shift)
			baud_cnt <= 0;
		else if(transmitting)
			baud_cnt <= baud_cnt +1;
	
	
	//SHIFT REG
	always_ff@(posedge clk, negedge rst_n)
		
		if (!rst_n)
			tx_shift_reg <= 9'b111111111;
		else if (init)
			tx_shift_reg <= {tx_data,1'b0};
		else if (shift)
			tx_shift_reg <= {1'b1,tx_shift_reg[8:1]};
			
	
	
	always_ff@(posedge clk, negedge rst_n)
		if (!rst_n)
			tx_done <= 0;
		else if(init || transmitting)
			tx_done <= 0;
		else if(set_done)
			tx_done <= 1'b1;
	
	//FSM 

	typedef enum reg {IDLE,TRANSMITING} state_t;
	state_t state, nxt_state;
	always_ff@(posedge clk, negedge rst_n)
		if (!rst_n)
			state <= IDLE;
		else 
			state <= nxt_state;
	
	
	always_comb begin
		
		nxt_state = state;
		init = 0;
		transmitting = 0;
		set_done = 0;
		case (state) inside 
			TRANSMITING: if (bit_cnt < 10)
							transmitting = 1;
						else begin
							transmitting = 0;
							set_done = 1'b1;
							nxt_state = IDLE;
						end
			default: if (trmt) begin
					init = 1;
					nxt_state = TRANSMITING;
					end 
		endcase
	end
	    
		
endmodule