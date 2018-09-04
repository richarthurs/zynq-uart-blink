// UART Receiver
// Richard Arthurs

module uart_rx#(baud = 115200, clk_freq = 125000000)(
    input wire          clk,
    input wire          rx,
    output reg          data_ready = 0,
    output reg[7:0]     data
);


localparam [31:0] baud_time = clk_freq/baud;

localparam READY = 3'b000, START = 3'b001, RECEIVE = 3'b010, WAIT = 3'b011, DONE = 3'b100;
reg [2:0]   state = READY;
reg [31:0]  timer = 32'b0;
reg [8:0]   rx_data;
reg [3:0]   bit_index = 3'b0;

always @(posedge clk) begin
    case(state)
    READY:
        if(rx == 1'b0) begin
            state <= START;
            bit_index <= 3'b0;
        end
        
    START:
        if(timer == baud_time / 2 ) begin
            state <= WAIT;
            timer <= 31'b0;
            data_ready <= 1'b0;
        end
    
        else timer <= timer + 1'b1;
        
    WAIT:
        if(timer == baud_time) begin
            timer <= 32'b0;
            if (data_ready) state <= READY;
            else state <= RECEIVE;
         end
        else timer <= timer + 1'b1;
    
    RECEIVE:
        begin
        rx_data[bit_index] <= rx;
        bit_index <= bit_index + 1'b1;
        if(bit_index == 4'd8) state <= DONE;
        else state <= WAIT; 
        end
                 
    DONE:
        begin
            data_ready <= 1'b1;
            state <= WAIT;
            data <= rx_data[7:0];
        end
    endcase

end
endmodule

