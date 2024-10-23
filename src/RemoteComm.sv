module RemoteComm(snd_cmd,cmd,clk,rst_n,TX,RX,cmd_snt);

	input clk,rst_n; //sync inputs 
	input [15:0] cmd; // data inputs
	input RX; //for UART when in receiving mode
	
	
	
	output cmd_snt; // cmd_snt asserts high when the entire 16 bits have been transmitted. 
	output TX; // TX is a single bit being sent.
	

	logic byte_sel; // if high transmitting cmd[15:8], [7:0] otherwise
	logic trmt; //sent to UART to initiate transmission
	logic tx_done; //output of UART, indicates completion of a transmission

	logic set_cmd_snt;
	
	UART_wrapper iUART(
				   .clk(clk),
				   .rst_n(rst_n),
				   .RX(RX),
				   .TX(TX),
				   .rx_rdy(rx_rdy),
				   .clr_rx_rdy(clr_rx_rdy),
				   .rx_data(rx_data),
				   .trmt(trmt),
				   .resp(resp),
				   .tx_done(tx_done),
				   .clr_cmd_rdy(clr_cmd_rdy),
				   .cmd_rdy(cmd_rdy)
				 );

	
	//// flop for cmd with snd_cmd en ////
	always_ff@(posedge clk, negedge rst_n)
		if (!rst_n)
			cmd_b1 <= 0;
		else if (snd_cmd) //sync en
			cmd_b1 <= cmd[7:0];
	
	
	
	typedef enum reg {BYTE1, BYTE2} state_t;
	state_t state, nxt_state;
	//// flop for state ////
	always_ff@(posedge clk, negedge rst_n)
		if (!rst_n)
			state <= BYTE1;
		else
			state <= nxt_state;
	
	//// always comb block for next state and output logic ////
	always_comb begin
		// default outputs 
		byte_sel = 1'b0;
		trmt = 1'b0;
		set_cmd_snt = 1'b0;

		case (state)
			// default is BYTE1 //
			default: begin if(snd_cmd) trmt = 1'b1;
	end

		

	//// SR flop for cmd_snt ////
	always@(posedge clk, negedge rst_n)
		if(!rst_n)
			cmd_snt <= 1'b0;
		else if(snd_cmd) //R
			cmd_snt <= 1'b0;
		else if(set_cmd_snt) //S
			cmd_snt <= 1'b1;
		
	
	

	