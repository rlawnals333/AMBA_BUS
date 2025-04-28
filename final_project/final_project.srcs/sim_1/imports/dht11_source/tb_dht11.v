`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/26 12:14:25
// Design Name: 
// Module Name: tb_dht11
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


module tb_dht11();

reg clk, reset, btn_start;
wire [3:0] led_state, fsm_state;
wire[39:0] dht11_data;
wire [3:0] fnd_comm,led_mode;
wire [7:0] fnd_font;
wire dht_io;
reg io_oe;
wire led;
reg dht_sensor_data;
assign dht_io = (~io_oe) ? dht_sensor_data : 1'bz;
reg [$clog2(80)-1:0] rand_width;
reg [$clog2(58*400)-1:0 ] random_echo;
reg rx_in;
wire tx_out;

reg echo;
wire start_trigger;
reg [2:0] sw_mode;


system_top_module u_top (
    //기본
    .clk(clk),
    .reset(reset),
    

    //uart 통신
    .pc_rx_in(rx_in),

    .pc_tx_out(tx_out),

    //버튼
    .btn_run(0), // 스탑워치 run
    .btn_clear_hour_up(0), // 시계 시 증가/ 스탑워치 클리어/ 온습도, 울트라 소닉 동작 시작 
    .btn_sec_up(0), // 시계 초 증가
    .btn_min_up(0), // 시계 분 증가

    //초음파
    .us_echo(echo),
    .us_start_trigger(start_trigger),

    //스위치
    .sw_mode(sw_mode), 

    //온습도
    .dht_io(dht_io),
    
    //온습도 led 모드
    // output [4:0] led,

    //display
    .fnd_comm(fnd_comm),
    .fnd_font(fnd_font)

    );

always #5 clk = ~clk; 
integer j;
initial begin
reset = 0;
clk = 0;
#1000;
reset = 1'b1;
// for(j=0;j<10;j=j+1) begin
// end
#1000;
watch_sim();



$stop;


end

// initial end 랑 endmodule 사이 

task data_send_dht (); 
integer i;
begin
rand_width = $random%80;
#50000;
$display("send width %d",rand_width);
dht_sensor_data = 1'b1;
for(i=0;i<rand_width;i=i+1) begin
    #1000;
end
dht_sensor_data = 1'b0;
end
endtask

task send_echo();
    integer i;

    begin
        random_echo = 100*$random%58*400;
        $display("sending echo_width: %h", random_echo);
        echo = 1'b1;
    
        for(i = 0; i<random_echo; i=i+1) begin
            @(posedge clk); 
        end
        #5;
        echo = 1'b0;
        $display("echo sent: %h", random_echo);

        #1000000;

    end
endtask


task send_data(input [7:0] data );
    integer i;
    begin
      
        $display("sending data: %h",data);
        rx_in = 0;
        #(10*10417);

        for(i = 0; i<8; i=i+1) begin
            rx_in = data[i];
            #(10*10417); 
        end
        rx_in =1;
        #(15*10417);
        $display("DATA sent: %h", data);

    end
endtask

task dht_sim ();
integer i;
begin
$display("start dht_11 sensor simulation");
io_oe = 1'b1;
sw_mode=3'b111;
#100;
reset = 0;
#100;
send_data("R");
wait(dht_io == 0);
wait(dht_io== 1'b1);
#29990;
io_oe = 0;
dht_sensor_data =0;
#80000;
dht_sensor_data = 1'b1;
#80000;
dht_sensor_data = 1'b0;

for(i=0;i<40;i=i+1) begin
    $display("%d th", i);
    data_send_dht();
end

$display("finish dht_11 sensor simulation");
end

endtask

task us_sim();
begin
$display("start ultrasonic senosor simulation");
reset = 0;
#100;
sw_mode=3'b100;
#100;
send_data("R");
#1000;

send_echo();

$display("finish ultrasonic senosor simulation");
end
endtask


task stop_watch_sim();
begin
$display("stopwatch sim start");
reset = 0;
#100;
sw_mode = 3'b000; // 스탑워치 밀리초초
send_data("R");
#100000000;
send_data("R");
#100;
send_data("C");
$display("stopwatch sim finish");
end
endtask

task watch_sim();
integer i;
begin
$display(" watch sim start");
reset = 0;
#100;
sw_mode = 3'b011; // 스탑워치 시간간

for(i=0; i<10; i=i+1) begin
send_data("H");
#10000000;
end

for(i=0; i<10; i=i+1) begin
send_data("m");
#10000000;
end


$display("watch sim finish");
end
endtask

endmodule
//tast 모듈안에서

