`timescale 1ns / 1ps

import common::*;


module execute_stage(
    input clk,
    input reset_n,
    input [31:0] data1,
    input [31:0] data2,
    input [31:0] immediate_data,
    input control_type control_in,
    input instruction_type instruction_in,
    output control_type control_out,
    output logic [31:0] alu_data,
    output logic [31:0] memory_data
);

    logic zero_flag;
    
    logic [31:0] left_operand;
    logic [31:0] right_operand;
    
    logic [31:0] wire_bw_data1_left_operand;
    logic [31:0] wire_bw_data2_right_operand;
    
    
    //logic [31:0] wire_bw_output_ALUresult;

    
    always_comb begin: operand_selector
       // left_operand = data1;
       left_operand  = ({instruction_in.funct7, instruction_in.funct3, instruction_in.opcode} == {7'b0000000, 3'b010, 7'b0110011}) ? $signed(data1) : //slt
      					 																									data1;
       
       right_operand =  ({instruction_in.funct7, instruction_in.funct3, instruction_in.opcode}  == {7'b0100000, 3'b000, 7'b0110011})   ?   -$signed(data2)        :          //sub
                        ({instruction_in.funct7, instruction_in.funct3, instruction_in.opcode}  == {7'b0000000, 3'b101,  7'b0110011})  ?  {{27{1'b0}}, data2[4:0]}:          //srl
   						({instruction_in.funct7, instruction_in.funct3, instruction_in.opcode}  == {7'b0000000, 3'b010, 7'b0110011})   ?   $signed(data2)         :          //slt
                        ({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b000, 7'b1100011})              ?  -$signed(data2)         :          //beq
     					({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b001, 7'b1100011})              ?  -$signed(data2)         :          //bne
      					({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b100, 7'b1100011})              ?  -$signed(data2)         :          //blt
                        ({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b110, 7'b1100011})              ?  (data2)                 :          //bltU
                        ({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b101, 7'b1100011})              ?  -$signed(data2)         :          //bge
      					({ instruction_in.funct3, instruction_in.opcode}                        == { 3'b111, 7'b1100011})              ?  (data2)                 :          //bgeU
     					 																									               data2                  ;
     					 																									               
        if (control_in.alu_src) begin
           // right_operand = immediate_data;
            right_operand = ({instruction_in.funct7, instruction_in.funct3, instruction_in.opcode} == {7'b0000000, 3'b010, 7'b0110011}) ?  $signed(immediate_data):  //stli
      																						                                                immediate_data; 
            end
     
    end
    
    
    alu inst_alu(
        .control(control_in.alu_op),
        .left_operand(left_operand), 
        .right_operand(right_operand),
        .zero_flag(zero_flag),
        //.result(wire_bw_output_ALUresult)
      .result(alu_data)
    );
  
   assign control_out = control_in;
   assign control_out.jump_id  =  (({ instruction_in.funct3, instruction_in.opcode} == { 3'b000, 7'b1100011}) &&  zero_flag 	      )  ?   1'b1 : //beq
    							(({ instruction_in.funct3, instruction_in.opcode} == { 3'b001, 7'b1100011}) && !zero_flag 			  )  ?   1'b1 : // bne
    							(({ instruction_in.funct3, instruction_in.opcode} == { 3'b100, 7'b1100011}) && $signed(alu_data) < 0  )  ?   1'b1 : // blt
    							(({ instruction_in.funct3, instruction_in.opcode} == { 3'b110, 7'b1100011}) && alu_data < 0           )  ?   1'b1 : // bltU
    							(({ instruction_in.funct3, instruction_in.opcode} == { 3'b101, 7'b1100011}) && $signed(alu_data) >= 0 )  ?   1'b1 : // bge
    							(({ instruction_in.funct3, instruction_in.opcode} == { 3'b111, 7'b1100011}) && alu_data >= 0 		  )  ?   1'b1 : // bgeu
    																											            	  			 1'b0;
    				
  
  
  

   // assign alu_data = ( control_in.encoding == I_TYPE && control_in.mem_read  && control_in.mem_to_reg ) ?  { {24{wire_bw_output_ALUresult[7]}}, wire_bw_output_ALUresult[7:0] } : wire_bw_output_ALUresult;
    
    assign memory_data = data2;
    
endmodule
