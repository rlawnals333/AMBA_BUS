`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 10:52:33
// Design Name: 
// Module Name: tb_timer_apb
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


module tb_timer_apb();
     logic clk;
     logic reset;
     logic enable;
     logic clear;
     logic [31:0] PSC;
     logic [31:0] ARR;
     logic [31:0] o_count;

 timer_apb dut(.*); 

always #5 clk = ~clk;
 initial begin
    PSC = 10;
    ARR = 5;
    enable = 1'b1;
    clear = 0;
    clk=0;reset =1'b1;
    #10 reset = 0;
    #1000 enable = 0;    

 end
    

endmodule
