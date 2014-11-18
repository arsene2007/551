module SPI_Slave_SM(MISO,cmd,cmd_rdy,rsp_rdy,clk,rst_n,SCLK,MOSI,SS_n,wrt,tx_data);
    input logic rst_n,clk,SCLK,MOSI,SS_n,wrt;
	input [15:0] tx_data;
	output logic cmd_rdy;
	output logic [15:0] cmd;
	output logic rsp_rdy,MISO;
	reg [15:0] cmd_shift_register,buffer;
	reg [4:0] RX_bit_cnt;
	reg SCLK_FF1,SCLK_FF2,SCLK_FF3,MOSI_FF1,MOSI_FF2,MOSI_FF3,SS_n_FF1,SS_n_FF2;
	logic shift, load, set_cmd_rdy, clr_RX_bit_cnt;
	wire negSCLK;
	typedef enum reg [2:0] {IDLE,RX,DONE} state_t;
	state_t state,next_state;
	
	//write is double buffered. Our core can write to SPI output
    //while read of previous in progress	
	always_ff@(posedge clk)
	begin
		if(wrt)
			buffer<=tx_data;
	end
	
	//response ready flop
	always_ff@(posedge clk,negedge rst_n)
	begin
		if(!rst_n)
			rsp_rdy<=0;
		else if(wrt)
			rsp_rdy<=1;
		else if(load)
			rsp_rdy<=0;
	end
	//parallel shift register
	always_ff@(posedge clk)
	begin
		if(load)
			cmd_shift_register<=buffer;
		else if(shift)
			cmd_shift_register<={cmd_shift_register[14:0],MOSI_FF3};
	end
	
	assign cmd=(cmd_rdy)? cmd_shift_register: cmd;
	
	always_ff@(posedge clk,negedge rst_n)
	begin
		if(!rst_n)
		begin
			SCLK_FF1<=0;
			SCLK_FF2<=0;
			SCLK_FF3<=0;
			MOSI_FF1<=0;
			MOSI_FF2<=0;
			MOSI_FF3<=0;
			SS_n_FF1<=1;
			SS_n_FF2<=1;
		end
		else
		begin
			SCLK_FF1<=SCLK;
			SCLK_FF2<=SCLK_FF1;
			SCLK_FF3<=SCLK_FF2;	
			MOSI_FF1<=MOSI;
			MOSI_FF2<=MOSI_FF1;
			MOSI_FF3<=MOSI_FF2;	
			SS_n_FF1<=SS_n;
			SS_n_FF2<=SS_n_FF1;
		end
	end
	assign negSCLK=SCLK_FF3&&(!SCLK_FF2);
	

	
	//count 16 SCLK for SS_n
	always_ff@(posedge clk)
	begin
		if(clr_RX_bit_cnt)
			RX_bit_cnt<=5'b00000;
		else if(shift)
			RX_bit_cnt<=RX_bit_cnt+1;
	end
	

	//cmd_rdy_register
	always_ff@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			cmd_rdy<=1'b0;
		end
		else if(load)
			cmd_rdy<=1'b0;
		else if(set_cmd_rdy)
			cmd_rdy<=1'b1;
	end
	
	assign MISO = (SS_n_FF2==1)? 1'bz: cmd_shift_register[15];
	//state register
	always_ff@(posedge clk or negedge rst_n) 
	begin
		if(!rst_n) 
			state<=IDLE;
		else 
			state<=next_state;
	end

	//state transition logic
	always_comb
	begin 
		 next_state=IDLE;	
		 shift=0;
		 load=0;
		 set_cmd_rdy=0;
		 clr_RX_bit_cnt=0;
		 case(state)
			IDLE:
				if(!SS_n_FF2)
		        begin 
					next_state=RX;
					shift=0;
					load=1;
					set_cmd_rdy=0;
					clr_RX_bit_cnt=0;
				end 
				else
				begin
					next_state=IDLE;
					shift=0;
					load=0;
					set_cmd_rdy=0;
					clr_RX_bit_cnt=1;
				end
			RX:
				if(SS_n_FF2)
				begin 
					next_state=DONE;
					shift=0;
					load=0;
					set_cmd_rdy=0;
					clr_RX_bit_cnt=1;
				end
				else 
				begin
					next_state=RX;
					shift=(negSCLK) && (!SS_n_FF2) && (RX_bit_cnt!=5'b10000);
					load=0;
					set_cmd_rdy=0;
					clr_RX_bit_cnt=0;
				end
			DONE:
				if(!SS_n_FF2)
				begin
					next_state=IDLE;
					shift=0;
					load=0;
					set_cmd_rdy=0;
					clr_RX_bit_cnt=0;
				end
				else
				begin
					next_state=DONE;
					shift=0;
					load=0;
					set_cmd_rdy=1;
					clr_RX_bit_cnt=0;
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
