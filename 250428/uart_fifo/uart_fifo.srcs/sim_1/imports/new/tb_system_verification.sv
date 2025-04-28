`timescale 1ns / 1ps

interface fifo_interface (
    input logic clk,
    input logic reset
);

    logic [7:0] rData;
    logic [7:0] wData;
    logic wr_en;
    logic rd_en;
    logic full;
    logic empty;


    clocking drv_cb @(posedge clk); // test bench 기준으로 방향을 정한다.
        default input #1 output #1;  // drv입장 

        input rData;
        output wData;
        output wr_en;
        output rd_en;
        input full;
        input empty;
    //drv 입장 
    endclocking

    clocking mon_cb @(posedge clk); // test bench 기준으로 방향을 정한다.
        default input #1 output #1;  // mon 입장 
        input rData;
        input wData;
        input wr_en;
        input rd_en;
        input full;
        input empty;
    endclocking

    modport drv_mport(clocking drv_cb,
        input reset
    );  // 방향성을 설정하여 실수를 줄일 수 있다.
    modport mon_mport(clocking mon_cb, input reset);

endinterface  //ram_intf

class transaction;
    rand logic oper;  // read or write 정의 

    logic [7:0] rData;
    rand logic [7:0] wData;
    rand logic wr_en;
    rand logic rd_en;
    logic full;
    logic empty;

    constraint oper_ctrl{oper dist{1'b0 := 20, 1'b1 := 80};}

    task display(string name);
        $display(
            "[%S] oper=%h, wData=%h, rData=%h, wr_en=%h, rd_en=%h, full=%h, empty=%h",
            name, oper, wData, rData, wr_en, rd_en, full, empty);
    endtask  //
endclass  //transaction

class generator;
    mailbox #(transaction) GenToDrv_mbox;
    event gen_next_event;

    function new(mailbox#(transaction) GenToDrv_mbox, event gen_next_event);
        this.GenToDrv_mbox  = GenToDrv_mbox;
        this.gen_next_event = gen_next_event;
    endfunction  //new()

    task run(int repeat_counter);
        transaction fifo_tr;
        repeat (repeat_counter) begin
            fifo_tr = new();
            if (!fifo_tr.randomize()) $error("Randomization failed!!!");
            fifo_tr.display("GEN");
            GenToDrv_mbox.put(fifo_tr);
            @(gen_next_event);
        end
    endtask  //
endclass  //generator

class driver;  //신호 가공 
    mailbox #(transaction) GenToDrv_mbox;
    virtual fifo_interface.drv_mport fifo_if;
    transaction fifo_tr;

    function new(mailbox#(transaction) GenToDrv_mbox,
                 virtual fifo_interface.drv_mport fifo_if);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.fifo_if = fifo_if;
    endfunction  //new()

    task write();
        @(fifo_if.drv_cb);  //clocking block ㄱㄷ
        fifo_if.drv_cb.wData <= fifo_tr.wData;
        fifo_if.drv_cb.wr_en <= 1'b1;
        fifo_if.drv_cb.rd_en <= 0;
        fifo_tr.display("DRV");
        //@(posedge ram_if.cb.clk);
        @(fifo_if.drv_cb);  //데이터적용 
        fifo_if.drv_cb.wr_en <= 1'b0;  // 보내고 1ns 후에 0으로 
    endtask

    task read();
        @(fifo_if.drv_cb);  //clocking block ㄱㄷ
        fifo_if.drv_cb.rd_en <= 1'b1;
        fifo_if.drv_cb.wr_en <= 0;
        fifo_tr.display("DRV");
        //@(posedge ram_if.cb.clk);
        @(fifo_if.drv_cb);  //데이터적용 
        fifo_if.drv_cb.rd_en <= 1'b0;  // 보내고 1ns 후에 0으로 
    endtask
    task run();
        forever begin
            @(fifo_if.drv_cb);  //delay주니깐 된다 한잔해
            GenToDrv_mbox.get(fifo_tr);
            if (fifo_tr.oper == 1'b1) write();
            else read();
        end
    endtask  //

endclass  //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual fifo_interface.mon_mport fifo_if;
    transaction fifo_tr;

    function new(mailbox#(transaction) MonToSCB_mbox,
                 virtual fifo_interface.mon_mport fifo_if);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.fifo_if = fifo_if;
    endfunction  //new()

    task run();
        forever begin
            @(posedge fifo_if.mon_cb);
            @(posedge fifo_if.mon_cb);
            //@(ram_if.cb);
            fifo_tr       = new();
            fifo_tr.wData = fifo_if.mon_cb.wData;
            fifo_tr.rData = fifo_if.mon_cb.rData;
            fifo_tr.wr_en = fifo_if.mon_cb.wr_en;
            fifo_tr.rd_en = fifo_if.mon_cb.rd_en;
            fifo_tr.full  = fifo_if.mon_cb.full;
            fifo_tr.empty = fifo_if.mon_cb.empty;
            fifo_tr.display("MON");
            MonToSCB_mbox.put(fifo_tr);
        end
    endtask  //

endclass  //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;
    event gen_next_event;
    logic [7:0] scb_fifo[$]; //$는 queue 표시 0:3이라는 뜻임 
    logic [7:0] pop_data;
    transaction fifo_tr;



    function new(mailbox#(transaction) MonToSCB_mbox, event gen_next_event);
        this.MonToSCB_mbox  = MonToSCB_mbox;
        this.gen_next_event = gen_next_event;

    endfunction  //new()

    task run();
        transaction fifo_tr;
        forever begin
            MonToSCB_mbox.get(fifo_tr);
            fifo_tr.display("SCB");
            if (fifo_tr.wr_en) begin
                if (fifo_tr.full == 1'b0) begin  //hw와 비슷하게
                    scb_fifo.push_back(fifo_tr.wData);
                    $display("[SCB] : DATA Stored in queue : %h",
                             fifo_tr.wData);
                end else begin
                    $display("[SCB] : FIFO is full");
                end
            end 
            if (fifo_tr.rd_en) begin
                if (~fifo_tr.empty) begin
                     
                    pop_data = scb_fifo.pop_front();
                    if(fifo_tr.rData == pop_data) begin
                    $display("[SCB]: DATA Matched %h == %h",
                             fifo_tr.rData, pop_data);
                    end
                end else begin
                    $display("[SCB] Dismatched Data! %h !=%h",
                        fifo_tr.rData, pop_data);
                end
            end
                 else begin
                    $display("[SCB] FIFO is empty");
            end
            ->gen_next_event;
        end
    endtask  //
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrv_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator              fifo_gen;
    driver                 fifo_drv;
    monitor                fifo_mon;
    scoreboard             fifo_scb;
    event                  gen_next_event;

    function new(virtual fifo_interface fifo_if);
        GenToDrv_mbox = new();
        MonToSCB_mbox = new();
        fifo_gen = new(GenToDrv_mbox,gen_next_event);
        fifo_drv = new(GenToDrv_mbox, fifo_if);
        fifo_mon = new(MonToSCB_mbox, fifo_if);
        fifo_scb = new(MonToSCB_mbox,gen_next_event);
    endfunction  //new()

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run();
            fifo_mon.run();
            fifo_scb.run();
        join_any
    endtask  //
endclass  //envirnment

module tb_fifo ();
    logic clk,reset;

    envirnment env;

    fifo_interface fifo_if (clk);

    // fifo dut (.intf(fifo_if)); // interface있는거 그대로 사용한다는 뜻
     fifo dut(
    .clk(clk),
    .reset(reset),
    .rData(fifo_if.rData),
    .wData(fifo_if.wData),
    .wr_en(fifo_if.wr_en),
    .rd_en(fifo_if.rd_en),
    .full(fifo_if.full),
    .empty(fifo_if.empty)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1'b1;
        #10 reset = 0;
        env = new(fifo_if);
        env.run(10);
        #50;
        $finish;
    end

endmodule
