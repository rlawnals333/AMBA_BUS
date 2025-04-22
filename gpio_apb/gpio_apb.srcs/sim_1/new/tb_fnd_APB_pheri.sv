`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/22 15:23:34
// Design Name: 
// Module Name: tb_fnd_APB_pheri
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

class transaction;  // 캡슐화

    //apb interface signal_fnd
    //slave임 
    

    rand logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
    rand logic [31:0] PWDATA;
    rand logic PWRITE;

    rand logic PENABLE;
    rand logic PSEL;

    logic [31:0] PRDATA;
    logic PREADY;

    logic [3:0] fndcomm;  // dut out
    logic [7:0] fndfont;  //dut out  => out은 렌덤으로 ㄴㄴㄴㄴ 

    constraint c_paddr {PADDR inside {4'h0,4'h4,4'h8};} // random 생성시 제약사항 괄호중에서만 랜덤 
    constraint c_wdata {PWDATA < 10;}
    task display(string name);

        $display(
            "[%s] PADDR = %h, PWADATA=%h, PWRITE = %h,PENABLE=%h, PSEL = %h, PRDATA = %h,PREADY = %h, fndcom=%h, fmdfont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            fndcomm, fndfont);

    endtask

endclass



interface APB_Slave_Interface;

    logic PCLK;  //slave임 
    logic PRESET;

    logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
    logic [31:0] PWDATA;
    logic PWRITE;

    logic PENABLE;
    logic PSEL;

    logic [31:0] PRDATA;
    logic PREADY;

    logic [3:0] fndcomm;  // dut out
    logic [7:0] fndfont;  // dut의 입출력값 받아야한다 
endinterface

class generator;  //transaction class를 담을 수 있음(주소값)
    mailbox #(transaction) Gen2Drv_mbox; //: 멤버임 system verilog 고유 기능 / reference를 담을 수 있는 변수 
    event gen_next_event;

    function new(
        mailbox#(transaction) Gen2Drv_mbox, event gen_next_event
    );  //instance화 실체화 / 이거 안하면 사용불가 
        this.Gen2Drv_mbox   = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        transaction fnd_tr;  //handler 객체만듬
        repeat (repeat_counter) begin
            fnd_tr = new(); // instance화 // ranom한 변수들 생성 repeat 만큼
            if (!fnd_tr.randomize()) $error("Randomize fail!");
            fnd_tr.display("GEN");  //randomize에 문제가 발생하면 
            Gen2Drv_mbox.put(fnd_tr);  // 고유 기능 
            @(gen_next_event); //wait a event from driver /event는 generator감시//계속해서 안만들고 driver에서 처리한 후 generator에서 만들게 하고 싶음 순차적으로
        end
    endtask
endclass  //generator

class driver;
    virtual APB_Slave_Interface fnd_interf;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_next_event;
    transaction fnd_tr; // generate가 아닌 만들어진 transaction을 활용 => 멤버로 활용

    function new(virtual APB_Slave_Interface fnd_interf,
                 mailbox#(transaction) Gen2Drv_mbox, event gen_next_event);
        this.fnd_interf = fnd_interf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_next_event = gen_next_event;

    endfunction

    task run();
        forever begin
            Gen2Drv_mbox.get(fnd_tr); //mailbox내의 transaction 가져와서 fnd_tr에 넣기
            fnd_tr.display("DRV");
            @(posedge fnd_interf.PCLK);

            
            
            fnd_interf.PADDR   <= fnd_tr.PADDR  ;  //4bit???  //알아서 자름 lsb 남김
            fnd_interf.PWRITE  <= 1'b1   ;
            fnd_interf.PWDATA  <= fnd_tr.PWDATA ;
            fnd_interf.PSEL    <= 1'b1   ;
            fnd_interf.PENABLE <= 1'b0   ;

            @(posedge fnd_interf.PCLK);
            
            fnd_interf.PADDR   <= fnd_tr.PADDR  ;
            fnd_interf.PWDATA  <= fnd_tr.PWDATA ;
            fnd_interf.PWRITE  <= 1'b1   ;
            fnd_interf.PENABLE <= 1'b1   ;
            fnd_interf.PSEL    <= 1'b1   ;
            wait(fnd_interf.PREADY == 1'b1);
            @(posedge fnd_interf.PCLK);
            @(posedge fnd_interf.PCLK);
            @(posedge fnd_interf.PCLK);
            ->gen_next_event; // event trigger
        end
    endtask
endclass


class environment;
    mailbox #(transaction) Gen2Drv_mbox;
    generator fnd_gen;
    driver fnd_drv;
    event gen_next_event;

    function new(virtual APB_Slave_Interface fnd_interf); //intf는 class 아님 
    Gen2Drv_mbox = new(); //class가아니라 new 
    this.fnd_gen = new(Gen2Drv_mbox, gen_next_event); //function code
    this.fnd_drv = new(fnd_interf,Gen2Drv_mbox,gen_next_event);
    endfunction

    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
        join_any;
    endtask
endclass


module tb_fnd_APB_pheri ();
    environment fnd_env; 
    APB_Slave_Interface fnd_interf(); // 바로 실체화 
    
    always #5 fnd_interf.PCLK = ~fnd_interf.PCLK;

    initial begin
        fnd_interf.PCLK = 0; fnd_interf.PRESET = 1'b1;
        #10 fnd_interf.PRESET = 0;
        fnd_env = new(fnd_interf);
        fnd_env.run(10);
        #30;
        $finish;
         
    end

     ABP_interface_fnd apb_fnd (
    .PCLK(fnd_interf.PCLK),
    .PRESET(fnd_interf.PRESET),

    .PADDR(fnd_interf.PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(fnd_interf.PWDATA),
    .PWRITE(fnd_interf.PWRITE),
    .PENABLE(fnd_interf.PENABLE),
    .PSEL(fnd_interf.PSEL),

    .PRDATA(fnd_interf.PRDATA),
    .PREADY(fnd_interf.PREADY),

    .fndcomm(fnd_interf.fndcomm),
    .fndfont(fnd_interf.fndfont)
    // output logic [7:0] outPort
);
endmodule  //제일 top 
