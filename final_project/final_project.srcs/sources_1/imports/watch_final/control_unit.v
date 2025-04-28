`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/11 19:38:06
// Design Name: 
// Module Name: control_unit
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

//sw에 따른 run_clear 출력은 여기서 받아야함 

module control_unit(
        input clk,
        input reset,
        input btn_run,
        input btn_clear,
        // input rd,

        output run,
        output clear
    );

    localparam STOP  = 2'b00;
    localparam RUN   = 2'b01;
    localparam CLEAR = 2'b10;

    reg r_run, r_clear;
    reg [1:0] current_state, next_state;

    assign run = r_run;
    assign clear = r_clear;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            current_state <= STOP;
        end

        else begin
            current_state <= next_state;
        end
    end

    always @(*) begin // btn이 한클럭 이상 1이면 run, stop 무한 반복함 (CLK가 빠르면) 물리적으로 그럴 수 밖에 없음 => DEBOUNCE로 한클럭만 내보내야함 BTN_RUN
        next_state = STOP;
        case (current_state)
        STOP: begin
            if(btn_run == 1'b1 ) begin
                next_state = RUN;
            end

            else if(btn_clear == 1'b1 ) begin
                next_state = CLEAR;
            end

            else begin
                next_state = current_state;
            end
        end 
        
        RUN: begin
            if(btn_run == 1'b1 ) begin
                next_state = STOP;
            end

            else begin
                next_state = current_state;
            end
        end 

        CLEAR: begin
            if(btn_run == 1'b1 ) begin
                next_state = RUN;
            end

            else begin
                next_state = current_state;
            end
        end  
        endcase
    end

    always @(*) begin
        r_run = 1'b0;
        r_clear = 1'b0;
        case (current_state)
        STOP: begin
                r_run = 1'b0;
                r_clear = 1'b0;
            end

        RUN: begin
            
                r_run = 1'b1;
                r_clear = 1'b0;
            end
          
        CLEAR: begin
                r_run = 1'b0;
                r_clear = 1'b1;
            end     
        endcase
    end
endmodule
