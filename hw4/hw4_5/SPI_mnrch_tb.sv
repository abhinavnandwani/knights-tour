/* 
    Author          : Abhinav Nandwani
    Filename        : SPI_mnrch_tb.sv
    Description     : Testbench for the SPI_mnrch module, has testcases for functional verification.
*/
module SPI_mnrch_tb();

    logic clk,rst_n,MISO,MOSI,SCLK,done,SS_n,snd,INT;
    logic [15:0] cmd,resp;

    // instantiate the DUT and NEMO
    SPI_mnrch iSPI (
        .clk(clk),
        .rst_n(rst_n),
        .MISO(MISO),
        .cmd(cmd),
        .snd(snd),
        .SS_n(SS_n),
        .SCLK(SCLK),
        .MOSI(MOSI),
        .resp(resp),
        .done(done)
        );

    SPI_iNEMO1 iNEMO(
        .SS_n(SS_n),
        .SCLK(SCLK),
        .MISO(MISO),
        .MOSI(MOSI),
        .INT(INT)
        );

    always #5 clk = ~clk; //clock generator



    initial begin
        
        clk = 0;
        rst_n = 0;
        snd = 0;
        cmd = 0;

        @(negedge clk); //deassert reset
        rst_n = 1;

        who_am_i();
        config_INT();
        @(posedge INT); //if the config was success, INT should eventually go HIGH 
        verify_ptchL();
        @(posedge INT); //wait for INT assertion after reading again
        verify_ptchH();


        $stop;
    end


    task who_am_i();
        @(negedge clk);
        //Test 1 : Read from 0x0F
        cmd = 16'h8fxx;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        @(negedge clk); //wait a clk cycle to propogate
        if (resp[7:0] === 8'h6A) begin 
            $display("WHO_AM_I reg test passed.");
        end else begin
            $display("WHO_AM_I reg test failed!");
            $stop;
        end 
    endtask

    task config_INT();
        @(negedge clk);
        // Test 2 : Configure INT 
        cmd = 16'h0D02;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        @(negedge clk); //wait a clk cycle to propogate
        if (iNEMO.NEMO_setup === 1'b1) begin 
            $display("INT configure pin test passed.");
        end else begin
            $display("INT configure pin test failed!");
            $stop;
        end 
    endtask

        
    task verify_ptchL();
        @(negedge clk);
        //Test 3 : ptchL
        cmd = 16'hA2xx;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        @(negedge clk); //wait a clk cycle to propogate
        if (resp[7:0] === 8'h63) begin 
            $display("ptchL read test passed.");
            if (INT !== 1'b0) begin
                $display("but INT did not drop");
                $stop;
            end 
        end else begin
            $display("ptchL read test failed!");
            $stop;
        end 
    endtask

       
    task verify_ptchH();
        @(negedge clk);
        //Test 4 : ptchH
        cmd = 16'hA3xx;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        @(negedge clk); //wait a clk cycle to propogate
        if (resp[7:0] === 8'hcd) begin 
            $display("ptchH read test passed.");
            if (INT !== 1'b1) begin
                $display("but INT dropped!");
                $stop;
            end 
        end else begin
            $display("ptchH read test failed!");
            $stop;
        end 
    endtask


endmodule

    












