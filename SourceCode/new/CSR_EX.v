`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/04/20 17:15:42
// Design Name: 
// Module Name: CSR_EX
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

//CSR
module CSR_EX(
    input wire clk,
    input wire bubbleE,
    input wire flushE,
    input wire [31:0] csr_data_ID,
    input wire [11:0] csr_addr_ID,
    output reg [31:0] csr_data_EX,
    output reg [11:0] csr_addr_EX
    );

    initial csr_data_EX=32'b0;
    initial csr_addr_EX=12'b0;

    always@(posedge clk)
        if (!bubbleE) 
        begin
            if (flushE)
            begin
                csr_data_EX <= 0;
                csr_addr_EX <= 0;
            end
            else
            begin
                csr_data_EX <= csr_data_ID;
                csr_addr_EX <=csr_addr_ID;
            end
        end

endmodule
