`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] pc,//pc
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic [31:0] jump_target//
);

    logic zero_flag;
    //logic sign_flag; // less than 0 /more than 1
    logic [31:0] branch_target;
    assign branch_target = pc + immediate_data;
    
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    
    
    always_comb begin: operand_selector
        left_operand = data1;
        right_operand = data2;
        if (control_in.alu_src) begin
            right_operand = immediate_data;
        end
    end
    
    
    alu inst_alu(
        .control(control_in.alu_op),//
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_data)
    );
     
    assign memory_data = data2;
    
    always_comb begin
        control_out = control_in;
        jump_target = pc + 4; //default,avoid latches
        
        if (control_in.is_branch) begin
            case (control_in.branch_type)
                3'b000: begin // BEQ
                    if (zero_flag == 1'b1) begin
                        control_out.is_jump = 1'b1;
                        jump_target = branch_target;
                    end
                end
            
                3'b001: begin // BNE
                    if (zero_flag == 1'b0) begin
                        control_out.is_jump = 1'b1;
                        jump_target = branch_target;
                    end
                end
                
                3'b110: begin // BLTU
                    if (alu_data == 1'b1) begin
                        control_out.is_jump = 1'b1;
                        jump_target = branch_target;
                    end
                end
            endcase
        end
        else if(control_in.is_jump) begin
            jump_target = alu_data & 32'hFFFFFFFE; // LSB -> 0
        end
    end
        
endmodule
