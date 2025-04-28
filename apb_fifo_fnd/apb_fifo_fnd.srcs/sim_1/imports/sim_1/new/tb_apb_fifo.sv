`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/27 18:44:14
// Design Name: 
// Module Name: tb_fifo_apb
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


module tb_fifo_apb(); //read/ write 과정
 
     logic clk;
     logic reset;

    wire [7:0] GPIOA_INOUTPORT, GPIOB_INOUTPORT,  GPIOC_INOUTPORT, GPIOD_INOUTPORT;
     logic [3:0] fndcomm;
     logic [7:0] fndfont ;// 밖으로 나가는 port 
    // output logic [7:0] GPIO_OUTPORT
   



     
 MCU dut (.*);
    // output logic [7:0] GPIO_OUTPOR);

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1'b1;
        #10 reset = 0;
       
    end

    // task write(logic [31:0] i_data);
    // begin //task 는 걍 begin 이네 
    //     PSEL= 1'b1;
    //     PADDR = 4'h4;
    //     PWRITE = 1'b1;
    //     PWDATA = i_data;
    //     @(posedge PCLK);
    //     PSEL= 1'b1;
    //     PWDATA = i_data; // = 순서 <= 한번에에
    //     PWRITE = 1'b1;
    //     PENABLE = 1'b1;
    //     @(posedge PCLK);
    //     PSEL= 1'b0;
    //     PENABLE = 1'b0;
    // end
    // endtask

    //  task read();
    // begin //task 는 걍 begin 이네 
    //     PSEL= 1'b1;
    //     PADDR = 4'h4;
    //     PWRITE = 1'b0;
    //     PWDATA = 32'bx;
    //     @(posedge PCLK);
    //     PSEL= 1'b1;
    //     PWDATA = 32'bx; // = 순서 <= 한번에에
    //     PWRITE = 1'b0;
    //     PENABLE = 1'b1;
    //     @(posedge PCLK);
    //     PSEL= 1'b0;
    //     PENABLE = 1'b0;
    // end
    // endtask
endmodule
