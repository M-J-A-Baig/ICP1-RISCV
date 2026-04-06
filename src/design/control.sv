`timescale 1ns / 1ps

import common::*;


module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control
);

    localparam logic [16:0] ADD_INSTRUCTION = {7'b0000000, 3'b000, 7'b0110011};
    localparam logic [16:0] SUB_INSTRUCTION = {7'b0100000, 3'b000, 7'b0110011};
    localparam logic [9:0] ADDI_INSTRUCTION = {3'b000, 7'b0010011};
    localparam logic [9:0] LW_INSTRUCTION = {3'b010, 7'b0000011};
    localparam logic [9:0] SW_INSTRUCTION = {3'b010, 7'b0100011};
    localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
    
    
    localparam logic [16:0] SLL_INSTRUCTION = {7'b0000000, 3'b001, 7'b0110011};
    localparam logic [16:0] SRLI_INSTRUCTION = {3'b101, 7'b0010011};
    localparam logic [16:0] XORI_INSTRUCTION = {3'b100, 7'b0010011};
    localparam logic [16:0] AND_INSTRUCTION = {7'b0000000, 3'b111, 7'b0110011};
    localparam logic [16:0] SLTI_INSTRUCTION = {3'b010, 7'b0010011};
    
    localparam logic [16:0] BNE_INSTRUCTION = {3'b001, 7'b1100011};
    localparam logic [16:0] BLTU_INSTRUCTION = {3'b110, 7'b1100011};
    localparam logic [16:0] JALR_INSTRUCTION = {3'b000, 7'b1100111};
    
    localparam logic [16:0] LBU_INSTRUCTION = {3'b100, 7'b0000011};
    localparam logic [16:0] SH_INSTRUCTION = {3'b001, 7'b0100011};
    
    localparam logic [16:0] LUI_INSTRUCTION = {7'b0110111};
    
    always_comb begin
        control = '0;
        
        case (instruction.opcode)
            7'b0110011: begin
                control.encoding = R_TYPE;
                control.reg_write = 1'b1;
            end
            //R-type
            
            7'b0000011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1;                
                control.mem_read = 1'b1;                
                control.mem_to_reg = 1'b1;
                control.alu_op = ALU_ADD;
                
                if(instruction.funct3 == 3'b100) begin
                    control.mem_type = 2'b00;
                    control.extend_type = 1'b0;
                end                
            end
            
            7'b0010011: begin
                control.encoding = I_TYPE;
                control.reg_write = 1'b1;
                control.alu_src = 1'b1; //INPUT IMM             
            end
            
            7'b0100011: begin
                control.encoding = S_TYPE;
                control.alu_src = 1'b1;
                control.mem_write = 1'b1;
                control.alu_op = ALU_ADD;
                
                if(instruction.funct3 == 3'b001) begin
                    control.mem_type = 2'b01;
//                    control.extend_type = 1'b0;
                end                   
            end
            
            7'b1100011: begin
                control.encoding = B_TYPE;
                control.is_branch = 1'b1;
                control.branch_type = instruction.funct3;             
            end
            
            7'b1100111: begin
                control.encoding = I_TYPE;
                control.is_jump = 1'b1;
                control.alu_src = 1'b1;            
            end// JALR
            
            7'b0110111: begin //LUI
                control.encoding = U_TYPE;
                control.alu_src = 1'b1;
                control.alu_op = ALU_LUI;
                control.reg_write = 1'b1;
            end
        endcase
        
        control.alu_op = ALU_ADD;
        if ({instruction.funct7, instruction.funct3, instruction.opcode} == ADD_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end 
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SUB_INSTRUCTION) begin
            control.alu_op = ALU_SUB;
        end 
        else if ({instruction.funct3, instruction.opcode} == BEQ_INSTRUCTION) begin
            control.alu_op = ALU_SUB;
        end            
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == SLL_INSTRUCTION) begin
            control.alu_op = ALU_SLL;
        end
        else if ({instruction.funct3, instruction.opcode} == SRLI_INSTRUCTION) begin
            control.alu_op = ALU_SRL;
        end
        else if ({instruction.funct3, instruction.opcode} == XORI_INSTRUCTION) begin
            control.alu_op = ALU_XOR;
        end 
        else if ({instruction.funct7, instruction.funct3, instruction.opcode} == AND_INSTRUCTION) begin
            control.alu_op = ALU_AND;
        end 
        else if ({instruction.funct3, instruction.opcode} == SLTI_INSTRUCTION) begin
            control.alu_op = ALU_SLT;
        end
        else if ({instruction.funct3, instruction.opcode} == JALR_INSTRUCTION) begin
            control.alu_op = ALU_ADD;
        end
        else if ({instruction.funct3, instruction.opcode} == BNE_INSTRUCTION) begin
            control.alu_op = ALU_SUB;
        end 
        else if ({instruction.funct3, instruction.opcode} == BLTU_INSTRUCTION) begin
            control.alu_op = ALU_SLTU;
        end
//        else if ({instruction.funct3, instruction.opcode} == LBU_INSTRUCTION) begin
//            control.alu_op = ALU_ADD;
//        end 
//        else if ({instruction.funct3, instruction.opcode} == SH_INSTRUCTION) begin
//            control.alu_op = ALU_ADD;
//        end               
                

    end
    
endmodule
