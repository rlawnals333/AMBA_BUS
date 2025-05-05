`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/28 17:28:55
// Design Name: 
// Module Name: APB_dht11
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

module APB_interface_dht11(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE, //access 
    input logic PSEL, // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    output logic [31:0]PRDATA,
    output logic PREADY,

    inout logic dht_io
  
 
    
    );

    logic [31:0] slv_reg0; // start_trigger
    logic [31:0] slv_reg1; // data //read만 
    logic [31:0] slv_reg2; // is_done, checksum //read 
    logic c_ready, n_ready;
    logic [39:0] data_out;


    logic checksum;
    // logic start_trigger;


  // check sum 제외 

    assign PREADY = n_ready; // n쓰면 한클럭 지연 사라짐 ff처럼 지연안함 
    // assign slv_reg0 = {{31{1'b0}},start_trigger};
    assign slv_reg1 = data_out[39:8];
    assign slv_reg2 = {{31{1'b0}},checksum}; // 비트수 맞추기 

    // assign trigger = slv_reg0[0];

    // assign rd_en = (((PSEL & PENABLE)&~PWRITE) && (PADDR == 4'h8)) ? 1'b1 : 0; // slv2에서만 반응하게
    
    always_ff@(posedge PCLK, posedge PRESET) begin
        if(PRESET) begin
        slv_reg0 <= 0;
        // slv_reg1 <= 0;
        // slv_reg2 <= 0; // read용은 초기화 ㄴㄴ 
        PRDATA <= 0;
        c_ready <= 0;
        end
        else begin
            c_ready <= n_ready;
            if(PSEL) begin // 여기 하고싶을 때만 활성화 
                if(PWRITE) begin //set up 때 저장 
                    case(PADDR)
                    4'h0: slv_reg0 <= PWDATA; //ff라서 access때 저장됨 write 하면 안됨 
                    // 4'h4: slv_reg1 <= PWDATA;
                    // 4'h8: slv_reg2 <= PWDATA; // 이미 assign 해놨는데 갑자기 PWRITE 끼얹으면 error 
                    endcase
                end  // tick 
                else begin
                    case(PADDR)
                    4'h0:  PRDATA <=slv_reg0;
                    4'h4:  PRDATA <=slv_reg1; //ff이기때문에 1clk delay 계속유지 // fifo가 rd_en 후에 xxx 가 나와도 slv는 ff으로 캡쳐하고 있음 넘어가기 전에 넘어가는건 IDLE 일떄 
                    4'h8:  PRDATA <=slv_reg2;
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
    //access 단계에서 master에서 정보를 취합함 이때 내보내야함 rdata, wdata를 
    top_dht11  u_dht11(
    .clk(PCLK),
    .reset(PRESET),
    .start_trigger(slv_reg0[0]),
    // input [2:0] sw_mode,

    .dht_io(dht_io),

    // output [2:0] led_state,
    .led(),
    .fsm_state(fsm_state),
    .data_out(data_out),
    .is_done(),
    .checksum(checksum)
    // output [39:0] dht11_data, 비트스트림위해해

    // The 8bit humidity integer data + 8bit the Humidity decimal data +8 bit temperature integer data +
// 8bit fractional temperature data +8 bit parity bit


);


    //fifo read 에서는 바로 다음 ptr로 옮기기 때문에 slv_reg0가 다음껄 가리킴  

endmodule


