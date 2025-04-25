`timescale 1ns / 1ps

`include "defined.sv"

module DataPath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instrCode,
    output logic [31:0] instrMemAddr,
    input  logic        regFileWe,
    input  logic [3:0]  aluControl,
    input  logic [2:0]  reg_wData_half_Sel, // half/ Byte  
    //imm
    input logic         AlUSrcMuxSel,
    input logic         reg_wData_MuxSel,   
    input logic         is_j,
    input logic         alu_mux_sel2,



    //ram
    input logic [31:0]  ram_rData,
    output logic [31:0] data_Addr,
    output logic [31:0] dataWdata,



    input logic jal,
    input logic is_b,
    input logic [1:0] s_half,
    input logic pc_en,

    input logic fetch_en, decode_en, execute_en

   
);
    wire [31:0] aluResult, RFData1, RFData2 , reg_RFData1, reg_RFData2,reg_aluResult;
    wire [31:0] PCSrcData, PCOutData,reg_PCSrcData;
    wire [31:0] imm_extend, alu_mux_result, wData_mux_result, alu_mux_sel2_result, reg_imm;
   wire [31:0] half_Byte_ram_rdata;
    wire [31:0] pc_mux_result;
    wire [31:0] jal_mux_result;
    wire bitget,reg_bitget;
    // wire is_au = (instrCode[6:0] == 7'b0010111) ? 1'b1 : 0;


    // wire[31:0] alu_wData_mux_result;

  
    assign instrMemAddr = PCOutData;
    assign data_Addr = reg_aluResult;
    // assign dataWdata = RFData2;
    always_comb begin
        dataWdata = reg_RFData2;
        case(s_half)
        2'b11:dataWdata = {{24{reg_RFData2[7]}},reg_RFData2[7:0]};//byte
        2'b10: dataWdata = {{16{reg_RFData2[15]}},reg_RFData2[15:0]};//half
        2'b00: dataWdata = reg_RFData2; //word 
        endcase
    end

    RegisterFile U_RegFile (
        .clk(clk),
        .we(regFileWe),
        .RAddr1(instrCode[19:15]),
        .RAddr2(instrCode[24:20]),
        .WAddr(instrCode[11:7]),
        .WData(wData_mux_result),
        .RData1(RFData1),
        .RData2(RFData2)
    );


     mux_2x1  U_AlU_SrcMux_b( // imm or RFdata2
    .sel(AlUSrcMuxSel),
    .x0(reg_RFData2),
    .x1(reg_imm),

    .y(alu_mux_result)
);

mux_2x1 u_alu_a_mux_sel_a (
    .sel(alu_mux_sel2),

    .x0(reg_RFData1),
    .x1(PCOutData),
   

    .y(alu_mux_sel2_result)

);
    alu U_ALU (
        .aluControl(aluControl),
        .a(alu_mux_sel2_result),
        .b(alu_mux_result),
        .bitget(bitget),
        .result(aluResult)
    );
        
    register excute_aluResult (
        .clk(clk),
        .reset(reset),
        .en(execute_en),
        .d(aluResult),
        .q(reg_aluResult)
        
    );
        
    register_1bit excute_BiTGET (
        .clk(clk),
        .reset(reset),
        .en(execute_en),
        .d(bitget),
        .q(reg_bitget)
        
    );

    register U_PC (
        .clk(clk),
        .reset(reset),
        .en(fetch_en ), //| (execute_en & (is_j | is_b | is_au ))
        .d(reg_PCSrcData),
        .q(PCOutData)
        
    );

    
    register decode_rs1 (
        .clk(clk),
        .reset(reset),
        .en(decode_en),
        .d(RFData1),
        .q(reg_RFData1)
    
    );

        register decode_rs2 (
        .clk(clk),
        .reset(reset),
        .en(decode_en),
        .d(RFData2),
        .q(reg_RFData2)
        
    );



// adv_mux2x1 u_pc_src_mux (
//     .aluResult(aluResult[0]),
//     .sel(pc_MuxSel),
//     .B_mux_sel(is_b),

//     .x0(32'd4),
//     .x1(imm_extend),

//     .y(pc_mux_result)
// );
 
mux_2x1  U_PC_adder_SrcMux( // imm or RFdata2
    .sel((is_b & reg_bitget) | is_j ),
    .x0(32'd4),
    .x1(reg_imm),

    .y(pc_mux_result)
);

mux_2x1  U_JAL_SrcMux( // imm or RFdata2
    .sel(jal),
    .x0(PCOutData),
    .x1(reg_RFData1),

    .y(jal_mux_result)
);
    adder U_PC_Adder (
        .a(jal_mux_result),
        .b(pc_mux_result),
        .y(PCSrcData)
    );

        register U_PC_adder_reg (
        .clk(clk),
        .reset(reset),
        .en(execute_en | pc_en),
        .d(PCSrcData),
        .q(reg_PCSrcData)
     
    );



 decoder half_byte_decoder (
    .reg_wData_half_Sel(reg_wData_half_Sel),
    .ram_wdata(ram_rData),


    .half_Byte_ram_rdata(half_Byte_ram_rdata)

);

     mux_2x1  U_reg_wData_SrcMux(   // wdata에 ram_rdata or alu_result 
    .sel(reg_wData_MuxSel),
    .x0(reg_aluResult),
    .x1(half_Byte_ram_rdata),

    .y(wData_mux_result)
);

extend u_extend (
    .instrCode(instrCode),

    .immExt(imm_extend)
);

register imm_decode_reg (
        .clk(clk),
        .reset(reset),
        .en(decode_en),
        .d(imm_extend),
        .q(reg_imm)
       
    );


endmodule


module alu (
    input  logic [3:0] aluControl,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result,
    output logic bitget

);


    // logic [63:0] mul_result;
    // assign mul_result = a * b;
    always_comb begin
        case (aluControl) //매크로 
            `ADD:   result = a + b; //ADD
            `SUB:   result = a - b; //SUB
            `SLL:   result = a << b; //SLL
            `SRL:   result = a >> b; //SRL
            `SRA:   result = $signed(a) >>> b; //SRA
            `SLT:   result = ($signed(a) < $signed(b)) ? 1 : 0; //SLT
            `SLTU:   result = (a < b) ? 1 : 0; //SLTU
            `XOR:   result = a ^ b; //XOR
            `OR:   result = a | b; //OR
            `AND:   result = a & b; //AND
            // `MULHU:   result =  mul_result[63:32] ;// * // 컴파일러에서 *나온다고 다 mulhu쓴는게 아니라필요할때만 쓰기 때문에 >> 해도됨 
            // `DIVU :   result= a / b; // /
            // `REMU :  result =   a % b; // % 너무 오래걸림
            // `EQUAL: result = (a == b) ? 1 : 0; // EQUAL
            // `NEQUAL: result = ( a != b) ? 1 : 0;
            // `GREATER: result = ($signed(a) >= $signed(b)) ? 1 : 0;
            // `GREATER_U : result = (a >= b) ? 1 : 0;
            `BUFFER    : result = b;
            `JUMP      : result = a + 4;
            default: result = 32'bx;
        endcase
    end

    always_comb begin
    bitget =0;
    case(aluControl)
    `BEQ: bitget =  (a == b) ? 1 : 0;
    `BNE: bitget =  ( a != b) ? 1 : 0;
    `BLT: bitget =  ($signed(a) < $signed(b)) ? 1 : 0;
    `BGE: bitget =  ($signed(a) >= $signed(b)) ? 1 : 0;
    `BLTU:bitget =  (a < b) ? 1 : 0;
    `BGEU:bitget =  (a >= b) ? 1 : 0;
    endcase
end

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
                q <= 0;
        else begin
        
             if(en) q <= d;
           
        end
    end

endmodule

module register_1bit (
    input  logic        clk,
    input  logic        reset,
    input  logic        d,
    input  logic        en,
    output logic         q

);
    logic c_temp, n_temp;

    always_ff @(posedge clk, posedge reset) begin
        if (reset) 
        begin
            q  <= 0;
            
        end
        else begin
        
             if(en) q<= d;
            
        end
    end
 

endmodule


module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] y
);
    assign y = a + b;
endmodule

module RegisterFile (
    input  logic        clk,
    input  logic        we,
    input  logic [ 4:0] RAddr1,
    input  logic [ 4:0] RAddr2,
    input  logic [ 4:0] WAddr,
    input  logic [31:0] WData,
    
    output logic [31:0] RData1,
    output logic [31:0] RData2
);
    logic [31:0] RegFile[0:2**5-1];
    // initial begin
    //     for (int i=0; i<32; i++) begin
    //         RegFile[i] = i;
    //     end
    // end



    always_ff @(posedge clk) begin
        if (we) RegFile[WAddr] <= WData;
    end

    assign RData1 = (RAddr1 != 0) ? RegFile[RAddr1] : 32'b0; // zero 영역
    assign RData2 = (RAddr2 != 0) ? RegFile[RAddr2] : 32'b0;
endmodule

module mux_2x1 (
    input logic sel,
    input logic [31:0] x0,
    input logic [31:0] x1,

    output logic [31:0] y
);
    always_comb begin
        y= 32'bx;
        case(sel)
        0 : y=  x0;
        1 : y = x1;
        endcase
    end
endmodule

module extend (
    input logic [31:0] instrCode,

    output logic [31:0] immExt
);
    wire [6:0] opcode = instrCode[6:0];
    wire [2:0] func3  = instrCode[14:12]; 
    wire [20:0] imm_j = {instrCode[31],instrCode[19:12],instrCode[20],instrCode[30:21],1'b0}; //21비트임 0추가해서
    wire [12:0] imm_b = {instrCode[31],instrCode[7],instrCode[30:25],instrCode[11:8],1'b0}; 

    

    always_comb begin
        immExt = 32'bx;  
        case(opcode)
        `OP_TYPE_R: immExt = 32'bx;
        `OP_TYPE_L: immExt = {{20{instrCode[31]}},instrCode[31:20]};
        `OP_TYPE_S : immExt = {{20{instrCode[31]}},instrCode[31:25], instrCode[11:7]}; // signed일때 대비 
        `OP_TYPE_I : begin
                        case({instrCode[30],func3})
                        4'b0001: immExt = {{27{instrCode[24]}},instrCode[24:20]};
                        4'b0101: immExt = {{27{instrCode[24]}},instrCode[24:20]};
                        4'b1101: immExt = {{27{instrCode[24]}},instrCode[24:20]};
                        default: immExt = {{20{instrCode[31]}},instrCode[31:20]};
                        endcase
        end  
        `OP_TYPE_B : immExt = {{19{imm_b[12]}},imm_b};
        `OP_TYPE_LU: immExt = {{12{instrCode[31]}},instrCode[31:12]} << 12;
        `OP_TYPE_AU: immExt = {{12{instrCode[31]}},instrCode[31:12]} << 12;
       
        `OP_TYPE_J : immExt = {{11{imm_j[20]}} ,imm_j};
        `OP_TYPE_JL : immExt = {{20{instrCode[31]}},instrCode[31:20]};
        endcase
        end
       
    
    
endmodule

module decoder (
    input logic [2:0] reg_wData_half_Sel,

    input logic [31:0] ram_wdata,


    output logic [31:0] half_Byte_ram_rdata

);

always_comb begin
    half_Byte_ram_rdata = ram_wdata;
    case(reg_wData_half_Sel)
    3'b000: begin // word
   
        half_Byte_ram_rdata = ram_wdata;
    end
    3'b001: begin // half
      
        half_Byte_ram_rdata = {{16{ram_wdata[15]}},ram_wdata[15:0]};
    end
    3'b010: begin // byte

        half_Byte_ram_rdata = {{24{ram_wdata[7]}},ram_wdata[7:0]};
    end
    3'b011: begin // half U
     
        half_Byte_ram_rdata = {{24{1'b0}},ram_wdata[15:0]};
    end 
    3'b100: begin // byte U
       
        half_Byte_ram_rdata = {{24{1'b0}},ram_wdata[7:0]};
    end         

    endcase
end
    
endmodule

module adv_mux2x1 (
    input logic aluResult,
    input logic sel,
    input logic B_mux_sel,

    input logic [31:0] x0,
    input logic [31:0] x1,

    output logic [31:0] y
);
    always_comb begin
        y= x0;
        if(B_mux_sel) begin
            case(sel)
            0 : y=  x0;
            1 : begin 
                if(aluResult) y = x1;
                else y = x0;
            end
            endcase
        end
        else begin
             case(sel)
            0 : y=  x0;
            1 :y  = x1;

             endcase
        end
    end
endmodule

// module mux3x1 (
//     input logic [1:0] sel,

//     input logic [31:0] x0,
//     input logic [31:0] x1,
//     input logic [31:0] x2,

//     output logic [31:0] y

// );

//     always_comb begin
//         y = x0;
//         case(sel)
//         2'b00: y = x0;
//         2'b01: y = x1;
//         2'b10: y = x2;
//         endcase

//     end
// endmodule

//LUI는 12bit보다 큰 수 일때