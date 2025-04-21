`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/09 12:15:33
// Design Name: 
// Module Name: tb_mcu_types
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


module tb_mcu_types();

logic clk, reset;
MCU u_mcu (
    .clk(clk),
    .reset(reset)
);

always #5 clk = ~clk;
initial begin
    clk = 0;
     reset = 1'b1;
     #10 reset = 0;
end
endmodule
