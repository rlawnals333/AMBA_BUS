`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/27 17:51:54
// Design Name: 
// Module Name: APB_interface_fifo
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


module APB_interface_fifo_uart_tx(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE, //access 
    input logic PSEL, // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    output logic [31:0 ]PRDATA,
    output logic PREADY,

    output logic tx_out

    
    );

    logic [31:0] slv_reg0; // empty / full // 2bit 1st full 2nd empty
    logic [31:0] slv_reg1; // wdata
    logic [31:0] slv_reg2; // rdata 
    logic [31:0] slv_reg3; //uart start_trigger fifo 관련 없음 

    logic c_ready, n_ready;
    logic full,empty;
    logic [7:0] rData;
    logic rd_en, wr_en;

    assign PREADY = n_ready; // n쓰면 한클럭 지연 사라짐 ff처럼 지연안함 
    assign slv_reg0 = {{30{1'b0}},full,empty};
    assign slv_reg2 = {{24{1'b0}},rData}; // 비트수 맞추기 
    assign wr_en = ((PSEL&PENABLE)&PWRITE) && (PADDR == 4'h4) ? 1'b1 : 0; //slv1에만 반응 안그러면 start trigger마다 wr_en 진행해서 full상태됨 
    assign rd_en = (((PSEL & PENABLE)&~PWRITE) && (PADDR == 4'h8)) ? 1'b1 : 0; // slv2에서만 반응하게
    
    always_ff@(posedge PCLK, posedge PRESET) begin
        if(PRESET) begin
        // slv_reg0 <= 0;
        slv_reg1 <= 0;
        slv_reg3 <= 0;
        // slv_reg2 <= 0; // read용은 초기화 ㄴㄴ 
        PRDATA <= 0;
        c_ready <= 0;
        end
        else begin
            c_ready <= n_ready;
            if(PSEL) begin // 여기 하고싶을 때만 활성화 
                if(PWRITE) begin //set up 때 저장 
                    case(PADDR)
                    // 4'h0: slv_reg0 <= PWDATA; //ff라서 access때 저장됨 write 하면 안됨 
                    4'h4: slv_reg1 <= PWDATA;
                    4'hC: slv_reg3 <= PWDATA;
                    // 4'h8: slv_reg2 <= PWDATA; // 이미 assign 해놨는데 갑자기 PWRITE 끼얹으면 error 
                    endcase
                end  // tick 
                else begin
                    case(PADDR)
                    4'h0:  PRDATA <=slv_reg0;
                    4'h4:  PRDATA <=slv_reg1; //ff이기때문에 1clk delay 계속유지 // fifo가 rd_en 후에 xxx 가 나와도 slv는 ff으로 캡쳐하고 있음 넘어가기 전에 넘어가는건 IDLE 일떄 
                    4'h8:  PRDATA <=slv_reg2;
                    4'hC:  PRDATA <=slv_reg3;
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
    fifo u_fifo_tx(
    .clk(PCLK),
    .reset(PRESET),
    .rData(rData),
    .wData(slv_reg1[7:0]), 
    .wr_en(wr_en), //access때 발생 //한틱일듯> 
    .rd_en(rd_en),//access때 원하는 rdata값 나가고 IDLE일때 ptr 1 올름   // @@@  실수하면 slv0 읽을 떄도 반응하네 시팔 
    .full(full),
    .empty(empty)
    );

    uart_tx u_uart_tx (
    .clk(PCLK),
    .reset(PRESET),
    .tx_in(PRDATA[7:0]), //일단 먼저 넣고  tx값만 넣는거임 
    .start_trigger(slv_reg3[0]),

    .tx_out(tx_out),
    .tx_busy(),
    .tx_done()
);

    //fifo read 에서는 바로 다음 ptr로 옮기기 때문에 slv_reg0가 다음껄 가리킴  

endmodule

module APB_interface_fifo_uart_rx(
    input logic PCLK,
    input logic PRESET,

    input logic [3:0] PADDR,  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE, //access 
    input logic PSEL, // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    output logic [31:0 ]PRDATA,
    output logic PREADY,
    

    input logic rx_in

    
    );

    logic [31:0] slv_reg0; // empty / full // 2bit 1st full 2nd empty
    logic [31:0] slv_reg1; // wdata
    logic [31:0] slv_reg2; // rdata 


    logic c_ready, n_ready;
    logic full,empty;
    logic [7:0] rData;
    logic [7:0] rx_out;
    logic rx_done;
    logic rd_en;




    assign PREADY = n_ready; // n쓰면 한클럭 지연 사라짐 ff처럼 지연안함 
    assign slv_reg0 = {{30{1'b0}},full,empty};
    assign slv_reg2 = {{24{1'b0}},rData}; // 비트수 맞추기 


    assign rd_en = (((PSEL & PENABLE)&~PWRITE) && (PADDR == 4'h8)) ? 1'b1 : 0; // slv2에서만 반응하게
    
    always_ff@(posedge PCLK, posedge PRESET) begin
        if(PRESET) begin
        // slv_reg0 <= 0;
        slv_reg1 <= 0;
     
        // slv_reg2 <= 0; // read용은 초기화 ㄴㄴ 
        PRDATA <= 0;
        c_ready <= 0;
        end
        else begin
            c_ready <= n_ready;
            if(PSEL) begin // 여기 하고싶을 때만 활성화 
                if(PWRITE) begin //set up 때 저장 
                    case(PADDR)
                    // 4'h0: slv_reg0 <= PWDATA; //ff라서 access때 저장됨 write 하면 안됨 
                    4'h4: slv_reg1 <= PWDATA;
     
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
    fifo u_fifo_rx(
    .clk(PCLK),
    .reset(PRESET),
    .rData(rData),
    .wData(rx_out), 
    .wr_en(rx_done), //access때 발생 //한틱일듯> 
    .rd_en(rd_en),//access때 원하는 rdata값 나가고 IDLE일때 ptr 1 올름   // @@@  실수하면 slv0 읽을 떄도 반응하네 시팔 
    .full(full),
    .empty(empty)
    );

 uart_rx u_uart_rx (
    .clk(PCLK),
    .reset(PRESET),
    .rx_in(rx_in),


    .rx_out(rx_out),
    .rx_busy(),
    .rx_done(rx_done)

);

endmodule