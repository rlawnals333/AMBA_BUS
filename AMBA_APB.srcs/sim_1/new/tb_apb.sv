`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/18 16:07:00
// Design Name: 
// Module Name: tb_APB_BUS
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


module tb_APB_BUS();
logic PCLK, PRESET;

logic [31:0] wdata,addr,rdata;
logic write, transfer,ready;
logic [31:0] PADDR,PWDATA;
logic PWRITE,PENABLE;
logic[31:0] PRDATA0,PRDATA1,PRDATA2,PRDATA3;

 APB_master u_master (.*);

 ABP_Slave u_slave0 (
    .*,

    .PSEL(PSEL0),

    .PRDATA(PRDATA0),
    .PREADY(PREADY0)
);

 ABP_Slave u_slave1(
    .*,

    .PSEL(PSEL1),

    .PRDATA(PRDATA1),
    .PREADY(PREADY1)
);


 ABP_Slave u_slave2 (
    .*,

    .PSEL(PSEL2),

    .PRDATA(PRDATA2),
    .PREADY(PREADY2)
);


 ABP_Slave u_slave3 (
    .*,

    .PSEL(PSEL3),

    .PRDATA(PRDATA3),
    .PREADY(PREADY3)
);




always #5 PCLK = ~PCLK;
initial begin
     PCLK = 0; PRESET = 1'b1;
     #10 PRESET = 0;
     @(posedge PCLK);
     //slave0 write
     #1 addr = 32'h1000_0000; write = 1'b1; wdata = 10; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_0004; write = 1'b1; wdata = 11; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_0008; write = 1'b1; wdata = 12; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_000C; write = 1'b1; wdata = 13; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);
     
          //slave1_wr
     #1 addr = 32'h1000_1000; write = 1'b1; wdata = 10; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_1004; write = 1'b1; wdata = 11; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_1008; write = 1'b1; wdata = 12; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_100C; write = 1'b1; wdata = 13; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

     //slave0 read
     #1 addr = 32'h1000_0000; write = 1'b0; wdata = 10; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_0004; write = 1'b0; wdata = 11; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_0008; write = 1'b0; wdata = 12; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_000C; write = 1'b0; wdata = 13; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);
     
          //slave1_read
     #1 addr = 32'h1000_1000; write = 1'b0; wdata = 10; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_1004; write = 1'b0; wdata = 11; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_1008; write = 1'b0; wdata = 12; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);

    #1 addr = 32'h1000_100C; write = 1'b0; wdata = 13; transfer = 1'b1;
     @(posedge PCLK);
     wait(ready == 1'b1);
     @(posedge PCLK);
     #20 $finish;
end

endmodule
