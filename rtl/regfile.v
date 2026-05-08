`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Register File
//------------------------------------------------------------------------------
module regfile (
    input                               clk_i,
    input                               rst_ni,

    input                               wr_en_i,
    input  [`CPU_REG_ADDR_WIDTH-1:0]    wr_addr_i,
    input  [`CPU_DATA_WIDTH-1:0]        wr_data_i,

    input  [`CPU_REG_ADDR_WIDTH-1:0]    rs1_addr_i,
    input  [`CPU_REG_ADDR_WIDTH-1:0]    rs2_addr_i,
    output [`CPU_DATA_WIDTH-1:0]        rs1_data_o,
    output [`CPU_DATA_WIDTH-1:0]        rs2_data_o
);

    integer idx;
    reg [`CPU_DATA_WIDTH-1:0] regs_q [0:3];

    assign rs1_data_o = regs_q[rs1_addr_i];
    assign rs2_data_o = regs_q[rs2_addr_i];

    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            for (idx = 0; idx < 4; idx = idx + 1) begin
                regs_q[idx] <= {`CPU_DATA_WIDTH{1'b0}};
            end
        end else if (wr_en_i) begin
            regs_q[wr_addr_i] <= wr_data_i;
        end
    end

endmodule