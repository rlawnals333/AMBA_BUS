`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/11 21:07:59
// Design Name: 
// Module Name: btn_debounce
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

// 조합회로도 clk에 따라 움직임 거의 edge에 따라 
// assign은 wire일 때만 reg 에 wire 갱신 가능 tb생각 
module btn_debounce #(parameter TICK_COUNT = 1_00_000, parameter BIT_SIZE = $clog2(TICK_COUNT))(
  input clk,
        input reset,
        input i_btn,
       

        output o_btn
    );

    reg state, next;
    reg [7:0] q_reg, q_next;
    wire btn_debo;
    reg edge_detect;

    //1khz clk
    reg [BIT_SIZE-1:0] counter_reg;
    // counter_next;
    reg r_1khz;
    // always @(posedge clk, posedge reset) begin
    //     if(reset) begin
    //         counter_reg <= 0;
    //     end
    //     else begin
    //         counter_reg <= counter_next;
    //     end
    // end
    // next 
    always @(posedge clk, posedge reset) begin
        
        if(reset) begin 
            counter_reg <= 0;
            r_1khz <= 1'b0;
        end
        else begin 
            if (counter_reg == TICK_COUNT -1) begin
                counter_reg <= 0;
                r_1khz <= 1'b1;
             end
            else begin
               counter_reg <= counter_reg + 1;
               r_1khz <= 1'b0;
             end
        end
    end

    always @(posedge r_1khz, posedge reset) begin
        
        if (reset) begin
            q_reg <= 0;
        end

        else begin
            q_reg <= q_next;
        end
    end

    always @(i_btn,r_1khz) begin
        //shift register 
        q_next = {i_btn, q_reg[7:1]};
    end

    //4input AND gate 
    assign btn_debo = &q_reg;

    //edge _ detetor

    always @(posedge clk, posedge reset) 
    begin
        if(reset) begin
           edge_detect <= 1'b0;
        end
        else begin
            edge_detect <= btn_debo;
        end
    end

    assign o_btn = btn_debo & (~edge_detect)  ; // edge_detect는 순차회로로 clk 마다 갱신, btn_debo와는 조합회로로 묶여있음 => btn_debo가 0 > 1 이 될때 edge_detect는 아직 갱신되기 전이라 0임 => 한 클럭동안 o_btn 1됨 -> tick 발생!
endmodule
