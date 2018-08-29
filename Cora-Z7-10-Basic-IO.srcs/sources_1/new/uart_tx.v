`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Richard
// 
// Create Date: 08/28/2018 09:50:30 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input wire      clk,
    input wire      baud_clk,
    input wire      tx_start,
    input wire[7:0] tx_data,
    output wire     data_out
    );
    
    reg [3:0] state;
    
    // the state machine starts when "tx_start" is asserted, but advances when "baud_clk" is asserted (115200 times a second)
    always @(posedge clk)
    case(state)
      4'b0000: if(tx_start) state <= 4'b0100;
      4'b0100: if(baud_clk) state <= 4'b1000; // start
      4'b1000: if(baud_clk) state <= 4'b1001; // bit 0
      4'b1001: if(baud_clk) state <= 4'b1010; // bit 1
      4'b1010: if(baud_clk) state <= 4'b1011; // bit 2
      4'b1011: if(baud_clk) state <= 4'b1100; // bit 3
      4'b1100: if(baud_clk) state <= 4'b1101; // bit 4
      4'b1101: if(baud_clk) state <= 4'b1110; // bit 5
      4'b1110: if(baud_clk) state <= 4'b1111; // bit 6
      4'b1111: if(baud_clk) state <= 4'b0001; // bit 7
      4'b0001: if(baud_clk) state <= 4'b0010; // stop1
      4'b0010: if(baud_clk) state <= 4'b0000; // stop2
      default: if(baud_clk) state <= 4'b0000;
    endcase
    
    reg muxbit; 
    
    always @(state[2:0])
    case(state[2:0])
      0: muxbit <= tx_data[0];
      1: muxbit <= tx_data[1];
      2: muxbit <= tx_data[2];
      3: muxbit <= tx_data[3];
      4: muxbit <= tx_data[4];
      5: muxbit <= tx_data[5];
      6: muxbit <= tx_data[6];
      7: muxbit <= tx_data[7];
    endcase
    
    // combine start, data, and stop bits together
    assign data_out = (state<4) | (state[3] & muxbit); 
endmodule
