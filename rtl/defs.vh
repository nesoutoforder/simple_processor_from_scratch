`ifndef DEFS_VH
`define DEFS_VH

// Data path widths
`define CPU_DATA_WIDTH      16
`define CPU_ADDR_WIDTH      7
`define CPU_REG_ADDR_WIDTH  2
`define CPU_OPCODE_WIDTH    4
`define CPU_ALU_OP_WIDTH    2
`define CPU_STATE_WIDTH     3

// Instruction opcodes
`define OPC_LOAD            4'b0000
`define OPC_STORE           4'b0001
`define OPC_ADD             4'b0010
`define OPC_SUB             4'b0011
`define OPC_ADDI            4'b0100
`define OPC_MOVI            4'b0101
`define OPC_BEQ             4'b0110
`define OPC_BNE             4'b0111
`define OPC_JMP             4'b1000

// ALU operation select values
`define ALU_OP_ADD          2'b00
`define ALU_OP_SUB          2'b01
`define ALU_OP_CMP          2'b10

// Multicycle controller states
`define CPU_ST_FETCH        3'b000
`define CPU_ST_DECODE       3'b001
`define CPU_ST_EXEC         3'b010
`define CPU_ST_MEM          3'b011
`define CPU_ST_WB           3'b100

`endif // DEFS_VH