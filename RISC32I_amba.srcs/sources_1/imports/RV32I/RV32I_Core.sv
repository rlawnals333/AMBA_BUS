`timescale 1ns / 1ps

module RV32I_Core (
    input logic clk,
    input logic reset,
    input logic [31:0] instrCode,
    input logic [31:0] ram_rData,
    output logic [31:0] instrMemAddr,
    input logic ready,
    output logic transfer,

    //ram
    // output logic data_we,
    output logic [31:0] data_Addr,
    output logic [31:0] dataWdata,
    output logic memaccess_en, writeback_en

);
    wire       regFileWe;
    wire [3:0] aluControl;
    wire AlUSrcMuxSel,reg_wData_MuxSel;  // cu <=> dp 사이 
    wire is_j;
    wire       alu_mux_sel2;
    wire [2:0] reg_wData_half_Sel;
    wire jal;
    wire [1:0] s_half;
    wire is_b;
    wire fetch_en, decode_en, execute_en;
    wire pc_en;
 

    

 

    ControlUnit U_ControlUnit (.*);
    DataPath U_DataPath (.*);

endmodule

