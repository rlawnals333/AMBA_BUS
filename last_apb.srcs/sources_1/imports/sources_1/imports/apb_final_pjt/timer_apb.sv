`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 09:33:33
// Design Name: 
// Module Name: timer_apb
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


module timer_apb(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic clear,
    input logic [31:0] PSC,//tick_limit,
    input logic [31:0] ARR,//count_limit,
    output logic [31:0] o_count
    );

    logic [31:0] tick_count;

    always_ff @( posedge clk, posedge reset ) begin 
        if(reset) begin
            tick_count <= 0;
            o_count <= 0;
        end

        else begin
            if(clear) begin
                tick_count <= 0;
                o_count <= 0;
            end
            else begin
                if(enable) begin
                    if((o_count == ARR) && (tick_count == PSC)) begin
                        o_count <= 0;
                        tick_count <= 0; //ff => 1clk delay // 얘도 추가안하면 buffer되서 꼬임 
                    end
                    else if(tick_count == PSC) begin // counter_limit과 tick_limit 달라야함 
                        tick_count <= 0;
                        o_count <= o_count + 1;
                    end
                    else begin
                        tick_count <= tick_count+1;
                    end
                end
                
            end
        end
    end
    //if문에 없으면 걍 유지/ if문이면 다음클럭에 실행 => 타이밍 잘 맞추도록 값 assign
endmodule
