`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/21 14:08:02
// Design Name: 
// Module Name: GPI
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

module GPIO (
    input logic [7:0] moder, //코어에서 받는입장 input
    output logic [7:0] idr, // 코어로 보내야하는 입장 output read만 가능능
    input logic [7:0] odr, //outport로 보내야하니까 master로부터 받아야지 받는입장 master로 데이터 줄일 없음 c언어 보셈 

    inout logic [7:0] inoutPort
    // output logic [7:0] outPort
    
);
    genvar i;
    generate
        for(i=0; i<8; i++) begin
            assign idr[i] = ~moder[i]? inoutPort[i] : 1'bz;
            assign inoutPort[i] = moder[i]? odr[i] : 1'bz; // inital begin 아니니깐 assign해야함  // 2개의 3state_buffer 만듬 
        end
    endgenerate
endmodule


module GPI (
    input logic [7:0] moder, //core 에서 받아오는거임 / ram 활용용
    output logic [7:0] idr, // inport 값 활용 

    input logic [7:0] inPort
);

// assign outPort[0] = moder[0] ? odr[0] : 1'bz;
// assign outPort[1] = moder[1] ? odr[1] : 1'bz;
// assign outPort[2] = moder[2] ? odr[2] : 1'bz;
// assign outPort[3] = moder[3] ? odr[3] : 1'bz;
// assign outPort[4] = moder[4] ? odr[4] : 1'bz;
// assign outPort[5] = moder[5] ? odr[5] : 1'bz;
// assign outPort[6] = moder[6] ? odr[6] : 1'bz;
// assign outPort[7] = moder[7] ? odr[7] : 1'bz;

genvar i;
generate
    for(i=0; i<8; i++) begin
        assign idr[i] = ~moder[i]? inPort[i]:1'bz;
    end
    
endgenerate
endmodule

module ABP_interface_GPIO (
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,

    output logic [31:0 ]PRDATA,
    output logic PREADY,

    inout logic [7:0] inoutPort
    // output logic [7:0] outPort
);
    logic [31:0] slv_reg0;
    logic [31:0] slv_reg1;
    logic [31:0] slv_reg2;
    logic [31:0] slv_reg3;
    //ff 안에서는 PREADY = 0 안해도 latch 발생 안함 
    logic c_ready, n_ready;
       logic [7:0] idr;

    assign PREADY = n_ready;
    // assign moder = slv_reg0[7:0];
    assign slv_reg1 = {{24{1'b0}},idr};
 
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            slv_reg0 <= 0;
            // slv_reg1 <= 0; // assign해서 input으로 받게 만들고선 초기화하면 안됨 
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
                        // 4: slv_reg1 <= PWDATA;
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

GPIO u_GPIO(
    .moder(slv_reg0[7:0]), //코어에서
    .idr(idr), // 코어로 보내기기 // extend 해야됨 
    .odr(slv_reg2[7:0]), //outport로 

    .inoutPort(inoutPort)
    // .outPort(outPort)
    
);


endmodule

// module ABP_interface_GPO (
//     input logic PCLK,
//     input logic PRESET,

//     input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
//     input logic [31:0] PWDATA,
//     input logic PWRITE,
//     input logic PENABLE,
//     input logic PSEL,

//     output logic [31:0 ]PRDATA,
//     output logic PREADY,

//     output logic [7:0] outPort
// );
//     logic [31:0] slv_reg0;
//     logic [31:0] slv_reg1;
//     logic [31:0] slv_reg2;
//     logic [31:0] slv_reg3;
//     //ff 안에서는 PREADY = 0 안해도 latch 발생 안함 
//     logic c_ready, n_ready;

//     assign PREADY = n_ready;
 
//     always_ff @(posedge PCLK, posedge PRESET) begin
//         if (PRESET) begin
//             slv_reg0 <= 0;
//             slv_reg1 <= 0;
//             slv_reg2 <= 0;
//             slv_reg3 <= 0;
//             PRDATA <= 0;
//             // PREADY <= 0;
//             c_ready <= 0;
          
//         end else begin
//             c_ready <= n_ready;
      
            
//             if(PSEL) begin
//                 if (PWRITE) begin
//                     case (PADDR) // 0000 => 0004 => 0008 => 000C 이런식으로 움직임 [3:2]만 바뀜
//                         0: slv_reg0 <= PWDATA; // moder
//                         4: slv_reg1 <= PWDATA; // odr
//                         // 8: slv_reg2 <= PWDATA;
//                         // 4'hC: slv_reg3 <= PWDATA;
//                     endcase
//                 end else begin
                   
//                     case (PADDR)
//                         0: PRDATA <= slv_reg0;
//                         4: PRDATA <= slv_reg1;
//                         // 8: PRDATA <= slv_reg2;
//                         // 4'hC: PRDATA <= slv_reg3;
//                     endcase
//                 end
            
//         end
//         end
//     end

//     always_comb begin
//         n_ready = c_ready;
//         if(PENABLE && PSEL)  n_ready = 1'b1;
//         else n_ready =0;
//     end
// GPO GPO_A (
//     .moder(slv_reg0[7:0]),
//     .odr(slv_reg1[7:0]),

//     .outPort(outPort)
// );
// endmodule


// module GPO (
//     input logic [7:0] moder,
//     input logic [7:0] odr,

//     output logic [7:0] outPort
// );

// // assign outPort[0] = moder[0] ? odr[0] : 1'bz;
// // assign outPort[1] = moder[1] ? odr[1] : 1'bz;
// // assign outPort[2] = moder[2] ? odr[2] : 1'bz;
// // assign outPort[3] = moder[3] ? odr[3] : 1'bz;
// // assign outPort[4] = moder[4] ? odr[4] : 1'bz;
// // assign outPort[5] = moder[5] ? odr[5] : 1'bz;
// // assign outPort[6] = moder[6] ? odr[6] : 1'bz;
// // assign outPort[7] = moder[7] ? odr[7] : 1'bz;

// genvar i;
// generate
//     for(i=0; i<8; i++) begin
//         assign outPort[i] = moder[i]? odr[i]:1'bz;
//     end
    
// endgenerate

// // genvar : 실제 hw

// // always_comb begin
// //     for(int i =0; i<8; i++) begin
// //         outPort = moder[i]? odr[i]:1'bz;
// //     end
// // end


// endmodule
