`timescale 1ns / 1ps
///
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/18 12:20:21
// Design Name: 
// Module Name: APB_master
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
//inout MODE 0: 읽기 1 쓰기 
//쓰기 -> 읽기 반복?  합쳐보자 

module APB_master (
    //global signal
    input logic PCLK,
    input logic PRESET,
    //APB INERFACE SIGNALs
    output logic [31:0] PADDR,

    output logic PSEL0,
    output logic PSEL1,
    output logic PSEL2,
    output logic PSEL3,
    // peri 한개당 1개씩 추가
    output logic PENABLE,
    output logic [31:0] PWDATA,
    output logic PWRITE,  // write or read

    input logic [31:0] PRDATA0,
    input logic [31:0] PRDATA1,
    input logic [31:0] PRDATA2,
    input logic [31:0] PRDATA3,
    // peri 한개당 1개씩 추가
    input logic PREADY0,
    input logic PREADY1,
    input logic PREADY2,
    input  logic PREADY3,// peri 한개당 1개씩 추가 (HRDATA에 같이 들어옴)

    //interface with cpu core(Internal interface signal)
    input logic transfer,  // 시작 알리기(trigger)
    output logic ready, // peri 동작 완료 (전부 완료해야함/ PREADY 전부 완료시)
    input logic [31:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata,
    input logic write  // 1:write 0: read


);

    typedef enum bit [1:0] {
        IDLE   = 0,
        SETUP,
        ACCESS
    } apb_state_e;
    apb_state_e current_state, next_state;

    logic temp_write_next, temp_write_reg;
    logic [31:0] temp_addr_next, temp_wdata_next, temp_addr_reg, temp_wdata_reg;

    logic decoder_en;
    logic [3:0] pselx;


    assign PSEL0 = pselx[0];
    assign PSEL1 = pselx[1];
    assign PSEL2 = pselx[2];
    assign PSEL3 = pselx[3];  // peri마다 연결 


    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            current_state  <= IDLE;
            temp_addr_reg  <= 0;
            temp_wdata_reg <= 0;
            temp_write_reg <= 0;
        end else begin
            current_state  <= next_state;
            temp_addr_reg  <= temp_addr_next;
            temp_wdata_reg <= temp_wdata_next;
            temp_write_reg <= temp_write_next;

        end
    end

    always_comb begin  //SEL가 high일때 특정 IP 선택  // 선택되면 high / 아니면 low 
        temp_addr_next = temp_addr_reg;
        temp_wdata_next = temp_wdata_reg;
        temp_write_next = temp_write_reg;
        next_state = current_state;
        PADDR = 0;
        PWDATA = 0;
        PWRITE = 0;
        // PSEL1 = 0;
        decoder_en = 0;
        PENABLE = 0;
        case (current_state)
            IDLE: begin
                // PSEL1 = 0;
                decoder_en = 0;  // 아무 선택 안함 
                if (transfer) begin
                    next_state = SETUP;
                    temp_addr_next = addr;
                    temp_wdata_next = wdata;
                    temp_write_next = write;
                end
            end
            SETUP: begin
                PADDR = temp_addr_reg;
                PENABLE = 0;
                // PSEL1 = 1'b1;
                decoder_en = 1'b1;  // 이따 바꿀거임 
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 0;
                end
                next_state = ACCESS;
            end

            ACCESS: begin
                decoder_en = 1'b1;
                PADDR = temp_addr_reg;  // addrm wdata는 계속 유지 
                PENABLE = 1'b1;
                if (temp_write_reg) begin
                    PWRITE = 1'b1;
                    PWDATA = temp_wdata_reg;
                end else begin
                    PWRITE = 0;  //rdata는 계속 내보내고 있는게 아니라 순간 캡쳐 
                end
                if (ready) begin
                    next_state = IDLE;
                end
            end
        endcase
        //ready를 한클럭만?? 한클럭많에에manager  
    end

    APB_Decoder decoder_abp (
        .en (decoder_en),
        .sel(temp_addr_reg), //address

        .y(pselx)
    );

    APB_Mux mux_abp (
        .sel(temp_addr_reg),  // address = decoder와 같은 거임
        .d0(PRDATA0),
        .d1(PRDATA1),
        .d2(PRDATA2),
        .d3(PRDATA3),
        .r0(PREADY0),
        .r1(PREADY1),
        .r2(PREADY2),
        .r3(PREADY3),  //ready

        .rdata(rdata),  //to cpu
        .ready(ready)   // 다 ready되면 활성화 


    );

endmodule

module APB_Decoder (  // selector memory mapping
    input logic en,
    input logic [31:0] sel,  //address

    output logic [3:0] y  //비트수 조정  //sel
);
    always_comb begin
        y = 0;
        if (en) begin
            case (sel[15:12]) // 얘는 메모리 맵에 따라 변경 
                4'h0: y = 4'b0001;  //ram
                4'h1: y = 4'b0010;  // peri1
                4'h2: y = 4'b0100;  // peri2
                4'h3: y = 4'b1000;  //peri3 
                // 20'h1000_
                // 20'h1000_
                // 20'h1000_
                // 20'h1000_
                //rom은 따로 
                // 32'h1000_0000 ~ 32'h1000_0fff; : y= 4'b0001;
                // 32'h1000_1000 ~ 32'h1000_1fff; : y= 4'b0010;
                // 32'h1000_2000 ~ 32'h1000_2fff; : y= 4'b0100;
            endcase
        end
    end

endmodule


module APB_Mux (  //read date 보내고 ready신호 
    input logic [31:0] sel,  // address = decoder와 같은 거임
    input logic [31:0] d0,
    input logic [31:0] d1,
    input logic [31:0] d2,
    input logic [31:0] d3,
    input logic r0,
    input logic r1,
    input logic r2,
    input logic r3,  //ready

    output logic [31:0] rdata,
    output logic        ready   // 다 ready되면 활성화 

    // ready register 필요?  저장하게 

);
    always_comb begin
        rdata = 0;
        case (sel[15:12]) //31:12
            4'h0: rdata = d0;  //ram
            4'h1: rdata = d1;  // peri1
            4'h2: rdata = d2;  // peri2
            4'h3: rdata = d3;  //peri3 
            //20'h1000_1

        endcase
    end

    always_comb begin
        ready = 0;
        case (sel[15:12])
            4'h0: ready = r0;  //ram
            4'h1: ready = r1;  // peri1
            4'h2: ready = r2;  // peri2
            4'h3: ready = r3;  //peri3 

        endcase
    end
    //ready 한클럭?? 

endmodule

// rom 0x0000_0FFF ~ 0x0000_0000 

//reserved => 사용안하는 부분 

//ram: 0x1000_0000 ~ 0x1000_0FFF

//p1 : 0x1000_1000 ~ 0x1000_1FFF;
//p2 : 0x1000_2000 ~ 0x1000_2FFF;
//~~

