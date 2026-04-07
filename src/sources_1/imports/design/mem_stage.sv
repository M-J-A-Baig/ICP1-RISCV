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
    logic [7:0]  memory_byte;
    logic [15:0] memory_halfword;
    logic [31:0] memory_data;
    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_out),
        .write_enable(control_in.mem_write),
        .write_data(memory_data_in),
        .read_data(memory_data)
    );
    
    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
    always_comb begin
    memory_data_out = memory_data;
        // 1. 字节提取 (基于内存地址的最低两位 alu_result[1:0])
        // 因为 RISC-V 是小端序 (Little-Endian)，地址 0 对应最低字节
        case (alu_data_in[1:0])
            2'b00: memory_byte = memory_data[7:0];
            2'b01: memory_byte = memory_data[15:8];
            2'b10: memory_byte = memory_data[23:16];
            2'b11: memory_byte = memory_data[31:24];
        endcase
        
        case (alu_data_in[1])
            1'b0: memory_halfword = memory_data[15:0];
            1'b1: memory_halfword = memory_data[31:16];
        endcase
        
        case (control_in.funct3)
            3'b000: // LB: 提取字节，并进行 24 位符号扩展
                memory_data_out = { {24{memory_byte[7]}}, memory_byte };
                
            3'b100: // LBU (Load Byte Unsigned): 提取字节，高位无脑补 0 (顺手把 LBU 也做了！)
                memory_data_out = { 24'b0, memory_byte };
                
            3'b010: // LW: 直接使用完整的 32 位内存数据
                memory_data_out = memory_data;
                
            3'b101: // LHU (你的目标): 提取半字，16位无脑补 0
                memory_data_out = { 16'b0, memory_halfword };                
            // 如果以后要实现 LH (半字) 和 LHU (无符号半字)，也是在这里加分支！
        endcase
    end

    
endmodule
