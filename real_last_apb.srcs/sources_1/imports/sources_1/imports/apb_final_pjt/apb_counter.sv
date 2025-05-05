`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 09:41:06
// Design Name: 
// Module Name: apb_counter
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


module ABP_interface_timer(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,

    output logic [31:0 ]PRDATA,
    output logic PREADY



    // output logic [7:0] outPort
);
    logic [31:0] slv_reg0; //clear/ enaable
    logic [31:0] slv_reg1; //o_count
    logic [31:0] slv_reg2; // tick_limit 
    logic [31:0] slv_reg3; // counter_limit 
    //ff 안에서는 PREADY = 0 안해도 latch 발생 안함 
    logic c_ready, n_ready;
    //    logic [7:0] idr;

    assign PREADY = n_ready;
    // assign moder = slv_reg0[7:0];
    // assign slv_reg1 = {{24{1'b0}},idr};
 
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            // slv_reg1 <= 0; // assign해서 input으로 받게 만들고선 초기화하면 안됨 
            slv_reg2 <= 0;
            slv_reg3 <= 0;
            PRDATA <= 0;
            // PREADY <= 0;
            c_ready <= 0;
          
        end else begin
            c_ready <= n_ready;
      
            
            if(PSEL) begin
                if (PWRITE) begin
                    case (PADDR) // 0000 => 0004 => 0008 => 000C 이런식으로 움직임 [3:2]만 바뀜
                        0: slv_reg0 <= PWDATA; // idr은 inPort로 부터 오는 값이므로 core에서 건들면 안됨 
                        // 4: slv_reg1 <= PWDATA; 
                        8: slv_reg2 <= PWDATA;
                        12: slv_reg3 <= PWDATA;
                        // 12:slv_reg3 <= PWDATA; // 주소눈 BYTE 단위인데 4바이트 짜리 데이터니까 4씩 증가함 
                        // 4'hC: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                   
                    case (PADDR)
                        0: PRDATA <= slv_reg0;
                        4: PRDATA <= slv_reg1;
                        8: PRDATA <= slv_reg2;
                        12: PRDATA <= slv_reg3;
                        // 12:PRDATA <= slv_reg3;
                        // 4'hC: PRDATA <= slv_reg3;
                    endcase
                end
            
        end
        end
    end

    always_comb begin
            n_ready = 0;
        if(PSEL && PENABLE) begin
            n_ready = 1'b1; //ready 1이면 master IDLE로 감
        end
    end

timer_apb counter(
    .clk(PCLK),
    .reset(PRESET),
    .enable(slv_reg0[0]),
    .clear(slv_reg0[1]), //0x01 00 10 
    .o_count(slv_reg1),
    .PSC(slv_reg2),
    .ARR(slv_reg3)
    );

endmodule