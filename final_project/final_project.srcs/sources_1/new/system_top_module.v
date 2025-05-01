`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 10:19:21
// Design Name: 
// Module Name: system_top_module
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


module system_top_module (
    //기본
    input clk,
    input reset,
    

    //uart 통신
    input pc_rx_in,

    output pc_tx_out,

    //버튼
    input btn_run, // 스탑워치 run
    input btn_clear_hour_up, // 시계 시 증가/ 스탑워치 클리어/ 온습도, 울트라 소닉 동작 시작 
    input btn_sec_up, // 시계 초 증가
    input btn_min_up, // 시계 분 증가

    //초음파
    input us_echo,
    output us_start_trigger,

    //스위치
    input [2:0] sw_mode, 

    //온습도
    inout dht_io,
    
    //온습도 led 모드
    output [4:0] led,
    output [3:0] fsm_state,

    //display
    output [3:0] fnd_comm,
    output [7:0] fnd_font

    );
    //uart_fifo
    wire [7:0] fifo_rx_data;

    //pc_control_data
    wire pc_btn_run, pc_btn_clear_hour_up, pc_btn_min_up, pc_btn_sec_up; // pc통신 control data

    //debounce

    wire w_btn_run,w_btn_clear_hour_up,w_btn_min_up,w_btn_sec_up;

    //datapath
    //watch
    wire [$clog2(100)-1 :0]  bcd_msec;
    wire [$clog2(60)-1 :0]  bcd_sec;
    wire [$clog2(60)-1 :0]  bcd_min;
    wire [$clog2(24)-1 :0]  bcd_hour;

    //ultrasonic
    wire [8:0] distance;
    wire us_done;

    //dht11
    wire [39:0] dht_data;
    wire dht_done;
    wire checksum;
    
    //row_counter 2 uart
    wire row_temper_start_trigger,row_humi_start_trigger,row_us_start_trigger;
    wire [7:0] row_temper_tx_data,row_humi_tx_data, row_us_tx_data;
    wire [7:0] tx_data;



    wire [3:0] fontR_10,fontR_1,fontL_10,fontL_1;
    //uart_tx
    wire tx_stop;
      
decoder u_decoder(
    .clk(clk),
    .reset(reset),
    .data_in(fifo_rx_data),
    .sw_mode(sw_mode),

  
    .btn_run(pc_btn_run),
    .btn_clear_hour_up(pc_btn_clear_hour_up),
    .btn_sec_up(pc_btn_sec_up),
    .btn_min_up(pc_btn_min_up)

);


btn_debounce #(.TICK_COUNT(100000)) btn_debounce_run(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_run),
        

        .o_btn(w_btn_run)

        );

btn_debounce #(.TICK_COUNT(100000)) btn_debounce_clear_hour_up(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_clear_hour_up),
     

        .o_btn(w_btn_clear_hour_up)

        );

btn_debounce #(.TICK_COUNT(100000)) btn_debounce_min_up(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_min_up),
        

        .o_btn(w_btn_min_up)

        );

btn_debounce #(.TICK_COUNT(100000)) btn_debounce_sec_up(
        .clk(clk),
        .reset(reset),
        .i_btn(btn_sec_up),
     

        .o_btn(w_btn_sec_up)

        );    


stop_watch u_stop_watch(
        .clk(clk),
        .reset(reset),
        .sw_mode(sw_mode),
        .btn_run(w_btn_run | pc_btn_run),
        .btn_clear_hour_up(w_btn_clear_hour_up | pc_btn_clear_hour_up),
        .btn_sec_up(w_btn_sec_up | pc_btn_sec_up),
        .btn_min_up(w_btn_min_up | pc_btn_min_up),
        // input rd,

        
        .bcd_msec(bcd_msec),
        .bcd_sec(bcd_sec),
        .bcd_min(bcd_min),
        .bcd_hour(bcd_hour) 
    );

us_control top_ultrasonic

(

    .clk(clk),
    .reset(reset),
    .SR04_data(us_echo),
    .btn_start(w_btn_run | pc_btn_run),
    .sw_mode(sw_mode),  // 필요할떄만 받기 

    .start_trigger(us_start_trigger),
    .distance(distance),
    .measure_done(us_done),
    .is_measure()
   
    );


top_dht11 u_dht11 (
    .clk(clk),
    .reset(reset),
    .btn_start(w_btn_run | pc_btn_run),
    .sw_mode(sw_mode),
    .dht_io(dht_io),


    // output [2:0] led_state,
    .led(),
    .fsm_state(fsm_state),
    .data_out(dht_data),
    .is_done(dht_done),
    .checksum(checksum)
    // output [39:0] dht11_data, 비트스트림위해해
    

);

row_counter_dht_humidity u_row_dht_humi(
    .clk(clk),
    .reset(reset),
    .is_done(tx_stop), // uart_fifo
    .btn_start(dht_done),
    .dht_in(dht_data),
    .checksum(checksum),
    .sw_mode(sw_mode),


    .start_trigger(row_humi_start_trigger),
    .tx_data(row_humi_tx_data)
);

row_counter_dht_temperature u_row_dht_temper(
    .clk(clk),
    .reset(reset),
    .is_done(tx_stop), // uart_fifo
    .btn_start(dht_done),
    .dht_in(dht_data),
    .checksum(checksum),
    .sw_mode(sw_mode),


    .start_trigger(row_temper_start_trigger),
    .tx_data(row_temper_tx_data)
);

row_counter_us u_row_us (
    .clk(clk),
    .reset(reset),
    .is_done(tx_stop),
    .btn_start(us_done),
    .distance(distance),
    .sw_mode(sw_mode),

    .start_trigger(row_us_start_trigger),
    .tx_data(row_us_tx_data)
);


datapath_fnd u_datapath (
    .clk(clk),
    .reset(reset),

    .sw_mode(sw_mode),

    //dht
    .dht_data(dht_data),
    .checksum(checksum),
    //us
    .distance(distance),

    //watch
    .bcd_msec(bcd_msec),
    .bcd_sec(bcd_sec),
    .bcd_min(bcd_min),
    .bcd_hour(bcd_hour),

    // to fnd 

    .fontR_10(fontR_10),
    .fontR_1( fontR_1),
    .fontL_10(fontL_10),
    .fontL_1(fontL_1)


);

fifo_wdata_mux u_fifo_wdata_mux(

    .temper_tx_data(row_temper_tx_data), 
    .humi_tx_data(row_humi_tx_data), 
    .us_tx_data(row_us_tx_data),
    .sw_mode(sw_mode),

    .tx_data(tx_data)
);


fifo_uart u_fifo_uart(
    .clk(clk),
    .reset(reset),
    .uart_rx_in(pc_rx_in),
    .measure_done(us_done | dht_done),
    .tx_data(tx_data),
    .start_trigger(row_us_start_trigger | row_humi_start_trigger | row_temper_start_trigger),
    
    // output rd,
    .uart_tx_out(pc_tx_out),
    .fifo_rx_data(fifo_rx_data),
    .tx_stop(tx_stop)

);


//datapath 만들기 

    fnd_controller#(.DIVE_SIZE(50_000)) U_Fnd_Ctrl(
        .clk(clk),
        .reset(reset),
        //datapath로부터
        .fontR_1(fontR_1),
        .fontR_10(fontR_10),

        .fontL_1(fontL_1),
        .fontL_10(fontL_10),
   
        .sw_mode(sw_mode), // 시계부분만 
        .bcd_msec(bcd_msec), // fnd_dot 때문에 
    // input [3:0] fnd_dot,

        .fnd_comm(fnd_comm),
        .fnd_font(fnd_font)
        );

    //8x1  먹서 그대로 사용하자   fnd data 보내는 모듈 따로 스위치에 따라 다른 데이터 2개씩 => row counter로 여러개 사용 (datapath) 

    ledmode_mux u_led_mux (
    .sw_mode(sw_mode),

    .led_mode(led)
);
endmodule

module fifo_wdata_mux(

    input [7:0] temper_tx_data,
    input [7:0] humi_tx_data, 
    input [7:0] us_tx_data,
    input [2:0] sw_mode,

    output reg[7:0] tx_data
);

always @(*) begin
    tx_data = 0;
    case(sw_mode)
    3'b100: tx_data = us_tx_data;
    3'b101: tx_data = humi_tx_data;
    3'b111: tx_data = temper_tx_data;
    endcase
end
endmodule


module ledmode_mux (
    input [2:0] sw_mode,

    output reg [4:0] led_mode
);
    always @(*) begin
        led_mode = 0;
        case(sw_mode)
        3'b000: led_mode = 5'b00001;
        3'b001: led_mode = 5'b00001;
        3'b010: led_mode = 5'b00010;
        3'b011: led_mode = 5'b00010;
        3'b100: led_mode = 5'b00100;
        3'b101: led_mode = 5'b01000;
        3'b111: led_mode = 5'b10000;
        endcase
    end
endmodule