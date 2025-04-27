`timescale 1ns / 1ps

interface fifo_interface (
    input logic clk,
    input logic reset
);

     logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
     logic [31:0] PWDATA;
     logic PWRITE;
     logic PENABLE; //access 
     logic PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    logic [31:0 ]PRDATA;
    logic PREADY;
    

    clocking drv_cb @(posedge clk); // test bench 기준으로 방향을 정한다.
        default input #1 output #1;  // drv입장 

      output PADDR;  //4bit???  //알아서 자름 lsb 남김
      output PWDATA;
      output PWRITE;
      output PENABLE; //access 
      output PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

      input PRDATA;
      input PREADY;
    //drv 입장 
    endclocking

    clocking mon_cb @(posedge clk); // test bench 기준으로 방향을 정한다.
        default input #1 output #1;  // mon 입장 
      input PADDR;  //4bit???  //알아서 자름 lsb 남김
      input PWDATA;
      input PWRITE;
      input PENABLE; //access 
      input PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

      input PRDATA;
      input PREADY;
    //drv 입장 
    endclocking

    modport drv_mport(clocking drv_cb,
        input reset
    );  // 방향성을 설정하여 실수를 줄일 수 있다.
    modport mon_mport(clocking mon_cb, input reset);

endinterface  //ram_intf

class transaction;
     rand logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
     rand logic [31:0] PWDATA;
     rand logic PWRITE;
     rand logic PENABLE; //access //drive에서 가공 가능  
     rand logic PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    logic [31:0 ]PRDATA;
    logic PREADY;
    

    constraint c_addr {PADDR dist{4'h0 := 20, 4'h4 := 40, 4'h8 :=40};}
    constraint c_sel {PSEL dist {0 := 10, 1'b1 := 90};}
    constraint c_wdata {PWDATA < 1000;}
   

    task display(string name);
        $display(
            "[%S] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h",
            name,PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY);
    endtask  //
endclass  //transaction

class generator;
    mailbox #(transaction) GenToDrv_mbox;
    event scb_end;
    event gen_end;

    function new(mailbox#(transaction) GenToDrv_mbox, event scb_end,event gen_end);
        this.GenToDrv_mbox  = GenToDrv_mbox;
        this.scb_end = scb_end;
        this.gen_end = gen_end;
    endfunction  //new()

    task run(int repeat_counter);
        transaction fifo_tr;
        repeat (repeat_counter) begin
            fifo_tr = new();
            if (!fifo_tr.randomize()) $error("Randomization failed!!!");
            fifo_tr.display("GEN");
            GenToDrv_mbox.put(fifo_tr);
            #1->gen_end;
            @(scb_end);
        end
    endtask  //
endclass  //generator

class driver;  //신호 가공 
    mailbox #(transaction) GenToDrv_mbox;
    virtual fifo_interface.drv_mport fifo_if;
    transaction fifo_tr;
    event gen_end;
    event drv_end;

    function new(mailbox#(transaction) GenToDrv_mbox,
                 virtual fifo_interface.drv_mport fifo_if,event gen_end, event drv_end);
        this.GenToDrv_mbox = GenToDrv_mbox;
        this.fifo_if = fifo_if;
        this.gen_end = gen_end;
        this.drv_end = drv_end;
    endfunction  //new()

    // task write();
    //     @(fifo_if.drv_cb);  //clocking block ㄱㄷ
    //     fifo_if.drv_cb.wData <= fifo_tr.wData;
    //     fifo_if.drv_cb.wr_en <= 1'b1;
    //     fifo_if.drv_cb.rd_en <= 0;
    //     fifo_tr.display("DRV");
    //     //@(posedge ram_if.cb.clk);
    //     @(fifo_if.drv_cb);  //데이터적용 
    //     fifo_if.drv_cb.wr_en <= 1'b0;  // 보내고 1ns 후에 0으로 
    // endtask

    // task read();
    //     @(fifo_if.drv_cb);  //clocking block ㄱㄷ
    //     fifo_if.drv_cb.rd_en <= 1'b1;
    //     fifo_if.drv_cb.wr_en <= 0;
    //     fifo_tr.display("DRV");
    //     //@(posedge ram_if.cb.clk);
    //     @(fifo_if.drv_cb);  //데이터적용 
    //     fifo_if.drv_cb.rd_en <= 1'b0;  // 보내고 1ns 후에 0으로 
    // endtask
    task run();
        forever begin
            @(gen_end);
            @(fifo_if.drv_cb);
              //delay주니깐 된다 한잔해
            GenToDrv_mbox.get(fifo_tr);
            fifo_tr.display("DRV");
            // @(fifo_if.drv_cb);
            fifo_if.drv_cb.PADDR <= fifo_tr.PADDR; //4bit???  //알아서 자름 lsb 남김
            fifo_if.drv_cb.PWDATA <= fifo_tr.PWDATA;
            if(fifo_tr.PADDR == 4'h4) fifo_if.drv_cb.PWRITE <= 1'b1;
            else fifo_if.drv_cb.PWRITE <= 0;
            fifo_if.drv_cb.PSEL  <= fifo_tr.PSEL;
            fifo_if.drv_cb.PENABLE <= 1'b1;

       //access //drive에서 가공 가능  
           
            #1 ->drv_end;
        end
    endtask  //

endclass  //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual fifo_interface.mon_mport fifo_if;
    transaction fifo_tr;
    event drv_end;
    event mon_end;

    function new(mailbox#(transaction) MonToSCB_mbox,
                 virtual fifo_interface.mon_mport fifo_if, event drv_end, event mon_end);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.fifo_if = fifo_if;
        this.drv_end = drv_end;
        this.mon_end = mon_end;
    endfunction  //new()

    task run();
        forever begin
            @(drv_end);
            // @(posedge fifo_if.mon_cb);
            // @(posedge fifo_if.mon_cb);
            //@(ram_if.cb);
            fifo_tr       = new();
            fifo_tr.PADDR = fifo_if.mon_cb.PADDR;
            fifo_tr.PWDATA = fifo_if.mon_cb.PWDATA;
            fifo_tr.PWRITE = fifo_if.mon_cb.PWRITE;
            fifo_tr.PENABLE = fifo_if.mon_cb.PENABLE;
            fifo_tr.PSEL  = fifo_if.mon_cb.PSEL;
            fifo_tr.PRDATA = fifo_if.mon_cb.PRDATA;
            fifo_tr.PREADY = fifo_if.mon_cb.PREADY;
            fifo_tr.display("MON");
            MonToSCB_mbox.put(fifo_tr);
            #10 -> mon_end;
        end
    endtask  //

endclass  //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;
    event mon_end;
    event scb_end;
    logic [7:0] scb_fifo[$]; //$는 queue 표시 0:3이라는 뜻임  // 가상의 fifo_memory 
    // logic [31:0] ref_reg [0:2]; // 가상의 slv //이거는 그냥 fifo mem과 연결되어있는 거니가 굳이 필요 없을 듯 괜한 고생 ㄴㄴ
    logic [7:0] pop_data;
    transaction fifo_tr;

    logic  full, empty;
    int total,pass,fail,not_sel,write;



    function new(mailbox#(transaction) MonToSCB_mbox, event mon_end, event scb_end);
        this.MonToSCB_mbox  = MonToSCB_mbox;
        this.mon_end = mon_end;
        this.scb_end = scb_end;
        
           
                // ref_reg[1] = 0;
          

            // scb_fifo = {8'bx,8'bx,8'bx,8'bx};

    endfunction  //new()

    task run();
        transaction fifo_tr;
        forever begin
            @(mon_end);
            MonToSCB_mbox.get(fifo_tr);
            fifo_tr.display("SCB");
            full = (scb_fifo.size() >= 4) ? 1'b1 : 0;
            empty = (scb_fifo.size() == 0) ? 1'b1 : 0;
            // ref_reg[0] = {{30{1'b0}},full,empty};
            total++;

            if((~fifo_tr.PWRITE & fifo_tr.PSEL) && (fifo_tr.PADDR == 4'h0)) begin

                    
                    if({{30{1'b0}},full,empty} != fifo_tr.PRDATA) begin
                        $display("Mismatch EMPTY/FULL : %h != %h",{{30{1'b0}},full,empty},fifo_tr.PRDATA);
                        fail++;
                    end
                    else begin
                         $display("Match EMPTY/FULL : %h == %h",{{30{1'b0}},full,empty},fifo_tr.PRDATA);
                         pass++;
                    end

            end 
            else if((fifo_tr.PWRITE & fifo_tr.PSEL) && (fifo_tr.PADDR == 4'h4)) begin
                write++;
                    // ref_reg[1] = fifo_tr.PWDATA;
                    if(full != 1'b1) begin
                        scb_fifo.push_back(fifo_tr.PWDATA);
                        $display("[SCB] : DATA Stored in queue : %h",
                             fifo_tr.PWDATA);
                             
                    end
                    else begin
                        $display("[SCB] : FIFO is full");
                    end
            end

            else if((~fifo_tr.PWRITE & fifo_tr.PSEL) && (fifo_tr.PADDR == 4'h8)) begin
                if(empty != 1'b1) begin
                    pop_data = scb_fifo.pop_front();
                    // ref_reg[2] = {{24{1'b0}},pop_data};
                    if(pop_data != fifo_tr.PRDATA[7:0]) begin
                        $display("[SCB]: DATA DISMatched %h == %h",
                             pop_data, fifo_tr.PRDATA[7:0]);
                              fail++;
                    end
                    else begin
                        $display("[SCB] Matched Data! %h !=%h, %h",
                        pop_data, fifo_tr.PRDATA[7:0],empty);
                         pass++;
                    end
                end
                else begin
                    $display("[SCB],FIFO is empty");
                    
                end
            end
            else begin
                $display("not selected");
                not_sel++;
            end

            // if (fifo_tr.wr_en) begin
            //     if (fifo_tr.full == 1'b0) begin  //hw와 비슷하게
            //         scb_fifo.push_back(fifo_tr.wData);
            //         $display("[SCB] : DATA Stored in queue : %h",
            //                  fifo_tr.wData);
            //     end else begin
            //         $display("[SCB] : FIFO is full");
            //     end
            // end 
            // if (fifo_tr.rd_en) begin
            //     if (~fifo_tr.empty) begin
                     
            //         pop_data = scb_fifo.pop_front();
            //         if(fifo_tr.rData == pop_data) begin
            //         $display("[SCB]: DATA Matched %h == %h",
            //                  fifo_tr.rData, pop_data);
            //         end
            //     end else begin
            //         $display("[SCB] Dismatched Data! %h !=%h",
            //             fifo_tr.rData, pop_data);
            //     end
            // end
            //      else begin
            //         $display("[SCB] FIFO is empty");
            // end
            #10 ->scb_end;
        end
    endtask  //

    task report();

    $display ("final report");
     $display ("total: %d, pass: %d, fail: %d not_sel %d, write %d", total,pass,fail,not_sel,write);
    endtask
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrv_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator              fifo_gen;
    driver                 fifo_drv;
    monitor                fifo_mon;
    scoreboard             fifo_scb;
    event                  gen_end;
    event                  drv_end;
    event                  mon_end;
    event                  scb_end;

    function new(virtual fifo_interface fifo_if);
        GenToDrv_mbox = new();
        MonToSCB_mbox = new();
        fifo_gen = new(GenToDrv_mbox,scb_end,gen_end);
        fifo_drv = new(GenToDrv_mbox, fifo_if,gen_end,drv_end);
        fifo_mon = new(MonToSCB_mbox, fifo_if,drv_end,mon_end);
        fifo_scb = new(MonToSCB_mbox,mon_end,scb_end);
    endfunction  //new()

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run();
            fifo_mon.run();
            fifo_scb.run();
        join_any
            fifo_scb.report();
    endtask  //
endclass  //envirnment

module tb_fifo ();
    logic clk,reset;

    envirnment env;

    fifo_interface fifo_if (clk);

    // fifo dut (.intf(fifo_if)); // interface있는거 그대로 사용한다는 뜻
APB_interface_fifo dut(
    .PCLK(clk),
    .PRESET(reset),

    .PADDR(fifo_if.PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(fifo_if.PWDATA),
    .PWRITE(fifo_if.PWRITE),
    .PENABLE(fifo_if.PENABLE), //access 
    .PSEL(fifo_if.PENABLE), // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    .PRDATA(fifo_if.PRDATA),
    .PREADY(fifo_if.PREADY)
    
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1'b1;
        #10 reset = 0;
        env = new(fifo_if);
        env.run(20);
        #50;
        $finish;
    end

endmodule
