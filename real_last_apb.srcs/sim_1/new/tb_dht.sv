`timescale 1ns / 1ps

interface dht_interface;

logic clk;
logic reset;
// logic start_trigger;
// input [2:0] sw_mode,

wire dht_io;
logic io_oe;   // output enable: 1이면 TB가 출력, 0이면 입력
logic dht_data;  // TB가 출력할 값
int rand_width;

logic [3:0] PADDR; //4bit???  //알아서 자름 lsb 남김
logic [31:0] PWDATA;
logic PWRITE;
logic PENABLE; //access 
logic PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

logic [31:0] PRDATA;
logic PREADY;

assign dht_io = io_oe ? 1'bz : dht_data; // interface에서 3state_buffer 만들기 
// output [2:0] led_state,

// logic is_done;
// logic checksum;

modport drv_mport ( // interface와의 관계 
output PADDR,
output PWDATA,
output PWRITE,
output PENABLE,
output PSEL,
input PRDATA,
input PREADY,
inout dht_io

// input is_done,
// input checksum
);

modport mon_mport (  //interface와의 관계계
output PADDR,
output PWDATA,
output PWRITE,
output PENABLE,
output PSEL,
input  PRDATA,
input  PREADY,
input  dht_io,
input  rand_width
);

modport dut_mport ( //interface와의 관계계 dut입장에서 
input PADDR,
input PWDATA,
input PWRITE,
input PENABLE,
input PSEL,
output PRDATA,
output PREADY,    
inout dht_io


); //interface와 물려있는 애들 port 설정 

endinterface  //ram_intf

class transaction;
   // read or write 정의 

// logic start_trigger;
// input [2:0] sw_mode,
rand int rand_width; // logic 이라 1 / 0만 나올 수 있잖아 그럼 안되지 int로 바꾸자 
// wire dht_io;

// output [2:0] led_state,
logic [3:0] PADDR; //4bit???  //알아서 자름 lsb 남김
logic [31:0] PWDATA;
logic PWRITE;
logic PENABLE; //access 
logic PSEL; // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

logic [31:0] PRDATA;
logic PREADY;

logic [31:0] data_out;
logic [31:0] checksum;

    constraint odata {rand_width dist{ 70 := 20, 75 := 10, 78 := 20, 25 := 20, 28 := 20,  30 := 10};}

    task display(string name);
        $display("[%S] rand_width=%d", 
            name,rand_width);
    endtask  //
endclass  //transaction
//driver 먼저 내보내자 
class generator;
    mailbox #(transaction) GenToDrvMon_mbox;
    event rand_width_accept;
    event rand_width_require;
    event scb_end;

    function new(mailbox#(transaction) GenToDrvMon_mbox, event rand_width_accept, event rand_width_require, event scb_end);
        this.GenToDrvMon_mbox  = GenToDrvMon_mbox;
        this.rand_width_accept = rand_width_accept;
        this.rand_width_require = rand_width_require;
        this.scb_end = scb_end;
    endfunction  //new()

    task run(int repeat_counter,int total_count);
        transaction dht_tr;
        dht_tr = new();
        repeat(total_count) begin
            repeat(repeat_counter) begin
            @(rand_width_require);
            if (!dht_tr.randomize()) $error("Randomization failed!!!");
            dht_tr.display("GEN_trancieve");
            GenToDrvMon_mbox.put(dht_tr);
            #10 -> rand_width_accept;
            #10;
            end
            @(scb_end);
        end
    endtask  //
endclass  //generator

class driver;  //신호 가공 
    mailbox #(transaction) GenToDrvMon_mbox;
    virtual dht_interface dht_if;
    transaction dht_tr;
    event rand_width_accept;
    event rand_width_require;
    event drv_end;
    event scb_end;


    function new(mailbox#(transaction) GenToDrvMon_mbox,
                 virtual dht_interface dht_if, event rand_width_accept, event rand_width_require, event drv_end,event scb_end);
        this.GenToDrvMon_mbox = GenToDrvMon_mbox;
        this.dht_if = dht_if;
        this.rand_width_accept = rand_width_accept;
        this.rand_width_require = rand_width_require;
        this.drv_end = drv_end;
        this.scb_end = scb_end;
    endfunction  //new()
 
 
    task start_up();
        dht_if.drv_mport.PADDR = 4'h0;
        dht_if.drv_mport.PWRITE = 1'b1;
        dht_if.drv_mport.PWDATA = 1;
        dht_if.drv_mport.PSEL = 1'b1;
        @(posedge dht_if.clk);
        dht_if.drv_mport.PENABLE = 1'b1; // 이때 pready 나옴 
        @(posedge dht_if.clk);
        dht_if.drv_mport.PSEL = 0;
        dht_if.drv_mport.PENABLE = 0; // 이거 안하면 계속 write 가능 
        
    endtask

    task start_down();
        dht_if.drv_mport.PADDR = 4'h0;
        dht_if.drv_mport.PWRITE = 1'b1;
        dht_if.drv_mport.PWDATA = 0;
        dht_if.drv_mport.PSEL = 1'b1;
        @(posedge dht_if.clk);
        dht_if.drv_mport.PENABLE = 1'b1;
        @(posedge dht_if.clk);
        dht_if.drv_mport.PSEL = 0;
        dht_if.drv_mport.PENABLE = 0;
        
    endtask
    task run(int repeat_counter);

        
            // fifo_if.drv_mport.dht_io = temp_dht_io;
        forever begin
            // fifo_if.drv_mport.dht_io = (io_oe == 1'b1) ? 1'bz : dht_data; 
            dht_if.io_oe = 1'b1;
            start_up();
            // @(posedge dht_if.drv_mport.PREADY);
            // @(posedge dht_if.clk);
            #100;
            start_down();
            // @(posedge dht_if.drv_mport.PREADY); 함수 끝나기전에 pready 나옴옴

            @(dht_if.dht_io == 0);
            @(dht_if.dht_io == 1'b1);
            #1000;
            dht_if.io_oe = 0;
            #35000;
            dht_if.dht_data = 1'b1;
            #10000;
            dht_if.dht_data = 0;
            #1000;
            repeat(repeat_counter) begin
            #10; ->rand_width_require;
            #10;
            @(rand_width_accept);
            #10;
            GenToDrvMon_mbox.get(dht_tr);
            dht_tr.display("DRV_receive");
            dht_if.rand_width = dht_tr.rand_width;
            #1000;
            dht_if.dht_data = 1'b1;
            for(int i =0; i< dht_tr.rand_width-1; i++) begin //randwidth int 형태임 
            #1000;
            end
            #10000;
            $display("dht_data : %d", dht_tr.rand_width);
            dht_if.dht_data = 0;
            end
            #1000;
            @(posedge dht_if.clk);
            #50000;
            @(posedge dht_if.clk);
            #1 ->drv_end;
            @(scb_end);
        end
    endtask  //

endclass  //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual dht_interface dht_if;
    event drv_end;
    event mon_end;
    event rand_width_accept;
    transaction dht_tr;



    function new(mailbox#(transaction) MonToSCB_mbox,
                 virtual dht_interface  dht_if, event drv_end, event mon_end, event rand_width_accept);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.dht_if = dht_if;
        this.drv_end = drv_end;
        this.mon_end = mon_end;
        this.rand_width_accept = rand_width_accept;
           
    endfunction  //new()
    
    task read_odata();
        dht_if.mon_mport.PADDR = 4'h4;
        dht_if.mon_mport.PWRITE = 0;
        dht_if.mon_mport.PSEL = 1'b1;
        @(posedge dht_if.clk);
        dht_if.mon_mport.PENABLE = 1'b1;
        @(posedge dht_if.clk);
        dht_if.mon_mport.PENABLE = 0;
        dht_if.mon_mport.PSEL = 0;
        
    endtask
        task read_chksum();
        dht_if.mon_mport.PADDR = 4'h8;
        dht_if.mon_mport.PWRITE = 0;
        dht_if.mon_mport.PSEL = 1'b1;
        @(posedge dht_if.clk);
        dht_if.mon_mport.PENABLE = 1'b1;
        @(posedge dht_if.clk);
        dht_if.mon_mport.PENABLE = 0;
        dht_if.mon_mport.PSEL = 0;
        
    endtask

    task run(int repeat_counter);
        dht_tr = new();
        forever begin
            repeat(repeat_counter) begin
            @(rand_width_accept);
            #10000;
            dht_tr.rand_width = dht_if.rand_width;
            MonToSCB_mbox.put(dht_tr);
            $display("MON: put randwidth :%d", dht_if.rand_width);
            end

            @(drv_end);
            #100000;
            read_odata();
            // @(posedge dht_if.PREADY);
            dht_tr.data_out = dht_if.mon_mport.PRDATA;
            $display("MON put result:%h",dht_if.mon_mport.PRDATA);
            @(posedge dht_if.clk);
            @(posedge dht_if.clk);
            read_chksum();
            // @(posedge dht_if.mon_mport.PREADY);
            dht_tr.checksum = dht_if.mon_mport.PRDATA;
           $display("MON put chksum:%h",dht_if.mon_mport.PRDATA);
            MonToSCB_mbox.put(dht_tr);
            #1 ->mon_end;
        end
    endtask  //

endclass  //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;
    event rand_width_accept;
    event mon_end;
    event scb_end;
    transaction dht_tr;
    logic [39:0] ref_data;
    logic ref_checksum;
    int num;
    int test_count;
    int data_pass;
    int data_fail;
    int chksum_pass;
    int chksum_fail;

    
    function new(mailbox#(transaction) MonToSCB_mbox, event rand_width_accept,
    event mon_end,event scb_end);
        this.MonToSCB_mbox  = MonToSCB_mbox;
        this.rand_width_accept = rand_width_accept;
        this.mon_end = mon_end;
        this.scb_end = scb_end;
        
        ref_data = 0;
        ref_checksum = 0;
        num = 0;
        test_count = 0;
        data_pass = 0;
        data_fail = 0;
        chksum_pass = 0;
        chksum_fail = 0;
    endfunction  //new()
    task report();
    begin
    
        $display("===================test  report =====================");
        $display("total test count :    %d", test_count);
        $display("data pass count :     %d", data_pass);
        $display("data fail count :     %d", data_fail);
        $display("checksum pass count : %d", chksum_pass);
        $display("checksum fail count : %d", chksum_fail);
        $display("=====================================================");

    end
    endtask;

    task run(int repeat_counter);
        transaction dht_tr;
        forever begin
            num = 0;
            repeat(repeat_counter) begin
                #10;
                @(rand_width_accept);
                #10000;
                MonToSCB_mbox.get(dht_tr);
                $display("scb get rand_width: %d",dht_tr.rand_width);
                ref_data[39-num] = (dht_tr.rand_width > 50) ? 1'b1 : 0; //msb부터
                num++;
            end
            test_count++;
            $display("test count: %d",test_count);
            
            ref_checksum = (ref_data[39:32] + ref_data[31:24] + ref_data[23:16] + ref_data[15:8])  == ref_data[7:0] ? 1'b1 : 0;
            @(mon_end);
            MonToSCB_mbox.get(dht_tr);
            if(ref_data[39:8] != dht_tr.data_out) begin
                $display("result Mismatched :%h != %h", ref_data[39:8],dht_tr.data_out);
                data_fail++;
            end
            else begin
                $display("result Matched :%h == %h", ref_data[39:8],dht_tr.data_out);
                data_pass++;
            end

            if(ref_checksum != dht_tr.checksum[0]) begin
                $display("checksum mismatched : %h != %h",ref_checksum,dht_tr.checksum[0]);
                chksum_fail++;
            end
            else begin
                $display("checksum OK : %h == %h",ref_checksum,dht_tr.checksum[0]);
                chksum_pass++;
            end
        
            #1 -> scb_end;
        end

    endtask  //
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrvMon_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator              dht_gen;
    driver                 dht_drv;
    monitor                dht_mon;
    scoreboard             dht_scb;
    event                  rand_width_accept;
    event                  rand_width_require;
    event                  drv_end;
    event                  mon_end;
    event                  scb_end;

    function new(virtual dht_interface dht_if);
        GenToDrvMon_mbox = new();
        MonToSCB_mbox = new();
        dht_gen = new(GenToDrvMon_mbox, rand_width_accept, rand_width_require, scb_end);
        dht_drv = new(GenToDrvMon_mbox, dht_if,rand_width_accept,rand_width_require,drv_end,scb_end);
        dht_mon = new(MonToSCB_mbox, dht_if,drv_end,mon_end,rand_width_accept);
        dht_scb = new(MonToSCB_mbox,rand_width_accept,mon_end,scb_end);
    endfunction  //new()

    task run(int count, int total_count);
        fork
            dht_gen.run(count,total_count);
            dht_drv.run(count);
            dht_mon.run(count);
            dht_scb.run(count);
        join_any
        dht_scb.report();
    endtask  //
endclass  //envirnment

module tb_dht11 ();
    // logic clk,reset;

    envirnment env;

    dht_interface dht_if();

    // fifo dut (.intf(fifo_if)); // interface있는거 그대로 사용한다는 뜻


APB_interface_dht11 dut(
    .PCLK(dht_if.clk),
    .PRESET(dht_if.reset),

    .PADDR(dht_if.dut_mport.PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(dht_if.dut_mport.PWDATA),
    .PWRITE(dht_if.dut_mport.PWRITE),
    .PENABLE(dht_if.dut_mport.PENABLE), //access 
    .PSEL(dht_if.dut_mport.PSEL), // setup // 이때 이미 rdata는 나가있음 write data도 다 들어옴 

    .PRDATA(dht_if.dut_mport.PRDATA),
    .PREADY(dht_if.dut_mport.PREADY),

    .dht_io(dht_if.dut_mport.dht_io)
  
 
    
    );

    always #5 dht_if.clk = ~dht_if.clk;

    initial begin
        dht_if.clk = 0; dht_if.reset = 1'b1;
        #10 dht_if.reset = 0;
        env = new(dht_if);
        env.run(40,20); //총 20번 
        #50;
        $finish;
    end

endmodule
