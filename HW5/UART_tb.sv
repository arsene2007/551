`timescale 1ns/100ps
module UART_TX_tb();
    logic rst_n,clk,trmt;
	logic [7:0] tx_data; 
	logic TX,tx_done;
	UART_TX_SM DUT1(TX,tx_done,clk,rst_n,tx_data,trmt);
	initial clk=0;
	always #12.5 clk=~clk;
	initial
	begin
		trmt=0;
		rst_n=1;
		tx_data=8'b0101_0101;
		@(negedge clk)
		rst_n=0;
		@(posedge clk)
		rst_n=1;
		@(posedge clk)
		trmt=1;
		repeat(2)@(posedge clk);
		trmt=0;
		@(posedge tx_done)
		repeat(100)@(posedge clk);
		$stop;
	end
endmodule