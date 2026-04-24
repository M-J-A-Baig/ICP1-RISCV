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

    logic [1:0] offset;// to choose which bytes
    logic [7:0] memory_byte;// different bytes in one address
    logic [15:0] memory_halfword;

    logic [31:0] write_data;
    assign offset = alu_data_in[1:0]; // byte offset

//--------link---------
    data_memory inst_mem(
    .clk(clk),        
    .byte_address(alu_data_out),
    .write_byte_enable(mem_byte_enable),  
    .write_data(write_data),
    .read_data(raw_read_data)
    );
    
//-----------WRITE---------------
    always_comb begin
        mem_byte_enable = 4'b0000;
        write_data = memory_data_in;

        if (control_in.mem_write) begin  //write-store
            if (control_in.funct3 == 3'b001) begin // SH
                case (offset[1])
                    1'b0: begin
                                mem_byte_enable = 4'b0011;
                                write_data = {16'b0, memory_data_in[15:0]};
                            end
                    1'b1: begin
                                mem_byte_enable = 4'b1100;
                                write_data = {memory_data_in[15:0], 16'b0};
                            end
                    default:begin
                        mem_byte_enable = 4'b0011;
                        write_data = {16'b0, memory_data_in[15:0]};
                    end
                endcase
                mem_byte_enable = 4'b0011;                  
            end 
            else if (control_in.funct3 == 3'b000) begin //SB
                case (offset)
                    2'b00:  begin
                                mem_byte_enable = 4'b0001;
                                write_data = {24'b0, memory_data_in[7:0]};
                            end
                    2'b01: begin
                                mem_byte_enable = 4'b0010;
                                write_data = {16'b0, memory_data_in[7:0], 8'b0};
                            end
                    2'b10: begin
                                mem_byte_enable = 4'b0100;
                                write_data = {8'b0, memory_data_in[7:0], 16'b0};
                            end
                    2'b11: begin
                                mem_byte_enable = 4'b1000;
                                write_data = {memory_data_in[7:0], 24'b0};
                            end
                    default:begin
                        mem_byte_enable = 4'b0001;
                        write_data = {24'b0, memory_data_in[7:0]};
                    end
                endcase
            end
            else begin //  SW 
                mem_byte_enable = 4'b1111;
            end
        end
    end

    
//---------READ--------------
    always_comb begin        
        memory_data_out = raw_read_data; //LW
        
        // determine which byte
        case (offset)
            2'b00: memory_byte = raw_read_data[7:0];
            2'b01: memory_byte = raw_read_data[15:8];
            2'b10: memory_byte = raw_read_data[23:16];
            2'b11: memory_byte = raw_read_data[31:24];
            default:begin
                memory_byte = raw_read_data[7:0];
            end
        endcase

        // determine which half
        case (offset[1])
            1'b0: memory_halfword = raw_read_data[15:0];
            1'b1: memory_halfword = raw_read_data[31:16];
            default:begin
                memory_halfword = raw_read_data[15:0];
            end
        endcase
  
        //different load type
        case (control_in.funct3)
            3'b000: // LB
                memory_data_out = { {24{memory_byte[7]}}, memory_byte };
            3'b001: // LH
                memory_data_out = { {16{memory_byte[15]}}, memory_halfword };
            3'b100: // LBU 
                memory_data_out = { 24'b0, memory_byte };
            3'b101: // LHU 
                memory_data_out = { 16'b0, memory_halfword };
            default:
               memory_data_out = raw_read_data; //LW
        endcase
    end

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
