package common;

    typedef enum logic [2:0] 
    {
        ALU_AND = 3'b000,
        ALU_OR = 3'b001,
        ALU_ADD = 3'b010,
        ALU_SUB = 3'b011

        // // Basic ALU ops
        // ALU_AND       = 6'b000000,
        // ALU_OR        = 6'b000001,
        // ALU_ADD       = 6'b000010,
        // ALU_SUB       = 6'b000011,

        // // Green commands - grade 4
        // ALU_SLL       = 6'b000100,
        // ALU_SLLI      = 6'b000101,
        // ALU_SRL       = 6'b000110,
        // ALU_SRLI      = 6'b000111,
        // ALU_SRA       = 6'b001000,
        // ALU_SRAI      = 6'b001001,
        // ALU_LUI       = 6'b001010,
        // ALU_AUPIC     = 6'b001011,
        // ALU_XOR       = 6'b001100,
        // ALU_XORI      = 6'b001101,
        // ALU_OR        = 6'b001110,
        // ALU_ORI       = 6'b001111,
        // ALU_AND       = 6'b010000,
        // ALU_ANDI      = 6'b010001,
        // ALU_SLT       = 6'b010010,
        // ALU_SLTI      = 6'b010011,
        // ALU_SLTU      = 6'b010100,
        // ALU_SLTIU     = 6'b010101,
        // ALU_BNE       = 6'b010110,
        // ALU_BLT       = 6'b010111,
        // ALU_BGE       = 6'b011000,
        // ALU_BLTU      = 6'b011001,
        // ALU_BGEU      = 6'b011010,
        // ALU_JAL       = 6'b011011,
        // ALU_JALR      = 6'b011100,
        // ALU_LB        = 6'b011101,
        // ALU_LH        = 6'b011110,
        // ALU_LBU       = 6'b011111,
        // ALU_LHU       = 6'b100000,
        // ALU_SB        = 6'b100001,
        // ALU_SH        = 6'b100010,

        // // Orange commands - grade 4
        // ALU_MUL       = 6'b100011,
        // ALU_MULH      = 6'b100100,
        // ALU_MULHU     = 6'b100101,  // <-- newly added
        // ALU_MULHSU    = 6'b100110,
        // ALU_DIV       = 6'b100111,
        // ALU_DIVU      = 6'b101000,
        // ALU_REM       = 6'b101001,
        // ALU_REMU      = 6'b101010,

        // // Red commands - grade 5
        // ALU_FCVT_S_W  = 6'b101011,
        // ALU_FCVT_S_WU = 6'b101100,
        // ALU_FCVT_W_S  = 6'b101101,
        // ALU_FCVT_WU_S = 6'b101110,
        // ALU_FLW       = 6'b101111,
        // ALU_FSW       = 6'b110000,
        // ALU_FADD_S    = 6'b110001,
        // ALU_FSUB_S    = 6'b110010,
        // ALU_FMUL_S    = 6'b110011,
        // ALU_FDIV_S    = 6'b110100
            
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
        logic [5:0] reg_rd_id;
        logic [31:0] data1;
        logic [31:0] data2;
        logic [31:0] immediate_data;
        control_type control;
    } id_ex_type;
    

    typedef struct packed
    {
        logic [5:0] reg_rd_id;
        control_type control;
        logic [31:0] alu_data;
        logic [31:0] memory_data;
    } ex_mem_type;
    
    
    typedef struct packed
    {
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
            default: immediate_extension = { {20{instruction.funct7[6]}}, {instruction.funct7, instruction.rs2} };
        endcase 
    endfunction


endpackage
