`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset,

    output logic [7:0] GPOA_PORT, // 밖으로 나가는 port 
    input logic [7:0] GPIB_PORT
);
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    
    // logic data_we;
    logic [31:0] dataWdata, data_Addr,ram_rData;
    logic memaccess_en, writeback_en;

    logic transfer,ready;


    RV32I_Core U_Core (.*);

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    logic PSEL_RAM, PREADY_RAM, PENABLE, PWRITE, PREADY1, PSEL1, PREADY2, PSEL2;
    logic [31:0] PRDATA_RAM,PRDATA1,PRDATA2, PWDATA;
    logic [31:0] PADDR;
    logic write_en;
    assign write_en = (memaccess_en == 1'b1) ? 1'b1 : (writeback_en == 1'b1) ? 0 : 0;
 ram u_ram(//이제 cpu 말고 bus랑 놀아야됨 
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL_RAM),

    .PRDATA(PRDATA_RAM),
    .PREADY(PREADY_RAM)
 );

 GPO_peri GPO_A(
    .PCLK(clk),
    .PRESET(reset),


    .PSEL(PSEL1),

    .PRDATA(PRDATA1),
    .PREADY(PREADY1),

    .outPort(GPOA_PORT)

);

 GPI_peri GPI_B(
    .PCLK(clk),
    .PRESET(reset),


    .PSEL(PSEL2),

    .PRDATA(PRDATA2),
    .PREADY(PREADY2),

    .inPort(GPIB_PORT)

);

//   ABP_Slave u_slave(//이제 cpu 말고 bus랑 놀아야됨 
//     .PCLK(clk),
//     .PRESET(reset),

//     .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
//     .PWDATA(PWDATA),
//     .PWRITE(PWRITE),
//     .PENABLE(PENABLE),
//     .PSEL(PSEL1),

//     .PRDATA(PRDATA1),
//     .PREADY(PREADY1)
//  );

    APB_master U_APB_MASTER (
    //global signal
    .PCLK(clk),
    .PRESET(reset),
    //APB INERFACE SIGNALs
    .PADDR(PADDR),

    .PSEL0(PSEL_RAM),
    .PSEL1(PSEL1),
    .PSEL2(PSEL2),
    .PSEL3(),
    // peri 한개당 1개씩 추가
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),  // write or read

    .PRDATA0(PRDATA_RAM),
    .PRDATA1(PRDATA1),
    .PRDATA2(PREADY2),
    .PRDATA3(),
    // peri 한개당 1개씩 추가
    .PREADY0(PREADY_RAM),
    .PREADY1(PREADY1),
    .PREADY2(PREADY2),
    .PREADY3(),// peri 한개당 1개씩 추가 (HRDATA에 같이 들어옴)

    //interface with cpu core(Internal interface signal)
    .transfer(transfer),  // 시작 알리기(trigger)
    .ready(ready), // peri 동작 완료 (전부 완료해야함/ PREADY 전부 완료시)
    .addr(data_Addr),
    .wdata(dataWdata),
    .rdata(ram_rData),
    .write(write_en)  // 1:write 0: read


);


endmodule

//c_compiler에 맞춰서 만드는 중 
// 항상 4의 배수로 줌 addr 를 