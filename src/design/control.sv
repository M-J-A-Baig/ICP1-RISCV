`timescale 1ns / 1ps

import common::*;

module control(
    input clk,
    input reset_n,
    input instruction_type instruction, 
    output control_type control
);

  localparam logic [9:0] ADD_INSTRUCTION =  {7'b0000000, 3'b000};
  localparam logic [9:0] ADDI_INSTRUCTION = {7'b0000000, 3'b000};
  localparam logic [9:0] SUB_INSTRUCTION =  {7'b0100000, 3'b000};
  
  localparam logic [9:0] SRL_INSTRUCTION =  {7'b0000000, 3'b101};
  localparam logic [9:0] SRA_INSTRUCTION =  {7'b0100000, 3'b101};
  localparam logic [9:0] SRAI_INSTRUCTION = {7'b0100000, 3'b101};
  
  localparam logic [9:0] AND_INSTRUCTION = {7'b0000000, 3'b111};
  localparam logic [2:0] ANDI_INSTRUCTION = {3'b111};
  localparam logic [9:0] XOR_INSTRUCTION = {7'b0000000, 3'b100};
  localparam logic [2:0] XORI_INSTRUCTION = {3'b100};
  localparam logic [9:0] OR_INSTRUCTION = {7'b0000000, 3'b110};
  localparam logic [2:0] ORI_INSTRUCTION = {3'b110};
  
  localparam logic [9:0] SLT_INSTRUCTION = {7'b0000000, 3'b010};
  localparam logic [2:0] SLTI_INSTRUCTION = {3'b010};
  localparam logic [9:0] SLTU_INSTRUCTION = {7'b0000000, 3'b011};
  localparam logic [2:0] SLTUI_INSTRUCTION = {3'b011};
  
  
  localparam logic [9:0] LB_INSTRUCTION = {3'b000, 7'b0000011};
  localparam logic [9:0] LBU_INSTRUCTION = {3'b100, 7'b0000011};
  localparam logic [9:0] LH_INSTRUCTION = {3'b001, 7'b0000011};
  localparam logic [9:0] LHU_INSTRUCTION = {3'b101, 7'b0000011};


//     localparam logic [9:0] LW_INSTRUCTION = {3'b010, 7'b0000011};
//     localparam logic [9:0] SW_INSTRUCTION = {3'b010, 7'b0100011};
//     localparam logic [9:0] BEQ_INSTRUCTION = {3'b000, 7'b1100011};
  

    // // green commands - grade 3
    // localparam logic [16:0] SLL_INSTRUCTION     = {7'b0000000, 3'b001, 7'b0110011};
    // localparam logic [9:0] SLLI_INSTRUCTION     = {3'b001, 7'b0010011};
    // //     ALU_SRL       = 6'b000110,
    // localparam logic [9:0] SRLI_INSTRUCTION     = {3'b101, 7'b0010011};
    // localparam logic [16:0] SRA_INSTRUCTION     = {7'b0100000, 3'b101, 7'b0110011};
    // localparam logic [9:0] SRAI_INSTRUCTION     = {3'b101, 7'b0010011}; // note funct7 needed at runtime
    // localparam logic [9:0] LUI_INSTRUCTION      = {3'b000, 7'b0110111};
    // localparam logic [9:0] AUIPC_INSTRUCTION    = {3'b000, 7'b0010111};
    // localparam logic [16:0] AND_INSTRUCTION     = {7'b0000000, 3'b111, 7'b0110011};
    // localparam logic [9:0] ANDI_INSTRUCTION     = {3'b111, 7'b0010011};
    // localparam logic [16:0] XOR_INSTRUCTION     = {7'b0000000, 3'b100, 7'b0110011};
    // localparam logic [9:0] XORI_INSTRUCTION     = {3'b100, 7'b0010011};
    // localparam logic [16:0] OR_INSTRUCTION      = {7'b0000000, 3'b110, 7'b0110011};
    // localparam logic [9:0] ORI_INSTRUCTION      = {3'b110, 7'b0010011};
    // localparam logic [16:0] SLT_INSTRUCTION     = {7'b0000000, 3'b010, 7'b0110011};
    // localparam logic [9:0] SLTI_INSTRUCTION     = {3'b010, 7'b0010011};
    // localparam logic [16:0] SLTU_INSTRUCTION    = {7'b0000000, 3'b011, 7'b0110011};
    // localparam logic [9:0] SLTIU_INSTRUCTION    = {3'b011, 7'b0010011};
    // localparam logic [9:0] BNE_INSTRUCTION      = {3'b001, 7'b1100011};
    // localparam logic [9:0] BLT_INSTRUCTION      = {3'b100, 7'b1100011};
    // localparam logic [9:0] BGE_INSTRUCTION      = {3'b101, 7'b1100011};
    // localparam logic [9:0] BLTU_INSTRUCTION     = {3'b110, 7'b1100011};
    // localparam logic [9:0] BGEU_INSTRUCTION     = {3'b111, 7'b1100011};
    // localparam logic [9:0] JAL_INSTRUCTION      = {3'b000, 7'b1101111};
    // localparam logic [9:0] JALR_INSTRUCTION     = {3'b000, 7'b1100111};
    // localparam logic [9:0] LB_INSTRUCTION       = {3'b000, 7'b0000011};
    // localparam logic [9:0] LH_INSTRUCTION       = {3'b001, 7'b0000011};
    // localparam logic [9:0] LBU_INSTRUCTION      = {3'b100, 7'b0000011};
    // localparam logic [9:0] LHU_INSTRUCTION      = {3'b101, 7'b0000011};
    // localparam logic [9:0] SB_INSTRUCTION       = {3'b000, 7'b0100011};
    // localparam logic [9:0] SH_INSTRUCTION       = {3'b001, 7'b0100011};
    // // orange commands - grade 4
    // localparam logic [16:0] MUL_INSTRUCTION     = {7'b0000001, 3'b000, 7'b0110011};
    // localparam logic [16:0] MULH_INSTRUCTION    = {7'b0000001, 3'b001, 7'b0110011};
    // localparam logic [16:0] MULHU_INSTRUCTION   = {7'b0000001, 3'b011, 7'b0110011};
    // localparam logic [16:0] MULHSU_INSTRUCTION  = {7'b0000001, 3'b010, 7'b0110011};
    // localparam logic [16:0] DIV_INSTRUCTION     = {7'b0000001, 3'b100, 7'b0110011};
    // localparam logic [16:0] DIVU_INSTRUCTION    = {7'b0000001, 3'b101, 7'b0110011};
    // localparam logic [16:0] REM_INSTRUCTION     = {7'b0000001, 3'b110, 7'b0110011};
    // localparam logic [16:0] REMU_INSTRUCTION    = {7'b0000001, 3'b111, 7'b0110011};
    // //grade 5 red commands
    // localparam logic [16:0] FCVT_S_W_INSTRUCTION   = {7'b1101000, 3'b000, 7'b1010011};
    // localparam logic [16:0] FCVT_S_WU_INSTRUCTION  = {7'b1101000, 3'b001, 7'b1010011};
    // localparam logic [16:0] FCVT_W_S_INSTRUCTION   = {7'b1100000, 3'b000, 7'b1010011};
    // localparam logic [16:0] FCVT_WU_S_INSTRUCTION  = {7'b1100000, 3'b001, 7'b1010011};
    // localparam logic [16:0] FADD_S_INSTRUCTION     = {7'b0000000, 3'b000, 7'b1010011};
    // localparam logic [16:0] FSUB_S_INSTRUCTION     = {7'b0000100, 3'b000, 7'b1010011};
    // localparam logic [16:0] FMUL_S_INSTRUCTION     = {7'b0001000, 3'b000, 7'b1010011};
    // localparam logic [16:0] FDIV_S_INSTRUCTION     = {7'b0001100, 3'b000, 7'b1010011};
    // localparam logic [16:0] FSQRT_S_INSTRUCTION    = {7'b0101100, 3'b000, 7'b1010011};
    // localparam logic [9:0] FLW_INSTRUCTION         = {3'b010, 7'b0000111};
    // localparam logic [9:0] FSW_INSTRUCTION         = {3'b010, 7'b0100111};



    
    
    always_comb begin
        control = '0;
        
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
        endcase
        
        
       control.alu_op = ALU_ADD;
      
      //control.alu_op = ALU_ADD;
     case (instruction.opcode)

            7'b0110011: begin // R-type
                 if ({instruction.funct7, instruction.funct3} == ADD_INSTRUCTION) begin
                  control.alu_op = ALU_ADD;
                    end 
                else if ({instruction.funct7, instruction.funct3} == SUB_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
                else if ({instruction.funct7, instruction.funct3} == SRL_INSTRUCTION) begin
                        control.alu_op = ALU_SRL;
                    end
               else if ({instruction.funct7, instruction.funct3} == SRA_INSTRUCTION) begin
                        control.alu_op = ALU_SRA;
                    end
              else if ({instruction.funct7, instruction.funct3} == XOR_INSTRUCTION) begin
                        control.alu_op = ALU_XOR;
                    end
              else if ({instruction.funct7, instruction.funct3} == OR_INSTRUCTION) begin
                        control.alu_op = ALU_OR;
                    end
              else if ({instruction.funct7, instruction.funct3} == AND_INSTRUCTION) begin
                        control.alu_op = ALU_AND;
                    end
               else if ({instruction.funct7, instruction.funct3} == SLT_INSTRUCTION) begin
                        control.alu_op = ALU_SLT;
                    end
              else if ({instruction.funct7, instruction.funct3} == SLTU_INSTRUCTION) begin
                        control.alu_op = ALU_SLT;
                    end
              
              
              
                else 
                  control.alu_op = ALU_ADD;
            end

            7'b0010011: begin // I-type ALU
                 if ({instruction.funct7, instruction.funct3} == ADDI_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
                 else if ({instruction.funct7, instruction.funct3} == SRAI_INSTRUCTION) begin
                        control.alu_op = ALU_SRA;
                    end 
                 else if ({instruction.funct3} == XORI_INSTRUCTION) begin
                        control.alu_op = ALU_XOR;
                    end
              	 else if ({instruction.funct3} == ANDI_INSTRUCTION) begin
                        control.alu_op = ALU_AND;
                    end
              	 else if ({instruction.funct3} == ORI_INSTRUCTION) begin
                        control.alu_op = ALU_OR;
                    end
                 else if ({instruction.funct3} == SLTI_INSTRUCTION) begin
                        control.alu_op = ALU_SLT;
                    end
                else if ({instruction.funct3} == SLTUI_INSTRUCTION) begin
                        control.alu_op = ALU_SLT;
                    end
              
                   
              
                else 
                  control.alu_op = ALU_ADD;
              
               end
            
            7'b0000011: begin
              if ({instruction.funct3, instruction.opcode} == LB_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
              else if ({instruction.funct3, instruction.opcode} == LBU_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
              else if ({instruction.funct3, instruction.opcode} == LHU_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
              else if ({instruction.funct3, instruction.opcode} == LH_INSTRUCTION) begin
                        control.alu_op = ALU_ADD;
                    end 
              
              
                   
              
                else 
                  control.alu_op = ALU_ADD;
            end

      endcase
      
      
      
      
      
    end
    
endmodule
