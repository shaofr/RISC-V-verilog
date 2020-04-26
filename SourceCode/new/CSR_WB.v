`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 17:43:59
// Design Name: 
// Module Name: CSR_WB
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


module CSR_WB(
    input wire clk,
    input wire bubbleW,
    input wire flushW,
    input wire [31:0] csr_data_MEM,
    input wire [11:0] csr_addr_MEM,
    output reg [11:0] csr_addr_WB,
    output reg [31:0] csr_data_WB
    );

    initial csr_data_WB=32'b0;
    initial csr_addr_WB=12'b0;

    always@(posedge clk)
        if (!bubbleW) 
        begin
            if (flushW)
            begin
                csr_data_WB <= 0;
                csr_addr_WB <= 0;
            end
            else
            begin
                csr_data_WB <= csr_data_MEM;
                csr_addr_WB <=csr_addr_MEM;
            end
        end


endmodule
