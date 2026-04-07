`timescale 1ns / 1ps

import common::*;


module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control
);

    localparam logic [16:0] ADD_INSTRUCTION = {7'b0000000, 3'b000, 7'b0110011};//
    localparam logic [16:0] SUB_INSTRUCTION = {7'b0100000, 3'b000, 7'b0110011};//
    localparam logic [16:0] SLLI_INSTRUCTION = {7'b0000000,3'b001, 7'b0010011};//
    localparam logic [16:0] SRA_INSTRUCTION = {7'b0100000, 3'b101, 7'b0110011};//
    localparam logic [16:0] OR_INSTRUCTION = {7'b0000000, 3'b110, 7'b0110011};//
    localparam logic [16:0] SLTU_INSTRUCTION = {7'b0000000, 3'b011, 7'b0110011};//
    localparam logic [9:0] ADDI_INSTRUCTION = {3'b000, 7'b0010011};//
    localparam logic [9:0] LW_INSTRUCTION = {3'b010, 7'b0000011};//
    localparam logic [9:0] SW_INSTRUCTION = {3'b010, 7'b0100011};//
    localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};// 
    localparam logic [9:0] ANDI_INSTRUCTION = {3'b111, 7'b0010011};//
    localparam logic [9:0] LB_INSTRUCTION = {3'b000, 7'b0000011};//
    localparam logic [9:0] LHU_INSTRUCTION = {3'b101, 7'b0000011};//
    localparam logic [9:0] BLT_INSTRUCTION = {3'b100, 7'b1100011};//
    localparam logic [9:0] BGEU_INSTRUCTION = {3'b111, 7'b1100011};//
    localparam logic [6:0] AUIPC_INSTRUCTION = 7'b0010111;//
    
    
    always_comb begin
        control = '0;
        control.funct3 = instruction.funct3;
        
        case (instruction.opcode)
            7'b0110011: begin
                control.encoding = R_TYPE;
                control.reg_write = 1'b1;
            end
            
            7'b0000011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;                
                control.mem_read = 1'b1;                
                control.mem_to_reg = 1'b1;                 
            end
            
            7'b0010011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;              
            end
            
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src = 1'b1;
                control.mem_write = 1'b1;                  
            end
            
            7'b1100011: begin
                control.encoding = B_TYPE;
                control.is_branch = 1'b1;            
            end
            
            7'b0010111: begin
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1; 
            end
            
            7'b0110111: begin
                control.encoding = U_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1; 
            end
        endcase
        
        control.alu_op = ALU_ADD;
        if ({instruction.funct7, instruction.funct3, instruction.opcode} == ADD_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if (instruction.opcode == AUIPC_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == ADDI_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == LW_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == LB_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == SW_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == LHU_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SUB_INSTRUCTION) begin
            control.alu_op = ALU_SUB;
        end 
        else if ({instruction.funct3, instruction.opcode} == BEQ_INSTRUCTION) begin
            control.alu_op = ALU_SUB;
        end
        
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == OR_INSTRUCTION) begin
            control.alu_op = ALU_OR;
        end
        
        else if ({instruction.funct3, instruction.opcode} == ANDI_INSTRUCTION) begin
            control.alu_op = ALU_AND;
        end
        
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLLI_INSTRUCTION) begin
            control.alu_op = ALU_SLL;
        end
        
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SRA_INSTRUCTION) begin
            control.alu_op = ALU_SRA;
        end
        
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLTU_INSTRUCTION) begin
            control.alu_op = ALU_SLTU;
        end    
        else if ({instruction.funct3, instruction.opcode} == BLT_INSTRUCTION) begin
            control.alu_op = ALU_SLTU;
        end
        
        else if ({instruction.funct3, instruction.opcode} == BGEU_INSTRUCTION) begin
            control.alu_op = ALU_BGEU;
        end            
    end
    
endmodule
