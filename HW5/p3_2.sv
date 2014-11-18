module SPI_Master_SM(SCLK,SS_n,done,MOSI,clk,rst_n,wrt,cmd,MISO);
    input logic rst_n,clk,wrt,MISO;
	input logic [15:0] cmd; 
	output logic SS_n,done,MOSI;
	output wire SCLK;
	logic [15:0] MOSI_shift_register;
	reg [15:0] buffer;
	logic [4:0]cnt;
	logic [4:0]bit_cnt;
	logic clr_cnt,clr_bit_cnt,shift,load,MISO_FF1,MISO_FF2,MISO_FF3;

	typedef enum reg [2:0] {IDLE,TX,BACK_PORCH,DONE} state_t;
	state_t state,next_state;
	
	//write is double buffered. Our core can write to SPI output
    //while read of previous in progress	
	always_ff@(posedge clk)
	begin
		if(wrt)
			buffer<=cmd;
	end
	
	//MOSI_shift_register
	always_ff@(posedge clk)
	begin
		if(wrt||load)
			MOSI_shift_register<=buffer;	
		else if(shift)
			MOSI_shift_register<={MOSI_shift_register[14:0],MISO_FF3};
		
	end
	
	
	always_ff@(posedge clk,negedge rst_n)
	begin
		if(!rst_n)
		begin
			MISO_FF1<=0;
			MISO_FF2<=0;
			MISO_FF3<=0;
		end
		else
		begin
			MISO_FF1<=MISO;
			MISO_FF2<=MISO_FF1;
			MISO_FF3<=MISO_FF2;	
		end
	end	
	

	
	assign MOSI= (SS_n==1)? 1'bz: MOSI_shift_register[15];
	
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
			bit_cnt<=5'b00000;
		else if(shift)
			bit_cnt<=bit_cnt+5'b00001;
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
		 shift=0;
		 load=0;
		 case(state)
			IDLE:
				if(wrt==1)
		        begin 
					next_state=TX;
					SS_n=1;
					done=0;
					clr_cnt=0;
					clr_bit_cnt=0;
					shift=0;
					load=1;
					
				end 
				else
				begin
					next_state=IDLE;
					SS_n=1;
					done=0;
					clr_cnt=1;
					clr_bit_cnt=1;
					shift=0;
					load=0;	
									
				end
			TX:
				if((&cnt) && (bit_cnt==5'b01111))
				begin 
					next_state=BACK_PORCH;
					SS_n=0;
					done=0;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=&cnt && (bit_cnt!=5'b10000);
					
					// If cnt=5'b1_1111 and bit_cnt!=4'b1111, set shift=1. 
					//If cnt!= 5'b1_1111 (waiting for falling edge of SCLK) 
					//or bit_cnt=4'b1111 (the last bit of cmd), set shift=0 and don't shift. 
					
					load=0;
					
				end
				else 
				begin
					next_state=TX;
					SS_n=0;
					done=0;
					clr_cnt=0;
					clr_bit_cnt=0;
					shift=&cnt && (bit_cnt!=5'b10000);
					load=0;
					
				end
			BACK_PORCH:
				if(cnt==5'b00111)
				begin
					next_state=DONE;
					SS_n=1;
					done=0;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=0;
					load=0;
					
				end
				else
				begin
					next_state=BACK_PORCH;
					SS_n=0;
					done=0;
					clr_cnt=0; 	
					clr_bit_cnt=1;
					shift=0;
					load=0;
					
				end
			
			DONE:
				if(cnt==5'b11111)
				begin
					next_state=IDLE;
					SS_n=1;
					done=1;
					clr_cnt=1; 	
					clr_bit_cnt=1;
					shift=0;
					load=0;
				end
				else
				begin
					next_state=DONE;
					SS_n=1;
					done=0;
					clr_cnt=0; 	
					clr_bit_cnt=1;
					shift=0;
					load=0;
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
