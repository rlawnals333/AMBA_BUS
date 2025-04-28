`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/12 11:53:35
// Design Name: 
// Module Name: led_mode
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

//sw에 따라 시계모드/ 스탑워치모드 / mse_sec 모드/ min_hour모드 
//sw2개 

module led_mode(
        input [1:0] sw_mode,

        output reg [3:0] led_mode
    );

    always @(*) begin
        led_mode = 4'b0000;
        case (sw_mode)
            2'b00: led_mode = 4'b0001;
            2'b01: led_mode = 4'b0010;
            2'b10: led_mode = 4'b0100;
            2'b11: led_mode = 4'b1000;
        endcase
    end
endmodule
