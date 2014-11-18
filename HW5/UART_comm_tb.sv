`timescale 1ns/100ps
module UART_comm_tb();
    logic clk,rst_n,clr_cmd_rdy,rdy;
	logic [7:0]rx_data;
	logic clr_rdy,cmd_rdy;
	logic [23:0] cmd;
	logic [23:0] RX_sent;
	
	logic trmt;
	logic [7:0] tx_data;
	logic TX,tx_done;
	
       UART_comm iWrapper(clr_rdy,cmd_rdy,cmd,clk,rst_n,rdy,clr_cmd_rdy,rx_data);
	   UART_transceiver DUT1(TX,rdy,tx_done,rx_data,TX,clr_rdy,trmt,tx_data,clk,rst_n);
	

	   
	initial clk=0;
	always #12.5 clk=~clk;
	initial RX_sent=24'b0101_0101_0000_1111_1111_0000;
	initial
	begin
		clr_cmd_rdy=0;
		trmt=0;
		tx_data=RX_sent[23:16];
		rst_n=1;	
		@(negedge clk) rst_n=0;
		@(posedge clk) rst_n=1;
		@(posedge clk) clr_cmd_rdy=1; 
		@(posedge clk) clr_cmd_rdy=0;
		@(posedge clk)
		trmt=1;
		@(posedge clk)
		trmt=0;
	
		
		
		@(posedge rdy);
		@(posedge tx_done);
		tx_data=RX_sent[15:8];
		@(posedge clk)
		trmt=1;
		@(posedge clk)
		trmt=0;
		@(posedge clk) 
		clr_cmd_rdy=1;
		@(posedge clk) 
		clr_cmd_rdy=0;
		
		
		
		
		
		@(posedge rdy);
		@(posedge tx_done);
		tx_data=RX_sent[7:0];
		@(posedge clk)
		trmt=1;
		@(posedge clk)
		trmt=0;
		@(posedge clk) 
		clr_cmd_rdy=1;
		@(posedge clk) 
		clr_cmd_rdy=0;
		
		@(posedge cmd_rdy);
		if(cmd!=RX_sent)
		begin
			$display("Error! cmd and RX_sent do not match up\n");
			$display("cmd =%b and RX_sent =%b\n", cmd,RX_sent);
		end
		else
		begin
			$display("Correct! cmd and RX_sent match up\n");
			$display("cmd =%b and RX_sent =%b\n", cmd,RX_sent);
		end
		repeat(300)@(posedge clk);	
		$stop;
	end
endmodule