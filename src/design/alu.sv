`timescale 1ns / 1ps

import common::*;


module alu(
    input wire [3:0] control, // modify regarding common.sv
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
            
            ALU_SLL: result = left_operand << right_operand;
            ALU_SRL: result = left_operand >> right_operand; // the same as ALU_SRLI
            ALU_LUI: result = right_operand;
            ALU_XOR: result = left_operand ^ right_operand;  // the same as ALU_XORI
            ALU_SLT: result = $signed(left_operand) < $signed(right_operand); // the same as ALU_SLTI(use SUB??)
            ALU_SLTU: result = $unsigned(left_operand) < $unsigned(right_operand);
            default: result = left_operand + right_operand;
        endcase
    end
    
    
    assign zero_flag = (result == 0) ? 1'b1 : 1'b0;
    

endmodule
