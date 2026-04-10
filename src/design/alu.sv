`timescale 1ns / 1ps

import common::*;
//`include "common.sv"

module alu(
    input wire [2:0] control,
    input wire [31:0] left_operand, 
    input wire [31:0] right_operand,
    output logic zero_flag,
    output logic [31:0] result 
);

    always_comb begin
        case (control)
            ALU_AND: result = left_operand & right_operand;
            ALU_OR: result = left_operand | right_operand;
            ALU_ADD: result = left_operand + right_operand;
            ALU_SUB: result = left_operand - right_operand;


            // ALU_SRL :  result = left_operand >> right_operand[4:0]; // shiift only lower 5 bit value
            // ALU_SRAI: result = $signed(left_operand) >>> right_operand[4:0]; // shiift only lower 5 bit value
            // ALU_XOR : result = left_operand ^ right_operand;
            // ALU_ORI : result = left_operand | right_operand;
            // ALU_SLT : result = ($signed(left_operand) < $signed(right_operand)) ? 32'd1 : 32'd0;
            // ALU_SLTIU: result = (left_operand < right_operand) ? 32'd1 : 32'd0;




            default: result = left_operand + right_operand;
        endcase
    end
    
    
    assign zero_flag = 1'b1 ? result == 0 : 1'b0;

endmodule
