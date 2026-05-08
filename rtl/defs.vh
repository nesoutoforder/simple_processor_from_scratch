`ifndef DEFS_VH
`define DEFS_VH

// OPCODES
`define LOAD    4'b0000
`define STORE   4'b0001
`define ADD     4'b0010
`define SUB     4'b0011
`define ADDI    4'b0100
`define MOVI    4'b0101
`define BEQ     4'b0110
`define BNE     4'b0111
`define JMP     4'b1000

// ALU OPS
`define ALU_ADD    2'b00
`define ALU_SUB    2'b01
`define ALU_COMP   2'b10

// STATES
`define FETCH      3'b000
`define DECODE     3'b001
`define EXEC       3'b010
`define MEM        3'b011
`define WB         3'b100

`endif