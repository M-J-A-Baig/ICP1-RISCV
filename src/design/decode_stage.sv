`timescale 1ns / 1ps

import common::*;


module decode_stage(
    input clk,
    input reset_n,
    input instruction_type instruction,
    input logic [31:0] pc,
    input logic write_en,
    input logic [5:0] write_id,
    input logic [31:0] write_data,
    output logic [5:0] reg_rd_id,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
  output logic [31:0] immediate_data,
    output control_type control_signals
);

    logic [31:0] rf_read_data1;
    logic [31:0] rf_read_data2;
  logic [4:0]   wire_read_decision_between_commands;
    
    control_type controls;
  
  //wire_read_decision_between_commands = (({instruction.funct3, instruction.opcode} == { 3'b000, 7'b0000011})) ? (instruction.rs1 + )
        

    register_file rf_inst(
        .clk(clk),
        .reset_n(reset_n),
        .write_en(write_en),
        .read1_id(instruction.rs1),
        .read2_id(instruction.rs2),
        .write_id(write_id),
        .write_data(write_data),
        .read1_data(rf_read_data1),
        .read2_data(rf_read_data2)        
    );
    

    control inst_control(
        .clk(clk), 
        .reset_n(reset_n), 
        .instruction(instruction),
        .control(controls)
    );
    
   
  
    assign reg_rd_id = instruction.rd;
    assign control_signals = controls;
  
    //assign immediate_data = ({instruction.funct7, instruction.funct3, instruction.opcode} == {7'b0000000, 3'b010, 7'b0110011}) ?  $signed(immediate_extension(instruction, controls.encoding)):  //stli
    //  																						                                      immediate_extension(instruction, controls.encoding);
 
   // assign read_data1 = ({instruction.funct7, instruction.funct3, instruction.opcode} == {7'b0000000, 3'b010, 7'b0110011}) ? $signed(rf_read_data1) : //slt
   //  					 																									  rf_read_data1;
   
    assign immediate_data =  immediate_extension(instruction, controls.encoding);
    assign read_data1 = rf_read_data1;
    assign read_data2 =  rf_read_data2;
//  	assign read_data2 = ({instruction.funct7, instruction.funct3, instruction.opcode} == {7'b0100000, 3'b000, 7'b0110011}) ? -$signed(rf_read_data2) : //sub
//   						({instruction.funct7, instruction.funct3, instruction.opcode} == {7'b0000000, 3'b010, 7'b0110011}) ? $signed(rf_read_data2) : //slt
//                        ({ instruction.funct3, instruction.opcode}                    == { 3'b000, 7'b1100011})            ? -$signed(rf_read_data2) : //beq
//     					({ instruction.funct3, instruction.opcode}                    == { 3'b001, 7'b1100011})            ? -$signed(rf_read_data2) : //bne
//      					({ instruction.funct3, instruction.opcode}                    == { 3'b100, 7'b1100011})            ? -$signed(rf_read_data2) : //blt
//                        ({ instruction.funct3, instruction.opcode}                    == { 3'b110, 7'b1100011})            ? (rf_read_data2) : //bltU
//                        ({ instruction.funct3, instruction.opcode}                    == { 3'b101, 7'b1100011})            ? -$signed(rf_read_data2) : //bge
//      					({ instruction.funct3, instruction.opcode}                    == { 3'b111, 7'b1100011})            ? (rf_read_data2) : //bgeU
//     					 																									  rf_read_data2;

    
endmodule
    
