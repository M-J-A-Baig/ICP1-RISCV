`timescale 1ns / 1ps

import common::*;

module fetch_stage(
    input clk,
    input reset_n,
  	input control_type control_in,
    input logic [31:0] offset_data,
    output logic [31:0] address,
    input [31:0] data
   //input instruction_type data
);

    logic [31:0] pc_next, pc_reg;
    logic [1:0] synchronzer_ctr; // 2 bit synchronizer
    
    
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            pc_reg <= 0;
        end
        else begin
            pc_reg <=  pc_next;
        end 
    end
        
  
  assign synchronzer_ctr = (control_in.is_branch == 1'b1 && control_in.jump_id == 1'b1) ?  (synchronzer_ctr + 1'b1) : 
                           (control_in.is_branch == 1'b1 && control_in.jump_id == 1'b0) ?  (synchronzer_ctr - 1'b1) :
    																						synchronzer_ctr;
        
    always_comb begin
      pc_next = (control_in.jump_id == 1'b1) ? (pc_reg + offset_data) : (pc_reg + 4);      
    end
    
    
    assign address = pc_reg;
    
endmodule
