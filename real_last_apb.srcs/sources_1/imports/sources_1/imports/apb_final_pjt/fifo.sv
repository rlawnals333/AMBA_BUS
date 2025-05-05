`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/25 11:31:05
// Design Name: 
// Module Name: fifo
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


module fifo(
    input logic clk,
    input logic reset,
    output logic [7:0] rData,
    input logic [7:0] wData,
    input logic wr_en,
    input logic rd_en,
    output logic full,
    output logic empty
    );

    logic [1:0] wAddr, rAddr;
    
    memory_fifo u_momory_fifo(
     .clk(clk),
     .wAddr(wAddr),
     .wData(wData),
     .wr_en(wr_en&~full), //full 될때는 ptr은 올라가지만 write은 안됨 // full 되고 나서는 ptr 안올라감 
     .rAddr(rAddr),
     .rdata(rData)
    );
    fifo_control_unit CU (
    .clk(clk),
    .reset(reset),
    //write side
    .wr_ptr(wAddr),
    .wr_en(wr_en),
    .full(full),
    //read side
    .rd_ptr(rAddr),
    .rd_en(rd_en),
    .empty(empty)
);

    
endmodule

module memory_fifo(
    input logic clk,
    input logic [1:0] wAddr,
    input logic [7:0] wData,
    input logic       wr_en,
    input logic [1:0] rAddr,
    output logic [7:0] rdata
);
    logic [7:0] mem [0:(2**2)-1];

    always_ff @( posedge clk ) begin 
        if(wr_en) mem[wAddr] <= wData;
    end

    assign rdata = mem[rAddr];

endmodule

module fifo_control_unit (
    input logic clk,
    input logic reset,
    //write side
    output logic [1:0] wr_ptr,
    input logic wr_en,
    output logic full,
    //read side
    output logic [1:0] rd_ptr,
    input  logic rd_en,
    output logic empty
);

localparam READ = 2'b01,WRITE = 2'b10, READ_WRITE = 2'b11;
logic [1:0] wr_ptr_reg, rd_ptr_reg,wr_ptr_next, rd_ptr_next;
logic full_reg, empty_reg,full_next, empty_next;
logic [1:0] fifo_state;

assign fifo_state = {wr_en,rd_en}; // state 자동 저장 좋은 기법이군
assign wr_ptr = wr_ptr_reg;
assign rd_ptr = rd_ptr_reg; // rd 신호 한클럭 뒤에 더해짐  
assign full = full_reg;
assign empty = empty_reg;

always_ff@(posedge clk, posedge reset) begin
    if(reset) begin
        wr_ptr_reg <= 0;
        rd_ptr_reg <= 0;
        full_reg <= 0;
        empty_reg <= 1'b1;
    end
    else begin
        wr_ptr_reg <= wr_ptr_next;
        rd_ptr_reg <= rd_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end
end

always_comb begin : fifo_comb // case combinational // next 하지않는이상 틱으로 동작 
    wr_ptr_next = wr_ptr_reg;
    rd_ptr_next = rd_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;

    case(fifo_state)
    READ: begin
        if(empty_reg == 1'b0) begin
            full_next = 0;
            rd_ptr_next = rd_ptr_reg + 1;
            if(wr_ptr_reg == rd_ptr_next) begin
                empty_next = 1'b1;
            end
        end
    end
    WRITE: begin
        if(full_reg == 0) begin
            empty_next = 1'b0;
            wr_ptr_next = wr_ptr_reg + 1;
            if(wr_ptr_next == rd_ptr_reg) begin
                full_next = 1'b1;
            end
        end
    end
    READ_WRITE: begin
        if(empty_reg == 1'b1) begin
            wr_ptr_next = wr_ptr_reg + 1;
            empty_next = 0;
        end
        else if(full_reg == 1'b1) begin
            rd_ptr_next = rd_ptr_reg + 1;
            full_next = 0;
        end

        else begin
            wr_ptr_next = wr_ptr_reg + 1;
            rd_ptr_next = rd_ptr_reg + 1;
        end
    end
    endcase
end


  
endmodule