`timescale 1ns / 1ps

module tb_cpu_grade4();

    localparam CLK_FREQ = 100_000_000;       // 100 MHz
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE; //  8680 ns

    logic clk;
    logic reset_n;
    logic io_rx;
    
    // 例化顶层 CPU
    cpu cpu_dut (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx)  
    );

    // 100MHz 时钟生成
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // UART 发送字节 Task
    task send_byte(input logic [7:0] tx_data);
        integer i;
        begin
            io_rx = 0; // Start Bit 
            #(BIT_PERIOD_NS);
            for (i = 0; i < 8; i++) begin // Data Bits
                io_rx = tx_data[i];
                #(BIT_PERIOD_NS);
            end
            io_rx = 1; // Stop Bit 
            #(BIT_PERIOD_NS);
        end
    endtask

    // 发送 32位 指令 Task
    task send_instruction(input logic [31:0] inst);
        begin
            send_byte(inst[31:24]); // Byte 1 
            send_byte(inst[23:16]); // Byte 2
            send_byte(inst[15:8]);  // Byte 3
            send_byte(inst[7:0]);   // Byte 4 
        end
    endtask

    // ========================================================
    // 核心监控器 (Monitor)：抓取每个时钟周期的寄存器与内存变化
    // ========================================================
    always @(negedge clk) begin
        // 只有当 CPU 启动（UART加载完毕）后才开始监控
        if (cpu_dut.cpu_reset_n == 1'b1) begin
            
            // 1. 监控寄存器写入 (探针连接到 WB 阶段)
            if (cpu_dut.wb_write_back_en && (cpu_dut.wb_reg_rd_id != 5'd0)) begin
                $display("[%0t ns] [REG WRITE] x%0d = 0x%08X (PC: 0x%08X)", 
                         $time, 
                         cpu_dut.wb_reg_rd_id, 
                         cpu_dut.wb_result,
                         cpu_dut.mem_wb_reg.pc); // 追溯是哪条指令写的
            end

            // 2. 监控内存写入 (探针连接到 EX/MEM 寄存器)
            if (cpu_dut.ex_mem_reg.control.mem_write) begin
                $display("[%0t ns] [MEM WRITE] Address = 0x%08X, Data = 0x%08X (PC: 0x%08X)", 
                         $time, 
                         cpu_dut.ex_mem_reg.alu_data, 
                         cpu_dut.ex_mem_reg.memory_data,
                         cpu_dut.ex_mem_reg.pc);
            end
        end
    end

    // 主测试流程：全指令大满贯 + 极端边界 Torture Test
    // ========================================================
// ========================================================
    // 主测试流程：全方位极端时序控制冲突测试
    // ========================================================
    initial begin
        reset_n = 0; io_rx = 1; #100; reset_n = 1; #100;
        $display("=========== Stage 1: UART Loading Torture Test ===========");

        // 将这些指令按顺序写入你的指令存储器 (从地址 0x00 开始)

        // --- 阶段 1: 基础寄存器赋值 ---
        send_instruction(32'h00A00093); // 0x00: ADDI x1, x0, 10    (x1 = 10)
        send_instruction(32'h00500113); // 0x04: ADDI x2, x0, 5     (x2 = 5)
        
        // --- 阶段 2: M 扩展乘除法与数据前推 (Forwarding) ---
        send_instruction(32'h022081B3); // 0x08: MUL  x3, x1, x2    (x3 = 10 * 5 = 50。测试 is_mdu)
        send_instruction(32'h0221C233); // 0x0C: DIV  x4, x3, x2    (x4 = 50 / 5 = 10。测试 MDU 结果直接前推给下一个 MDU)
        
        // --- 阶段 3: 内存读写与经典的 Load-Use 冒险 (Load-Use Hazard) ---
        send_instruction(32'h0040A023); // 0x10: SW   x4, 0(x1)     (将 10 存入地址 10)
        send_instruction(32'h0000A283); // 0x14: LW   x5, 0(x1)     (从地址 10 读回数据，x5 = 10)
        send_instruction(32'h00128333); // 0x18: ADD  x6, x5, x1    (x6 = 10 + 10 = 20) 
        // ⚠️ 极限测试点 1：上一条刚 LW 写入 x5，下一条立刻 ADD 读取 x5！
        // 你的硬件必须在这里产生 1 个周期的 Stall (流水线气泡)，然后从 MEM 阶段前推数据到 EX 阶段！
        
        // --- 阶段 4: 分支冲刷连招 (Branch Flush Hazards) ---
        send_instruction(32'h00128463); // 0x1C: BEQ  x5, x1, +8    (10 == 10，条件成立，跳转到 0x24)
        send_instruction(32'h06300313); // 0x20: ADDI x6, x0, 99    (⚠️ 绝对不能执行！气泡必须冲刷掉它)
        send_instruction(32'h00229463); // 0x24: BNE  x5, x2, +8    (10 != 5，条件成立，跳转到 0x2C)
        send_instruction(32'h05800313); // 0x28: ADDI x6, x0, 88    (⚠️ 绝对不能执行！再次冲刷)
        
        // --- 阶段 5: JAL 与 JALR 背靠背地址依赖极限测试 ---
        send_instruction(32'h004003EF); // 0x2C: JAL  x7, +4        (跳到 0x30，并记录返回地址 x7 = 0x2C + 4 = 0x30)
        send_instruction(32'h00838467); // 0x30: JALR x8, x7, +8    (跳到 x7 + 8 = 0x38，记录 x8 = 0x30 + 4 = 0x34)
        // ⚠️ 极限测试点 2：JAL 刚算出 x7，下一条紧跟着的 JALR 就要拿 x7 当基地址算跳转位置！
        // 你的前推单元必须能把 JAL 算出的 PC+4 直接无缝塞给 JALR 的 ALU/取指模块。
        
        send_instruction(32'h04200313); // 0x34: ADDI x6, x0, 66    (⚠️ 绝对不能执行！被 JALR 跳过了)
        send_instruction(32'h00838333); // 0x38: ADD  x6, x7, x8    (x6 = 0x30 + 0x34 = 48 + 52 = 100)
        send_instruction(32'h0000006F); // 0x3C: JAL  x0, 0         (无穷死循环，停机坪)

        $display("[%0t ns] Instructions sent. Waiting for execution...", $time);
        wait(cpu_dut.uart_data.finish == 1'b1);
        $display("=========== Stage 2: CPU Begin Executing ===========");
        
        #(1000 * 50); 
        $display("=========== Stage 3: Execution Finished ===========");
        $finish; 
    end

endmodule