/* 
    Author          : Abhinav Nandwani
    Filename        : CommTB.sv
    Description     : This module is a testbench for the 
                      RemoteComm.sv and UART_wrapper.sv modules.
*/

module CommTB();

	logic clk,rst_n;
	
	// UART_wrapper ports //
	logic UART_TX; //UART outputs TX
	logic UART_clr_cmd_rdy,UART_cmd_rdy,UART_resp_trmt,UART_resp_tx_done;
	logic [15:0] UART_cmd;
	logic [7:0] UART_resp_tx_data;
	
	// RemoteComm ports //
	logic RC_RX; // RC outputs RX
	logic RC_snd_cmd,RC_cmd_snt,RC_resp_rx_rdy,RC_resp_clr_rx_rdy;
	logic [15:0] RC_cmd;
	logic [7:0] RC_resp_rx_data;
	
	// clock generator 
	always #5 clk = ~clk; 
	
	
    // Instantiate the modules
    UART_wrapper iUART (
        .clk(clk),
        .rst_n(rst_n),
        .RX(RC_RX),
        .TX(UART_TX),
        .clr_cmd_rdy(UART_clr_cmd_rdy),
        .cmd_rdy(UART_cmd_rdy),
        .cmd(UART_cmd),
        .resp_trmt(UART_resp_trmt),
        .resp_tx_data(UART_resp_tx_data),
        .resp_tx_done(UART_resp_tx_done)
    );
	
    RemoteComm iRemoteComm (
        .clk(clk),
        .rst_n(rst_n),
        .snd_cmd(RC_snd_cmd),
        .cmd(RC_cmd),
        .RX(RC_RX),
        .TX(UART_TX), // Connect to UART TX
        .cmd_snt(RC_cmd_snt),
        .resp_rx_rdy(RC_resp_rx_rdy),
        .resp_rx_data(RC_resp_rx_data),
        .resp_clr_rx_rdy(RC_resp_clr_rx_rdy)
    );
	
	

	
	