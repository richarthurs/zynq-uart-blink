// UART Transmitter
// Richard Arthurs


module uart_tx #(baud = 115200, clk_freq = 125000000)(
    input wire      clk,
    input wire      tx_start,
    input wire[7:0] tx_data,
    output wire     data_out,
    output wire     ready,
    output reg      baud_out
    );
    
reg [3:0] state;
localparam READY = 2'b00, LOAD_BIT = 2'b01, SEND_BIT = 2'b11;
localparam bit_index_max = 10;
reg[9:0] tx_buf;
reg[3:0] bit_index;
reg out_bit = 1'b1;

localparam[31:0] baud_time = clk_freq / baud;
reg [31:0] m_timer = 0;


always @(posedge clk)
case(state)
    READY: begin
        if(tx_start) begin
            tx_buf <= {1'b1, tx_data, 1'b0};
            state <= LOAD_BIT;
        end
        bit_index <= 0;
        out_bit <= 1'b1;
        m_timer <= 0;
        baud_out <= 1'b0;
    end
    
    LOAD_BIT: begin
        state <= SEND_BIT;
        bit_index <= bit_index + 1'b1;
        out_bit <= tx_buf[bit_index];
    end
    
    SEND_BIT: begin
        if(m_timer == baud_time) begin
            m_timer <= 0; 
            if(bit_index == bit_index_max) state <= READY;
            else state <= LOAD_BIT;
            baud_out <= ~baud_out;
        end
        else begin 
            m_timer <= m_timer + 1'b1;
        end
    end
    
    default: state <= READY;
endcase

assign data_out = out_bit;
assign ready = (state == READY);
    

endmodule
