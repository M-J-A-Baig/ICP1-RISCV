`timescale 1ns / 1ps


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] alu_data_out
);

    logic [3:0] mem_byte_enable;
    logic [31:0] raw_read_data;
    logic [1:0] offset;
    
    assign offset = alu_data_in[1:0]; // byte offset
    
//WRITE
    always_comb begin
        mem_byte_enable = 4'b0000;
        
        if (control_in.mem_write) begin//write/store
            if (control_in.funct3 == 3'b001) begin // SH
                    mem_byte_enable = 4'b0011;                  
            end else begin //  SW 
                mem_byte_enable = 4'b1111;
            end
        end
    end
    
    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_out),
        .write_byte_enable(mem_byte_enable),
        .write_data(memory_data_in),
        .read_data(raw_read_data)
    );
    
//READ
    always_comb begin        
        memory_data_out = raw_read_data; //LW
        if (control_in.mem_read) begin
            if (control_in.funct3 == 3'b100) begin // LBU 
                case (offset)
                    2'b00: memory_data_out = {24'b0, raw_read_data[7:0]};
                    2'b01: memory_data_out = {24'b0, raw_read_data[15:8]};
                    2'b10: memory_data_out = {24'b0, raw_read_data[23:16]};
                    2'b11: memory_data_out = {24'b0, raw_read_data[31:24]};
                endcase
            end
        end
    end

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
