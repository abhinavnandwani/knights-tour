module MtrDrv_tb();
	
	logic clk,rst_n;
	logic signed [10:0] lft_spd,rght_spd;
	logic lftPWM1,lftPWM2,rghtPWM1,rghtPWM2;

	//clock generator
	always #5 clk = ~clk;
	
	MtrDrv iDUT(.clk(clk),.rst_n(rst_n),.lft_spd(lft_spd),.rght_spd(rght_spd),.lftPWM1(lftPWM1),.lftPWM2(lftPWM2),.rghtPWM1(rghtPWM1),.rghtPWM2(rghtPWM2));
	int test_data_l[5] = {1024,512,2048,2047,1023};
	int test_data_r[5] = {1023,2047,2048,1024,512};
	
	
	initial begin
	
	// reset DUT
	rst_n = 0;
	clk = 0;
	lft_spd = 0;
	rght_spd = 0;
	
	
	
	@(negedge clk);
	rst_n = 1; //deassert reset 
	
	for (int i=0;i<5;i++) begin
		lft_spd = test_data_l[i];
		rght_spd = test_data_r[i];
		#40000;
	end
	$finish;
	end
	
endmodule