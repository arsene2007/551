`timescale 1ns/100ps
module SPI_Master_SM_tb();
	logic clk,rst_n,wrt;
	logic SCLK,SS_n,done;
	SPI_Master_SM iDUT(SCLK,SS_n,done,clk,rst_n,wrt);
	initial clk=0;
	always #12.5 clk=~clk;

	initial
	begin
		wrt=0;
		rst_n=1;
		#25 rst_n=0;
		#25 rst_n=1;
		#25 wrt=1;
		repeat(2)@(posedge clk);
		wrt=0;
		@(posedge SS_n)
		repeat(100)@(posedge clk);
		$stop;
	end
endmodule

