`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/11 22:04:06
// Design Name: 
// Module Name: stopwatch_datapath
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

//조합회로는 기본적으로 clk 변할때마다 실행


module stopwatch_datapath#(parameter FCOUNT = 1_000_000)(
    input clk,
    input reset,
    input run,
    input clear,
    input sw_mode,

    output [$clog2(100)-1 :0] bcd_msec,
    output [$clog2(60)-1 :0] bcd_sec,
    output [$clog2(60)-1 :0] bcd_min,
    output [$clog2(24)-1 :0] bcd_hour

    // output[3:0] fnd_dot
    );

wire tick_100hz,tick_msec,tick_sec,tick_min;


clk_div #(.FCOUNT(FCOUNT)) u_clk_div (    
    .clk(clk),
    .reset(reset),
    .run(run),

    .o_tick(tick_100hz)
);

tick_count u_count_msec(
    .clk(clk),
    .reset(reset),
    .tick(tick_100hz),
    .clear(clear),

    .o_tick(tick_msec),
    .bcd(bcd_msec)
);

tick_count#(.FCOUNT(60)) u_count_sec(
    .clk(clk),
    .reset(reset),
    .tick(tick_msec),
    .clear(clear),

    .o_tick(tick_sec),
    .bcd(bcd_sec)
);
tick_count#(.FCOUNT(60)) u_count_minute(
    .clk(clk),
    .reset(reset),
    .tick(tick_sec),
    .clear(clear),

    .o_tick(tick_min),
    .bcd(bcd_min)
);
tick_count#(.FCOUNT(24)) u_count_hour(
    .clk(clk),
    .reset(reset),
    .tick(tick_min),
    .clear(clear),

    .o_tick(),
    .bcd(bcd_hour)
);


// tick_count #(.FCOUNT(2)) u_count_half(
//     .clk(clk),
//     .reset(reset),
//     .tick(tick_msec),
//     .clear(clear),

//     .o_tick(),
//     .bcd(sel_dot)
// );

// mux_dot u_mux_dot (
//     .sel_dot(sel_dot),

//     .fnd_dot(fnd_dot)
// );

endmodule

module clk_div #(parameter FCOUNT = 1_000_000, parameter BIT_SIZE = $clog2(FCOUNT)) (
    
    input clk,
    input reset,
    input run,
    
    output o_tick
);
    reg [BIT_SIZE-1:0] current_count, next_count;
    reg current_tick, next_tick;

    assign o_tick = next_tick & ~(current_tick);

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            current_count <= 0;
            current_tick <= 1'b0;
        end

        else begin
            current_count <= next_count;
            current_tick <= next_tick;
        end
    end

    always @(*) begin
        next_count = 0;
        next_tick = 1'b0;
        if(run == 1'b1) begin
            if(current_count == FCOUNT -1) begin
                next_count = 0;
                next_tick = 1'b1;
            end

            else begin
            next_count = current_count + 1;
            next_tick = 1'b0;
            end
        end
        else begin
            next_count = current_count;
            next_tick = current_tick;
        end
    end
    
endmodule

module tick_count #(parameter FCOUNT = 100, parameter BIT_SIZE = $clog2(FCOUNT))(
    input clk,
    input reset,
    input tick,
    input clear,
 

    output o_tick,
    output [BIT_SIZE-1:0] bcd
);
    reg current_tick, next_tick;
    reg [BIT_SIZE-1:0] current_count, next_count;

    assign o_tick = next_tick & ~(current_tick);
    assign bcd = current_count;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            current_count <= 0;
            current_tick = 1'b0;
        end

        else begin
            current_count <= next_count;
            current_tick <= next_tick;
        end
    end 
    // next tick이 한클럭이여야함 
    always @(*) begin
        next_count = 0;
        next_tick = 1'b0;
        
        if(clear == 1'b0) begin
            if(tick == 1'b1) begin
                if(current_count == FCOUNT-1) begin
                    next_count = 0;
                    next_tick = 1'b1;
                end
                else begin
                    next_count = current_count + 1;
                    next_tick = 1'b0;
                end
            end 
            else begin
                next_count = current_count;
                next_tick = current_tick;
            end
        end
        else begin
            next_count = 0;
            next_tick = 1'b0;
        end
        
    

    end

endmodule