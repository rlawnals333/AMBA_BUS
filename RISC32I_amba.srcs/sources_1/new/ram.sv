`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/04/09 11:54:40
// Design Name: 
// Module Name: ram
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


module ram(//이제 cpu 말고 bus랑 놀아야됨 
    input logic PCLK,
    input logic PRESET,

    input logic [31:0] PADDR, //12bit?  //4bit???  //알아서 자름 lsb 남김
    input logic [31:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,

    output logic [31:0] PRDATA,
    output logic PREADY


    // input logic memaccess_en, writeback_en,


    // output logic [31:0] rData
    );
    logic [31:0] mem[0:63]; // 10bit?
    // logic [31:0] temp_rData;

 logic c_ready, n_ready;

    assign PREADY = n_ready;
 
    always_ff @(posedge PCLK, posedge PRESET) begin
        if (PRESET) begin
            PRDATA <= 0;
            // PREADY <= 0;
            c_ready <= 0;
          
        end else begin
            c_ready <= n_ready;
      
            
            if(PSEL) begin
                if (PWRITE) begin
                    // 0000 => 0004 => 0008 => 000C 이런식으로 움직임 [3:2]만 바뀜
                    mem[PADDR[31:2]] <= PWDATA;
                    
                end else begin    
                 PRDATA <= mem[PADDR[31:2]];
               
                end
            
        end
        end
    end

    always_comb begin
        n_ready = c_ready;
        if(PENABLE && PSEL)  n_ready = 1'b1;
        else n_ready =0;
    end
  

    // always_ff@(posedge clk) begin // write
        
    //     if(memaccess_en) begin
    //         mem[addr[31:2]] <= wData; 
           
    //     end
        
    // end

    // assign temp_rData = mem[PADDR]; //read 

        register U_ram_reg (
        .clk(PCLK),
        .reset(PRESET),
        .en(PWRITE),
        .d(mem[PADDR]),
        .q(PRDATA)
       
    );


endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    input  logic        en,
    output logic [31:0] q

);
   

    always_ff @(posedge clk, posedge reset) begin
        if (reset) 
        begin
            q <= 0;
           
        end
        else begin
        
             if(en) q <= d;
           
        end
    end

endmodule
