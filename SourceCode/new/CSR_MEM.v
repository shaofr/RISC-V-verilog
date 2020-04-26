`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 17:27:10
// Design Name: 
// Module Name: CSR_MEM
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


module CSR_MEM(
    input wire clk,
    input wire bubbleM,
    input wire flushM,
    input wire [31:0] csr_data_EX,
    input wire [11:0] csr_addr_EX,
    output reg [31:0] csr_data_MEM,
    output reg [11:0] csr_addr_MEM
    );

    initial csr_data_MEM=32'b0;
    initial csr_addr_MEM=12'b0;

    always@(posedge clk)
        if (!bubbleM) 
        begin
            if (flushM)
            begin
                csr_data_MEM <= 0;
                csr_addr_MEM <= 0;
            end
            else
            begin
                csr_data_MEM <= csr_data_EX;
                csr_addr_MEM <=csr_addr_EX;
            end
        end


endmodule
