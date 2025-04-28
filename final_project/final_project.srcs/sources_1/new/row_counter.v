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


module row_counter_dht_temperature(
    input clk,
    input reset,
    input is_done,
    input btn_start,
    input [39:0] dht_in,
    input checksum,
    input [2:0] sw_mode,


    output start_trigger,
    output [7:0] tx_data
);
    localparam IDLE = 0, START = 1;
    reg current_state,next_state;
    reg c_start, n_start;

  
    assign start_trigger = c_start;
    reg [4:0] c_count, n_count;
    reg [7:0] c_tx, n_tx;
    reg n_done;
    wire done_edge = ((is_done == 1'b0)&&(n_done == 1'b1))? 1'b1 : 1'b0;
    
    assign tx_data = c_tx;

    wire [3:0] rh_int_10 ,rh_int_1 ,rh_dec_10 ,rh_dec_1 ,t_int_10, t_int_1 ,t_dec_10 ,t_dec_1; 
    wire [7:0] ascii_rh_int_10 ,ascii_rh_int_1 ,ascii_rh_dec_10 ,ascii_rh_dec_1 ,ascii_t_int_10, ascii_t_int_1 ,ascii_t_dec_10 ,ascii_t_dec_1; 
 


digit_split_dht u_digit_split(

    .dht(dht_in),

    .rh_int_10(rh_int_10),
    .rh_int_1(rh_int_1),

    .rh_dec_10(rh_dec_10),
    .rh_dec_1(rh_dec_1),

    .t_int_10(t_int_10),
    .t_int_1(t_int_1),

    .t_dec_10(t_dec_10),
    .t_dec_1(t_dec_1)
); 

hex2ascii conv_rh_int_10 (
    .i_data(rh_int_10),

    .o_data(ascii_rh_int_10)
);
hex2ascii conv_rh_int_1 (
    .i_data(rh_int_1),

    .o_data(ascii_rh_int_1)
);

hex2ascii conv_rh_dec_10 (
    .i_data(rh_dec_10),

    .o_data(ascii_rh_dec_10)
);
hex2ascii conv_rh_dec_1 (
    .i_data(rh_dec_1),

    .o_data(ascii_rh_dec_1)
);


hex2ascii conv_t_int_10 (
    .i_data(t_int_10),

    .o_data(ascii_t_int_10)
);

hex2ascii conv_t_int_1 (
    .i_data(t_int_1),

    .o_data(ascii_t_int_1)
);

hex2ascii conv_t_dec_10 (
    .i_data(t_dec_10),

    .o_data(ascii_t_dec_10)
);

hex2ascii conv_t_dec_1 (
    .i_data(t_dec_1),

    .o_data(ascii_t_dec_1)
);



    always @(posedge clk, posedge reset) begin
        if(reset) begin
            c_start <= 0;
            current_state <= IDLE;
            c_count <= 0;
            c_tx <= 0;
            n_done <= 0;
        end

        else begin
            c_start <= n_start;
            current_state <= next_state;
            c_count <= n_count;
            c_tx <= n_tx;
            n_done <= is_done;
        end
    end
    
    always @(*) begin
        n_start = 0;
        n_count = c_count;
        n_tx = c_tx;
        next_state = current_state;

        case(current_state)
        IDLE:begin
                n_tx = "T"; // 첫번째 글자 
                n_count = 0;
                if(btn_start & (sw_mode == 3'b111) ) begin
                    next_state = START;
                    
                end
            end
    
        
        START: begin
    
        if(done_edge) begin
             n_tx =  (c_count == 0) ? ":" :
                (c_count == 1) ? ascii_t_int_10:
                (c_count == 2) ? ascii_t_int_1:
                (c_count == 3) ? ".":
                (c_count == 4) ? ascii_t_dec_10:
                (c_count == 5) ? ascii_t_dec_1:
                (c_count == 6) ? "," :
                (c_count == 7) ? "c":
                (c_count == 8) ? "h":
                (c_count == 9) ? "k":
                 (c_count == 10) ? ":":
                (c_count == 11) ? (checksum)? "o" : "x" :
                (c_count == 12) ? 8'h0A : 0; // 완전 else NULL
            if(c_count == 13) begin
                next_state = IDLE;

                
            end

            else begin
                n_count = c_count + 1;
                n_start = 1'b1;
            end
        end
        else n_tx = c_tx;
        end
        endcase
     end
    
    
endmodule

module row_counter_dht_humidity(
    input clk,
    input reset,
    input is_done,
    input btn_start,
    input [39:0] dht_in,
    input checksum,
    input [2:0] sw_mode,


    output start_trigger,
    output [7:0] tx_data
);
    localparam IDLE = 0, START = 1;
    reg current_state,next_state;
    reg c_start, n_start;

  
    assign start_trigger = c_start;
    reg [4:0] c_count, n_count;
    reg [7:0] c_tx, n_tx;
    reg n_done;
    wire done_edge = ((is_done == 1'b0)&&(n_done == 1'b1))? 1'b1 : 1'b0;
    
    assign tx_data = c_tx;

    wire [3:0] rh_int_10 ,rh_int_1 ,rh_dec_10 ,rh_dec_1 ,t_int_10, t_int_1 ,t_dec_10 ,t_dec_1; 
    wire [7:0] ascii_rh_int_10 ,ascii_rh_int_1 ,ascii_rh_dec_10 ,ascii_rh_dec_1 ,ascii_t_int_10, ascii_t_int_1 ,ascii_t_dec_10 ,ascii_t_dec_1; 
 


digit_split_dht u_digit_split(

    .dht(dht_in),

    .rh_int_10(rh_int_10),
    .rh_int_1(rh_int_1),

    .rh_dec_10(rh_dec_10),
    .rh_dec_1(rh_dec_1),

    .t_int_10(t_int_10),
    .t_int_1(t_int_1),

    .t_dec_10(t_dec_10),
    .t_dec_1(t_dec_1)
); 

hex2ascii conv_rh_int_10 (
    .i_data(rh_int_10),

    .o_data(ascii_rh_int_10)
);
hex2ascii conv_rh_int_1 (
    .i_data(rh_int_1),

    .o_data(ascii_rh_int_1)
);

hex2ascii conv_rh_dec_10 (
    .i_data(rh_dec_10),

    .o_data(ascii_rh_dec_10)
);
hex2ascii conv_rh_dec_1 (
    .i_data(rh_dec_1),

    .o_data(ascii_rh_dec_1)
);


hex2ascii conv_t_int_10 (
    .i_data(t_int_10),

    .o_data(ascii_t_int_10)
);

hex2ascii conv_t_int_1 (
    .i_data(t_int_1),

    .o_data(ascii_t_int_1)
);

hex2ascii conv_t_dec_10 (
    .i_data(t_dec_10),

    .o_data(ascii_t_dec_10)
);

hex2ascii conv_t_dec_1 (
    .i_data(t_dec_1),

    .o_data(ascii_t_dec_1)
);



    always @(posedge clk, posedge reset) begin
        if(reset) begin
            c_start <= 0;
            current_state <= IDLE;
            c_count <= 0;
            c_tx <= 0;
            n_done <= 0;
        end

        else begin
            c_start <= n_start;
            current_state <= next_state;
            c_count <= n_count;
            c_tx <= n_tx;
            n_done <= is_done;
        end
    end
    
    always @(*) begin
        n_start = 0;
        n_count = c_count;
        n_tx = c_tx;
        next_state = current_state;

        case(current_state)
        IDLE:begin
                n_tx = "R"; // 첫번째 글자 
                n_count = 0;
                if(btn_start & (sw_mode == 3'b101) ) begin
                    next_state = START;
                    
                end
            end
    
        
        START: begin
    
        if(done_edge) begin
             n_tx =  (c_count == 0) ? "H" :
                (c_count == 1) ? ":" :
                (c_count == 2) ? ascii_rh_int_10 :
                (c_count == 3) ? ascii_rh_int_1 :
                (c_count == 4) ? ".":
                (c_count == 5) ? ascii_rh_dec_10 :
                (c_count == 6) ? ascii_rh_dec_1 :
                (c_count == 7) ? "%" :
                (c_count == 8) ? "," :
                (c_count == 9) ? "c":
                (c_count == 10) ? "h":
                (c_count == 11) ? "k":
                 (c_count == 12) ? ":":
                (c_count == 13) ? (checksum)? "o" : "x" :
                (c_count == 14) ? 8'h0A : 0; // 완전 else NULL
            if(c_count == 15) begin
                next_state = IDLE;

                
            end

            else begin
                n_count = c_count + 1;
                n_start = 1'b1;
            end
        end
        else n_tx = c_tx;
        end
        endcase
     end
    
    
endmodule

module row_counter_us (
    input clk,
    input reset,
    input is_done,
    input btn_start,
    input [8:0] distance,
    input [2:0]sw_mode,

    output start_trigger,
    output [7:0] tx_data
);
    localparam IDLE = 0, START = 1;
    reg current_state,next_state;
    reg c_start, n_start;

  
    assign start_trigger = c_start;
    reg [3:0] c_count, n_count;
    reg [7:0] c_tx, n_tx;
    reg n_done;
    wire done_edge = ((is_done == 1'b0)&&(n_done == 1'b1))? 1'b1 : 1'b0;
      assign tx_data = c_tx;

    wire [3:0] d_100,d_10,d_1;
    wire [7:0] dist_100, dist_10,dist_1;


digit_split_us u_digit_split(
    .distance(distance),

    .distance_100(d_100),
    .distance_10(d_10),
    .distance_1(d_1)
); 

hex2ascii conv_100 (
    .i_data(d_100),

    .o_data(dist_100)
);
hex2ascii conv_10 (
    .i_data(d_10),

    .o_data(dist_10)
);

hex2ascii conv_1 (
    .i_data(d_1),

    .o_data(dist_1)
);


    always @(posedge clk, posedge reset) begin
        if(reset) begin
            c_start <= 0;
            current_state <= IDLE;
            c_count <= 0;
            c_tx <= 0;
            n_done <= 0;
        end

        else begin
            c_start <= n_start;
            current_state <= next_state;
            c_count <= n_count;
            c_tx <= n_tx;
            n_done <= is_done;
        end
    end
    
    always @(*) begin
        n_start = 0;
        n_count = c_count;
        n_tx = c_tx;
        next_state = current_state;
        case(current_state)
        IDLE:begin
            n_tx = "d"; // 첫번째 글자 
            n_count = 0;
            if(btn_start & (sw_mode == 3'b100)) begin
                next_state = START;
                
            end
        end
        
        START: begin
           
        if(done_edge) begin
             n_tx =  (c_count == 0) ? "i" :
                (c_count == 1) ? "s" :
                (c_count == 2) ? "t" :
                (c_count == 3) ? "a" :
                (c_count == 4) ? "n" :
                (c_count == 5) ? "c" :
                (c_count == 6) ? "e" :
                (c_count == 7) ? ":" :
                (c_count == 8) ? dist_100:
                (c_count == 9) ? dist_10 :
                (c_count == 10) ? dist_1 :
                (c_count == 11) ? "c" :
                (c_count == 12) ? "m" :
                (c_count == 13) ? 8'h0A : 0; // 완전 else NULL
            if(c_count == 14) begin
                next_state = IDLE;

                
            end

            else begin
                n_count = c_count + 1;
                n_start = 1'b1;
            end
        end
        else n_tx = c_tx;
    end
endcase
    end
    
    
endmodule



