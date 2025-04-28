`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 19:46:24
// Design Name: 
// Module Name: tb_timer
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


module tb_timer();

APB_interface_dht11 u_timer(.*);
 logic PCLK;
 logic PRESET;
 logic [3:0] PADDR; //4bit???  //알아서 자름 lsb 남김
 logic [31:0] PWDATA;
 logic PWRITE;
 logic PENABLE;//access 
 logic PSEL;// setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 
    logic [31:0 ]PRDATA;
    logic PREADY;
 wire dht_io;
 logic temp;
 assign dht_io = temp;
    always #5 PCLK =~PCLK;
initial begin
    PCLK =0; PRESET =1'b1;
    #10 PRESET = 0;
    write(4'h0, 1);
    // write(4'h8,10);
    write(4'hc,1000);
    forever begin
    write(4'h0,1);
    @(posedge PCLK);
    read(4'h4);
    #100;
    read(4'h4);
    end

end

task write(logic [3:0] addr, logic [31:0] wdata);
    begin
        PADDR = addr;
        PWDATA = wdata;
        PWRITE = 1'b1;
        PENABLE = 0;
        PSEL = 1'b1;
        @(posedge PCLK);
        PENABLE = 1'b1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
        @(posedge PCLK);
    end
endtask

task read(logic [3:0] addr);
    begin
        PADDR = addr;
        PWDATA = 0;
        PWRITE = 0;
        PENABLE = 0;
        PSEL = 1'b1;
        @(posedge PCLK);
        PENABLE = 1'b1;
        @(posedge PCLK);
        PSEL = 0;
        PENABLE = 0;
        @(posedge PCLK);
    end
endtask
endmodule
