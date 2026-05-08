`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Data Memory
//------------------------------------------------------------------------------
// Single-port data memory with synchronous read/write.
//------------------------------------------------------------------------------
module dmem (
    input                            clk_i,

    input                            wr_en_i,
    input  [`CPU_ADDR_WIDTH-1:0]     addr_i,
    input  [`CPU_DATA_WIDTH-1:0]     wr_data_i,
    output reg [`CPU_DATA_WIDTH-1:0] rd_data_o
);

    reg [`CPU_DATA_WIDTH-1:0] mem_q [0:(1 << `CPU_ADDR_WIDTH)-1];

    always @(posedge clk_i) begin
        if (wr_en_i) begin
            mem_q[addr_i] <= wr_data_i;
        end

        rd_data_o <= mem_q[addr_i];
    end

endmodule