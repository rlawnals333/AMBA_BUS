`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 00:38:50
// Design Name: 
// Module Name: top_stop_watch
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


module stop_watch#(parameter DP_COUNT = 1_000_000)(
        input clk,
        input reset,
        input [2:0] sw_mode,
        input btn_run,
        input btn_clear_hour_up,
        input btn_sec_up,
        input btn_min_up,

        output [$clog2(100)-1 :0] bcd_msec,
        output [$clog2(60)-1 :0]  bcd_sec,
        output [$clog2(60)-1 :0]  bcd_min,
        output [$clog2(24)-1 :0]  bcd_hour  // fnd_ctrl로 ㄱㄱ 
    
     
    );


    wire run, clear;
    wire stop_watch_run, stop_watch_clear, watch_run, watch_clear;

    
    assign stop_watch_run =btn_run & (sw_mode[2:1] == 2'b00);
    assign stop_watch_clear = btn_clear_hour_up & (sw_mode[2:1] == 2'b00);
    assign watch_clear = btn_clear_hour_up & (sw_mode[2:1] == 2'b01);   // btn자체를 sw와 묶었음 


    wire [$clog2(100)-1 :0] stop_bcd_msec, watch_bcd_msec;
    wire [$clog2(60)-1 :0]  stop_bcd_sec, watch_bcd_sec;
    wire [$clog2(60)-1 :0]  stop_bcd_min, watch_bcd_min;
    wire [$clog2(24)-1 :0]  stop_bcd_hour, watch_bcd_hour;

    // wire [3:0] fnd_dot;


    control_unit U_CU_STOP(
        .clk(clk),
        .reset(reset),
        .btn_run(stop_watch_run),
        .btn_clear(stop_watch_clear),
        // .rd(rd),
        .run(run),
        .clear(clear)
    );


    stopwatch_datapath#(.FCOUNT(DP_COUNT)) U_stop_DP(
        .clk(clk),
        .reset(reset),
        .run(run),
        .clear(clear),
        .sw_mode(sw_mode[1]),

        .bcd_msec(stop_bcd_msec),
        .bcd_sec(stop_bcd_sec),
        .bcd_min(stop_bcd_min),
        .bcd_hour(stop_bcd_hour)
        // .fnd_dot(fnd_dot)
        );

    datapath_watch#(.FCOUNT(DP_COUNT)) U_watch_dp(
        .clk(clk), 
        .reset(reset),
        .btn_hour(watch_clear),
        .btn_min(btn_min_up ),
        .btn_sec(btn_sec_up),
        // .rd(rd),
        
      
        .bcd_msec(watch_bcd_msec),
        .bcd_sec(watch_bcd_sec),
        .bcd_min(watch_bcd_min),
        .bcd_hour(watch_bcd_hour) 
    );

    watch_mode_mux U_Mux_Mode(
        .sw_mode(sw_mode),
        .stop_bcd_msec(stop_bcd_msec),
        .stop_bcd_sec(stop_bcd_sec),
        .stop_bcd_min(stop_bcd_min),
        .stop_bcd_hour(stop_bcd_hour), 

        .watch_bcd_msec(watch_bcd_msec),
        .watch_bcd_sec(watch_bcd_sec),
        .watch_bcd_min(watch_bcd_min),
        .watch_bcd_hour(watch_bcd_hour),

        .o_bcd_msec(bcd_msec),
        .o_bcd_sec(bcd_sec),
        .o_bcd_min(bcd_min),
        .o_bcd_hour(bcd_hour)  

    );


    


endmodule
