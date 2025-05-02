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

module APB_interface_SR04(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE, //access 
    input logic PSEL, // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    output logic [31:0]PRDATA,
    output logic PREADY,

    input logic echo,
    output logic start_trigger
  
 
    
    );

    logic [31:0] slv_reg0; // start_trigger
    logic [31:0] slv_reg1; // data //read만 
    // logic [31:0] slv_reg2; // is_done, checksum //read 
    logic c_ready, n_ready;
    


    logic [8:0] distance;
    


  // check sum 제외 

    assign PREADY = n_ready; // n쓰면 한클럭 지연 사라짐 ff처럼 지연안함 
    // assign slv_reg0 = {{31{1'b0}},start_trigger};
    assign slv_reg1 = {{23{1'b0}},distance};
    // assign slv_reg2 = {{31{1'b0}},checksum}; // 비트수 맞추기 

    assign trigger = slv_reg0[0];

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
                    4'h0:  PRDATA <=slv_reg0; //start trigger
                    4'h4:  PRDATA <=slv_reg1; // distance
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
    us_control #(.TICK_COUNT(400*58), .DISTANCE_RANGE(400)) SR04 // 거리 cm 단위 
    (
        .clk(PCLK),
        .reset(PRESET),
        .SR04_data(echo),
        .btn_start(slv_reg0[0]),
       
    
        .start_trigger(start_trigger),
        .distance(distance) //9비트임
        // .measure_done,
        // .is_measure
       
        
    
        );


    //fifo read 에서는 바로 다음 ptr로 옮기기 때문에 slv_reg0가 다음껄 가리킴  

endmodule


