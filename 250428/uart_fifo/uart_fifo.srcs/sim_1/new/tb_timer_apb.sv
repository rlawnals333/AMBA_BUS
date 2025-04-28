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

    wire [7:0] GPIOA_INOUTPORT, GPIOB_INOUTPORT,  GPIOC_INOUTPORT, GPIOD_INOUTPORT;
     logic [3:0] fndcomm;
     logic [7:0] fndfont ;

 MCU dut(.*); 

always #5 clk = ~clk;
 initial begin

    clk=0;reset =1'b1;
    #10 reset = 0;
   

 end
    

endmodule
