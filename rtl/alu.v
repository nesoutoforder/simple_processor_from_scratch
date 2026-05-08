`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Arithmetic Logic Unit
//------------------------------------------------------------------------------
// Combinational ALU used by the CPU datapath.
//
// Supported operations:
//   ALU_OP_ADD : result = op_a + op_b, carry flag valid
//   ALU_OP_SUB : result = op_a - op_b, borrow flag valid
//   ALU_OP_CMP : zero flag set when op_a == op_b
//------------------------------------------------------------------------------
module alu (
    input  [`CPU_ALU_OP_WIDTH-1:0] alu_op_i,
    input  [`CPU_DATA_WIDTH-1:0]   op_a_i,
    input  [`CPU_DATA_WIDTH-1:0]   op_b_i,

    output reg [`CPU_DATA_WIDTH-1:0] result_o,
    output reg                       zero_o,
    output reg                       carry_o,
    output reg                       borrow_o
);

    always @(*) begin
        result_o = {`CPU_DATA_WIDTH{1'b0}};
        zero_o   = 1'b0;
        carry_o  = 1'b0;
        borrow_o = 1'b0;

        case (alu_op_i)
            `ALU_OP_ADD: begin
                {carry_o, result_o} = op_a_i + op_b_i;
                zero_o = (result_o == {`CPU_DATA_WIDTH{1'b0}});
            end

            `ALU_OP_SUB: begin
                result_o = op_a_i - op_b_i;
                borrow_o = (op_b_i > op_a_i);
                zero_o = (result_o == {`CPU_DATA_WIDTH{1'b0}});
            end

            `ALU_OP_CMP: begin
                result_o = op_a_i - op_b_i;
                borrow_o = (op_b_i > op_a_i);
                zero_o = (op_a_i == op_b_i);
            end

            default: begin
                result_o = {`CPU_DATA_WIDTH{1'b0}};
                zero_o   = 1'b0;
                carry_o  = 1'b0;
                borrow_o = 1'b0;
            end
        endcase
    end

endmodule