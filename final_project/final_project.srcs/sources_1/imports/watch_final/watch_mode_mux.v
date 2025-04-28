`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 14:02:30
// Design Name: 
// Module Name: watch_mode_mux
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


module watch_mode_mux(
        input [2:0]sw_mode,
        input [$clog2(100)-1 :0]  stop_bcd_msec,
        input [$clog2(60)-1 :0]   stop_bcd_sec,
        input [$clog2(60)-1 :0]   stop_bcd_min,
        input [$clog2(24)-1 :0]   stop_bcd_hour, 

        input [$clog2(100)-1 :0]  watch_bcd_msec,
        input [$clog2(60)-1 :0]   watch_bcd_sec,
        input [$clog2(60)-1 :0]   watch_bcd_min,
        input [$clog2(24)-1 :0]   watch_bcd_hour,

        output reg [$clog2(100)-1 :0] o_bcd_msec,
        output reg [$clog2(60)-1 :0]  o_bcd_sec,
        output reg [$clog2(60)-1 :0]  o_bcd_min,
        output reg [$clog2(24)-1 :0]  o_bcd_hour  

    );

    always @(*) begin
        o_bcd_msec = stop_bcd_msec;
        o_bcd_sec = stop_bcd_sec;
        o_bcd_min = stop_bcd_min;
        o_bcd_hour =  stop_bcd_hour;
        case (sw_mode[2:1])
        2'b00 :begin
            o_bcd_msec = stop_bcd_msec;
            o_bcd_sec = stop_bcd_sec;
            o_bcd_min = stop_bcd_min;
            o_bcd_hour =  stop_bcd_hour;
        end 

        2'b01 :begin
            o_bcd_msec = watch_bcd_msec;
            o_bcd_sec =  watch_bcd_sec;
            o_bcd_min =  watch_bcd_min;
            o_bcd_hour = watch_bcd_hour;
        end 
           
        endcase
    end


endmodule
