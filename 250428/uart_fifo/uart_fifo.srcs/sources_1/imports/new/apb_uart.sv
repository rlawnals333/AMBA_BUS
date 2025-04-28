`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/03 18:16:52
// Design Name: 
// Module Name: uart_top
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


module uart_top(
    input clk,
    input reset,
    //tx
    input [7:0] tx_in,
    input tx_start_trigger,

    output tx_out,
    output tx_busy,
    output tx_done,
    //rx
    input rx_in,

    output [7:0] rx_out,
    output rx_busy,
    output rx_done


    );

    uart_tx uartTX (
    .clk(clk),
    .reset(reset),
    .tx_in(tx_in),
    .start_trigger(tx_start_trigger),

    .tx_out(tx_out),
    .tx_busy(tx_busy),
    .tx_done(tx_done)
);

    uart_rx uartRX (
    .clk(clk),
    .reset(reset),
    .rx_in(rx_in),


    .rx_out(rx_out),
    .rx_busy(rx_busy),
    .rx_done(rx_done)
);

endmodule

module uart_tx (
    input clk,
    input reset,
    input [7:0] tx_in,
    input start_trigger,

    output tx_out,
    output tx_busy,
    output tx_done
);

    reg [2:0] current_state, next_state;
    reg  c_tx, n_tx;
    reg [3:0] c_count, n_count;
    reg [2:0] c_bit_count, n_bit_count;
    reg c_done, n_done;
    reg c_busy, n_busy;
    wire baud_tick;
    reg [7:0] c_temp, n_temp;

    assign tx_out = c_tx;
    assign tx_busy = c_busy;
    assign tx_done = c_done;

    //ouput assign 
    localparam IDLE = 0, SEND = 1, START = 2, DATA =3, STOP = 4 ;

    tick_gen#(.FCOUNT(10000_0000 / (9600 * 16))) tick_baudrate( // oversampling 16 
    .clk(clk),
    .reset(reset),

    .tick(baud_tick)
    );

    always @(posedge clk, posedge reset) begin
        
        if(reset) begin
            current_state <= 0;
            c_tx <= 0;
            c_count <= 0;
            c_bit_count <= 0;
            c_done <= 0;
            c_busy <= 0;
            c_temp <= 0;
        end

        else begin
            current_state <= next_state;
            c_tx <= n_tx;
            c_count <= n_count;
            c_bit_count <= n_bit_count; // fsm 식으로 가야되
            c_done <= n_done;
            c_busy <= n_busy;
            c_temp <= n_temp;
        end

    end

    always @(*) begin
        next_state = current_state;
        n_tx = c_tx;
        n_count = c_count;
        n_bit_count = c_bit_count;
        n_done = 0;  // tick 
        n_busy = c_busy; // 유지
        n_temp = c_temp;

        case(current_state) // case문은 begin이 없음 
        IDLE : begin
            n_count = 0;
            n_bit_count = 0;
            n_tx = 1'b1;
            if(start_trigger) begin
                next_state = SEND;
                n_temp = tx_in; // tick 사용하면 무조건 send 이래야 일정한 pulse 유지 가능
            end
        end
        
        SEND: begin
            if(baud_tick) next_state = START; 
            n_busy = 1'b1;
        end

        START: begin
            n_tx = 0;
            if(baud_tick) begin
                if(c_count == 15) begin
                    next_state = DATA;
                    n_count = 0;  //count 초기화 해줘야함 무조건 state 넘어갈 때 
                end

                else begin
                    n_count = c_count + 1;
                end
            end
        end

        DATA: begin
            n_tx = c_temp[c_bit_count];  // 저장할때는 {} / 내보낼 때는 소프트웨어적 lsb부터 
            if(baud_tick) begin
                if(c_bit_count == 7) begin  // 탈출조건 먼저 
                    if(c_count == 15) begin
                        next_state = STOP;
                        n_bit_count = 0;
                        n_count = 0;
                        
                    end

                    else begin
                        n_count = c_count + 1;
                    end
                end

                else begin // 탈출조건 아닐때 
                    if(c_count == 15) begin
                        n_count = 0;
                        n_bit_count = c_bit_count + 1;
                        
                    end
                    else begin
                        n_count = c_count + 1;
                    end
                end
            end
        end

        STOP: begin
            n_tx = 1'b1;
            if(baud_tick) begin
                if(c_count == 15) begin
                    next_state = IDLE;
                    n_done = 1'b1;
                    n_busy = 0;
                end

                else begin
                    n_count = c_count + 1;
                end
            end
        end

        endcase
    end
endmodule

module uart_rx (
    input clk,
    input reset,
    input rx_in,


    output [7:0] rx_out,
    output rx_busy,
    output rx_done
);

    reg [2:0] current_state, next_state;
    reg [7:0] c_rx, n_rx;
    reg [4:0] c_count, n_count;
    reg [2:0] c_bit_count, n_bit_count;
    reg c_done, n_done;
    reg c_busy, n_busy;
    wire baud_tick;

    assign rx_out = c_rx;
    assign rx_busy = c_busy;
    assign rx_done = c_done;

    //ouput assign 
    localparam IDLE = 0, SEND = 1, START = 2, DATA =3, STOP = 4 ;

    tick_gen#(.FCOUNT(10000_0000 / (9600 * 16))) tick_baudrate( // oversampling 16 
    .clk(clk),
    .reset(reset),

    .tick(baud_tick)
    );

    always @(posedge clk, posedge reset) begin
        
        if(reset) begin
            current_state <= 0;
            c_rx <= 0;
            c_count <= 0;
            c_bit_count <= 0;
            c_done <= 0;
            c_busy <= 0;
        end

        else begin
            current_state <= next_state;
            c_rx <= n_rx;
            c_count <= n_count;
            c_bit_count <= n_bit_count; // fsm 식으로 가야되
            c_done <= n_done;
            c_busy <= n_busy;
        end

    end

    always @(*) begin
        next_state = current_state;
        n_rx = c_rx;
        n_count = c_count;
        n_bit_count = c_bit_count;
        n_done = 0;  // tick 
        n_busy = c_busy; // 유지


        case(current_state) // case문은 begin이 없음 
        IDLE : begin
            n_count = 0;
            n_bit_count = 0;
            if(rx_in == 0) begin
                next_state = SEND; // tick 사용하면 무조건 send 이래야 일정한 pulse 유지 가능
            end
        end
        
        SEND: begin
            if(baud_tick) next_state = START; 
            n_busy = 1'b1;
        end

        START: begin
            if(baud_tick) begin
                if(c_count == 7) begin
                    next_state = DATA;
                    n_count = 0;  //count 초기화 해줘야함 무조건 state 넘어갈 때 
                end

                else begin
                    n_count = c_count + 1;
                end
            end
        end

        DATA: begin
            
            if(baud_tick) begin
                if(c_bit_count == 7) begin  // 탈출조건 먼저 
                    if(c_count == 15) begin

                        n_rx = {rx_in,c_rx[7:1]};  // 저장 shift register / lsb 부터  // 앞에서 들어와야함 => 생각잘하셈 
                        next_state = STOP;
                        n_bit_count = 0;
                        n_count = 0;
                        
                    end

                    else begin
                        n_count = c_count + 1;
                    end
                end

                else begin // 탈출조건 아닐때 
                    if(c_count == 15) begin
                        n_rx = {rx_in,c_rx[7:1]};
                        n_count = 0;
                        n_bit_count = c_bit_count + 1;
                        
                    end
                    else begin
                        n_count = c_count + 1;
                    end
                end
            end
        end

        STOP: begin
            if(baud_tick) begin
                if(c_count == 23) begin
                    next_state = IDLE;
                    n_done = 1'b1;
                    n_busy = 0;
                end

                else begin
                    n_count = c_count + 1;
                end
            end
        end

        endcase
    end
endmodule