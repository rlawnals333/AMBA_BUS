`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 10:29:00
// Design Name: 
// Module Name: decoder
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


module decoder(
    input clk,
    input reset,
    input [7:0] data_in,
    input [2:0] sw_mode,

  
    output btn_run,
    output btn_clear_hour_up,
    output btn_sec_up,
    output btn_min_up

);

reg c_run,n_run,
    c_clear_hour, n_clear_hour,
    c_sec, n_sec,
    c_min, n_min;


assign btn_run = c_run;
assign btn_clear_hour_up = c_clear_hour;
assign btn_sec_up = c_sec;
assign btn_min_up = c_min;


always@(posedge clk, posedge reset) begin
    if(reset) begin
      
        c_run <= 0;
        c_clear_hour <= 0;
        c_sec <= 0;
        c_min <= 0;
         
    end
    else begin
     
        c_run <= n_run;
        c_clear_hour <= n_clear_hour;
        c_sec <= n_sec;
        c_min <= n_min;
    end
end

always @(*) begin
    n_run = 0;
    n_clear_hour = 0;
    n_sec = 0;
    n_min = 0;
   
case(data_in)

 "R","r": begin
        n_run = 1'b1;
         end
 "C","c": begin
        n_clear_hour = 1'b1;
    end
 "H","h": begin
        n_clear_hour = 1'b1;
    end
 "M","m": begin
        n_min = 1'b1;
    end
 "S","s": begin
        n_sec = 1'b1;
    end
    
    endcase
end

endmodule
