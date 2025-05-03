`timescale 1ns / 1ps

interface fifo_interface;

logic clk;
logic reset;
logic start_trigger;
// input [2:0] sw_mode,

wire dht_io;
logic io_oe;   // output enable: 1이면 TB가 출력, 0이면 입력
logic dht_data;  // TB가 출력할 값
int rand_width;

assign dht_io = io_oe ? 1'bz : dht_data; // interface에서 3state_buffer 만들기 
// output [2:0] led_state,

logic [39:0] data_out;
logic is_done;
logic checksum;

modport drv_mport ( //
output start_trigger, 
inout dht_io,
input data_out,
input is_done,
input checksum
);

modport mon_mport (
input start_trigger, 
input dht_io,
input data_out,
input is_done,
input checksum,
input rand_width
);

modport dut_mport (
input start_trigger, 
inout dht_io,
output data_out,
output is_done,
output checksum
);

endinterface  //ram_intf

class transaction;
   // read or write 정의 

// logic start_trigger;
// input [2:0] sw_mode,
rand int rand_width; // logic 이라 1 / 0만 나올 수 있잖아 그럼 안되지 int로 바꾸자 
// wire dht_io;

// output [2:0] led_state,

logic [39:0] data_out;
logic is_done;
logic checksum;

    constraint odata {rand_width dist{ 70 := 40, 30 := 60};}

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

    task run(int repeat_counter);
        transaction fifo_tr;
        fifo_tr = new();
        forever begin
            repeat(repeat_counter) begin
            @(rand_width_require);
            if (!fifo_tr.randomize()) $error("Randomization failed!!!");
            fifo_tr.display("GEN_trancieve");
            GenToDrvMon_mbox.put(fifo_tr);
            #10 -> rand_width_accept;
            #10;
            end
            @(scb_end);
        end
    endtask  //
endclass  //generator

class driver;  //신호 가공 
    mailbox #(transaction) GenToDrvMon_mbox;
    virtual fifo_interface fifo_if;
    transaction fifo_tr;
    event rand_width_accept;
    event rand_width_require;
    event drv_end;
    event scb_end;


    function new(mailbox#(transaction) GenToDrvMon_mbox,
                 virtual fifo_interface fifo_if, event rand_width_accept, event rand_width_require, event drv_end,event scb_end);
        this.GenToDrvMon_mbox = GenToDrvMon_mbox;
        this.fifo_if = fifo_if;
        this.rand_width_accept = rand_width_accept;
        this.rand_width_require = rand_width_require;
        this.drv_end = drv_end;
        this.scb_end = scb_end;
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
    task run(int repeat_counter);

        
            // fifo_if.drv_mport.dht_io = temp_dht_io;
        forever begin
            // fifo_if.drv_mport.dht_io = (io_oe == 1'b1) ? 1'bz : dht_data; 
            
            fifo_if.drv_mport.start_trigger = 1'b1;
            fifo_if.io_oe = 1'b1;
            @(posedge fifo_if.clk);
            fifo_if.drv_mport.start_trigger = 0;
            @(fifo_if.dht_io == 0);
            @(fifo_if.dht_io == 1);
            #30000 fifo_if.io_oe = 0;
            // @(posedge fifo_if.clk);
            fifo_if.dht_data = 1'b1;
            #10000;
            fifo_if.dht_data = 0;
            #10000;
            repeat(repeat_counter) begin
            #10; ->rand_width_require;
            #10;
            @(rand_width_accept);
            #10;
            GenToDrvMon_mbox.get(fifo_tr);
            fifo_tr.display("DRV_receive");
            fifo_if.rand_width = fifo_tr.rand_width;
            #1000;
            fifo_if.dht_data = 1'b1;
            for(int i =0; i< fifo_tr.rand_width; i++) begin //randwidth int 형태임 
            #1000;
            end
            #10000;
            $display("dht_data : %h", fifo_tr.rand_width);
            fifo_if.dht_data = 0;
            end
            #1000;
            @(posedge fifo_if.clk);
            #50000;
            @(posedge fifo_if.clk);
            #1 ->drv_end;
            @(scb_end);
        end
    endtask  //

endclass  //driver

class monitor;
    mailbox #(transaction) MonToSCB_mbox;
    virtual fifo_interface.mon_mport fifo_if;
    event drv_end;
    event mon_end;
    event rand_width_accept;
    transaction fifo_tr;



    function new(mailbox#(transaction) MonToSCB_mbox,
                 virtual fifo_interface.mon_mport fifo_if, event drv_end, event mon_end, event rand_width_accept);
        this.MonToSCB_mbox = MonToSCB_mbox;
        this.fifo_if = fifo_if;
        this.drv_end = drv_end;
        this.mon_end = mon_end;
        this.rand_width_accept = rand_width_accept;
           
    endfunction  //new()
    
    task run(int repeat_counter);
        fifo_tr = new();
        forever begin
            repeat(repeat_counter) begin
            @(rand_width_accept);
            #10000;
            fifo_tr.rand_width = fifo_if.rand_width;
            MonToSCB_mbox.put(fifo_tr);
            $display("MON: put randwidth :%d", fifo_if.rand_width);
            end

            @(drv_end);
            #100000;
             //@(ram_if.cb);
            // fifo_tr.start_trigger = fifo_if.start_trigger;
            // fifo_tr.dht_io = fifo_if.dht_io;
            fifo_tr.data_out = fifo_if.data_out;
            fifo_tr.is_done = fifo_if.is_done;
            fifo_tr.checksum = fifo_if.checksum;
           $display("MON put result:%h",fifo_if.data_out);
            MonToSCB_mbox.put(fifo_tr);
            #1 ->mon_end;
        end
    endtask  //

endclass  //monitor

class scoreboard;
    mailbox #(transaction) MonToSCB_mbox;
    event rand_width_accept;
    event mon_end;
    event scb_end;
    transaction fifo_tr;
    logic [39:0] ref_data;
    logic ref_checksum;
    int num;
    int test_count;

    
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
    endfunction  //new()

    task run(int repeat_counter);
        transaction fifo_tr;
        forever begin
            num = 0;
            repeat(repeat_counter) begin
                #10;
                @(rand_width_accept);
                #10000;
                MonToSCB_mbox.get(fifo_tr);
                $display("scb get rand_width: %d",fifo_tr.rand_width);
                // GenToDrvMon_mbox.get(fifo_tr);
                ref_data[39-num] = (fifo_tr.rand_width > 50) ? 1'b1 : 0; //msb부터
                num++;
            end
            test_count++;
            $display("test count: %d",test_count);
            

            ref_checksum = ((ref_data[39:32] + ref_data[31:24] + ref_data[23:16] + ref_data[15:8]) == ref_data[7:0]) ? 1'b1 : 1'b0;
            @(mon_end); //40번 끝나고 결과 받기 
            MonToSCB_mbox.get(fifo_tr);
            if(ref_data != fifo_tr.data_out) begin
                $display("result Mismatched :%h != %h", ref_data,fifo_tr.data_out);
            end
            else begin
                $display("result Matched :%h != %h", ref_data,fifo_tr.data_out);
            end

            if(ref_checksum != fifo_tr.checksum) begin
                $display("checksum mismatched : %h != %h",ref_checksum,fifo_tr.checksum);
            end
            else begin
                $display("checksum OK : %h != %h",ref_checksum,fifo_tr.checksum);
            end
        
            #1 -> scb_end;
        end

    endtask  //
endclass  //scoreboard

class envirnment;
    mailbox #(transaction) GenToDrvMon_mbox;
    mailbox #(transaction) MonToSCB_mbox;
    generator              fifo_gen;
    driver                 fifo_drv;
    monitor                fifo_mon;
    scoreboard             fifo_scb;
    event                  rand_width_accept;
    event                  rand_width_require;
    event                  drv_end;
    event                  mon_end;
    event                  scb_end;

    function new(virtual fifo_interface fifo_if);
        GenToDrvMon_mbox = new();
        MonToSCB_mbox = new();
        fifo_gen = new(GenToDrvMon_mbox, rand_width_accept, rand_width_require, scb_end);
        fifo_drv = new(GenToDrvMon_mbox, fifo_if,rand_width_accept,rand_width_require,drv_end,scb_end);
        fifo_mon = new(MonToSCB_mbox, fifo_if,drv_end,mon_end,rand_width_accept);
        fifo_scb = new(MonToSCB_mbox,rand_width_accept,mon_end,scb_end);
    endfunction  //new()

    task run(int count);
        fork
            fifo_gen.run(count);
            fifo_drv.run(count);
            fifo_mon.run(count);
            fifo_scb.run(count);
        join
    endtask  //
endclass  //envirnment

module tb_dht11 ();
    // logic clk,reset;

    envirnment env;

    fifo_interface fifo_if();

    // fifo dut (.intf(fifo_if)); // interface있는거 그대로 사용한다는 뜻
     top_dht11 dut(
        .clk(fifo_if.clk),
        .reset(fifo_if.reset),
        .start_trigger(fifo_if.dut_mport.start_trigger),
        // input [2:0] sw_mode,
    
        .dht_io(fifo_if.dut_mport.dht_io),
    
        // output [2:0] led_state,
        .led(),
        .fsm_state(),
        .data_out(fifo_if.dut_mport.data_out),
    
        .is_done(),
        .checksum(fifo_if.dut_mport.checksum)
    );

    always #5 fifo_if.clk = ~fifo_if.clk;

    initial begin
        fifo_if.clk = 0; fifo_if.reset = 1'b1;
        #10 fifo_if.reset = 0;
        env = new(fifo_if);
        env.run(40);
        // #50;
        // $finish;
    end

endmodule
