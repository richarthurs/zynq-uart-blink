`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richard Arthurs
// 
// Create Date: 08/28/2018 09:50:30 PM
// Design Name: 
// Module Name: baud_gen
// Project Name: fpga-uart
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


module baud_gen#(
    parameter CLK_HZ = 125000000,
    parameter BAUD = 115200,
    parameter BAUD_ACC_W = 16,  // baud rate accumulator width
    parameter BAUD_GEN_INC = ((BAUD<<(BAUD_ACC_W-4))+(CLK_HZ>>5))/(CLK_HZ>>4)   // baud rate incrementer
)(
    input wire clk,
    output wire baud_clk
    );
    
    reg[BAUD_ACC_W:0] baud_accumulator;
    
    always@(posedge clk)
      baud_accumulator <= baud_accumulator[BAUD_ACC_W-1:0] + BAUD_GEN_INC;
  
    assign baud_clk = baud_accumulator[BAUD_ACC_W]; 
    
endmodule
