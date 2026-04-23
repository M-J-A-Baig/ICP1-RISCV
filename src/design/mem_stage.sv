`timescale 1ns / 1ps
//`include "data_memory.sv"


module mem_stage(
    input clk,
    input reset_n,
    input [31:0] alu_data_in,
    input [31:0] memory_data_in,
  	input instruction_type intruction_in,
    input control_type control_in,
    output control_type control_out,
    output logic [31:0] memory_data_out,
    output logic [31:0] alu_data_out
);
  
  logic[31:0] wire_memdataout_readout;
  logic[31:0] wire_memdataoin_datamem;

	
  localparam logic [9:0] LB_INSTRUCTION  = {3'b000, 7'b0000011};
  localparam logic [9:0] LBU_INSTRUCTION = {3'b100, 7'b0000011};
  localparam logic [9:0] LH_INSTRUCTION  = {3'b001, 7'b0000011};
  localparam logic [9:0] LHU_INSTRUCTION = {3'b101, 7'b0000011};
  
  
  localparam logic [9:0] SB_INSTRUCTION  = {3'b000, 7'b0100011};
  localparam logic [9:0] SH_INSTRUCTION = {3'b001, 7'b0100011};
  
  assign wire_memdataoin_datamem = ( {intruction_in.funct3, intruction_in.opcode} == SB_INSTRUCTION)  ? { {24{1'b0}}, wire_memdataout_readout[7:0] }    :  // sb
                                   ( {intruction_in.funct3, intruction_in.opcode} == SH_INSTRUCTION)  ? { {16{1'b0}}, wire_memdataout_readout[15:0] }    :  // sh
    																									memory_data_in;                                    //sw
  
  
    data_memory inst_mem(
        .clk(clk),        
        .byte_address(alu_data_out),
        .write_enable(control_in.mem_write),
        .write_data(wire_memdataoin_datamem),
        .read_data(wire_memdataout_readout)
    );
    
  
    
    assign memory_data_out = ( {intruction_in.funct3, intruction_in.opcode} == LB_INSTRUCTION)  ?  { {24{wire_memdataout_readout[7]}}, wire_memdataout_readout[7:0] } : //only when Itype load
     						 ( {intruction_in.funct3, intruction_in.opcode} == LBU_INSTRUCTION) ?  { {24{1'b0}}, wire_memdataout_readout[7:0] } : //lbu
                             ( {intruction_in.funct3, intruction_in.opcode} == LH_INSTRUCTION)  ?  { {16{wire_memdataout_readout[7]}}, wire_memdataout_readout[15:0] } : // lh
                             ( {intruction_in.funct3, intruction_in.opcode} == LHU_INSTRUCTION) ?  { {16{1'b0}}, wire_memdataout_readout[15:0] } : //lhu
      																								wire_memdataout_readout;  

    assign alu_data_out = alu_data_in;    
    assign control_out = control_in;
    
endmodule
