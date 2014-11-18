module SPI_Master_SM(SCLK,SS_n,done,clk,rst_n,wrt);
    input logic rst_n,clk,wrt;
	output logic SS_n,SCLK,done; 
	logic [4:0]cnt;
	logic [3:0]bit_cnt;
	logic clr_cnt,clr_bit_cnt,shift;

	typedef enum reg [2:0] {IDLE,TX,BACK_PORCH,DONE} state_t;
	state_t state,next_state;
	
	
	//count 32 clk to generate SCLK
	always_ff@(posedge clk)
	begin
		if(clr_cnt)
			cnt<=5'b0_0000;
		else
			cnt<=cnt+5'b0_0001;
	end
	assign SCLK=cnt[4];
 
	
	//count 16 SCLK for SS_n
	always_ff@(posedge clk)
	begin
		if(clr_bit_cnt)
			bit_cnt<=4'b0000;
		else if(shift)
			bit_cnt<=bit_cnt+4'b0001;
	end
	
	
	//state transistion
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
		 SS_n=1;
		 done=0;
		 clr_cnt=0;  
		 clr_bit_cnt=0;
		 shift=&cnt;
		 case(state)
			IDLE:
				if(wrt==1)
		        begin 
					next_state=TX;
					SS_n=1;
					done=0;
					clr_cnt=0;
					clr_bit_cnt=0;
					shift=&cnt && (!(&bit_cnt));
				end 
				else
				begin
					next_state=IDLE;
					SS_n=1;
					done=0;
					clr_cnt=1;
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
					
				end
			TX:
				if((&cnt) && (&bit_cnt))
				begin 
					next_state=BACK_PORCH;
					SS_n=0;
					done=0;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
				end
				else 
				begin
					next_state=TX;
					SS_n=0;
					done=0;
					clr_cnt=0;
					clr_bit_cnt=0;
					shift=&cnt && (!(&bit_cnt));
				end
			BACK_PORCH:
				if(cnt==5'b00111)
				begin
					next_state=DONE;
					SS_n=1;
					done=0;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
				end
				else
				begin
					next_state=BACK_PORCH;
					SS_n=0;
					done=0;
					clr_cnt=0; 	
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
				end
			
			DONE:
				if(cnt==5'b00001)
				begin
					next_state=IDLE;
					SS_n=1;
					done=1;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
				end
				else
				begin
					next_state=DONE;
					SS_n=1;
					done=0;
					clr_cnt=0; 	
					clr_bit_cnt=1;
					shift=&cnt && (!(&bit_cnt));
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
