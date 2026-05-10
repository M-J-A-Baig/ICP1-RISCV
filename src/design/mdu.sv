`timescale 1ns / 1ps

module mdu(
    input  logic        clk,
    input  logic        reset_n,
    input  logic        start,
    input  logic [2:0]  op,        // 000:MUL, 001:MULH, 010:MULHSU, 011:MULHU, 100:DIV, 101:DIVU, 110:REM, 111:REMU
    input  logic [31:0] operand_a,
    input  logic [31:0] operand_b,
    output logic [31:0] result,
    output logic        ready
);

    // ==========================================
    // 状态定义
    // ==========================================
    typedef enum logic [1:0] {IDLE, MULT_DELAY, DIV_CALC, DONE} state_t;
    
    // ==========================================
    // 寄存器与 next 信号声明 (分离的核心)
    // ==========================================
    // 状态寄存器
    state_t state, state_next;
    
    // 控制与计数寄存器
    logic [5:0] count, count_next;
    
    // 除法数据通路寄存器
    logic [31:0] divisor, divisor_next;
    logic [31:0] remainder, remainder_next;
    logic [31:0] quotient, quotient_next;
    
    // 除法异常与符号记录寄存器
    logic [31:0] orig_a, orig_a_next;
    logic div_sign_q, div_sign_q_next;
    logic div_sign_r, div_sign_r_next;
    logic div_by_zero, div_by_zero_next;
    logic div_overflow, div_overflow_next;
    
    logic [31:0] reg_a, reg_a_next;
    logic [31:0] reg_b, reg_b_next;
    // ==========================================
    // 纯组合逻辑模块 (独立的计算网络)
    // ==========================================
    
    // 1. 乘法计算 (DSP硬核前瞻)
    logic [63:0] mult_full_result;
    always_comb begin
        case (op)
            3'b000, 3'b001: mult_full_result = $signed(reg_a) * $signed(reg_b);
            3'b010:         mult_full_result = $signed(reg_a) * $signed({1'b0, reg_b});
            3'b011:         mult_full_result = $unsigned(reg_a) * $unsigned(reg_b);
            default:        mult_full_result = 64'b0;
        endcase
    end

    // 2. 除法移位与减法计算网络
    logic is_signed_div;
    logic [31:0] next_R;
    logic [31:0] sub_res;
    
    assign is_signed_div = (op == 3'b100) || (op == 3'b110);
    assign next_R = {remainder[30:0], quotient[31]}; 
    assign sub_res = next_R - divisor;

    // 3. 除法结果修正网络
    logic [31:0] final_q, final_r;
    always_comb begin
        if (div_by_zero) begin
            final_q = 32'hFFFFFFFF; 
            final_r = orig_a;
        end else if (div_overflow) begin
            final_q = 32'h80000000;
            final_r = 32'd0;
        end else begin
            final_q = div_sign_q ? (~quotient + 1) : quotient;
            final_r = div_sign_r ? (~remainder + 1) : remainder;
        end
    end

    // ==========================================
    // 核心状态机：纯组合逻辑 (计算 next 状态与数据)
    // ==========================================
    always_comb begin
        // 【关键】赋予默认值，防止产生 Latch，且保持当前状态
        state_next        = state;
        count_next        = count;
        divisor_next      = divisor;
        remainder_next    = remainder;
        quotient_next     = quotient;
        orig_a_next       = orig_a;
        div_sign_q_next   = div_sign_q;
        div_sign_r_next   = div_sign_r;
        div_by_zero_next  = div_by_zero;
        div_overflow_next = div_overflow;
        result = 32'b0;
        ready = 0;
        reg_a_next = reg_a;
        reg_b_next = reg_b;

        case (state)
            IDLE: begin
                if (start) begin
                    reg_a_next = operand_a;
                    reg_b_next = operand_b;
                    if (op[2] == 1'b0) begin 
                        // --- 启动乘法 ---
                        state_next = MULT_DELAY;
                        count_next = 6'd4;
                    end else begin
                        // --- 启动除法 ---
                        state_next = DIV_CALC;
                        count_next = 6'd31;
                        
                        orig_a_next       = operand_a;
                        div_by_zero_next  = (operand_b == 0);
                        div_overflow_next = is_signed_div && (operand_a == 32'h80000000) && (operand_b == 32'hFFFFFFFF);
                        div_sign_q_next   = is_signed_div && (operand_a[31] ^ operand_b[31]);
                        div_sign_r_next   = is_signed_div && operand_a[31];
                        
                        // 初始化除法数据 (修复了商未初始化的Bug)
                        divisor_next      = (is_signed_div && operand_b[31]) ? (~operand_b + 1) : operand_b;
                        quotient_next     = (is_signed_div && operand_a[31]) ? (~operand_a + 1) : operand_a; // 被除数放入商寄存器参与移位
                        remainder_next    = 32'd0;
                    end
                end
            end
            
            MULT_DELAY: begin
                if (count == 0) state_next = DONE;
                else            count_next = count - 1;
            end
            
            DIV_CALC: begin
                // 执行硬件移位与减法
                if (next_R >= divisor) begin
                    remainder_next = sub_res;
                    quotient_next  = {quotient[30:0], 1'b1};
                end else begin
                    remainder_next = next_R;
                    quotient_next  = {quotient[30:0], 1'b0};
                end
                
                if (count == 0) state_next = DONE;
                else            count_next = count - 1;
            end
            
            DONE: begin
                ready = 1'b1;
                state_next = IDLE;
                
                // 锁存最终计算结果
                if (op[2] == 1'b0) begin
                    case (op)
                        3'b000: result = mult_full_result[31:0];
                        3'b001, 3'b010, 3'b011: result = mult_full_result[63:32];
                        default: result = 32'b0;
                    endcase
                end else begin
                    if (op[1] == 1'b0) result = final_q;
                    else               result = final_r;
                end
            end
        endcase
    end

    // ==========================================
    // 核心状态机：纯时序逻辑 (只做寄存器赋值)
    // ==========================================
    always_ff @(posedge clk) begin
        if (!reset_n) begin
            state        <= IDLE;
            count        <= 0;
            divisor      <= 0;
            remainder    <= 0;
            quotient     <= 0;
            orig_a       <= 0;
            div_sign_q   <= 0;
            div_sign_r   <= 0;
            div_by_zero  <= 0;
            div_overflow <= 0;
            reg_a        <= 0;
            reg_b        <= 0;
        end else begin
            state        <= state_next;
            count        <= count_next;
            divisor      <= divisor_next;
            remainder    <= remainder_next;
            quotient     <= quotient_next;
            orig_a       <= orig_a_next;
            div_sign_q   <= div_sign_q_next;
            div_sign_r   <= div_sign_r_next;
            div_by_zero  <= div_by_zero_next;
            div_overflow <= div_overflow_next;
            reg_a        <= reg_a_next;
            reg_b        <= reg_b_next;
        end
    end

endmodule