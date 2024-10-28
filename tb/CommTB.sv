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

    // receives a 16 bit transmission over UART
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

    // sends a 16 bit transmission over UART
	
    RemoteComm iRemoteComm (
        .clk(clk),
        .rst_n(rst_n),
        .snd_cmd(RC_snd_cmd),
        .cmd(RC_cmd),
        .RX(UART_TX),
        .TX(RC_RX), // Connect to UART TX
        .cmd_snt(RC_cmd_snt),
        .resp_rx_rdy(RC_resp_rx_rdy),
        .resp_rx_data(RC_resp_rx_data),
        .resp_clr_rx_rdy(RC_resp_clr_rx_rdy)
    );

    int test_data[4] = {120,255,80,10};

    initial begin
        
        clk = 0;
        rst_n = 0; //assert reset (active low)

        // UART inputs //
        UART_clr_cmd_rdy = 0;
        UART_resp_tx_data = 0;
        UART_resp_trmt = 0;

        // RemoteComm inputs //
        RC_snd_cmd = 0;
        RC_cmd = 0;
        RC_resp_clr_rx_rdy = 0;

        // deassert rst_n //
        @(negedge clk) rst_n = 1'b1;

        // loop to iterate through test vector //
        for (int i = 0; i<4; i++) begin
            
            @(negedge clk);
            UART_clr_cmd_rdy = 1'b1; // previous transmission consumed
            @(negedge clk); //wait a clk cycle
            if (UART_cmd_rdy !== 1'b0) begin
                $display("UART clr_cmd_rdy not working");
                $stop();
            end
            UART_clr_cmd_rdy = 1'b0;
            // start new transmission
            RC_snd_cmd = 1'b1;
            RC_cmd = test_data[i];

            @(negedge clk);
            RC_snd_cmd = 1'b0;

            @(posedge RC_cmd_snt);
            if (!UART_cmd_rdy) begin
                $display("UART cmd_rdy not working");
                $stop();               
            end
            if (UART_cmd != test_data[i]) begin
                $display("Error: UART received %0d, expected %0d", UART_cmd, test_data[i]);
                $stop();
            end
            $display("Test %0d passed: Sent %0d, Received %0d", i, test_data[i], UART_cmd);
        end
        $display("YAHOO! Test passed ");
        $stop();
    end

endmodule 







	
	

	
	