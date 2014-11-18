module dig_core(clr_cmd_rdy,resp_data,send_resp,ss,wrt_SPI,SPI_data,cmd,cmd_rdy,resp_sent,SPI_done,EEP_data,rst_n,clk);

input  SPI_done,cmd_rdy,resp_sent,rst_n,clk;
input  [7:0]EEP_data;
input  [23:0]cmd;
output logic [15:0]SPI_data;
output logic clr_cmd_rdy,send_resp,wrt_SPI;
output logic [7:0]resp_data;
output logic [2:0]ss;
logic capture_ch1_gain,capture_ch2_gain,capture_ch3_gain;

typedef enum reg [1:0] {IDLE,CMD_DISPATCH,WRT_EEP2,RD_EEP2} state_t;
state_t state,next_state;
localparam CFG_GAIN=4'b0010;
localparam CFG_TRG_LVL=4'b0011;
localparam WRT_EEP=4'b1000;
localparam RD_EEP=4'b1001;



always_ff@(posedge clk,negedge rst_n) 
begin
	if(!rst_n)
		state<=IDLE;
	else
		state<=next_state;
end

always_comb
begin
	next_state=IDLE;
	wrt_SPI=0;
	ss=3'b000;
	capture_ch1_gain=0;
	capture_ch2_gain=0;
	capture_ch3_gain=0;
	SPI_data=16'h0000;
	case(state)
		CMD_DISPATCH: 
		begin
			if(cmd_rdy)
			begin
				case(cmd[19:16])
					CFG_GAIN:
					begin
						wrt_SPI=1;
						case(cmd[9:8])
							2'b00:
							begin
								ss=3'b001;
								capture_ch1_gain=1;
							end
							2'b01:
							begin
								ss=3'b010;
								capture_ch2_gain=1;
							end
							default:
							begin
								ss=3'b011;
								capture_ch3_gain=1;
							end
						endcase
					
						case(cmd[12:10])
							3'b000:
								SPI_data=16'h1302;
							3'b001:
								SPI_data=16'h1305;
							3'b010:
								SPI_data=16'h1309;
							3'b011:
								SPI_data=16'h1314;
							3'b100:
								SPI_data=16'h1328;
							3'b101:
								SPI_data=16'h1346;
							3'b110:
								SPI_data=16'h136B;
							3'b111:
								SPI_data=16'h13DD;
							default:
								SPI_data=16'h1302;
						endcase
					end
				
					CFG_TRG_LVL:
					begin
						wrt_SPI=1;
						ss=3'b000;
						if(cmd[7:0]>=8'h2E && cmd[7:0]<=8'hC9)
							SPI_data={8'h13,cmd[7:0]};
						else if(cmd[7:0]<8'h2E)
							SPI_data={8'h13,8'h2E};
						else
							SPI_data={8'h13,8'hC9};
					end
				
					WRT_EEP:
					begin
						wrt_SPI=1;
						ss=3'b100;
						SPI_data={2'b01,cmd[13:0]};
						next_state=WRT_EEP2;
					end
				
					RD_EEP:
					begin
						wrt_SPI=1;
						ss=3'b100;
						SPI_data={2'b00,cmd[13:0]};
						next_state=RD_EEP2;
					end
					default:
					begin
						next_state=CMD_DISPATCH;
					end
				endcase
			end
			else	
			begin
			end
		end
	
		//WRT_EEP2: Write EEP state
	
		//RD_EEP2: Read EEP state
		
		default:
			next_state=CMD_DISPATCH;
	endcase
end
endmodule