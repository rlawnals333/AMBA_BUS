`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/03 17:26:35
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


module btn_debounce#(parameter COUNT = 100_000)(
    input clk,
    input reset,
    input btn,

    output btn_debo
    

    );
    reg [7:0] c_debounce,n_debounce;
    wire edge_detect;
    wire tick_1khz;

    assign btn_debo = edge_detect;

    tick_gen#(.FCOUNT(COUNT)) u_tick_1khz(
    .clk(clk),
    .reset(reset),

    .tick(tick_1khz)
    );


    always @(posedge clk, posedge reset) begin
       if(reset) begin
         c_debounce <= 0;
       
       end

       else begin
        c_debounce <= n_debounce;
     
       end
    end

    always @(*) begin
        n_debounce = c_debounce;
     // next 쓴거는 전부다 넣어야되 무조건 
        if(tick_1khz) begin
            n_debounce = {c_debounce[6:0],btn}; // n-1 부터 0 까지 , in /msb 로 들어오면 input, [7:1] 
            // 이런 방식으로 해야 돈케어가 뜨지 않음 중요!!
            
        end
        
    end

   assign edge_detect = (&n_debounce) & ~(&c_debounce);

    // n_bit 에다 연산할 떄는 왠만하면 c 기준으로 
    //n은 이제 바뀔애 c 는 이미 전에값   c는 이전값 n은 변한값 

endmodule

