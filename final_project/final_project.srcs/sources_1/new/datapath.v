`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/28 14:09:41
// Design Name: 
// Module Name: datapath
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


module datapath_fnd (
    input clk,
    input reset,

    input [2:0] sw_mode,

    //dht
    input [39:0] dht_data,
    input checksum,
    //us
    input [8:0] distance,

    //watch
    input [$clog2(100)-1 :0] bcd_msec,
    input [$clog2(60)-1 :0]  bcd_sec,
    input [$clog2(60)-1 :0]  bcd_min,
    input [$clog2(24)-1 :0]  bcd_hour,

    // to fnd 

    output[3:0] fontR_10,
    output[3:0] fontR_1,
    output[3:0] fontL_10,
    output[3:0] fontL_1

    


);

    reg [3:0] c_fontR_10,n_fontR_10;
    reg [3:0] c_fontR_1, n_fontR_1;
    reg [3:0] c_fontL_10,n_fontL_10;
    reg [3:0] c_fontL_1, n_fontL_1;
    
    assign fontR_10 = c_fontR_10;
    assign fontR_1 = c_fontR_1;
    assign fontL_10 = c_fontL_10;
    assign fontL_1 = c_fontL_1;

    wire [3:0] rh_int_10 ,rh_int_1 ,rh_dec_10 ,rh_dec_1 ,t_int_10, t_int_1 ,t_dec_10 ,t_dec_1; 
    wire [3:0] distance_10, distance_1, distance_100;

    
    wire [3:0] ascii_rh_int_10 ,ascii_rh_int_1 ,ascii_rh_dec_10 ,ascii_rh_dec_1 ,ascii_t_int_10, ascii_t_int_1 ,ascii_t_dec_10 ,ascii_t_dec_1; 
    wire [3:0] ascii_distance_10, ascii_distance_1, ascii_distance_100;


    wire [3:0] bcd_msec_10,bcd_msec_1,bcd_sec_10,bcd_sec_1;

    wire [3:0] bcd_min_10,bcd_min_1,bcd_hour_10,bcd_hour_1;


digit_split_dht u_digit_dht(

    .dht(dht_data),

    .rh_int_10(rh_int_10),
    .rh_int_1(rh_int_1),

    .rh_dec_10(rh_dec_10),
    .rh_dec_1(rh_dec_1),

    .t_int_10(t_int_10),
    .t_int_1(t_int_1),

    .t_dec_10(t_dec_10),
    .t_dec_1(t_dec_1)
); 

digit_split_us u_digit_us(

    .distance(distance),

    .distance_100(distance_100),
    .distance_10(distance_10),
    .distance_1(distance_1)
); 

digit_split_watch u_digit_watch(

    .bcd_msec(bcd_msec),
    .bcd_sec(bcd_sec),
    .bcd_min(bcd_min),
    .bcd_hour(bcd_hour),


    .bcd_msec_10(bcd_msec_10),
    .bcd_msec_1(bcd_msec_1),
    .bcd_sec_10(bcd_sec_10),
    .bcd_sec_1(bcd_sec_1),

    .bcd_min_10(bcd_min_10),
    .bcd_min_1(bcd_min_1),
    .bcd_hour_10(bcd_hour_10),
    .bcd_hour_1(bcd_hour_1)
); 


    always @(posedge clk, posedge reset) begin
        if(reset) begin
            c_fontL_1 <= 0;
            c_fontL_10 <= 0;
            c_fontR_1 <= 0;
            c_fontR_10 <= 0;
        end

        else begin
            c_fontL_1 <=  n_fontL_1;
            c_fontL_10 <= n_fontL_10;
            c_fontR_1 <= n_fontR_1;
            c_fontR_10 <= n_fontR_10;
        end
    end
    

    always @(*) begin
            n_fontL_1 =  c_fontL_1;
            n_fontL_10 = c_fontL_10;
            n_fontR_1 =  c_fontR_1;
            n_fontR_10 = c_fontR_10;
        case(sw_mode)

        3'b000: begin
                n_fontL_1 = bcd_sec_1; 
                n_fontL_10= bcd_sec_10; 
                n_fontR_1 = bcd_msec_1;
                n_fontR_10= bcd_msec_10;
        end

        3'b001: begin
                n_fontL_1 = bcd_hour_1; 
                n_fontL_10= bcd_hour_10; 
                n_fontR_1 = bcd_min_1;
                n_fontR_10= bcd_min_10;
        end

        3'b010: begin
                n_fontL_1 = bcd_sec_1; 
                n_fontL_10= bcd_sec_10; 
                n_fontR_1 = bcd_msec_1;
                n_fontR_10= bcd_msec_10;
        end

        3'b011: begin
                n_fontL_1 = bcd_hour_1; 
                n_fontL_10= bcd_hour_10; 
                n_fontR_1 = bcd_min_1;
                n_fontR_10= bcd_min_10;
        end

        3'b100: begin
                n_fontL_1 = distance_100;
                n_fontL_10=  0;
                n_fontR_1 = distance_1;
                n_fontR_10= distance_10;
        end

        3'b111: begin
                n_fontL_1 = t_int_1; 
                n_fontL_10= t_int_10; 
                n_fontR_1 = t_dec_1;
                n_fontR_10= t_dec_10;
        end

        3'b101: begin
                n_fontL_1 = rh_int_1;
                n_fontL_10= rh_int_10;
                n_fontR_1 = rh_dec_1;
                n_fontR_10= rh_dec_10;
        end
endcase
    end
    
    
endmodule

module digit_split_dht(

    input [39:0] dht,

    output [3:0] rh_int_10,
    output [3:0] rh_int_1,

    output [3:0] rh_dec_10,
    output [3:0] rh_dec_1,

    output [3:0] t_int_10,
    output [3:0] t_int_1,

    output [3:0] t_dec_10,
    output [3:0] t_dec_1
); 

    

    assign rh_int_10 = dht[39:32] / 10 %10;
    assign rh_int_1 = dht[39:32]  % 10;

    assign rh_dec_10 = dht[31:24] / 10 %10;
    assign rh_dec_1 = dht[31:24]  % 10;


    assign t_int_10 = dht[23:16] / 10 %10;
    assign t_int_1 = dht[23:16]  % 10;

    assign t_dec_10 = dht[15:8] / 10 %10;
    assign t_dec_1 = dht[15:8]  % 10;


endmodule


module digit_split_us(

    input [8:0] distance,

    output [3:0] distance_100,
    output [3:0] distance_10,
    output [3:0] distance_1
); 

    
    assign distance_100 = distance / 100 % 10;
    assign distance_10 = distance / 10 %10;
    assign distance_1 =  distance  % 10;



endmodule

module digit_split_watch(

    input [$clog2(100)-1 :0]  bcd_msec,
    input [$clog2(60)-1 :0]  bcd_sec,
    input [$clog2(60)-1 :0]  bcd_min,
    input [$clog2(24)-1 :0]  bcd_hour,


    output [3:0] bcd_msec_10,
    output [3:0] bcd_msec_1,
    output [3:0] bcd_sec_10,
    output [3:0] bcd_sec_1,

    output [3:0] bcd_min_10,
    output [3:0] bcd_min_1,
    output [3:0] bcd_hour_10,
    output [3:0] bcd_hour_1
); 

    

    assign bcd_msec_10  =  bcd_msec/ 10 %10; 
    assign bcd_msec_1   =  bcd_msec % 10;
    assign bcd_sec_10  =  bcd_sec/ 10 %10;
    assign bcd_sec_1   =  bcd_sec  %10;

    assign bcd_min_10  =  bcd_min/ 10 %10;
    assign bcd_min_1   =  bcd_min %10;
    assign bcd_hour_10 =  bcd_hour/ 10 %10;
    assign bcd_hour_1  =  bcd_hour %10;

endmodule

module hex2ascii (
    input [3:0] i_data,

    output reg [7:0] o_data
);

  always @(*) begin
    o_data = 0;
    case(i_data) 
    0: o_data = "0";
    1: o_data = "1";
    2: o_data = "2";
    3: o_data = "3";
    4: o_data = "4";
    5: o_data = "5";
    6: o_data = "6";
    7: o_data = "7";
    8: o_data = "8";
    9: o_data = "9";
    endcase
  end  
endmodule