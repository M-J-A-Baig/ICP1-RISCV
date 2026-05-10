`timescale 1ns / 1ps

import common::*;


module cpu(
    input clk,
    input reset_n,
    input io_rx
);

    logic [31:0] program_mem_address ;
    logic program_mem_write_enable ;   
    logic [31:0] program_mem_write_data;       
    //logic [31:0] program_mem_write_data = 0; 
    //logic [31:0] program_mem_address = 0;
    //logic program_mem_write_enable = 0;  
    logic [31:0] program_mem_read_data;
    logic [31:0] program_mem_write_address;
    logic [31:0] program_mem_read_address;
    logic cpu_reset_n;
    logic uart_finish;

    logic [5:0] decode_reg_rd_id;
    logic [31:0] decode_data1;
    logic [31:0] decode_data2;
    logic [31:0] decode_immediate_data;
    control_type decode_control;
    
    logic [31:0] execute_alu_data;
    control_type execute_control;
    logic [31:0] execute_memory_data;
    logic [31:0] execute_jump_target;//
    
    logic [31:0] memory_memory_data;
    logic [31:0] memory_alu_data;
    control_type memory_control;
    
    logic [5:0] wb_reg_rd_id;
    logic [31:0] wb_result;
    logic wb_write_back_en;    
    
    if_id_type if_id_reg;
    id_ex_type id_ex_reg;
    ex_mem_type ex_mem_reg;
    mem_wb_type mem_wb_reg;
    
    logic [1:0] forward_A;
    logic [1:0] forward_B;//forwarding unit
    logic stall_control;
    
    logic stall_req_ex;
   
    always_ff @(posedge clk) begin
        if (!cpu_reset_n) begin
            if_id_reg <= '0;
            id_ex_reg <= '0;
            ex_mem_reg <= '0;
            mem_wb_reg <= '0;
        end
        else begin
            if ((!stall_control)&&(!stall_req_ex)) begin
                if_id_reg.pc <= program_mem_address;
                if (execute_control.is_jump) begin
                    if_id_reg.instruction <= 32'h00000013;//NOP
                end else begin
                    if_id_reg.instruction <= program_mem_read_data;
                end
            end
        
        if(!stall_req_ex) begin          
            id_ex_reg.pc <= if_id_reg.pc;
            id_ex_reg.reg_rd_id <= decode_reg_rd_id;
            id_ex_reg.data1 <= decode_data1;
            id_ex_reg.data2 <= decode_data2;
            id_ex_reg.immediate_data <= decode_immediate_data;
            id_ex_reg.rs1 <= if_id_reg.instruction.rs1;
            id_ex_reg.rs2 <= if_id_reg.instruction.rs2;
            if (execute_control.is_jump || stall_control) begin
                id_ex_reg.control <= '0;//NO CONTROL
            end else begin
                id_ex_reg.control <= decode_control;
            end
        end 
            
        if(!stall_req_ex) begin
            ex_mem_reg.pc <= id_ex_reg.pc;
            ex_mem_reg.reg_rd_id <= id_ex_reg.reg_rd_id;
            ex_mem_reg.control <= execute_control;
            ex_mem_reg.alu_data <= execute_alu_data;
            ex_mem_reg.memory_data <= execute_memory_data;
        end
            else begin
            ex_mem_reg <= '0;
            end
            
            mem_wb_reg.pc <= ex_mem_reg.pc;
            mem_wb_reg.reg_rd_id <= ex_mem_reg.reg_rd_id;
            mem_wb_reg.memory_data <= memory_memory_data;
            mem_wb_reg.alu_data <= memory_alu_data;
            mem_wb_reg.control <= memory_control;
        end
    end

    uart_data uart_data(
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx),
        .io_data_valid(program_mem_write_enable),
        .data(program_mem_write_data),
        .program_mem_write_address(program_mem_write_address),
        .finish(uart_finish)          
    );

    program_memory inst_mem(
        .clk(clk),        
        .byte_address(program_mem_address),
        .write_enable(program_mem_write_enable),
        .write_data(program_mem_write_data),
        .read_data(program_mem_read_data)
    );
    
    
    fetch_stage inst_fetch_stage(
        .clk(clk), 
        .reset_n(cpu_reset_n),
        .address(program_mem_read_address),
        .data(program_mem_read_data),
        .jump_en(execute_control.is_jump),
        .jump_target(execute_jump_target),
        .stall_control(stall_control|stall_req_ex)
        //.jump_en(ex_mem_reg.control.is_jump),
        //.jump_target(ex_mem_reg.alu_data)        
    );
    
    
    decode_stage inst_decode_stage(
        .clk(clk), 
        .reset_n(cpu_reset_n),    
        .instruction(if_id_reg.instruction),
        .pc(if_id_reg.pc),
        .write_en(wb_write_back_en),
        .write_id(wb_reg_rd_id),        
        .write_data(wb_result),
        .reg_rd_id(decode_reg_rd_id),
        .read_data1(decode_data1),
        .read_data2(decode_data2),
        .immediate_data(decode_immediate_data),
        .control_signals(decode_control)
    );
    
    
    execute_stage inst_execute_stage(
        .clk(clk), 
        .reset_n(cpu_reset_n),
        .pc(id_ex_reg.pc),
        .data1(id_ex_reg.data1),
        .data2(id_ex_reg.data2),
        .immediate_data(id_ex_reg.immediate_data),
        .forward_A(forward_A), // forward control
        .forward_B(forward_B), // forward control
        .forward_data_mem(ex_mem_reg.alu_data), // forward_data from EX/MEM
        .forward_data_wb(wb_result), // forward_data from MEM/WB
        .control_in(id_ex_reg.control),
        .control_out(execute_control),
        .alu_data(execute_alu_data),
        .memory_data(execute_memory_data),
        .stall_req_ex(stall_req_ex),
        .jump_target(execute_jump_target)          
    );
    
    
    mem_stage inst_mem_stage(
        .clk(clk), 
        .reset_n(cpu_reset_n),
        .alu_data_in(ex_mem_reg.alu_data),
        .memory_data_in(ex_mem_reg.memory_data),
        .control_in(ex_mem_reg.control),
        .control_out(memory_control),
        .memory_data_out(memory_memory_data),
        .alu_data_out(memory_alu_data)
    );

    assign cpu_reset_n = reset_n & uart_finish;
    assign program_mem_address = program_mem_write_enable ? program_mem_write_address : program_mem_read_address;
    assign wb_reg_rd_id = mem_wb_reg.reg_rd_id;
    assign wb_write_back_en = mem_wb_reg.control.reg_write;
    //assign wb_result = mem_wb_reg.control.mem_read ? mem_wb_reg.memory_data : mem_wb_reg.alu_data;
    assign wb_result = mem_wb_reg.control.mem_read ? mem_wb_reg.memory_data : mem_wb_reg.alu_data;

    forwarding inst_forwarding(
        .id_ex_reg(id_ex_reg),
        .ex_mem_reg(ex_mem_reg),
        .mem_wb_reg(mem_wb_reg),
        .forward_A(forward_A),
        .forward_B(forward_B)
    );
    
    // load_use_hazard detection
    
    always_comb begin
        stall_control = 1'b0; 
        
        if (id_ex_reg.control.mem_read && (id_ex_reg.reg_rd_id != 0)) begin
            if ((id_ex_reg.reg_rd_id == if_id_reg.instruction.rs1) || 
                (id_ex_reg.reg_rd_id == if_id_reg.instruction.rs2)) begin
                stall_control = 1'b1; 
            end
        end
    end
    
endmodule
