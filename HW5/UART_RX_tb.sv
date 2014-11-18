`timescale 1ns/100ps
module UART_RX_tb();
	logic rst_n,clk,clr_rdy,RX;
	logic rdy;
	logic [7:0] rx_data;
	UART_RX_SM DUT1(rx_data,rdy,clk,rst_n,RX,clr_rdy);
	initial clk=0;
	always #12.5 clk=~clk;
	initial
	begin
		clr_rdy=0;
		rst_n=1;
		RX=1;
		@(negedge clk) rst_n=0;
		@(posedge clk) rst_n=1;
		@(posedge clk) clr_rdy=1; 
		@(negedge clk)
		clr_rdy=0;
		RX=0;
		repeat(43)@(negedge clk);
		RX=1;
		repeat(43)@(negedge clk);
		RX=0;
		repeat(43)@(negedge clk);
		RX=1;
		repeat(43)@(negedge clk);
		RX=0;
		repeat(43)@(negedge clk);
		RX=1;
		repeat(43)@(negedge clk);
		RX=0;
		repeat(43)@(negedge clk);
		RX=1;
		repeat(43)@(negedge clk);
		RX=0;
		repeat(43)@(negedge clk);
		RX=1;
		repeat(100)@(posedge clk);
		repeat(8)@(posedge clk);
		clr_rdy=1;
		$stop;
	end
endmodule