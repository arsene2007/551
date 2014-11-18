module DSO_dig(adc_clk,rclk,en,we,addr,clr_cmd_rdy,resp_data,send_resp,ss,wrt_SPI,SPI_data,SPI_done,cmd_rdy,resp_sent,EEP_data,cmd,rst_n,clk,ch1_rdata,ch2_rdata,ch3_rdata,trig1,trig2);
input  SPI_done,cmd_rdy,resp_sent,trig1,trig2,rst_n,clk;
input  [7:0]EEP_data;
input  [7:0]ch1_rdata,ch2_rdata,ch3_rdata;
input  [23:0]cmd;
output logic [15:0]SPI_data;
output logic clr_cmd_rdy,send_resp,wrt_SPI,rclk,en,we,adc_clk;
output logic [8:0]addr;
output logic [7:0]resp_data;
output logic [2:0]ss;	
	dig_core i_dig_core(clr_cmd_rdy,resp_data,send_resp,ss,wrt_SPI,SPI_data,cmd,cmd_rdy,resp_sent,SPI_done,EEP_data,rst_n,clk);
endmodule