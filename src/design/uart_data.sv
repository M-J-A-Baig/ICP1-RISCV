module uart_data(
    input logic clk,
    input logic reset_n,
    input logic io_rx,
    output logic io_data_valid,
    output logic [31 : 0] data,
    output logic [31 : 0] program_mem_write_address,
    output logic finish
);
    		
	parameter MSB_FIRST = 1;	//
	parameter TIME_OUT = 100000;//个时钟周期  公式：(FREQUENCY_IN_HZ / BAUD) *设定的传多少bit算超时
	logic [31 : 0]data_next;
    logic [31 : 0]program_mem_write_address_next;
	logic [7:0] data_byte;
	logic byte_rx_done;	
	logic [8:0]cnt_next;	
	logic [8:0]cnt;
	logic [1:0]state;
	logic [1:0]state_next;
	logic finish_next = 0;
	
	logic [31:0]timeout_cnt;
	logic [31:0]timeout_cnt_next;
	logic count_enable;
	logic count_enable_next;
	
	localparam S0 = 0;	
	localparam S1 = 1;	
	localparam S2 = 2;	
	
		uart uart(
		.clk(clk),
		.reset_n(reset_n),
		.io_rx(io_rx),
		.io_data_valid(byte_rx_done),
		.io_data_packet(data_byte)
	);
	
	    always_ff @ (posedge clk)
    begin
        if (reset_n == 0) begin
            data <= '0;
            cnt <= '0;
            state <= S0;
            program_mem_write_address <= '0;
            count_enable <= '0;
            timeout_cnt <= '0;
            finish <= '0;           
        end 
        else begin
            data <= data_next;
            cnt <= cnt_next;
            state <= state_next;
            program_mem_write_address <= program_mem_write_address_next;
            count_enable <= count_enable_next;
            timeout_cnt <= timeout_cnt_next; 
            finish <= finish_next;      
        end
    end
    	
    
	always_comb
	begin
		data_next = data;
		state_next = state;
		cnt_next = cnt;
		io_data_valid = 0;
		program_mem_write_address_next = program_mem_write_address;
		count_enable_next = count_enable;
		timeout_cnt_next = timeout_cnt;
		finish_next = finish;
		
		if (count_enable==1)begin
		   timeout_cnt_next = timeout_cnt+1;
		end
		
		
		if (timeout_cnt == TIME_OUT)begin
            finish_next = 1;
            count_enable_next = 0;
            timeout_cnt_next = '0;
		end
		
		case(state)
			S0: 
				begin
					io_data_valid = 0;
					data_next = 0;
					 if(byte_rx_done)begin
						state_next = S1;
						cnt_next = cnt + 9'd8;
						timeout_cnt_next = '0;
						if(MSB_FIRST == 1)
							data_next = {data[23 : 0], data_byte};
						else
							data_next = {data_byte, data[31 : 8]};
					end
				end
			
			S1:

				 if(byte_rx_done)begin
					state_next = S2;
					cnt_next = cnt + 9'd8;
					if(MSB_FIRST == 1)
						data_next = {data[23 : 0], data_byte};
					else
						data_next = {data_byte, data[31 : 8]};
				end
				
			S2:
				if(cnt == 32)begin
					state_next = S0;
					cnt_next = 0;
					data_next = data;
					io_data_valid = 1;
					count_enable_next = 1;
					program_mem_write_address_next = program_mem_write_address+4;
				end
				else begin
					state_next = S1;
					io_data_valid = 0;
					count_enable_next = 0;
				end
			default:state_next = S0;
		endcase 	
	end

endmodule