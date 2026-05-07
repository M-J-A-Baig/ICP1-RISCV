`timescale 1ns / 1ps

module tb_cpu_uart_boot();

    
    localparam CLK_FREQ = 100_000_000;       // 100 MHz
    localparam BAUD_RATE = 115200;
    localparam BIT_PERIOD_NS = 1_000_000_000 / BAUD_RATE; //  8680 ns

    logic clk;
    logic reset_n;
    logic io_rx;
    

    cpu cpu_dut (
        .clk(clk),
        .reset_n(reset_n),
        .io_rx(io_rx)  
    );

    // 100MHz 
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task send_byte(input logic [7:0] tx_data);
        integer i;
        begin
            // Start Bit 
            io_rx = 0;
            #(BIT_PERIOD_NS);

            // Data Bits (LSB First)
            for (i = 0; i < 8; i++) begin
                io_rx = tx_data[i];
                #(BIT_PERIOD_NS);
            end

            // Stop Bit 
            io_rx = 1;
            #(BIT_PERIOD_NS);
        end
    endtask

    // RISC-V instruction
    task send_instruction(input logic [31:0] inst);
        begin
            $display("[%0t] Sending: 0x%08X", $time, inst);
            send_byte(inst[31:24]); // Byte 1 
            send_byte(inst[23:16]); // Byte 2
            send_byte(inst[15:8]);  // Byte 3
            send_byte(inst[7:0]);   // Byte 4 
        end
    endtask

    initial begin
        reset_n = 0;
        io_rx = 1; 

        #100;
        reset_n = 1;
        #100;

        $display("=========== Stage 1:UART ===========");

        // test all instructions
//        send_instruction(32'h00A00093); // 00. addi x1, x0, 10
//        send_instruction(32'hFFB00113); // 04: addi x2, x0, -5
//        send_instruction(32'h01400193); // 08: addi x3, x0, 20
//        send_instruction(32'h00308233); // 0C: add  x4, x1, x3
//        send_instruction(32'h401202B3); // 10: sub  x5, x4, x1
//        send_instruction(32'h00209313); // 14: slli x6, x1, 2
//        send_instruction(32'h00F1F393); // 18: andi x7, x3, 15
//        send_instruction(32'hFFF0C413); // 1C: xori x8, x1, -1
//        send_instruction(32'h00012493); // 20: slti x9, x2, 0
//        send_instruction(32'h00402023); // 24: sw   x4, 0(x0)
//        send_instruction(32'h00002503); // 28: lw   x10, 0(x0)
//        send_instruction(32'h001505B3); // 2C: add  x11, x10, x1
//        send_instruction(32'hBCD00613); // 30: addi x12, x0, 0xBCD  
//        send_instruction(32'h00C01223); // 34: sh   x12, 4(x0)
//        send_instruction(32'h00405683); // 38: lhu  x13, 4(x0)
//        send_instruction(32'h07F00713); // 3C: addi x14, x0, 0x7F
//        send_instruction(32'h00E00423); // 40: sb   x14, 8(x0)
//        send_instruction(32'h00800783); // 44: lb   x15, 8(x0)
//        send_instruction(32'h12345837); // 48: lui  x16, 0x12345
//        send_instruction(32'h00001897); // 4C: auipc x17, 1
//        send_instruction(32'h00108463); // 50: beq  x1, x1, test_bne  
//        send_instruction(32'hBAD00F93); // 54: addi x31, x0, 0xBAD    
//        send_instruction(32'h00209463); // 58: bne  x1, x2, test_blt  
//        send_instruction(32'hBAD00F93); // 5C: addi x31, x0, 0xBAD    
//        send_instruction(32'h00114463); // 60: blt  x2, x1, test_bgeu 
//        send_instruction(32'hBAD00F93); // 64: addi x31, x0, 0xBAD    
//        send_instruction(32'h00117463); // 68: bgeu x2, x1, test_jalr 
//        send_instruction(32'hBAD00F93); // 6C: addi x31, x0, 0xBAD    
//        send_instruction(32'h00000917); // 70: auipc x18, 0           
//        send_instruction(32'h01090913); // 74: addi  x18, x18, 16     
//        send_instruction(32'h00090067); // 78: jalr  x0, x18, 0
//        send_instruction(32'hBAD00F93); // 7C: addi  x31, x0, 0xBAD   
//        send_instruction(32'hDEADBF37); // 80: lui  x30, 0xDEADB
//        send_instruction(32'h00000063); // 84: beq  x0, x0, 0
        
        // test JAL & JALR
//        send_instruction(32'h008000EF); // 00: jal   x1, 8       
//        send_instruction(32'hBAD00F93); // 04: addi  x31, x0, 0xBAD <-- should be Flush
//        send_instruction(32'h11100113); // 08: addi  x2, x0, 0x111
//        send_instruction(32'h00000197); // 0C: auipc x3, 0       (x3 = 0x0C)
//        send_instruction(32'h01018193); // 10: addi  x3, x3, 16  (x3 = 0x1C)
//        send_instruction(32'h00018267); // 14: jalr  x4, x3, 0   
//        send_instruction(32'hBAD00F93); // 18: addi  x31, x0, 0xBAD <-- should be Flush
//        send_instruction(32'h22200293); // 1C: addi  x5, x0, 0x222
//        send_instruction(32'hDEADBF37); // 20: lui   x30, 0xDEADB
//        send_instruction(32'h00000063); // 84: beq  x0, x0, 0
        
//        //test load use hazard
//        send_instruction(32'h00A00093); // 00: addi x1, x0, 10      (x1 = 10)
//        send_instruction(32'h01400113); // 04: addi x2, x0, 20      (x2 = 20
//        send_instruction(32'h00202023); // 08: sw   x2, 0(x0)       (M[0] = 20)   
//        send_instruction(32'h00002503); // 0C: lw   x10, 0(x0)      (x10 = 20)
//        send_instruction(32'h001505B3); // 10: add  x11, x10, x1    need Stall！otherwise there is a hazard
//        send_instruction(32'h40258633); // 14: sub  x12, x11, x2    (x12 = x11 - 20)        
//        send_instruction(32'hDEADBF37); // 18: lui  x30, 0xDEADB    (end)
//        send_instruction(32'h00000063); // 1C: beq  x0, x0, 0       (end)
        
        //test the rest of instructions
        send_instruction(32'h0F000093); // 00: addi x1, x0, 240    (x1 = 0x000000F0)
        send_instruction(32'hFF000113); // 04: addi x2, x0, -16    (x2 = 0xFFFFFFF0)
        send_instruction(32'h00300193); // 08: addi x3, x0, 3      (x3 = 3)
        send_instruction(32'h00309233); // 0C: sll  x4, x1, x3     (x4 = 240 << 3 = 1920)
        send_instruction(32'h0030D2B3); // 10: srl  x5, x1, x3     (x5 = 240 >> 3 = 30)
        send_instruction(32'h00415313); // 14: srli x6, x2, 4      (x6 = 0xFFFFFFF0 >> 4bits = 0x0FFFFFFF)
        send_instruction(32'h403153B3); // 18: sra  x7, x2, x3     (x7 = -16 >> 3bits = -2)
        send_instruction(32'h40215413); // 1C: srai x8, x2, 2      (x8 = -16 >> 2bits = -4)
        send_instruction(32'h0020C4B3); // 20: xor  x9, x1, x2     (x9 = 0x000000F0 ^ 0xFFFFFFF0 = 0xFFFFFF00)
        send_instruction(32'h0020E533); // 24: or   x10, x1, x2    (x10= 0x000000F0 | 0xFFFFFFF0 = 0xFFFFFFF0)
        send_instruction(32'h00F0E593); // 28: ori  x11, x1, 15    (x11= 240 | 15 = 255)
        send_instruction(32'h0020F633); // 2C: and  x12, x1, x2    (x12= 0x000000F0 & 0xFFFFFFF0 = 0x000000F0)
        send_instruction(32'h001126B3); // 30: slt  x13, x2, x1    (x13= -16 < 240  ? 1 : 0) -> 1
        send_instruction(32'h00113733); // 34: sltu x14, x2, x1    (x14= -16 < 240  ? 1 : 0) -> 0 
        send_instruction(32'h0FF13793); // 38: sltiu x15, x2, 255  (x15= -16 < 255  ? 1 : 0) -> 0
        send_instruction(32'h12345837); // 3C: lui  x16, 0x12345   (x16= 0x12345000)
        send_instruction(32'h67880813); // 40: addi x16, x16, 0x678(x16= 0x12345678)
        send_instruction(32'h01001823); // 44: sh   x16, 16(x0)    ( 0x5678 -> M[ 16 ])
        send_instruction(32'h01000923); // 48: sb   x16, 18(x0)    (0x78 -> M[ 18 ])
        send_instruction(32'h01001883); // 4C: lh   x17, 16(x0)    (M[ 16 ] ->sign extend，x17 = 0x00005678)
        send_instruction(32'h01204903); // 50: lbu  x18, 18(x0)    (M[ 18 ] ->unsign extend，x18 = 0x00000078)
        send_instruction(32'h0020D463); // 54: bge  x1, x2, test_bltu (240 >= -16 jump)
        send_instruction(32'hBAD00F93); // 58: addi x31, x0, 0xBAD    (Flush )
        send_instruction(32'h0020E463); // 5C: bltu x1, x2, end_test  (240 < -16 jump)
        send_instruction(32'hBAD00F93); // 60: addi x31, x0, 0xBAD    (Flush)
        send_instruction(32'hDEADBF37); // 64: lui  x30, 0xDEADB      (end)
        send_instruction(32'h00000063); // 68: beq  x0, x0, 0         end
       
        
        
        $display("[%0t] instructions sent. waiting Timeout / Finish signal...", $time);

        
        wait(cpu_dut.uart_data.finish == 1'b1);
        $display("[%0t] TIMEOUT ! (Finish = 1)", $time);

        $display("=========== Stage 2:CPU begin executing ===========");
        
        
        #(1000 * 10); 

        $display("--- END! waveform check time ---");
        $finish; 
    end

    
    initial begin
        forever begin
            @(posedge clk);
            if (cpu_dut.uart_data.io_data_valid) begin
                $display(">>> [write in memory] address: %0d | machine code: 0x%08X", 
                          cpu_dut.uart_data.program_mem_write_address, 
                          cpu_dut.uart_data.data);
            end
        end
    end

endmodule