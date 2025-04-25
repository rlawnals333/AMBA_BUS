`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/24 09:48:30
// Design Name: 
// Module Name: tb_verifi_fnd
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
    //내가 master 역할을 해야됨 // transaction 내부는 apb slave 임 
    rand logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
    rand logic [31:0] PWDATA;
    rand logic PWRITE;
    rand logic PENABLE; //만약 안오면 어쩌나 공부 
    rand logic PSEL;
    logic [31:0 ]PRDATA;
    logic PREADY;
    logic [3:0] fndcomm;
    logic [7:0] fndfont;

    constraint c_padder {PADDR inside {4'h0,4'h4,4'h8,4'hC};}
    constraint c_wdata  {
        (PADDR == 0) -> PWDATA inside {0,1};
        (PADDR == 4) -> PWDATA inside {4'b0001, 4'b0010, 4'b0100, 4'b1000};
        (PADDR == 8) -> PWDATA < 10000;
        (PADDR == 12) -> PWDATA <4'b1111;
    }

    task display(string name);
        $display ("[%s] PADDR=%h, PWDATA=%h, PWRITE=%h, PENABLE=%h, PSEL=%h, PRDATA=%h, PREADY=%h, fndCom=%h, fndFont=%h",
            name, PADDR, PWDATA, PWRITE, PENABLE, PSEL, PRDATA, PREADY, fndcomm,
            fndfont);
    endtask

endclass

interface APB_Slave_Interface; // dut와 연결 입출력 가능 

    logic PCLK;
    logic PRESET;

    logic [3:0] PADDR;  //4bit???  //알아서 자름 lsb 남김
    logic [31:0] PWDATA;
    logic PWRITE;
    logic PENABLE; //만약 안오면 어쩌나 공부 
    logic PSEL;
    logic [31:0 ]PRDATA;
    logic PREADY;
    logic [3:0] fndcomm;
    logic [7:0] fndfont;

endinterface

class generator;
    mailbox #(transaction) Gen2Drv_mbox;
    event gen_scb_event;
    event gen_event;
   // transaction 마구잡이로 만들지 않고 순서 지키면서 만들기위해

    function new(mailbox#(transaction) Gen2Drv_mbox, event gen_scb_event, event gen_event); // 나중에 env의 멤버 들로 채우기 위해 
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.gen_scb_event = gen_scb_event;
        this.gen_event = gen_event;
    endfunction

    task run(int repeat_count); // 몇개 생성?
        transaction fnd_tr; // handler
        repeat(repeat_count) begin
            fnd_tr = new(); //계속 갱신 // 여기서 instance하기 떄문에 env에서 실체화 할필요 x 
            if(!fnd_tr.randomize()) $error("Randomization fail!"); 
            fnd_tr.display("GEN");
            Gen2Drv_mbox.put(fnd_tr);
            #10;
            ->gen_event;
            @(gen_scb_event); // 순서 지키기 scb 작동할때까지 ㄱㄷ / scb에선s drv를 기다려야 겠지 
        end//for문 비슷

    endtask
endclass

class driver;
    virtual APB_Slave_Interface fnd_intf;
    mailbox#(transaction) Gen2Drv_mbox;
    transaction fnd_tr; // generator로부터 transaction 받기 
    event drv_event;
    event gen_event;  //class간 옮겨다녀야 하기 때문에 env 선언 

    function new(virtual APB_Slave_Interface fnd_intf,mailbox#(transaction) Gen2Drv_mbox,event drv_event, event gen_event); // 여기들어가는건 env를 위해
        this.fnd_intf = fnd_intf;
        this.Gen2Drv_mbox = Gen2Drv_mbox;
        this.drv_event = drv_event;
        this.gen_event = gen_event;
    endfunction 

        task run();
        forever begin // 여기서 시나리오 구성 근데 너무 운에 맡기면 힘들 수 있음 // master의 idle / set up/ access/  과정 
            @(gen_event);
            Gen2Drv_mbox.get(fnd_tr);
            fnd_tr.display("DRV");
            @(posedge fnd_intf.PCLK); // 싱크맞추기 
            fnd_intf.PADDR <= fnd_tr.PADDR; // setup 
            fnd_intf.PWDATA <= fnd_tr.PWDATA;
            fnd_intf.PWRITE <= fnd_tr.PWRITE;
            @(posedge fnd_intf.PCLK);
            fnd_intf.PENABLE <= 1'b1;  //너무 꼬이지 않게 조절 
            fnd_intf.PSEL   <=  fnd_tr.PSEL;
            // @(posedge fnd_intf.PREADY);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            @(posedge fnd_intf.PCLK);
            ->drv_event;
            

        end
        endtask
endclass

class monitor;
    mailbox#(transaction) Mon2Scb_mbox;
    virtual APB_Slave_Interface fnd_intf;
    transaction fnd_tr;
    event drv_event;
    event mon_event;

    function new(mailbox #(transaction) Mon2Scb_mbox, virtual APB_Slave_Interface fnd_intf, event drv_event, event mon_event);
    this.Mon2Scb_mbox = Mon2Scb_mbox;
    this.fnd_intf = fnd_intf;
    this.drv_event = drv_event;
    this.mon_event = mon_event;
    endfunction

    task run();
    forever begin
        fnd_tr = new(); 
        // wait(fnd_intf.PREADY == 1'b1);
        @(drv_event);
        fnd_tr.PADDR   = fnd_intf.PADDR;
        fnd_tr.PWDATA  = fnd_intf.PWDATA;
        fnd_tr.PWRITE  = fnd_intf.PWRITE;
        fnd_tr.PENABLE = fnd_intf.PENABLE;
        fnd_tr.PSEL    = fnd_intf.PSEL;
        fnd_tr.PRDATA  = fnd_intf.PRDATA;
        fnd_tr.PREADY  = fnd_intf.PREADY;
        fnd_tr.fndcomm  = fnd_intf.fndcomm;
        fnd_tr.fndfont = fnd_intf.fndfont;
        Mon2Scb_mbox.put(fnd_tr);
        fnd_tr.display("MON");
        @(posedge fnd_intf.PCLK);
        ->mon_event;
    end
    endtask
endclass

class scoreboard; // ip 같은역할 설계 
    mailbox#(transaction) Mon2Scb_mbox;
    transaction fnd_tr;
    event gen_scb_event;
    event mon_event;

    logic [31:0] ref_fnd_reg[0:3];
    int ref_fndfont[20] = '{
        8'hc0,
        8'hf9,
        8'ha4,
        8'hb0,
        8'h99,
        8'h92,
        8'h82,
        8'hf8,
        8'h80,
        8'h90, // dot 없는 버전 //10개개

        8'hc0 - (2**7),
        8'hf9 - (2**7),
        8'ha4 - (2**7),
        8'hb0 - (2**7),
        8'h99 - (2**7),
        8'h92 - (2**7),
        8'h82 - (2**7),
        8'hf8 - (2**7),
        8'h80 - (2**7),
        8'h90 - (2**7) //10개 
    };

    int write_cnt;
    int read_cnt;
    int pass_cnt;
    int fail_cnt;
    int total_cnt;
    
    function new(mailbox#(transaction) Mon2Scb_mbox, event gen_scb_event,event mon_event);
     // 실체화 
    this.Mon2Scb_mbox = Mon2Scb_mbox;
    this.gen_scb_event = gen_scb_event;
    this.mon_event = mon_event;


    foreach (ref_fnd_reg[i]) begin
        ref_fnd_reg[i] = 0;
    end
    write_cnt = 0;
    read_cnt = 0;
    pass_cnt = 0;
    fail_cnt = 0;
    total_cnt = 0;

    endfunction

    task run();
    integer fd;
    forever begin
        @(mon_event);
        total_cnt++;
        Mon2Scb_mbox.get(fnd_tr);
        fnd_tr.display("SCB");
        
        fd = $fopen("C:/Users/kccistc/Desktop/uvm_output.txt","a"); //덮어쓰기 알아서 다음 줄에 추가 
        if(fd == 0)  begin
            $display("cannot open file");
        end
        $fwrite(fd,"PADDR:%h,PWRITE:%h,PENABLE:%h,PSEL:%h,PRDATA:%h,fndcomm:%h,fndfont:%h\n",fnd_tr.PADDR,fnd_tr.PWRITE,fnd_tr.PENABLE,fnd_tr.PSEL,fnd_tr.PRDATA,fnd_tr.fndcomm,fnd_tr.fndfont);
        $fclose(fd);

        if(fnd_tr.PWRITE & fnd_tr.PSEL) begin 
            write_cnt++;
            ref_fnd_reg[fnd_tr.PADDR[3:2]] = fnd_tr.PWDATA; //해당하는 곳에 집어넣기 
            if(ref_fnd_reg[0][0] == 0) begin //enable 일떄 
                if(4'b0000 != ~fnd_tr.fndcomm) begin
                    $display("Mismatch fndcom offmode: %h != %h", 4'b0000, ~fnd_tr.fndcomm);
                    fail_cnt++;
                end
                else begin
                    $display("Match fndcom offmode: %h != %h", 4'b0000, ~fnd_tr.fndcomm);  ;// reg에는 FMR/FDR 값 / fnd 에는 lookuptable
                    pass_cnt++;
                end // 다꺼짐 
            end
            else begin // enable 일때 

                if(ref_fnd_reg[1][3:0] == 4'b0001) begin // 첫번쨰 자리수 
                    if(ref_fnd_reg[1][3:0] & ref_fnd_reg[3][3:0]) begin // dot 있으면 
                        if(ref_fndfont[10+((ref_fnd_reg[2])%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2])%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2])%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    else begin
                         if(ref_fndfont[((ref_fnd_reg[2])%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2])%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2])%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                end

                else if(ref_fnd_reg[1][3:0] == 4'b0010) begin //2번쨰 자리수 
                     if(ref_fnd_reg[1][3:0] & ref_fnd_reg[3][3:0]) begin // dot 있으면 
                        if(ref_fndfont[10+((ref_fnd_reg[2]/10)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/10)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/10)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    else begin
                         if(ref_fndfont[((ref_fnd_reg[2]/10)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/10)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/10)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                end

                else if(ref_fnd_reg[1][3:0] == 4'b0100) begin
                    if(ref_fnd_reg[1][3:0] & ref_fnd_reg[3][3:0]) begin // dot 있으면 
                        if(ref_fndfont[10+((ref_fnd_reg[2]/100)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/100)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/100)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    else begin
                         if(ref_fndfont[((ref_fnd_reg[2]/100)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/100)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/100)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    
                end

                else if(ref_fnd_reg[1][3:0] == 4'b1000) begin 
                     if(ref_fnd_reg[1][3:0] & ref_fnd_reg[3][3:0]) begin // dot 있으면 
                        if(ref_fndfont[10+((ref_fnd_reg[2]/1000)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/1000)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[10+((ref_fnd_reg[2]/1000)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    else begin
                         if(ref_fndfont[((ref_fnd_reg[2]/1000)%10)] != fnd_tr.fndfont) begin
                                $display("Mismatch fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/1000)%10)], fnd_tr.fndfont);
                                fail_cnt++;
                        end
                        else begin
                                $display("Match fndFont: %h != %h", ref_fndfont[((ref_fnd_reg[2]/1000)%10)], fnd_tr.fndfont);
                                pass_cnt++;
                        end
                    end
                    
                end

                // read일떄 

                end

            end

            else if(~fnd_tr.PWRITE & fnd_tr.PSEL) begin
                read_cnt++;
                if(ref_fnd_reg[fnd_tr.PADDR[3:2]] != fnd_tr.PRDATA) begin
                    $display("Mismatch PRDATA: %h != %h", ref_fnd_reg[fnd_tr.PADDR[3:2]], fnd_tr.PRDATA);
                    fail_cnt++;
                end //얘가 slv 내용임임
                else begin
                     $display("Match PRDATA: %h != %h", ref_fnd_reg[fnd_tr.PADDR[3:2]], fnd_tr.PRDATA);
                     pass_cnt++;
                end //얘가 slv 내용임임
                end
            

            else begin
                    $display("not selected");
            end
                
            
        #10;
        ->gen_scb_event;
    end
        




        
    endtask
endclass

class environment;
    mailbox #(transaction) Gen2Drv_mbox;
    mailbox #(transaction) Mon2Scb_mbox;
    generator fnd_gen; //handler
    driver fnd_drv;
    monitor fnd_mon;
    scoreboard fnd_scb;
    event gen_scb_event;
    event gen_event;
    event drv_event;
    event mon_event;
  // 실제활용 => 다른애들 매개변수로 넣어주기

    function new (virtual APB_Slave_Interface fnd_intf); //실체화 할꺼 하기
    Gen2Drv_mbox = new();
    Mon2Scb_mbox = new();
    this.fnd_gen = new(Gen2Drv_mbox,gen_scb_event,gen_event);
    this.fnd_drv = new(fnd_intf,Gen2Drv_mbox,drv_event,gen_event);
    this.fnd_mon = new(Mon2Scb_mbox,fnd_intf,drv_event,mon_event);
    this.fnd_scb = new(Mon2Scb_mbox,gen_scb_event,mon_event);
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


module tb_verifi_fnd();
    int write_cnt;
    int read_cnt;
    int pass_cnt;
    int fail_cnt;
    int total_cnt;
environment fnd_env;
APB_Slave_Interface fnd_intf(); // 실체화화

always #5 fnd_intf.PCLK = ~fnd_intf.PCLK;

ABP_interface_fnd u_dut (
    .PCLK(fnd_intf.PCLK),
    .PRESET(fnd_intf.PRESET),
    .PADDR(fnd_intf.PADDR),  //4bit???  //알아서 자름 lsb 남김
    .PWDATA(fnd_intf.PWDATA),
    .PWRITE(fnd_intf.PWRITE),
    .PENABLE(fnd_intf.PENABLE),
    .PSEL(fnd_intf.PSEL),
    .PRDATA(fnd_intf.PRDATA),
    .PREADY(fnd_intf.PREADY),
    .fndcomm(fnd_intf.fndcomm),
    .fndfont(fnd_intf.fndfont)
    // output logic [7:0] outPort
);

initial begin
    fnd_intf.PCLK = 0;
    fnd_intf.PRESET = 1'b1;
    #10 fnd_intf.PRESET = 0;
    fnd_env = new(fnd_intf);
    fnd_env.run(1000);
    #30;
    $display("total_cnt:%d,write_cnt:%d,read_cnt: %d,pass_cnt: %d,fail_cnt:%d, not_sel_cnt:%d", fnd_env.fnd_scb.total_cnt,fnd_env.fnd_scb.write_cnt,fnd_env.fnd_scb.read_cnt,fnd_env.fnd_scb.pass_cnt,fnd_env.fnd_scb.fail_cnt,fnd_env.fnd_scb.total_cnt -(fnd_env.fnd_scb.write_cnt + fnd_env.fnd_scb.read_cnt) );
    $finish;
end

endmodule
