package common;

    typedef enum logic [3:0] 
    {
        ALU_AND = 4'b0000,
        ALU_OR = 4'b0001,
        ALU_ADD = 4'b0010,
        ALU_SUB = 4'b0011,
        ALU_SLL = 4'b0100, //4
        ALU_SRL = 4'b0101, //5
        ALU_LUI = 4'b0111, //7
        ALU_XOR = 4'b1001, //9
        //ALU_AND = 4'b1011, //11
        ALU_SLT = 4'b1010 //10
    } alu_op_type;
    
    
    typedef enum logic [2:0]
    {
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } encoding_type;
    
    
    typedef struct packed
    {
        alu_op_type alu_op;
        encoding_type encoding;
        logic alu_src;
        logic mem_read;
        logic mem_write;
        logic reg_write;
        logic mem_to_reg;
        logic is_branch;
        logic is_jump;
        logic [2:0] branch_type;
        logic [1:0] mem_type;     //00: Byte, 01: Halfword, 10: Word
        logic extend_type;     //0:Unsigned
    } control_type;
    
    
    typedef struct packed
    {
        logic [6:0] funct7;
        logic [4:0] rs2;
        logic [4:0] rs1;
        logic [2:0] funct3;
        logic [4:0] rd;
        logic [6:0] opcode;
    } instruction_type;
    
        
    typedef struct  packed
    {
        logic [31:0] pc;
        instruction_type instruction;
    } if_id_type;
    
    
    typedef struct packed
    {
        logic [31:0] pc;
        logic [5:0] reg_rd_id;
        logic [31:0] data1;
        logic [31:0] data2;
        logic [31:0] immediate_data;
        control_type control;
    } id_ex_type;
    

    typedef struct packed
    {
        logic [31:0] pc;
        logic [5:0] reg_rd_id;
        control_type control;
        logic [31:0] alu_data;
        logic [31:0] memory_data;
    } ex_mem_type;
    
    
    typedef struct packed
    {
        logic [31:0] pc;
        logic [5:0] reg_rd_id;
        logic [31:0] memory_data;
        logic [31:0] alu_data;
        control_type control;
    } mem_wb_type;


    function [31:0] immediate_extension(instruction_type instruction, encoding_type inst_encoding);
        case (inst_encoding)
            I_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
            S_TYPE: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rd} };
            B_TYPE: immediate_extension = 
                { {20{instruction.funct7[6]}}, {instruction.funct7[6], instruction.rd[0], instruction.funct7[5:0], instruction.rd[4:1]} };
            U_TYPE: immediate_extension = {instruction.funct7, instruction.rs2, instruction.rs1, instruction.funct3, 12'b0};
            default: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
        endcase 
    endfunction
    
endpackage
