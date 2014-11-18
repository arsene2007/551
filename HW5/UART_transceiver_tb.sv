`timescale 1ns/100ps
module UART_transceiver_tb();
logic clr_rdy,trmt,clk,rst_n;
logic [7:0] tx_data;
logic TX,rdy,tx_done;
logic [7:0]rx_data;

	UART_transceiver DUT1(TX,rdy,tx_done,rx_data,TX,clr_rdy,trmt,tx_data,clk,rst_n);
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
		clr_rdy=1; 
		@(posedge clk)
		trmt=1;
		repeat(2)@(posedge clk);
		trmt=0;
		clr_rdy=0;
		@(posedge rdy)
		if(rx_data!=tx_data)
			$display("Error! tx_data and rx_data do not match up\n");
		else
			$display("Correct! tx_data and rx_data match up\n");
		repeat(100)@(posedge clk);
		$stop;
	end
endmodule