`timescale 1ns/100ps
module SPI_Slave_SM_tb();
	logic clk,rst_n;
	logic SCLK,MOSI,SS_n,cmd_rdy,rsp_rdy,wrt,MISO;
	logic [15:0] cmd,tx_data;
	SPI_Slave_SM iDUT(MISO,cmd,cmd_rdy,rsp_rdy,clk,rst_n,SCLK,MOSI,SS_n,wrt,tx_data);
	initial 
	begin
		clk=0;
		SCLK=0;
	end
	always #12.5 clk=~clk;
	always #400 SCLK=~SCLK;

	initial
	begin
		wrt=0;
		SS_n=1;
		rst_n=1;
		tx_data=16'b1111_0000_1111_0000;
		@(posedge clk) rst_n=0;
		@(posedge clk) rst_n=1;
		@(posedge clk) wrt=1;
		@(posedge clk) wrt=0;
		@(posedge clk)
		SS_n=0;
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		@(negedge SCLK);
		MOSI=0;
		@(negedge SCLK);
		MOSI=1;
		repeat(2)@(negedge SCLK);
		repeat(8)@(posedge clk);
		SS_n=1;
		repeat(100)@(posedge clk);
		$stop;
	end
endmodule