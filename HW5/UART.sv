module UART_TX_SM(TX,tx_done,clk,rst_n,tx_data,trmt);
    input logic rst_n,clk,trmt;
	input logic [7:0] tx_data; 
	output logic TX,tx_done;
	logic [9:0] tx_shift_register;
	logic [3:0]bit_cnt;
	logic [5:0]baud_cnt;
	logic clr_bit_cnt,clr_baud_cnt,shift,load,transmitting;
	typedef enum reg [1:0] {IDLE,LOAD,TRANSMIT} state_t;
	state_t state,next_state;
	
	
	//bit_cnt is used to count start bit+8bit data. Max should be 9
	always_ff@(posedge clk)
	begin
		if(clr_bit_cnt)
			bit_cnt<=4'b0000;
		else if(load)
			bit_cnt<=4'b0000;
		else if(shift)
			bit_cnt<=bit_cnt+4'b0001;
	end
	
	//baud_cnt is used to count 43 clock
	always_ff@(posedge clk)
	begin
		if(load)
			baud_cnt<=6'b00_0000;
		else if(clr_baud_cnt)
			baud_cnt<=6'b00_0000;
		else if(shift)
			baud_cnt<=6'b00_0000;
		else if(transmitting)
			baud_cnt<=baud_cnt+6'b00_0001;
	end
	assign shift=(baud_cnt==6'b10_1010 && bit_cnt!=4'b1001)?1'b1:1'b0;
	
	
	//tx_shift_register
	always_ff@(posedge clk)
	begin
		if(!rst_n)
			tx_shift_register <= 10'b00_0000_0000;
		else if(load)
			tx_shift_register <= {1'b1,tx_data,1'b0};
		else if(shift)
			tx_shift_register <= tx_shift_register>>1;
	end
	assign TX= tx_shift_register[0];
	
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
		 tx_done=0;
		 load=0;
		 clr_bit_cnt=0;	
		 clr_baud_cnt=0;
		 transmitting=0;
		 case(state)
			IDLE:
				if(trmt==1)
		        begin 
					next_state=LOAD;
					tx_done=0;
					load=1;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
					transmitting=1;
				end 
				else
				begin
					next_state=IDLE;
					tx_done=1;
					load=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
					transmitting=1;
				end
			LOAD:
				if((baud_cnt==6'b10_1010))
				begin
					next_state=TRANSMIT;
					tx_done=0;
					load=0;
					clr_bit_cnt=0;
					clr_baud_cnt=1;
					transmitting=1;
				end
				else
				begin
					next_state=LOAD;
					tx_done=0;
					load=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
					transmitting=1;
				end
			TRANSMIT:
				if(bit_cnt==4'b1001 && baud_cnt==6'b10_1010)
				begin
					next_state=IDLE;
					tx_done=1;
					load=0;
					clr_bit_cnt=1;
					clr_baud_cnt=1;
					transmitting=0;
				end
				else if(bit_cnt==4'b1001 && baud_cnt!=6'b10_1010)
				begin
					next_state=TRANSMIT;
					tx_done=0;
					load=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
					transmitting=1;
				end
				else
				begin
					next_state=LOAD;
					tx_done=0;
					load=0;
					clr_bit_cnt=0;
					clr_baud_cnt=0;
					transmitting=1;
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
