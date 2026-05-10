`timescale 1ns / 1ps

import common::*;

module forwarding(

    input id_ex_type id_ex_reg,
    input ex_mem_type ex_mem_reg,
    input mem_wb_type mem_wb_reg,
    
    output logic [1:0] forward_A, //  alu_left_operand: 00-regular; 01-EX/MEM; 10-MEM/WB
    output logic [1:0] forward_B  // alu_right_operand
    
    );


    logic [4:0] id_ex_rs1;
    logic [4:0] id_ex_rs2;
    logic [4:0] ex_mem_rd;
    logic [4:0] mem_wb_rd;
    
    assign id_ex_rs1 = id_ex_reg.rs1; 
    assign id_ex_rs2 = id_ex_reg.rs2;
    assign ex_mem_rd = ex_mem_reg.reg_rd_id;
    assign mem_wb_rd = mem_wb_reg.reg_rd_id;
    
    always_comb begin
    
        forward_A = 2'b00; 
        if (ex_mem_reg.control.reg_write && 
            (ex_mem_rd != 0) && 
            (ex_mem_rd == id_ex_rs1)) begin
            forward_A = 2'b01;
        end
        else if (mem_wb_reg.control.reg_write && 
                 (mem_wb_rd != 0) && 
                 (mem_wb_rd == id_ex_rs1)) begin
            forward_A = 2'b10;
        end
        
        forward_B = 2'b00; 
        if (ex_mem_reg.control.reg_write && 
            (ex_mem_rd != 0) && 
            (ex_mem_rd == id_ex_rs2)) begin
            forward_B = 2'b01;
        end
        else if (mem_wb_reg.control.reg_write && 
                 (mem_wb_rd != 0) && 
                 (mem_wb_rd == id_ex_rs2)) begin
            forward_B = 2'b10;
        end
    end

endmodule