`timescale 1ns / 1ps

module MCU (
    input logic clk,
    input logic reset,

    inout logic [7:0] GPIOA_INOUTPORT, GPIOB_INOUTPORT,  GPIOC_INOUTPORT, GPIOD_INOUTPORT,
    inout logic dht_io,
    output logic [3:0] fndcomm,
    output logic [7:0] fndfont // 밖으로 나가는 port 
    // output logic [7:0] GPIO_OUTPORT
);

       parameter FCOUNT = 1000_00 ; // display hz 조절 시뮬 or 실제 1khz
    //    parameter COUNTER = 1000_00; // timer
       
    logic [31:0] instrCode;
    logic [31:0] instrMemAddr;
    
    // logic data_we;
    logic [31:0] dataWdata, data_Addr,ram_rData;
    logic memaccess_en, writeback_en;

    logic transfer,ready;
    // wire w_btn0,w_btn1,w_btn2,w_btn3;

//  btn_debounce#(.COUNT(100_000)) deb0(
//     .clk(clk),
//     .reset(reset),
//     .btn(GPIOA_INOUTPORT[0]),

//     .btn_debo(w_btn0)
    

//     );

//      btn_debounce#(.COUNT(100_000))deb1(
//     .clk(clk),
//     .reset(reset),
//     .btn(GPIOA_INOUTPORT[1]),

//     .btn_debo(w_btn1)
    

//     );
//      btn_debounce#(.COUNT(100_000))deb2(
//     .clk(clk),
//     .reset(reset),
//     .btn(GPIOA_INOUTPORT[2]),

//     .btn_debo(w_btn2)
    

//     );
//      btn_debounce#(.COUNT(100_000)) deb3(
//     .clk(clk),
//     .reset(reset),
//     .btn(GPIOA_INOUTPORT[3]),

//     .btn_debo(w_btn3)
    

    // );
    

    RV32I_Core U_Core (.*);

    rom U_ROM (
        .addr(instrMemAddr),
        .data(instrCode)
    );

    logic PSEL_RAM, PREADY_RAM, PENABLE, PWRITE,
     PREADY1, PSEL1,
     PREADY2, PSEL2,
     PREADY3, PSEL3, 
     PREADY4, PSEL4,
     PREADY5, PSEL5,
     PREADY6, PSEL6,
     PREADY7, PSEL7;
     
    logic [31:0] PRDATA_RAM,PRDATA1,PRDATA2,PRDATA3,PRDATA4,PRDATA5,PRDATA6,PRDATA7;
    logic [31:0] PADDR,PWDATA;
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

//  ABP_interface_GPO GPO_A(
//     .*,
//     .PCLK(clk),
//     .PRESET(reset),


//     .PSEL(PSEL1),

//     .PRDATA(PRDATA1),
//     .PREADY(PREADY1),

//     .outPort(GPOA_PORT)

// );

//  ABP_interface_GPI GPI_B(
//     .*,
//     .PCLK(clk),
//     .PRESET(reset),


//     .PSEL(PSEL2),

//     .PRDATA(PRDATA2),
//     .PREADY(PREADY2),

//     .inPort(GPIB_PORT)

// );

// ABP_interface_GPIO u_GPIOA_INTF (
//     .PCLK(clk),
//     .PRESET(reset),

//     .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
//     .PWDATA(PWDATA),
//     .PWRITE(PWRITE),
//     .PENABLE(PENABLE),
//     .PSEL(PSEL1),

//     .PRDATA(PRDATA1),
//     .PREADY(PREADY1),

//     .inoutPort(GPIOA_INOUTPORT)
//     // .outPort(GPIO_OUTPORT)
// );

ABP_interface_GPIO u_GPIOA_INTF (
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL1), // 0x10001000번지 부터 

    .PRDATA(PRDATA1),
    .PREADY(PREADY1),

    .inoutPort(GPIOA_INOUTPORT)
    // .outPort(GPIO_OUTPORT)
);

ABP_interface_GPIO u_GPIOB_INTF (
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL2),

    .PRDATA(PRDATA2),
    .PREADY(PREADY2),

    .inoutPort(GPIOB_INOUTPORT)
    // .outPort(GPIO_OUTPORT)
);

ABP_interface_GPIO u_GPIOC_INTF (
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL3),

    .PRDATA(PRDATA3),
    .PREADY(PREADY3),

    .inoutPort(GPIOC_INOUTPORT)
    // .outPort(GPIO_OUTPORT)
);

// ABP_interface_GPIO u_GPIOD_INTF (
//     .PCLK(clk),
//     .PRESET(reset),

//     .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
//     .PWDATA(PWDATA),
//     .PWRITE(PWRITE),
//     .PENABLE(PENABLE),
//     .PSEL(PSEL4),

//     .PRDATA(PRDATA4),
//     .PREADY(PREADY4),

//     .inoutPort(GPIOD_INOUTPORT)
//     // .outPort(GPIO_OUTPORT)
// );

 ABP_interface_fnd u_fnd (
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL5),

    .PRDATA(PRDATA5),
    .PREADY(PREADY5),

    .fndcomm(fndcomm),
    .fndfont(fndfont)
    // output logic [7:0] outPort
);

 APB_interface_fifo u_fifo(
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL6),

    .PRDATA(PRDATA6),
    .PREADY(PREADY6)
    
    );


ABP_interface_timer u_timer(
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL7),

    .PRDATA(PRDATA7),
    .PREADY(PREADY7)
);


//     // output logic [7:0] outPort


 APB_interface_dht11 u_dht11(
    .PCLK(clk),
    .PRESET(reset),
    .PADDR(PADDR),  
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),
    .PENABLE(PENABLE),
    .PSEL(PSEL4),

    .PRDATA(PRDATA4),
    .PREADY(PREADY4),

    .dht_io(dht_io)
    
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
    .PSEL3(PSEL3),
    .PSEL4(PSEL4),
    .PSEL5(PSEL5),
    .PSEL6(PSEL6),
    .PSEL7(PSEL7),
    // peri 한개당 1개씩 추가
    .PENABLE(PENABLE),
    .PWDATA(PWDATA),
    .PWRITE(PWRITE),  // write or read

    .PRDATA0(PRDATA_RAM),
    .PRDATA1(PRDATA1),
    .PRDATA2(PRDATA2),
    .PRDATA3(PRDATA3),
    .PRDATA4(PRDATA4),
    .PRDATA5(PRDATA5),
    .PRDATA6(PRDATA6),
    .PRDATA7(PRDATA7),
    // peri 한개당 1개씩 추가
    .PREADY0(PREADY_RAM),
    .PREADY1(PREADY1),
    .PREADY2(PREADY2),
    .PREADY3(PREADY3),
    .PREADY4(PREADY4),
    .PREADY5(PREADY5),
    .PREADY6(PREADY6),
    .PREADY7(PREADY7),// peri 한개당 1개씩 추가 (HRDATA에 같이 들어옴)

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