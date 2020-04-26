`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 16:01:14
// Design Name: 
// Module Name: ControlAndStatusRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//csr
module ControlAndStatusRegister(
    input wire clk,
    input wire rst,
    input wire csr_write_en,
    input wire [11:0] csr_addr,
    input wire [11:0] csr_wb_addr,
    input wire [31:0] csr_wb_data,
    output wire [31:0] csr_data
    );

    reg [31:0] csr_reg_file[4095:0];
    integer i;
    
    initial
    begin
        for(i = 0; i < 4096; i = i + 1) 
            csr_reg_file[i][31:0] <= i;
    end

    always@(negedge clk or posedge rst) 
    begin 
        if (rst)
            for(i = 0; i < 4096; i = i + 1) 
                csr_reg_file[i][31:0] <= 32'b0;
        else if(csr_write_en)
            csr_reg_file[csr_wb_addr] <= csr_wb_data;   
    end

    // read data changes when address changes
    assign csr_data = csr_reg_file[csr_addr];

endmodule
