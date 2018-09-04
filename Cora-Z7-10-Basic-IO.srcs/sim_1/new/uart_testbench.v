`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// UART Testbench
// Richard Arthurs
//////////////////////////////////////////////////////////////////////////////////


module uart_testbench();
 reg clk;
 reg tx_start;
 reg [7:0] tx_data;
 wire uart_tx_pin;
 wire ready;
 wire baud_out;
 
 // UART DUT
 uart_tx m_tx(
 .clk(clk),
 .tx_start(tx_start),
 .tx_data(tx_data),
 .data_out(uart_tx_pin),
 .ready(ready),
 .baud_out(baud_out)
 );
 
 // 125 MHZ Clock generator 
 always begin
        // 125 MHz clock -> period = 8 ns
        clk <= 1'b1;
        #4;
        clk <= 1'b0;
        #4;
    end
    
/* Test
    - Send out R, \0, R
*/

  initial begin
    tx_data <= 8'd0;
    #5;
    
    // Send R
    tx_data <= 8'd82; // 'R' 
    while(ready == 1'b0) begin
        @(posedge clk);
    end
    
    tx_start <= 1'b1;
    @(posedge clk);
    tx_start <= 1'b0;
    
    #87000; // 1/115200 = 8.68 us * 9 bits out + 1bit spacing ~= 87000 ns
    
    // Send \0
    tx_data <= 8'd0;
    
        while(ready == 1'b0) begin
        @(posedge clk);
    end
    
    tx_start <= 1'b1;
    @(posedge clk);
    tx_start <= 1'b0;
    
     #87000;
     
     // Send R again
    tx_data <= 8'd82;
       
    while(ready == 1'b0) begin
        @(posedge clk);
    end
       
    tx_start <= 1'b1;
    @(posedge clk);
    tx_start <= 1'b0;
    
    #87000;
  end
    
    
endmodule
