module UART_RX_SM(rx_data,rdy,clk,rst_n,RX,clr_rdy);
    input logic rst_n,clk,clr_rdy,RX;
	output logic rdy;
	output logic [7:0] rx_data;
	
	logic [8:0] rx_shift_register;
	logic [3:0]bit_cnt;
	logic [5:0]baud_cnt;
	logic clr_bit_cnt,shift,RX_FF1,RX_FF2,RX_FF3,negRX,clr_baud_cnt;
	
	typedef enum reg [1:0] {IDLE,RECEIVE,DONE} state_t;
	state_t state,next_state;
	
	
	always_ff@(posedge clk,negedge rst_n)
	begin
		if(!rst_n)
		begin
			RX_FF1<=1;
			RX_FF2<=1;
			RX_FF3<=1;
		end
		else
		begin
			RX_FF1<=RX;
			RX_FF2<=RX_FF1;
			RX_FF3<=RX_FF2;	
		end
	end
	assign negRX=RX_FF3&&(!RX_FF2);
	
	//bit_cnt is used to count start bit+8bit data. Max should be 9
	always_ff@(posedge clk)
	begin
		if(clr_bit_cnt)
			bit_cnt<=4'b0000;
		else if(shift)
			bit_cnt<=bit_cnt+4'b0001;
	end
	
	//baud_cnt is used to count 43 clock
	always_ff@(posedge clk,negedge rst_n)
	begin
		if(!rst_n)
			baud_cnt<=6'b00_0000;
		else if(clr_baud_cnt)
			baud_cnt<=6'b00_0000;
		//else if(negRX && bit_cnt==4'b0000 )
			//baud_cnt<=6'b00_0000;
		else if(shift)
			baud_cnt<=6'b00_0000;
		else
			baud_cnt<=baud_cnt+6'b00_0001;
	end
	assign shift=((baud_cnt==6'b11_1111 && bit_cnt==0) || (baud_cnt==6'b10_1010 && bit_cnt!=0 && bit_cnt!=8))?1'b1:1'b0;
	
	
	//rx_shift_register
	always_ff@(posedge clk)
	begin
		if(!rst_n)
			rx_shift_register <= 9'b0000_0000;
		else if(shift)
			rx_shift_register <= rx_shift_register>>1;
		else 
			rx_shift_register <= {RX_FF2,rx_shift_register[7:0]};
	end
	assign rx_data=(rdy)? rx_shift_register[7:0]: rx_data;
	
	//state transition
	always_ff@(posedge clk or negedge rst_n) 
	begin
		if(!rst_n) 
			state<=IDLE;
		else 
			state<=next_state;
	end

	always_comb
	begin 
		 next_state=IDLE;	
		 rdy=0;
		 clr_bit_cnt=0;	
		 clr_baud_cnt=0;
		 case(state)
			IDLE:
				if(negRX && clr_rdy)// RX有值(negRX)而且wrapper準備好(clr_rdy)才可以開始傳值
		       	begin 
					next_state=RECEIVE;
					rdy=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;					
				end 
				else
				begin
					next_state=IDLE;
					rdy=1;
					clr_bit_cnt=1;
					clr_baud_cnt=1;
				end
			RECEIVE:
				if((baud_cnt==6'b10_1010) &&(bit_cnt==4'b1000))
				begin 
					next_state=DONE;
					rdy=0;
					clr_bit_cnt=1;
					clr_baud_cnt=1;
				end
				else 
				begin
					next_state=RECEIVE;
					rdy=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
				end
			DONE:
				begin
					next_state=IDLE;
					rdy=1;
					clr_bit_cnt=1;
					clr_baud_cnt=1;
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
