`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 11:47:34
// Design Name: 
// Module Name: top_dht11
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

//40비트짜리 fifo 만들어서 거기로 ? 40비트 어케 처리할지 생각 FIFO로 가자   done 신호 만들어서 

module top_dht11 (
    input clk,
    input reset,
    input start_trigger,
    // input [2:0] sw_mode,

    inout dht_io,

    // output [2:0] led_state,
    output led,
    output [3:0] fsm_state,
    output [39:0] data_out,
    output is_done,
    output checksum
    // output [39:0] dht11_data, 비트스트림위해해
    


);

    // wire w_btn_start;

    // assign w_btn_start = btn_start & ( (sw_mode == 3'b101) || (sw_mode == 3'b111));
    wire us_tick;
    tick_gen#(.FCOUNT(100)) u_tick_gen (
        .clk  (clk),
        .reset(reset),

        .tick(us_tick)

    );

    dht11_controller u_dht_ctrl (
        .clk(clk),
        .reset(reset),
        .btn_start(start_trigger),
        .us_tick(us_tick),
        .dht_io(dht_io),

        .led(led),
        .cu_state(fsm_state),
        .data_out(data_out),
        .is_done(is_done),
        .checksum(checksum)
    );
endmodule


// module us_tick_gen (
//     input clk,
//     input reset,

//     output tick

// );
//     parameter COUNT = 100, BIT_SIZE = $clog2(COUNT);
//     reg c_tick, n_tick;
//     reg [BIT_SIZE-1:0] c_count, n_count;
//     reg [7:0] c_dht, n_dht;

//     assign tick = c_tick;

//     always @(posedge clk, posedge reset) begin
//         if (reset) begin
//             c_tick  <= 0;
//             c_count <= 0;
//         end else begin
//             c_tick  <= n_tick;
//             c_count <= n_count;
//         end
//     end

//     always @(*) begin
//         n_tick  = 0;  // 10us 유지 tick 
//         n_count = c_count;

//         if (c_count == COUNT - 1) begin
//             n_tick  = 1;
//             n_count = 0;
//         end else begin
//             n_count = c_count + 1;
//             n_tick  = 0;
//         end
//     end

// endmodule

module dht11_controller (
    input clk,
    input reset,
    input btn_start,
    input us_tick,

    inout dht_io,

    output led,
    output [3:0] cu_state,
    output [39:0] data_out,
    output is_done,
    output checksum
);

    localparam IDLE = 0, SEND = 1, START = 2, WAIT = 3, SYNC_LOW = 4, SYNC_HIGH = 5,DATA_START = 6 ,DATA_TRANS = 7 ,STOP = 8;

    parameter START_CNT = 18000, WAIT_TIME = 30, TIME_OUT = 20000, SYNC_COUNT = 80, 
            DATA_SYNC = 50, DATA_0 = 40, DATA_1 = 70, STOP_CNT = 80;

    reg io_oe_reg, io_oe_next;


    reg [3:0] current_state, next_state;
    reg [5:0] c_data, n_data;

    reg [$clog2(TIME_OUT)-1:0] c_tick_count, n_tick_count;
    reg io_out_reg, io_out_next;
    reg led_ind_reg, led_ind_next;
    reg [39:0] c_odata, n_odata;
    reg c_checksum, n_checksum;
  

    // reg n_dht_io;
    // wire data_negedge = ((n_dht_io == 1'b1)&&(dht_io == 1'b0)) ? 1'b1 : 1'b0; // data 하강엣지 검출 
    reg [5:0] c_data_count, n_data_count;
    reg c_done, n_done;
    // assign dht_io = io_out_reg;
    assign led = led_ind_reg;
    assign data_out = c_odata;
    assign cu_state = current_state;
    assign is_done = c_done;
    assign dht_io = (io_oe_reg) ? io_out_reg : 1'bz; // oe 1일때 출력 0이면 z 


    assign checksum = c_checksum;
    

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            current_state = IDLE;
            led_ind_reg <= 0;
            io_out_reg <= 1'b1;  // idle high 
            c_tick_count <= 0;
            io_oe_reg <= 1'b1;
            // n_dht_io <= 0;
            c_data_count <= 0;
            c_odata <= 0;
            c_done <= 0;
            c_checksum <=0;
            

        end else begin
            current_state <= next_state;
            c_data = n_data;
            c_tick_count <= n_tick_count;
            led_ind_reg <= led_ind_next;
            io_out_reg <= io_out_next;
            io_oe_reg <= io_oe_next;
            // n_dht_io <= dht_io;
            c_data_count <= n_data_count;
            c_odata <= n_odata;
            c_done <= n_done;
            c_checksum <= n_checksum;
        end
    end

    always @(*) begin
        next_state = current_state;
        n_data = c_data;
        n_tick_count = c_tick_count;
        led_ind_next = led_ind_reg;
        io_out_next = io_out_reg;
        io_oe_next = io_oe_reg;
        n_data_count = c_data_count;
        n_odata = c_odata;
        n_done = c_done;
        n_checksum = c_checksum;

        case (current_state)
           
            IDLE: begin
                 n_checksum = ((c_odata[39:32] + c_odata[31:24] + c_odata[23:16] + c_odata[15:8]) == c_odata[7:0]) ? 1'b1 : 1'b0;
                io_out_next = 1'b1;
                io_oe_next  = 1'b1; 
                led_ind_next = 1'b0; // 출력모드 
                if (btn_start) begin
                    next_state = SEND;
                    n_done = 0;
                end
            end
            SEND: begin
                if (us_tick) begin
                    
                    next_state   = START;
                    n_tick_count = 0;
                end
            end

            START: begin
                io_out_next = 1'b0;

                if (us_tick) begin
                    if (c_tick_count == (START_CNT - 1)) begin
                        n_tick_count = 0;
                        next_state   = WAIT;
                    end else begin
                        n_tick_count = c_tick_count + 1;
                    end
                end
            end

            WAIT: begin
                io_out_next = 1'b1;

                if (us_tick) begin
                    if (c_tick_count == WAIT_TIME - 1) begin
                        n_tick_count = 0;
                        next_state   = SYNC_LOW;
                        io_oe_next = 1'b0;
                    end else begin
                        n_tick_count = c_tick_count + 1;
                    end
                end
            end

            SYNC_LOW: begin
                 //read모드로 , 출력 끊기  output enable 
                // if(us_tick) begin
                //     if(c_tick_count == SYNC_COUNT-1 ) begin
                //         n_tick_count = 0;
                //         next_state = SYNC_HIGH;
                //     end
                //     else begin
                //         n_tick_count = c_tick_count + 1;
                //     end
                // end
            if(us_tick) begin
                if (dht_io == 1'b0) begin
                    led_ind_next = 1'b1;
                end else begin
                    led_ind_next = 1'b0;
                    next_state   = SYNC_HIGH;
                end
            end
            end

            SYNC_HIGH: begin
                //read모드로 , 출력 끊기  output enable 
                // if(us_tick) begin
                //     if(c_tick_count == SYNC_COUNT-1 ) begin
                //         n_tick_count = 0;
                //         next_state = DATA_START;
                //     end
                //     else begin
                //         n_tick_count = c_tick_count + 1;
                //     end
                // end
            if(us_tick) begin
                if (dht_io == 1'b0) begin
                    led_ind_next = 1'b0;
                    next_state   = DATA_START;
                end else begin
                    led_ind_next = 1'b1;
                end
            end
            end

            DATA_START: begin
                led_ind_next = 1'b1;
                // if (us_tick) begin
                //     if (c_tick_count == DATA_SYNC - 1) begin
                //         n_tick_count = 0;
                //         next_state   = DATA_TRANS;
                //     end else begin
                //         n_tick_count = c_tick_count + 1;
                //     end
                // end
            if(us_tick) begin
               if (c_data_count == 40) begin
                   
                    next_state   = STOP;
                    n_data_count = 0;
                    io_out_next = 1'b1;
                    io_oe_next  = 1'b1;
                end else begin 
                    if(dht_io == 1'b1) begin
                    led_ind_next = 1'b1;
                    next_state   = DATA_TRANS;
                    end else begin
                    led_ind_next = 1'b0;
                end
            
                end
            end
        end

            DATA_TRANS: begin  // 탈출조건 먼저 
                led_ind_next = 1'b0;
             
                    
                if(us_tick) begin  // 너무 예민하게 반응하지않게 tick 물려주기
                    if (dht_io == 1'b0) begin
                        n_data_count = c_data_count + 1;
                        if (c_tick_count > 50) begin
                            next_state   = DATA_START;
                            n_tick_count = 0;
                            n_odata[39-c_data_count] = 1'b1;
                            // data 1임 
                        end else begin
                            next_state   = DATA_START;
                             n_odata[39-c_data_count] = 1'b0; // msb부터 채워짐 
                             n_tick_count = 0;
                       
                           
                            //data 0임 
                        end
                    end else begin
                        
                            n_tick_count = c_tick_count + 1;
                    end
                end
                end


            
            STOP: begin
                
                if (us_tick) begin
                    if (c_tick_count == DATA_SYNC - 1) begin
                        n_tick_count = 0;
                        next_state   = IDLE;
                        n_done = 1'b1;
                    end else begin
                        n_tick_count = c_tick_count + 1;
                    end
                end
            end
           

            //이떄 0이면 출발할게 

        endcase

    end

// The 8bit humidity integer data + 8bit the Humidity decimal data +8 bit temperature integer data +
// 8bit fractional temperature data +8 bit parity bit
endmodule
