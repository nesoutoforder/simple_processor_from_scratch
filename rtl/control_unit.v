`include "defs.vh"
`timescale 1ns/1ps

module control_unit(
    input clk,
    input rst_n,
    input [3:0] opcode,
    input z,

    output reg [2:0] state,
    output reg pc_write,
    output reg ir_write,
    output reg result_write,
    output reg pc_src,
    output reg we_mem,
    output reg we_reg,
    output reg [1:0] alu_op
);

    always @(*) begin
        pc_write    = 1'b0;
        ir_write    = 1'b0;
        result_write = 1'b0;
        pc_src      = 1'b0;
        we_mem      = 1'b0;
        we_reg      = 1'b0;
        alu_op      = `ALU_ADD;

        case(state)
            `DECODE: begin
                pc_write = 1'b1;
                ir_write = 1'b1;
            end

            `EXEC: begin
                result_write = 1'b1;

                if(opcode == `SUB)
                    alu_op = `ALU_SUB;
                else if(opcode == `BEQ || opcode == `BNE)
                    alu_op = `ALU_COMP;
                else
                    alu_op = `ALU_ADD;

                if(opcode == `BEQ && z) begin
                    pc_write = 1'b1;
                    pc_src = 1'b1;
                end else if(opcode == `BNE && !z) begin
                    pc_write = 1'b1;
                    pc_src = 1'b1;
                end else if(opcode == `JMP) begin
                    pc_write = 1'b1;
                    pc_src = 1'b1;
                end
            end

            `MEM: begin
                if(opcode == `STORE)
                    we_mem = 1'b1;
            end

            `WB: begin
                if(opcode == `LOAD || opcode == `ADD ||
                   opcode == `SUB  || opcode == `ADDI ||
                   opcode == `MOVI)
                    we_reg = 1'b1;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= `FETCH;
        end else begin
            case(state)
                `FETCH:  state <= `DECODE;
                `DECODE: state <= `EXEC;

                `EXEC: begin
                    if(opcode == `BEQ || opcode == `BNE || opcode == `JMP)
                        state <= `FETCH;
                    else
                        state <= `MEM;
                end

                `MEM: state <= `WB;
                `WB:  state <= `FETCH;

                default: state <= `FETCH;
            endcase
        end
    end

endmodule
