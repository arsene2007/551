module UART_transceiver(TX,rdy,tx_done,rx_data,RX,clr_rdy,trmt,tx_data,clk,rst_n);
input logic RX,clr_rdy,trmt,clk,rst_n;
input logic [7:0] tx_data;
output logic TX,rdy,tx_done;
output logic [7:0]rx_data;
	UART_TX_SM DUT_TX_SM(TX,tx_done,clk,rst_n,tx_data,trmt);
	UART_RX_SM DUT_RX_SM(rx_data,rdy,clk,rst_n,RX,clr_rdy);
endmodule