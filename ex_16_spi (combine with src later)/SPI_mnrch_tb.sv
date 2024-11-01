module SPI_mnrch_tb();

    logic clk,rst_n,MISO,MOSI,SCLK,done,SS_n,snd,INT;
    logic [15:0] cmd,resp;


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
        .SS_n(SS_N),
        .SCLK(SCLK),
        .MISO(MISO),
        .MOSI(MOSI),
        .INT(INT)
        );

    always #5 clk = ~clk;

    logic cmd_vector[4] = {16'h8Fxx,16'h0D02,};
    logic expected_rsp[4] = {16'h006A,};

    inital begin
        
        clk = 0;
        rst_n = 0;
        snd = 0;
        cmd = 0;

        @(negedge clk);
        rst_n = 1;

        @(negedge clk);
        //Test 1 : Read from 0x0F
        cmd = 16'h8fxx;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        if (resp === 16'h006A) begin 
            $display("WHO_AM_I reg test passed.");
        end else begin
            $display("WHO_AM_I reg test failed!");
            $stop;
        end 

        @(negedge clk);
        // Test 2 : Configure INT 
        cmd = 16'h0D02;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        if (iNEMO1.NEMO_setup === 1'b1) begin 
            $display("INT configure pin test passed.");
        end else begin
            $display("INT configure pin test failed!");
            $stop;
        end 


        @(negedge clk);
        // Test 3 : Configure INT 
        cmd = 16'h0D02;
        snd = 1'b1;
        @(negedge clk);
        snd = 1'b0;
        @(posedge done);
        if (iNEMO1.NEMO_setup === 1'b1) begin 
            $display("INT configure pin test passed.");
        end else begin
            $display("INT configure pin test failed!");
            $stop;
        end 

        @(posedge INT);
        @(negedge clk);
        //Test 4 : ptchL
        




        







    end


    



endmodule

    























endmodule