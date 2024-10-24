module UART_tb();

    // common inputs //
    logic clk,rst_n;

    // UART_tx ports //
    logic trmt;
    logic [7:0] tx_data;
    logic tx_done;

    logic TX_RX; // TX is output of transmistter and RX is input of receiver

    // UART_rx ports //
    logic clr_rdy;
    logic [7:0] rx_data;

    UART_tx txDUT (.clk(clk), .rst_n(rst_n), .tx_data(tx_data), .trmt(trmt), .TX(TX_RX), .tx_done(tx_done));
    UART_rx rxDUT (.clk(clk), .rst_n(rst_n), .clr_rdy(clr_rdy), .rdy(rdy), .RX(TX_RX), .rx_data(rx_data));

    // test vectors //
    // test data is 1 byte so 8 bits, so max is 2^8 -1 = 255 //
    int test_data[4] = {120,255,80,10};
    

    always #5 clk = ~clk; //clock generator

    initial begin 
    clk = 0;
    rst_n = 0;
    trmt = 0;
    tx_data = 0;
    clr_rdy = 0;

    // deassert rst_n //
    @(negedge clk) rst_n = 1'b1;

    for (int i = 0; i<4;i++) begin
        @(negedge clk);
        tx_data = test_data[i];
        trmt = 1'b1;
        @(negedge clk);
        trmt = 1'b0;

        // 2 clk cycles for RX_2ff + 10 clk cycles of trmt
        @(posedge rdy);
        if (rx_data != test_data[i]) begin
            $strobe("rx_data was not valid for data:%d", test_data[i]);
            $stop();
        end
        @(posedge tx_done);
        
    end
    $display("YAHOO! Test passed ");
    $stop();
    end
    



endmodule