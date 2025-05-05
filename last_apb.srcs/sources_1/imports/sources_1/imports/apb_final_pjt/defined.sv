`define ADD  4'b0000 // {func7[5], func3}
`define SUB  4'b1000
`define SLL  4'b0001
`define SRL  4'b0101
`define SRA  4'b1101
`define SLT  4'b0010
`define SLTU 4'b0011
`define XOR  4'b0100
`define OR   4'b0110
`define AND  4'b0111
// `define MULHU 4'b1001 // 시간 너무 오래걸림 
// `define DIVU 4'b1011
// `define REMU 4'b1100

// `define EQUAL 4'b1001
// `define NEQUAL 4'b1011
// `define GREATER 4'b1100
// `define GREATER_U 4'b1110
`define BUFFER  4'b1111
`define JUMP    4'b1010

//한마디로 조립해라 

`define OP_TYPE_R 7'b0110011
`define OP_TYPE_L 7'b0000011
`define OP_TYPE_I 7'b0010011
`define OP_TYPE_S 7'b0100011
`define OP_TYPE_B 7'b1100011
`define OP_TYPE_LU 7'b0110111
`define OP_TYPE_AU 7'b0010111
`define OP_TYPE_J  7'b1101111
`define OP_TYPE_JL 7'b1100111

`define func3_S_SB 3'b000
`define func3_S_SH 3'b001
`define func3_S_SW 3'b010

`define func3_L_LB 3'b000
`define func3_L_LH 3'b001
`define func3_L_LW 3'b010
`define func3_L_LBU 3'b100
`define func3_L_LHU 3'b101

`define func3_I_ADDI 3'b000
`define func3_I_SLTI 3'b010
`define func3_I_SLTIU 3'b011
`define func3_I_XORI 3'b100
`define func3_I_ORI 3'b110
`define func3_I_ANDI 3'b111 
`define shamt_I_SLLI 3'b001

`define shamt_I_SRLI 4'b0101
`define shamt_I_SRAI 4'b1101

`define func3_B_BEQ 3'b000
`define func3_B_BNE 3'b001
`define func3_B_BLT 3'b100
`define func3_B_BGE 3'b101
`define func3_B_BLTU 3'b110
`define func3_B_BGEU 3'b111

`define BEQ  4'b0000
`define BNE  4'b0001
`define BLT  4'b0100
`define BGE  4'b0101
`define BLTU 4'b0110
`define BGEU 4'b0111


`define WORD 3'b000
`define HALF 3'b001
`define BYTE 3'b010
`define BYTE_U 3'b100
`define HALF_U 3'b011


