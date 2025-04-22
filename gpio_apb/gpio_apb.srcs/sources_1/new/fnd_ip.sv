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


module fnd_ip(
    input logic FCR,
    input logic [3:0] FMR,
    input logic [3:0] FDR,

    output logic [3:0] fndcomm,
    output logic [7:0] fndfont
    );

    genvar i;
    generate
        for(i=0;i<4;i++) begin
            assign fndcomm[i] = ~FMR[i];
        end
    endgenerate

    // 걍 assign fndcomm = ~FMR ; 하면돼
    
    always_comb begin
        fndfont = 8'hff;
        if(FCR) begin
        case(FDR)
        0: fndfont = 8'hc0;
        1: fndfont = 8'hf9;
        2: fndfont = 8'ha4;
        3: fndfont = 8'hb0;
        4: fndfont = 8'h99;
        5: fndfont = 8'h92;
        6: fndfont = 8'h82;
        7: fndfont = 8'hf8;
        8: fndfont = 8'h80;
        9: fndfont = 8'h90;
        endcase
        end
        else fndfont = 8'hff;
    end

endmodule

module ABP_interface_fnd (
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
    logic [31:0] slv_reg0;
    logic [31:0] slv_reg1;
    logic [31:0] slv_reg2;
    logic [31:0] slv_reg3;
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
                        // 4'hC: slv_reg3 <= PWDATA;
                    endcase
                end else begin
                   
                    case (PADDR)
                        0: PRDATA <= slv_reg0;
                        4: PRDATA <= slv_reg1;
                        8: PRDATA <= slv_reg2;
                        // 4'hC: PRDATA <= slv_reg3;
                    endcase
                end
            
        end
        end
    end

    always_comb begin
        n_ready = c_ready;
        if(PENABLE && PSEL)  n_ready = 1'b1;
        else n_ready =0;
    end
 fnd_ip ip_fnd(
    .FCR(slv_reg0[0]),
    .FMR(slv_reg1[3:0]),
    .FDR(slv_reg2[3:0]),

    .fndcomm(fndcomm),
    .fndfont(fndfont)
    );

endmodule
