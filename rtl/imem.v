`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Instruction Memory
//------------------------------------------------------------------------------
// Read-only instruction memory with synchronous read.
//------------------------------------------------------------------------------
module imem #(
    parameter IMEM_INIT_FILE = "programs/mem_init.hex"
) (
    input                            clk_i,
    input  [`CPU_ADDR_WIDTH-1:0]     addr_i,
    output reg [`CPU_DATA_WIDTH-1:0] instr_o
);

    reg [`CPU_DATA_WIDTH-1:0] mem_q [0:(1 << `CPU_ADDR_WIDTH)-1];

    initial begin
        $readmemh(IMEM_INIT_FILE, mem_q, 0, (1 << `CPU_ADDR_WIDTH)-1);
    end

    always @(posedge clk_i) begin
        instr_o <= mem_q[addr_i];
    end

endmodule
