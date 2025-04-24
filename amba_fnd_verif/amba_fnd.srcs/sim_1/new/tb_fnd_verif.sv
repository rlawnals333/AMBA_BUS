`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/24 19:02:39
// Design Name: 
// Module Name: tb_fnd_verif
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

class transaction;

    // APB Interface Signals
    rand logic [ 3:0] PADDR;
    rand logic [31:0] PWDATA;
    rand logic        PWRITE;
    rand logic        PENABLE;
    rand logic        PSEL;

    logic      [31:0] PRDATA;  // dut out data
    logic             PREADY;  // dut out data
    // outport signals
    logic      [ 3:0] fndcomm;  // dut out data
    logic      [ 7:0] fndfont;

    constraint c_paddr {PADDR inside {4'h0, 4'h4, 4'h8, 4'hC};}
    constraint c_wdata {

        if (PADDR == 4'h0)
        PWDATA inside {0, 1};
        else
        if (PADDR == 4'h4)
        PWDATA inside {4'b0001, 4'b1000, 4'b0100, 4'b0010};
        else
        if (PADDR == 4'h8)
        PWDATA < 10000;
        else
        if (PADDR == 4'hc) PWDATA < 4'b1111;
    }
    task display(string name);
        $display(
            "[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h, fndCom=%h, fndFont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY,
            fndcomm, fndfont);
    endtask

endclass

interface APB_Slave_Intferface;
    logic        PCLK;  // tb 에서 interface를 통해 clk 입력해줌 
    logic        PRESET;
    // APB Interface Signals
    logic [ 3:0] PADDR;
    logic [31:0] PWDATA;
    logic        PWRITE;
    logic        PENABLE;
    logic        PSEL;
    logic [31:0] PRDATA;  // dut out data
    logic        PREADY;  // dut out data
    // outport signals
    logic [ 3:0] fndcomm;  // dut out data
    logic [ 7:0] fndfont;  // dut out data
endinterface

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event scb_end;
    event gen_end;

    function new(mailbox#(transaction) Gen2Drv_mbox, event scb_end,
                 event gen_end);
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.scb_end = scb_end;
        this.gen_end = gen_end;
    endfunction

    task run(int repeat_counter);
        transaction fnd_tr; // 사용하기위한 handler 선언할때마다 새로운 fnd_tr 핸들러 생성성;
        repeat (repeat_counter) begin
            fnd_tr = new();
            if (!fnd_tr.randomize()) $error("Randomization fail!");
            fnd_tr.display("GEN");
            Gen2Drv_mbox.put(fnd_tr);
            #10;
            ->gen_end; // event 생성 전에는 일단 한클럭 쉬어줘 
            @(scb_end);
        end
    endtask
endclass

class driver;
    virtual APB_Slave_Intferface fnd_intf;
    mailbox #(transaction) Gen2Drv_mbox;
    transaction fnd_tr; // 같은 transaction 으로 쓰니까 어차피 바뀔이유 없음 
    event gen_end;
    event drv_end;

    function new(virtual APB_Slave_Intferface fnd_intf,
                 mailbox #(transaction) Gen2Drv_mbox, event gen_end,
                 event drv_end);
        this.fnd_intf = fnd_intf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_end = gen_end;
        this.drv_end = drv_end;
    endfunction

    task run();
        forever begin
            @(gen_end);
            Gen2Drv_mbox.get(fnd_tr); //받아서 참조할떄는 fnd_tr = new() 안해도됨 
            fnd_tr.display("DRV");
            @(posedge fnd_intf.PCLK);
            fnd_intf.PADDR  <= fnd_tr.PADDR;
            fnd_intf.PWDATA <= fnd_tr.PWDATA;
            fnd_intf.PWRITE <= fnd_tr.PWRITE;  // SETUP
            fnd_intf.PSEL   <= fnd_tr.PSEL;
            @(posedge fnd_intf.PCLK);
            fnd_intf.PENABLE <= 1'b1;  // master에서는 무조건 1내보냄 

            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            
            ->drv_end;  // end신호받고 바로 monitor에서 결과값 받기 때문에 어느정도 delay필요요


        end
    endtask
endclass

class monitor;
    mailbox #(transaction) Mon2Scb_mbox;
    virtual APB_Slave_Intferface fnd_intf;
    transaction fnd_tr;
    event drv_end;
    event mon_end;

    function new(mailbox #(transaction) Mon2Scb_mbox,
                 virtual APB_Slave_Intferface fnd_intf,
                 event drv_end, event mon_end);

        this.Mon2Scb_mbox = Mon2Scb_mbox;
        this.fnd_intf = fnd_intf;
        this.drv_end  = drv_end;
        this.mon_end  = mon_end;
    endfunction

    task run();
    
        forever begin
            @(drv_end);
            fnd_tr = new(); //put할때는 실체화
            
            fnd_tr.PADDR   = fnd_intf.PADDR;
            fnd_tr.PWDATA  = fnd_intf.PWDATA;
            fnd_tr.PWRITE  = fnd_intf.PWRITE;
            fnd_tr.PENABLE = fnd_intf.PENABLE;
            fnd_tr.PSEL    = fnd_intf.PSEL;
            fnd_tr.PRDATA  = fnd_intf.PRDATA;
            fnd_tr.PREADY  = fnd_intf.PREADY;
            fnd_tr.fndcomm  = fnd_intf.fndcomm;
            fnd_tr.fndfont = fnd_intf.fndfont;
            fnd_tr.display("MON");
            Mon2Scb_mbox.put(fnd_tr);  // 그때 mailbox에 put
            @(posedge fnd_intf.PCLK); // ready가 1이 된 후에 CLK 3번을 대기
            @(posedge fnd_intf.PCLK); // ready가 1이 된 후에 CLK 3번을 대기
            @(posedge fnd_intf.PCLK);
            ->mon_end;  // re
        end
    endtask

endclass

class scoreboard;

    mailbox #(transaction) Mon2Scb_mbox; // mailbox 한칸 띄워야됨
    transaction fnd_tr;
    event mon_end;
    event scb_end;

    int total_cnt;
    int write_cnt;
    int read_cnt;
    int pass_cnt;
    int fail_cnt;
    int not_sel_cnt;

    logic [31:0] ref_fnd_reg[0:3];
    logic [7:0] ref_fndfont[0:19] = {
        8'hc0,
        8'hf9,
        8'ha4,
        8'hb0,
        8'h99,
        8'h92,
        8'h82,
        8'hf8,
        8'h80,
        8'h90,

        //
        8'hc0 - (2**7), //dot 켜진 버전 
        8'hf9 - (2**7),
        8'ha4 - (2**7),
        8'hb0 - (2**7),
        8'h99 - (2**7),
        8'h92 - (2**7),
        8'h82 - (2**7),
        8'hf8 - (2**7),
        8'h80 - (2**7),
        8'h90 - (2**7)
    };

    function new(mailbox #(transaction) Mon2Scb_mbox,
    event mon_end,event scb_end); //초기화 

    this.Mon2Scb_mbox = Mon2Scb_mbox;
    this.mon_end = mon_end;
    this.scb_end = scb_end;
    for(int i=0;i<4;i++) begin
        ref_fnd_reg[i] = 0;
    end
    
    total_cnt = 0;
    write_cnt = 0;
    read_cnt =0;
    pass_cnt =0;
    fail_cnt =0;
    not_sel_cnt =0;
    endfunction

    task run();
    forever begin
        @(mon_end); // 값 다 들어옴 
        total_cnt++;
        Mon2Scb_mbox.get(fnd_tr);
        fnd_tr.display("SCB");
        if(fnd_tr.PWRITE && fnd_tr.PSEL) begin
            write_cnt++;
            ref_fnd_reg[fnd_tr.PADDR[3:2]] = fnd_tr.PWDATA;
            //지금부터 스코어보드와 결과값 비교 
            if(ref_fnd_reg[0][0] == 0) begin // 스코어 보드 기준으로 if / endable/disable
                if(4'b0000 !=~fnd_tr.fndcomm  ) begin
                    fail_cnt++;
                    $display("Mismatch offmode: %h != %h", 4'b0000,~fnd_tr.fndcomm);
                end //틀린경우 먼저저
                else begin
                     pass_cnt++;
                     $display("Match offmode: %h == %h", 4'b0000,~fnd_tr.fndcomm);
                end
            end
            else begin
             //너무 당연하게 되는건 제외 지금부터는 font값 잘나오는지 종합 확인 
             //font 값이 fmr 값마다 다르게 나오므로 이걸 기준으로 잡자
                if(ref_fnd_reg[1] == 4'b0001) begin
                    if((ref_fnd_reg[1] & ref_fnd_reg[3]) != 0) begin // dot있을때때
                        if(ref_fndfont[10+(ref_fnd_reg[2]%10)] != fnd_tr.fndfont) begin
                            fail_cnt++;
                            $display("Mismatch fndfont: %h != %h", ref_fndfont[10+(ref_fnd_reg[2]%10)],fnd_tr.fndfont);
                        end
                        else begin
                            pass_cnt++;
                            $display("Match fndfont: %h == %h", ref_fndfont[10+(ref_fnd_reg[2]%10)],fnd_tr.fndfont);
                        end
                    end
                    else begin
                        if(ref_fndfont[(ref_fnd_reg[2]%10)] != fnd_tr.fndfont) begin
                            fail_cnt++;
                            $display("Mismatch fndfont: %h != %h", ref_fndfont[(ref_fnd_reg[2]%10)],fnd_tr.fndfont);
                        end
                        else begin
                            pass_cnt++;
                            $display("Match fndfont: %h == %h", ref_fndfont[(ref_fnd_reg[2]%10)],fnd_tr.fndfont);
                        end
                    end

                end
                else if(ref_fnd_reg[1] == 4'b0010) begin
                     if((ref_fnd_reg[1] & ref_fnd_reg[3]) != 0) begin // dot있을때때
                        if(ref_fndfont[10+(ref_fnd_reg[2]/10%10)] != fnd_tr.fndfont) begin
                            fail_cnt++;
                            $display("Mismatch fndfont: %h != %h", ref_fndfont[10+(ref_fnd_reg[2]/10%10)],fnd_tr.fndfont);
                        end
                        else begin
                            pass_cnt++;
                            $display("Match fndfont: %h == %h", ref_fndfont[10+(ref_fnd_reg[2]/10%10)],fnd_tr.fndfont);
                        end
                    end
                    else begin
                        if(ref_fndfont[(ref_fnd_reg[2]/10%10)] != fnd_tr.fndfont) begin
                            fail_cnt++;
                            $display("Mismatch fndfont: %h != %h", ref_fndfont[(ref_fnd_reg[2]/10%10)],fnd_tr.fndfont);
                        end
                        else begin
                            pass_cnt++;
                            $display("Match fndfont: %h == %h", ref_fndfont[(ref_fnd_reg[2]/10%10)],fnd_tr.fndfont);
                        end
                    end
                    
                end
                else if(ref_fnd_reg[1] == 4'b0100) begin
                        if((ref_fnd_reg[1] & ref_fnd_reg[3]) != 0) begin // dot있을때때
                            if(ref_fndfont[10+(ref_fnd_reg[2]/100%10)] != fnd_tr.fndfont) begin
                                fail_cnt++;
                                $display("Mismatch fndfont: %h != %h", ref_fndfont[10+(ref_fnd_reg[2]/100%10)],fnd_tr.fndfont);
                            end
                            else begin
                                pass_cnt++;
                                $display("Match fndfont: %h == %h", ref_fndfont[10+(ref_fnd_reg[2]/100%10)],fnd_tr.fndfont);
                            end
                        end
                        else begin
                            if(ref_fndfont[(ref_fnd_reg[2]/100%10)] != fnd_tr.fndfont) begin
                                fail_cnt++;
                                $display("Mismatch fndfont: %h != %h", ref_fndfont[(ref_fnd_reg[2]/100%10)],fnd_tr.fndfont);
                            end
                            else begin
                                pass_cnt++;
                                $display("Match fndfont: %h == %h", ref_fndfont[(ref_fnd_reg[2]/100%10)],fnd_tr.fndfont);
                            end
                        end
                    
                end
                else if(ref_fnd_reg[1] == 4'b1000) begin
                    if((ref_fnd_reg[1] & ref_fnd_reg[3]) != 0) begin // dot있을때때
                            if(ref_fndfont[10+(ref_fnd_reg[2]/1000%10)] != fnd_tr.fndfont) begin
                                fail_cnt++;
                                $display("Mismatch fndfont: %h != %h", ref_fndfont[10+(ref_fnd_reg[2]/1000%10)],fnd_tr.fndfont);
                            end
                            else begin
                                pass_cnt++;
                                $display("Match fndfont: %h == %h", ref_fndfont[10+(ref_fnd_reg[2]/1000%10)],fnd_tr.fndfont);
                            end
                        end
                    else begin
                            if(ref_fndfont[(ref_fnd_reg[2]/1000%10)] != fnd_tr.fndfont) begin
                                fail_cnt++;
                                $display("Mismatch fndfont: %h != %h", ref_fndfont[(ref_fnd_reg[2]/1000%10)],fnd_tr.fndfont);
                            end
                            else begin
                                pass_cnt++;
                                $display("Match fndfont: %h == %h", ref_fndfont[(ref_fnd_reg[2]/1000%10)],fnd_tr.fndfont);
                            end
                        end
                    
                end

                end
            end
        else if(~fnd_tr.PWRITE && fnd_tr.PSEL) begin
            read_cnt++;
            if(ref_fnd_reg[fnd_tr.PADDR[3:2]] != fnd_tr.PRDATA) begin
                fail_cnt++;
                 $display("Mismatch RDATA: %h != %h", ref_fnd_reg[fnd_tr.PADDR[3:2]],fnd_tr.PRDATA);
            end
            else begin
                pass_cnt++;
                 $display("Match RDATA: %h == %h", ref_fnd_reg[fnd_tr.PADDR[3:2]],fnd_tr.PRDATA);
            end
        end

        else begin
            not_sel_cnt++;
            $display("NOT SELECTED");
        end
        #10;
        ->scb_end;
    end
        
endtask
endclass

class envirnment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2Scb_mbox;

    generator fnd_gen;
    driver fnd_drv;
    monitor fnd_mon;
    scoreboard fnd_scb;

    event gen_end;
    event drv_end;
    event mon_end;
    event scb_end; //내부에서 직접 사용하는 아이들 

    function new(virtual APB_Slave_Intferface fnd_intf); //외부와 소통하는 아이들 //한번 실행 여러번 실행하면 계속 초기화됨
     this.Gen2Drv_mbox = new();
     this.Mon2Scb_mbox = new();
     this.fnd_gen = new(Gen2Drv_mbox,scb_end,gen_end);
     this.fnd_drv = new(fnd_intf,Gen2Drv_mbox,gen_end,drv_end);
     this.fnd_mon = new(Mon2Scb_mbox,fnd_intf,drv_end,mon_end);
     this.fnd_scb = new(Mon2Scb_mbox,mon_end,scb_end);
    endfunction

    task run(int count);
        fork
            fnd_gen.run(count);
            fnd_drv.run();
            fnd_mon.run();
            fnd_scb.run();
        join_any;
    endtask
endclass

module tb_fnd_verif ();
    envirnment fnd_env; 
    APB_Slave_Intferface fnd_intf(); //실체화화

    always #5 fnd_intf.PCLK = ~fnd_intf.PCLK;

    ABP_interface_fnd dut (
        // global signal
        .PCLK(fnd_intf.PCLK),
        .PRESET(fnd_intf.PRESET),
        // APB Interface Signals
        .PADDR(fnd_intf.PADDR),
        .PWDATA(fnd_intf.PWDATA),
        .PWRITE(fnd_intf.PWRITE),
        .PENABLE(fnd_intf.PENABLE),
        .PSEL(fnd_intf.PSEL),
        .PRDATA(fnd_intf.PRDATA),
        .PREADY(fnd_intf.PREADY),
        // outport signals
        .fndcomm(fnd_intf.fndcomm),
        .fndfont(fnd_intf.fndfont)
    );

        initial begin
        fnd_intf.PCLK   = 0;
        fnd_intf.PRESET = 1;
        #10 fnd_intf.PRESET = 0;
        fnd_env = new(fnd_intf); //  함수내에서 new 
        fnd_env.run(1000);
        #30;
        $display("total:%d,write:%d,read:%d,pass:%d,fail:%d,not_sel:%d",fnd_env.fnd_scb.total_cnt,fnd_env.fnd_scb.write_cnt,fnd_env.fnd_scb.read_cnt,fnd_env.fnd_scb.pass_cnt,fnd_env.fnd_scb.fail_cnt,fnd_env.fnd_scb.not_sel_cnt);
        $finish;
    end
endmodule
