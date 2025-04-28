`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/03/11 23:23:25
// Design Name: 
// Module Name: fnd_controller
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
//mux case문 

module fnd_controller#(parameter DIVE_SIZE = 50_000)(
    input clk,
    input reset,

    input [3:0] fontR_1,
    input [3:0] fontR_10,

    input [3:0] fontL_1,
    input [3:0] fontL_10,
   
    input [2:0] sw_mode,  
    input [$clog2(100)-1:0] bcd_msec, // fnd_dot 때문에 
    // input [3:0] fnd_dot,

    output [3:0] fnd_comm,
    output [7:0] fnd_font
    );

    wire div_tick;
    wire [2:0] sel;


    wire [3:0] font2bcd;
    wire [3:0] fnd_dot;

    
 

clk_div #(.FCOUNT(DIVE_SIZE)) u_clk_div (    
    .clk(clk),
    .reset(reset),
    .run(1'b1),

    .o_tick(div_tick)
);


tick_count #(.FCOUNT(8)) u_count_8(
    .clk(clk),
    .reset(reset),
    .tick(div_tick),
    .clear(1'b0),

    .o_tick(),
    .bcd(sel)
);



MUX_8x1 mux8_1 (
    .sel(sel),
    .fontL_1(fontL_1),
    .fontL_10(fontL_10),
    .fontR_1(fontR_1),
    .fontR_10(fontR_10),

    .fnd_dot(fnd_dot),

    .font(font2bcd)
);


bcd_seg u_bcd_seg (
    .font(font2bcd),

    .fnd_font(fnd_font)
);

mux_3_4 u_comm_mux (
    .sel(sel),

    .fnd_comm(fnd_comm)
);

comparator_dot u_comparator(
    .sw_mode(sw_mode),
    .msec(bcd_msec),

    .fnd_dot(fnd_dot)

);

endmodule

module MUX_8x1 (
    input [2:0]sel,
    input [3:0] fontL_1,
    input [3:0] fontL_10,
    input [3:0] fontR_1,
    input [3:0] fontR_10,

    input[3:0] fnd_dot,

    output reg [3:0] font
);

    always @(*) begin
        font = fontR_1;
        case (sel)
        3'b000: font = fontR_1;
        3'b001: font = fontR_10; 
        3'b010: font = fontL_1; 
        3'b011: font = fontL_10; 
        3'b100: font = 4'hF; 
        3'b101: font = 4'hF; 
        3'b110: font = fnd_dot; 
        3'b111: font = 4'hF;  
             
        endcase
    end
    
endmodule


module bcd_seg (
    input [3:0] font,

    output reg [7:0] fnd_font
);
    
    always @(*) begin
        fnd_font = 8'hFF;
        case (font)
        4'h0: fnd_font = 8'hC0;
        4'h1: fnd_font = 8'hF9;
        4'h2: fnd_font = 8'hA4;
        4'h3: fnd_font = 8'hB0;
        4'h4: fnd_font = 8'h99;
        4'h5: fnd_font = 8'h92;
        4'h6: fnd_font = 8'h82;
        4'h7: fnd_font = 8'hF8;
        4'h8: fnd_font = 8'h80;
        4'h9: fnd_font = 8'h90;
        4'ha: fnd_font = 8'h7F; // dot
        4'hb: fnd_font = 8'h83;
        4'hc: fnd_font = 8'hC6;
        4'hd: fnd_font = 8'hA1;
        4'he: fnd_font = 8'h86;
        4'hf: fnd_font = 8'hFF; // 다꺼짐짐
        endcase
    end
endmodule

module mux_3_4 (
    input [2:0] sel,

    output reg [3:0] fnd_comm
);
    
    always @(*) begin
        fnd_comm = 4'b1110;
        case (sel)
        3'b000: fnd_comm = 4'b1110;
        3'b001: fnd_comm = 4'b1101;
        3'b010: fnd_comm = 4'b1011;
        3'b011: fnd_comm = 4'b0111;
        3'b100: fnd_comm = 4'b1110;
        3'b101: fnd_comm = 4'b1101;
        3'b110: fnd_comm = 4'b1011;
        3'b111: fnd_comm = 4'b0111; 
    
        endcase
    end
endmodule

module comparator_dot(
    input [$clog2(100)-1 : 0] msec,
    input [2:0] sw_mode,

    output [3:0] fnd_dot

);

assign fnd_dot = ((sw_mode != 3'b100)  && (msec < 50)) ? 4'ha : 4'hF ;

endmodule

// module mux_dot (
//     input sel_dot,

//     output reg [3:0] fnd_dot
// );
//     always @(*) begin
//         case (sel_dot)
//             1'b0: fnd_dot = 4'hF;
//             1'b1: fnd_dot = 4'ha;
//         endcase
//     end
// endmodule

//16번쨰에서 먼가 이상함 