`timescale 1ns / 1ps


module data_memory (
    input clk,
    input [9:0] byte_address,
    input [3:0] write_byte_enable,         
    input [31:0] write_data, 
    output logic [31:0] read_data
);

    logic [31:0] ram [256];
    logic [7:0] word_address;
    
    
    assign word_address = byte_address[9:2];
    
    
    always @(posedge clk) begin
    
            if (write_byte_enable[0]) ram[word_address][7:0]   <= write_data[7:0];
            if (write_byte_enable[1]) ram[word_address][15:8]  <= write_data[15:8];
            if (write_byte_enable[2]) ram[word_address][23:16] <= write_data[23:16];
            if (write_byte_enable[3]) ram[word_address][31:24] <= write_data[31:24];
        
    end

    
    assign read_data = ram[word_address];
    
endmodule