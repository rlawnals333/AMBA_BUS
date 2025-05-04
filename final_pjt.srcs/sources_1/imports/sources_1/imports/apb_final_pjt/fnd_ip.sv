`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/22 11:26:08
// Design Name: 
// Module Name: fnd_ip
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


module fnd_ip #(parameter FCOUNT = 1000_00)(
    input logic [1:0] sel,

    input logic FCR,
    // input logic [3:0] FMR,
    
    input logic [31:0] FDR,
    input logic [3:0] FPR,

    output logic [3:0] fndcomm,
    output logic [7:0] fndfont
    );

    logic [3:0] FMR;
    assign FMR = (sel == 0) ? 4'b0001 : (sel == 1)? 4'b0010 : (sel == 2) ? 4'b0100 : 4'b1000;

    genvar i;
    generate
        for(i=0;i<4;i++) begin
            assign fndcomm[i] = (FCR) ? ~FMR[i] : 1'b1;
        end
    endgenerate

   


    // 걍 assign fndcomm = ~FMR ; 하면돼
    logic [3:0] num_1,num_10,num_100,num_1000;
    assign num_1 = FDR %10;
    assign num_10 = FDR /10%10;
    assign num_100 = FDR /100%10;
    assign num_1000 = FDR /1000%10;


    logic [3:0] font;
    logic [7:0] t_fndfont;
    logic is_dot;
    // assign font = (FMR == 4'b0001) ? num_1 : (FMR == 4'b0010) ? num_10 :
    //               (FMR == 4'b0100) ? num_100 :(FMR == 4'b1000) ? num_1000 : 0;
    always_comb begin
        font = 0;
        if(FDR == 10000) begin //all
           font =  (FMR == 4'b0001) ? 13 : (FMR == 4'b0010) ? 13 :(FMR == 4'b0100) ? 12 :(FMR == 4'b1000) ? 14 : 0;  //all
        end
        else if(FDR == 20000) begin //error 
            font =  (FMR == 4'b0001) ? 11 : (FMR == 4'b0010) ? 11 :(FMR == 4'b0100) ? 10 :(FMR == 4'b1000) ? 14  : 0;  //error
        end
        else begin
            font =  (FMR == 4'b0001) ? num_1 : (FMR == 4'b0010) ? num_10 :(FMR == 4'b0100) ? num_100 :(FMR == 4'b1000) ? num_1000 : 0; 
        end
    end

    always_comb begin
        t_fndfont = 8'hff;
       
        case(font)
        0: t_fndfont = 8'hc0;
        1: t_fndfont = 8'hf9;
        2: t_fndfont = 8'ha4;
        3: t_fndfont = 8'hb0;
        4: t_fndfont = 8'h99;
        5: t_fndfont = 8'h92;
        6: t_fndfont = 8'h82;
        7: t_fndfont = 8'hf8;
        8: t_fndfont = 8'h80;
        9: t_fndfont = 8'h90;
        10:t_fndfont = 8'h86; //e
        11:t_fndfont = 8'hAF;  //r
        12:t_fndfont = 8'h88; //a
        13:t_fndfont = 8'hC7; //l
        14:t_fndfont = 8'hFF; // 다꺼짐 

        endcase
        
    end

   assign is_dot = (FMR&FPR)? 0 : 1'b1;

        assign  fndfont = {is_dot,t_fndfont[6:0]};

 //dp memory 하나 추가 c언어로 dot 포인트 지정 
endmodule

module ABP_interface_fnd #(parameter FCOUNT = 1000_00)(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,

    output logic [31:0 ]PRDATA,
    output logic PREADY,

    output logic [3:0] fndcomm,
    output logic [7:0] fndfont

    // output logic [7:0] outPort
);
    logic [31:0] slv_reg0; //fcr
    logic [31:0] slv_reg1; //fdr
    logic [31:0] slv_reg2; //fpr
    // logic [31:0] slv_reg3;
    //ff 안에서는 PREADY = 0 안해도 latch 발생 안함 
    logic c_ready, n_ready;
    //    logic [7:0] idr;

    assign PREADY = n_ready;
    // assign moder = slv_reg0[7:0];
    // assign slv_reg1 = {{24{1'b0}},idr};
 
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            slv_reg1 <= 0; // assign해서 input으로 받게 만들고선 초기화하면 안됨 
            slv_reg2 <= 0;
            // slv_reg3 <= 0;
            PRDATA <= 0;
            // PREADY <= 0;
            c_ready <= 0;
          
        end else begin
            c_ready <= n_ready;
      
            
            if(PSEL) begin
                if (PWRITE) begin
                    case (PADDR) // 0000 => 0004 => 0008 => 000C 이런식으로 움직임 [3:2]만 바뀜
                        0: slv_reg0 <= PWDATA; // idr은 inPort로 부터 오는 값이므로 core에서 건들면 안됨 
                        4: slv_reg1 <= PWDATA;
                        8: slv_reg2 <= PWDATA;
                        // 12:slv_reg3 <= PWDATA; // 주소눈 BYTE 단위인데 4바이트 짜리 데이터니까 4씩 증가함 
                        // 4'hC: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                   
                    case (PADDR)
                        0: PRDATA <= slv_reg0;
                        4: PRDATA <= slv_reg1;
                        8: PRDATA <= slv_reg2;
                        // 12:PRDATA <= slv_reg3;
                        // 4'hC: PRDATA <= slv_reg3;
                    endcase
                end
            
        end
        end
    end
    logic[1:0] sel;
    always_comb begin
        n_ready = c_ready;
        if(PENABLE && PSEL)  n_ready = 1'b1;
        else n_ready =0;
    end
    counter #(.FCOUNT(FCOUNT)) u_counter(
    .clk(PCLK),
    .reset(PRESET),

    .sel(sel)

);
 fnd_ip ip_fnd(
    .FCR(slv_reg0[0]),
    // .FMR(slv_reg1[3:0]),
    .FDR(slv_reg1),
    .FPR(slv_reg2[3:0]),
    .sel(sel),

    .fndcomm(fndcomm),
    .fndfont(fndfont)
    );

endmodule

module counter #(parameter FCOUNT = 1000_00, BIT_SIZE = $clog2(FCOUNT)) (
    input logic clk,
    input logic reset,

    output logic [1:0] sel

);
    logic [BIT_SIZE-1:0] counter;
    
  always_ff @(posedge clk, posedge reset) begin
    if(reset) begin 
        sel <= 0;
        counter <= 0;
    end
    else begin
        if(counter == FCOUNT -1) begin
            sel <= sel + 1;
            counter <= 0;
        end
        else counter <= counter + 1;
    end
  end

  
endmodule