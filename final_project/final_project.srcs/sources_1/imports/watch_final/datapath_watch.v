`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 12:27:57
// Design Name: 
// Module Name: control_unit_watch
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

//fsm 식으로 가자 
module datapath_watch #(
    parameter FCOUNT = 1_000_000

) (
    input clk,
    input reset,
    input btn_hour,
    input btn_min,
    input btn_sec,
    // input rd,

    output [$clog2(100)-1 : 0] bcd_msec,
    output [ $clog2(60)-1 : 0] bcd_sec,
    output [ $clog2(60)-1 : 0] bcd_min,
    output [ $clog2(24)-1 : 0] bcd_hour
);


wire tick_100hz,tick_msec,tick_sec,tick_min;
wire w_clear;
// assign w_clear = clear & ~(sw_mode);
// wire sel_dot;

clk_div_watch #(.FCOUNT(FCOUNT)) u_clk_di_watch (    
    .clk(clk),
    .reset(reset),
  

    .o_tick(tick_100hz)
);

tick_count_watch u_count_msec_watch(
    .clk(clk),
    .reset(reset),
    .tick(tick_100hz),
    .btn(1'b0),
    // .rd(rd),
    

    .o_tick(tick_msec),
    .bcd(bcd_msec)
);

tick_count_watch#(.FCOUNT(60)) u_count_sec_watch(
    .clk(clk),
    .reset(reset),
    .tick(tick_msec),
    .btn(btn_sec),
    // .rd(rd),
    

    .o_tick(tick_sec),
    .bcd(bcd_sec)
);
tick_count_watch#(.FCOUNT(60)) u_count_minute_watch(
    .clk(clk),
    .reset(reset),
    .tick(tick_sec),
    .btn(btn_min),
    // .rd(rd),
  

    .o_tick(tick_min),
    .bcd(bcd_min)
);
tick_count_watch_hour#(.FCOUNT(24)) u_count_hour_watch(
    .clk(clk),
    .reset(reset),
    .tick(tick_min),
    .btn(btn_hour),
    // .rd(rd),
    

    .o_tick(),
    .bcd(bcd_hour)
);



endmodule


module clk_div_watch #(parameter FCOUNT = 1_000_000, parameter BIT_SIZE = $clog2(FCOUNT)) (
    
    input clk,
    input reset,
    
    
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
        
         if(current_count == FCOUNT -1) begin
             next_count = 0;
             next_tick = 1'b1;
         end
         else begin
         next_count = current_count + 1;
         next_tick = 1'b0;
         end
    
    end
    
endmodule

module tick_count_watch #(parameter FCOUNT = 100, parameter BIT_SIZE = $clog2(FCOUNT))(
    input clk,
    input reset,
    input tick,
    input btn,
    input rd,
   
 

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
            current_tick <= 1'b0;
        end

        else begin
            current_count <= next_count;
            current_tick <= next_tick;
        end
    end 
    // next tick이 한클럭이여야함 
    always @(*) begin
        next_count = current_count;
        next_tick = 1'b0;
        
    
        if((tick == 1'b1) || (btn == 1'b1)) begin
            if(current_count == FCOUNT-1) begin
                next_count = 0;
                next_tick = 1'b1;
            end
            else begin
                next_count = current_count + 1;
                next_tick = 1'b0;
            end
        end 
       

        // else begin
        //     next_count = current_count;
        //     next_tick = current_tick;
        // end

        
    end

endmodule

module tick_count_watch_hour #(parameter FCOUNT = 100, parameter BIT_SIZE = $clog2(FCOUNT))(
    input clk,
    input reset,
    input tick,
    input btn,
    input rd,
   
 

    output o_tick,
    output [BIT_SIZE-1:0] bcd
);
    reg current_tick, next_tick;
    reg [BIT_SIZE-1:0] current_count, next_count;

    assign o_tick = next_tick & ~(current_tick);
    assign bcd = current_count;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            current_count <= 12;
            current_tick <= 1'b0;
        end

        else begin
            current_count <= next_count;
            current_tick <= next_tick;
        end
    end 
    // next tick이 한클럭이여야함 
    always @(*) begin
        next_count = current_count;
        next_tick = 1'b0;
        
    
        if((tick == 1'b1) || (btn == 1'b1)) begin
            if(current_count == FCOUNT-1) begin
                next_count = 0;
                next_tick = 1'b1;
            end
            else begin
                next_count = current_count + 1;
                next_tick = 1'b0;
            end
        end 
       

        // else begin
        //     next_count = current_count;
        //     next_tick = current_tick;
        // end

        
    end

endmodule


