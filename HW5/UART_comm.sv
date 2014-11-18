module UART_comm(clr_rdy,cmd_rdy,cmd,clk,rst_n,rdy,clr_cmd_rdy,rx_data);
    input logic clk,rst_n,clr_cmd_rdy,rdy;
	input logic [7:0]rx_data;
	output logic clr_rdy,cmd_rdy;
	output logic [23:0] cmd;
	logic byte_sel_1,byte_sel_2,clr_byte_cnt,rdy_FF1,posedge_rdy;
	logic [1:0] byte_cnt;
	logic [7:0]cmd_1st_byte,cmd_2nd_byte,rx_mux_1st_byte,rx_mux_2nd_byte;
	typedef enum reg [1:0] {IDLE,RECEIVE,DONE} state_t;
	state_t state,next_state;
	
	assign rx_mux_1st_byte=(byte_sel_1 && !rdy)?  rx_data: cmd_1st_byte; 
	assign rx_mux_2nd_byte=(byte_sel_2 && !rdy)?  rx_data: cmd_2nd_byte;
	

	always_ff@(posedge clk, negedge rst_n)
	begin
		if(!rst_n)
		begin
			cmd_1st_byte<=8'b0000_0000;
			cmd_2nd_byte<=8'b0000_0000;
		end
		else
		begin
			cmd_1st_byte<=rx_mux_1st_byte;
			cmd_2nd_byte<=rx_mux_2nd_byte;
		end
	end
	assign cmd=cmd_rdy? {cmd_1st_byte,cmd_2nd_byte,rx_data[7:0]}:cmd;
	
	
	always_ff@(posedge clk)//找RX rising edge 用來讓_byte_cnt+1
	begin
			rdy_FF1<=rdy;
	end
	assign posedge_rdy=!rdy_FF1&&(rdy);
	
	
	
	always_ff@(posedge clk)///count whether there are 3 bytes
	begin
		if(clr_byte_cnt)
			byte_cnt<=2'b00;
		else if(posedge_rdy)
			byte_cnt<=byte_cnt+2'b01;
	end
	
	
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
		 clr_rdy=0;
		 cmd_rdy=1;
		 byte_sel_1=0;
		 byte_sel_2=0;
		 clr_byte_cnt=0;

		 case(state)
			IDLE:
				if(clr_cmd_rdy && rdy)
		        begin 
					next_state=RECEIVE;
					clr_rdy=0;	
					cmd_rdy=0;
					byte_sel_1=0;
					byte_sel_2=0;
					clr_byte_cnt=0;				
				end 
				else
				begin
					next_state=IDLE;
					clr_rdy=0;	
					cmd_rdy=1;
					byte_sel_1=0;
					byte_sel_2=0;
					clr_byte_cnt=1;	
				end
			RECEIVE:
				if(byte_cnt==2'b00)
				begin 
					next_state=RECEIVE;
					clr_rdy=1;
					cmd_rdy=0;
					byte_sel_1=0;
					byte_sel_2=0;
					clr_byte_cnt=0;	
				end
				else if(byte_cnt==2'b01)
				begin
					next_state=RECEIVE;
					clr_rdy=1;
					cmd_rdy=0;
					byte_sel_1=1;
					byte_sel_2=0;
					clr_byte_cnt=0;	
				end
				else if(byte_cnt==2'b10)
				begin
					next_state=RECEIVE;
					clr_rdy=1;
					cmd_rdy=0;
					byte_sel_1=0;
					byte_sel_2=1;
					clr_byte_cnt=0;	
				end
				else
				begin
					next_state=DONE;
					clr_rdy=1;
					cmd_rdy=0;
					byte_sel_1=0;
					byte_sel_2=0;
					clr_byte_cnt=0;	
				end
				
			DONE:
				begin
					next_state=IDLE;
					clr_rdy=0;
					cmd_rdy=1;
					byte_sel_1=0;
					byte_sel_2=0;
					clr_byte_cnt=0;	
				end
			default: next_state=IDLE;
      endcase
    end
endmodule
