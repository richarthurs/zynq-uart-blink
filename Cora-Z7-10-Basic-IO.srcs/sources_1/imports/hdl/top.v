`timescale 1ns / 1ps
`default_nettype none
// Richard Arthurs
// FPGA demo

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
    input wire  uart_rx_pin,
    
    // 2 Buttons
    input wire [1:0] btn
);

    localparam  CD_COUNT_MAX = 125000000/2;
    wire        brightness;
    reg [$clog2(CD_COUNT_MAX-1)-1:0] cd_count = 'b0;
    reg [3:0]   led_shift   = 4'b0001;
    wire [1:0]  db_btn;
    reg [7:0]   duty_ticker = 8'b0;
    reg [2:0]   blinky      = 3'b0;
    
    // Signals for UART TX
    reg         tx_start    = 0;
    wire[7:0]   tx_data;
    wire        ready;
    
    
    // Signals for UART RX
    wire[7:0]   rx_data;
    wire        rx_data_ready;
    
    // Signals for UART test
    localparam READY = 2'b00, WAITING = 2'b01, COPYING = 2'b10;
    reg[2:0]    uart_test_state = READY;    
    reg[7:0]    uart_rx_buf;                // flop to store the data
    
    // Signals for UART controlled blinky
    localparam RED = 3'b100, GREEN = 3'b010, BLUE = 3'b001, PURPLE = 3'b101, YELLOW = 3'b110, TURQ = 3'b011, WHITE = 3'b111, OFF = 3'b000;      // RGB assignments
    localparam RED_c = 114, GREEN_c = 103, BLUE_c = 98, PURPLE_c = 112, YELLOW_c = 121, TURQ_c = 116, WHITE_c = 119;                            // ASCII codes 
    reg [2:0] colour = 3'b0;

    
    // PWM generator instance
    pwm #(
        .COUNTER_WIDTH(8),
        .MAX_COUNT(255)
    ) m_pwm (
        .clk(clk),
        .duty(duty_ticker),
        .pwm_out(brightness)
    );
    
    // UART TX instance
    uart_tx m_tx(
        .clk(clk),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .data_out(uart_tx_pin),
        .ready(ready)
    );
    
    // UART RX instance
    uart_rx m_rx(
        .clk(clk),
        .rx(uart_rx_pin),
        .data_ready(rx_data_ready),
        .data(rx_data)
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
            
        end 
        else begin
            cd_count <= cd_count + 1'b1;
        end
        
    // UART Loopback
    always @(posedge clk)
    case(uart_test_state)
        READY:
            begin
            tx_start <= 1'b0;
            if (!rx_data_ready) uart_test_state <= WAITING;
            end
        WAITING:
            if(rx_data_ready)   uart_test_state <= COPYING;
            
        COPYING:
            begin
                uart_rx_buf <= rx_data;
                if(ready) tx_start <= 1'b1;
                uart_test_state <= READY; 
            end
    endcase
    
    // UART blinky colour
    always @(posedge clk)
    case(uart_rx_buf)
        RED_c:      colour <= RED;
        GREEN_c:    colour <= GREEN;
        BLUE_c:     colour <= BLUE;
        YELLOW_c:   colour <= YELLOW;
        TURQ_c:     colour <= TURQ;
        WHITE_c:    colour <= WHITE;
        default:    colour <= OFF;
        endcase
        
    
    
    // Assignments
    assign tx_data = uart_rx_buf;
//    assign led0_b = blinky & ~db_btn[0];
    assign  {led0_r, led0_g, led0_b} = blinky & colour;
    assign {led1_r, led1_g, led1_b} = uart_rx_buf[2:0]; //led_shift[2:0] & {3{brightness & ~db_btn[1]}};
    
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
