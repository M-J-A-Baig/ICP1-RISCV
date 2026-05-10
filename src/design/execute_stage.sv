`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] pc,//pc
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input [1:0]  forward_A, //forward control
    input [1:0]  forward_B, //forward control
    input [31:0] forward_data_mem, //forward data
    input [31:0] forward_data_wb, //forward data
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data,
    output logic stall_req_ex,
    output logic [31:0] jump_target//
);

    logic zero_flag;
    //logic sign_flag; // less than 0 /more than 1
    logic [31:0] branch_target;
    assign branch_target = pc + immediate_data;
    
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    logic [31:0] forwarded_data2;
    
    logic mdu_ready;
    logic [31:0] mdu_result;
    logic [31:0] alu_result;

    always_comb begin: operand_selector
        case(forward_A)
            2'b00: left_operand = data1;              
            2'b01: left_operand = forward_data_mem;   
            2'b10: left_operand = forward_data_wb;    
            default: left_operand = data1;
        endcase
        
        if (control_in.encoding == U_TYPE) begin
            left_operand = pc; 
        end
        
        case(forward_B)
            2'b00: forwarded_data2 = data2;
            2'b01: forwarded_data2 = forward_data_mem;
            2'b10: forwarded_data2 = forward_data_wb;
            default: forwarded_data2 = data2;
        endcase
        right_operand = forwarded_data2;
        if (control_in.alu_src) begin
            right_operand = immediate_data;
        end
    end
        assign memory_data = forwarded_data2;
//    always_comb begin: operand_selector
//        left_operand = data1;
//        right_operand = data2;
//        if (control_in.alu_src) begin
//            right_operand = immediate_data;
//        end
//    end
    
    
    alu inst_alu(
        .control(control_in.alu_op),//
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        .result(alu_result)
    );
     
    mdu mdu_inst (
        .clk(clk),
        .reset_n(reset_n),
        .start(control_in.is_mdu && !mdu_ready), // 如果是 MDU 指令且还没算完，就启动
        .op(control_in.funct3),
        .operand_a(left_operand),
        .operand_b(right_operand),
        .result(mdu_result),
        .ready(mdu_ready)
    );
    
    assign stall_req_ex = control_in.is_mdu & ~mdu_ready;
    
    assign alu_data = control_in.is_jump ? (pc+4) : (control_in.is_mdu ? mdu_result : alu_result);
    
    always_comb begin
        control_out = control_in;
        jump_target = pc + 4; //default,avoid latches
        
        if (control_in.is_branch) begin
            case (control_in.funct3)
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
                
                default: begin // other branch instructions
                    if (alu_result == 1'b1) begin
                        control_out.is_jump = 1'b1;
                        jump_target = branch_target;
                    end
                end
            endcase
        end
        else if(control_in.is_jump) begin
            if (control_in.encoding == J_TYPE) begin
                // JAL target : PC + offset 
                jump_target = branch_target; 
            end 
            else begin
                // JALR target: rs1 + offset 
                jump_target = alu_result & 32'hFFFFFFFE; // LSB -> 0
            end
        end
    end
        
endmodule
