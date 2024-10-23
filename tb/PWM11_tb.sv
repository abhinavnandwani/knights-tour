module PWM11_tb();
	
	logic clk,rst_n;
	logic [10:0] duty;
	logic PWN_sig,PWN_sig_n;

	//clock generator
	always #5 clk = ~clk;
	
	PWM11 iDUT(.clk(clk),.rst_n(rst_n),.duty(duty),.PWM_sig(PWM_sig),.PWM_sig_n(PWM_sig_n));
	int test_data[4] = {1024,512,2048,2047};
	
	
	initial begin
	
	// reset DUT
	rst_n = 0;
	clk = 0;
	PWN_sig = 0;
	PWN_sig_n = 0;
	duty = 0;
	
	
	
	@(negedge clk);
	rst_n = 1; //deassert reset 
	
	for (int i=0;i<4;i++) begin
		duty = test_data[i];
		#40000;
	end
	$finish;
	end
	
endmodule