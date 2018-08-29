`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent
// Engineer: Arthur Brown
// 
// Create Date: 04/13/2018 03:33:26 PM
// Design Name: Cora Z7-10 Basic I/O Demo
// Module Name: top
// Target Devices: Cora Z7-10
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top (
    // 125MHz System Clock
    input wire clk,
    // RGB LED (Active Low)
    output wire led0_r,
    output wire led0_g,
    output wire led0_b,
    output wire led1_r,
    output wire led1_g,
    output wire led1_b,
    
    // UART pins
    output wire uart_tx_pin,
    
    // 2 Buttons
    input wire [1:0] btn
);
    localparam CD_COUNT_MAX = 125000000/2;
    wire brightness;
    reg [$clog2(CD_COUNT_MAX-1)-1:0] cd_count = 'b0;
    reg [3:0] led_shift = 4'b0001;
    wire [1:0] db_btn;
    reg [7:0] duty_ticker = 8'b0;
    reg [1:0] blinky = 0;
    
    // Signals for UART
    wire        baud_clk;
    reg         tx_start = 0;
    wire[7:0]   tx_data = 8'd82;
    
    
    // PWM generator instance
    pwm #(
        .COUNTER_WIDTH(8),
        .MAX_COUNT(255)
    ) m_pwm (
        .clk(clk),
        .duty(duty_ticker),
        .pwm_out(brightness)
    );
    
    // Baud rate generator instance
    baud_gen #(
        .CLK_HZ(125000000),
        .BAUD(115200),
        .BAUD_ACC_W(16)
    ) m_baud_gen(
        .clk(clk),
        .baud_clk(baud_clk)
    );
    
    // Transmitter instance
    uart_tx m_tx(
        .clk(clk),
        .baud_clk(baud_clk),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .data_out(uart_tx_pin)
    );
    
    always@(posedge clk)
        if (cd_count >= CD_COUNT_MAX-1) begin // 2Hz
            cd_count <= 'b0;
           // led_shift <= {led_shift[2:0], led_shift[3]}; // cycle the LEDs and the color of the RGB LED. blue-green-red-black
            
            // Fade in-out by varying the duty cycle
            if(duty_ticker <= 200) begin
                duty_ticker <= duty_ticker + 8'd8;
            end else
                duty_ticker <= 8'd0;
            
            // Simple heartbeat blinky
            blinky <= ~blinky;
            
            // Trigger a uart transfer
            tx_start <= 1;
        end else begin
            cd_count <= cd_count + 1'b1;
            
            // Uart transfer deassert
            tx_start <= 0;
        end
    
    assign led0_r = blinky & ~db_btn[0];
    assign {led1_r, led1_g, led1_b} = led_shift[2:0] & {3{brightness & ~db_btn[1]}};
    
    debouncer #(
        .WIDTH(2),
        .CLOCKS(1024),
        .CLOCKS_CLOG2(10)
    ) m_db_btn (
        .clk(clk),
        .din(btn),
        .dout(db_btn)
    );
endmodule
