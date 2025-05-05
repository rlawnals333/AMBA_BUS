`timescale 1ns / 1ps

`include "defined.sv"
//메모리가 작을 때는 메모리 매핑을 통해 c언어에 명시해야되
//single cycle core : 너무 단순 => multi cycle core: 이거 쓰셈 

// transfer 내보낼 때 bus에서 신호 캡쳐 
//R타입 확장 , mulhu, divu, remu 추가/ 양수만 연산가능 => 실패 : 곱셈연산이 한번에 안끝남 
module ControlUnit (
    input  logic [31:0] instrCode,
    input  logic        clk,
    input  logic        reset,
    output logic        regFileWe,
    output logic [3:0] aluControl,
    //ram
    // output logic data_we,
    output logic AlUSrcMuxSel,
    output logic reg_wData_MuxSel,
    output logic [2:0] reg_wData_half_Sel,
    output logic is_j,
    output logic alu_mux_sel2,
    output logic jal,
    output logic is_b,
    output logic [1:0] s_half, //ram wdata 비트 수
    output logic fetch_en, decode_en, execute_en,memaccess_en,writeback_en,pc_en,

    // amba bus
    output logic transfer, 
    input logic ready



    // decode하면 사실 연산은 끝남 근데 나머지 en 해야 ff로 나오는 구조 
    //pc_en: branch는 2 클럭 사용하기 때문에 (비교 연산 , pc 연산) excute할때 비교/ wait때 pc 연산
    //wait execute : 연산 기다리기 = 이시간에 연산결과 나오니 바로 w신호 내보내는거임 
    //setup은 en신호 전 state에 넣고 저장하는 시간임 
);
    wire [6:0] opcode = instrCode[6:0]; 
    wire [2:0] func3  = instrCode[14:12];
    wire [6:0] func7  = instrCode[31:25];
    wire [3:0] operators_R = {instrCode[30], instrCode[14:12]};  // {func7[5], func3}
    logic [3:0] operators_I;
    logic [3:0] operators_B;
//    logic [3:0] operators_R;
   

    // always_comb begin
    //     operators_R = {instrCode[30], instrCode[14:12]};
    //     if(func7 == 7'b0000001) begin
    //         case(func3)
    //         3'b011: operators_R = `MULHU;
    //         // 3'b101: operators_R = `DIVU;
    //         // 3'b111: operators_R = `REMU;
    //         endcase
    //     end
    // end

    typedef enum { FETCH = 0, DECODE , EXECUTE , WAIT_EXECUTE, MEMACCESS, WRITEBACK} state_e;
    state_e current_state, next_state, d_next_state;

    assign jal = (opcode == `OP_TYPE_JL) ? 1'b1 : 0;
    assign is_j = ((opcode == `OP_TYPE_JL) || (opcode == `OP_TYPE_J) ) ? 1'b1 : 0;
    assign is_b = (opcode == `OP_TYPE_B) ? 1'b1 : 0;

    always_comb begin
        fetch_en = 0;
        decode_en = 0;
        execute_en = 0;
        memaccess_en =0;
        writeback_en = 0;
        regFileWe = 0;
        pc_en =0;
        transfer = 0; //평소 0 나와야되 이런거 깜빡하지마 

        case(current_state)
        FETCH: fetch_en = 1'b1;
        DECODE: decode_en = 1'b1;
        EXECUTE: execute_en = 1'b1;
        //memaccess일때 read/ write 둘다 ready를 받아야지 
           
        
        WRITEBACK: begin
            
            regFileWe = 1'b1;
        end

        MEMACCESS: begin
            memaccess_en = 1'b1;
            transfer =1'b1; // addr값 들감 이떄 bus 신호 내보내야함 
        end
        WAIT_EXECUTE : begin // 이때 addr, wdata,rdata다 준비됌
            case(opcode)
           `OP_TYPE_R: begin
            regFileWe = 1'b1;  // R-Type
           end  
           `OP_TYPE_L:  begin
            // writeback_en = 1'b1;
            transfer = 1'b1; //addr 값 들감  이때 bus 신호 내보내기 
                        end
            `OP_TYPE_B: begin
                pc_en = 1'b1;
            end
           `OP_TYPE_I: begin
            regFileWe = 1'b1;
                        end
           `OP_TYPE_LU: begin
            regFileWe = 1'b1;
                        end // a 무상관
           `OP_TYPE_AU : begin
            regFileWe = 1'b1;
                        end
           `OP_TYPE_J : begin
            regFileWe = 1'b1;
                        end //b 무상관
           `OP_TYPE_JL : begin
            regFileWe = 1'b1;
                        end //b 무상관

            endcase
        end
        endcase
    end
    //    always_ff@(posedge clk, posedge reset) begin
    //   if(reset) d_next_state <= FETCH;
    //      else d_next_state <= next_state;
    // end
    //신호 지연 처리 ㅈ같네네

    always_ff@(posedge clk, posedge reset) begin
        if(reset) begin
             current_state <= FETCH;
      
        end
        else begin
             current_state <= next_state;
            
        end
    end

    always_comb begin
        next_state = FETCH;

    
        case(current_state)
        FETCH: begin
              next_state = DECODE;
        end
        
        DECODE: begin
              next_state = EXECUTE; // 바로 연산됨 
        end
    
        EXECUTE: begin
            if(opcode == `OP_TYPE_S) next_state = MEMACCESS;
            else next_state = WAIT_EXECUTE;   //한클럭 대기           
           
        end

        WAIT_EXECUTE: begin
             case(opcode)
               `OP_TYPE_R:  next_state = FETCH;
               `OP_TYPE_L: if(ready) next_state = WRITEBACK; else next_state = WAIT_EXECUTE;
               `OP_TYPE_I:  next_state = FETCH;
               `OP_TYPE_B:  next_state = FETCH;
               `OP_TYPE_LU:  next_state = FETCH;
               `OP_TYPE_AU:  next_state = FETCH;
               `OP_TYPE_J:  next_state = FETCH;
               `OP_TYPE_JL:  next_state = FETCH;
               endcase
        end
        WRITEBACK: begin

           next_state = FETCH;
        end

        MEMACCESS: begin
            if(ready) next_state = FETCH; else next_state = MEMACCESS;
        end
     

        endcase
    end


    always_comb begin
         s_half = 2'b00;
        if(opcode == `OP_TYPE_S) begin
        case(func3)
        3'b000: s_half = 2'b11; // byte
        3'b001: s_half = 2'b10; // half
        3'b010: s_half = 2'b00; //word
        endcase
        end
    end

    always_comb begin
        case(func3)
            `func3_I_ADDI : operators_I = `ADD;
            `func3_I_SLTI : operators_I = `SLT;
            `func3_I_SLTIU:operators_I = `SLTU;
            `func3_I_XORI :operators_I = `XOR;
            `func3_I_ORI :operators_I = `OR;
            `func3_I_ANDI :operators_I = `AND;
            `shamt_I_SLLI : operators_I = `SLL;
            3'b101        : begin
                                case (instrCode[30])
                                0: operators_I = `SRL;
                                1'b1: operators_I = `SRA;
                                endcase
                            end 
        endcase
    end

    always_comb begin
        operators_B = `ADD;
        case(func3)
        `func3_B_BEQ : operators_B = `BEQ;
        `func3_B_BNE : operators_B = `BNE;
        `func3_B_BLT : operators_B = `BLT;
        `func3_B_BGE : operators_B = `BGE;
        `func3_B_BLTU : operators_B = `BLTU;
        `func3_B_BGEU : operators_B = `BGEU;

        endcase
    end



    logic [8:0] signals;
    assign {AlUSrcMuxSel,reg_wData_MuxSel,reg_wData_half_Sel,alu_mux_sel2} = signals; // 신호 많아지니까 깔끔하게 만들기 위해 
//AluSrcMuxsel -> 1이면 alu에서 imm extend 0이면 RData2 연산 (alu 에서 b 값)
//data_we : ram enable, reg_wdata_muxsel >> 0: aluResult 1: ram_rdata
//pc_mux_sel : pc counter에 4더할지 immm 더할지  0:4, 1:imm
//muxsel2 : rdata1 pc (alu에서 a 값값)
    always_comb begin
        signals = 0;
        case (opcode)
           `OP_TYPE_R: signals = 6'b0_0_000_0;  // R-Type
           `OP_TYPE_S: begin
                            signals = 6'b1_0_000_0; // word
                            case(func3) 
                            3'b010:signals = 6'b1_0_000_0; // word
                            3'b001:signals = 6'b1_0_001_0; //half
                            3'b000:signals = 6'b1_0_010_0; //byte
                            endcase
                        end
           `OP_TYPE_L:  begin
                            signals = 6'b1_1_000_0;
                            case(func3) 
                            3'b010:signals = 6'b1_1_000_0; //word
                            3'b001:signals = 6'b1_1_001_0; // half
                            3'b000:signals = 6'b1_1_010_0; // BYTE
                            3'b100:signals = 6'b1_1_100_0; // BYTE U
                            3'b101:signals = 6'b1_1_011_0; // half U  
                            endcase
                        end
           `OP_TYPE_I: signals = 6'b1_0_000_0;

           `OP_TYPE_B: signals = 6'b0_0_000_0;

           `OP_TYPE_LU: signals = 6'b1_0_000_0; // a 무상관
           `OP_TYPE_AU : signals = 6'b1_0_000_1; 
           `OP_TYPE_J : signals = 6'b0_0_000_1; //b 무상관
           `OP_TYPE_JL : signals = 6'b0_0_000_1; //b 무상관

               
                      
        endcase
    end

    always_comb begin
        aluControl = 0;
        case (opcode)
           `OP_TYPE_R: aluControl = operators_R;  // R-Type
           `OP_TYPE_S: aluControl = `ADD;  // S-Type // ADD만 
           `OP_TYPE_L: aluControl = `ADD;
           `OP_TYPE_I: aluControl = operators_I;
           `OP_TYPE_B: aluControl = operators_B;
           `OP_TYPE_LU: aluControl = `BUFFER;
           `OP_TYPE_AU : aluControl = `ADD;
           `OP_TYPE_J  : aluControl = `JUMP;
           `OP_TYPE_JL : aluControl = `JUMP;


        endcase
    end


endmodule



