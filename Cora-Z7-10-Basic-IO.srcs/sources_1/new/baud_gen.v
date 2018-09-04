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
    reg[12:0] counter = 0;
    localparam[31:0] baud_time = 125000000/115200;
     reg tick = 0;
   // reg[BAUD_ACC_W:0] baud_accumulator;
    
    always@(posedge clk)
        
        
        if(counter == baud_time) begin
         tick <= 1;
         counter <= 0;
         end
        else begin 
            tick <= 0;
            counter <= counter + 1;
        end
    assign baud_clk = tick; //baud_accumulator[BAUD_ACC_W]; 
    
endmodule
