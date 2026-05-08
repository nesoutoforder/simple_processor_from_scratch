`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// Control Unit
//------------------------------------------------------------------------------
module control_unit (
    input                             clk_i,
    input                             rst_ni,

    input  [`CPU_OPCODE_WIDTH-1:0]    opcode_i,
    input                             alu_zero_i,

    output reg [`CPU_STATE_WIDTH-1:0] state_o,
    output reg                        pc_wr_en_o,
    output reg                        ir_wr_en_o,
    output reg                        alu_result_wr_en_o,
    output reg                        pc_src_branch_o,
    output reg                        dmem_wr_en_o,
    output reg                        regfile_wr_en_o,
    output reg [`CPU_ALU_OP_WIDTH-1:0] alu_op_o
);

    reg [`CPU_STATE_WIDTH-1:0] next_state;

    // Control signal decode
    always @(*) begin
        pc_wr_en_o          = 1'b0;
        ir_wr_en_o          = 1'b0;
        alu_result_wr_en_o  = 1'b0;
        pc_src_branch_o     = 1'b0;
        dmem_wr_en_o        = 1'b0;
        regfile_wr_en_o     = 1'b0;
        alu_op_o            = `ALU_OP_ADD;

        case (state_o)
            `CPU_ST_DECODE: begin
                // Instruction memory is synchronous. The instruction requested
                // in FETCH is captured into the IR in DECODE.
                ir_wr_en_o = 1'b1;
                pc_wr_en_o = 1'b1;
            end

            `CPU_ST_EXEC: begin
                alu_result_wr_en_o = 1'b1;

                case (opcode_i)
                    `OPC_SUB: begin
                        alu_op_o = `ALU_OP_SUB;
                    end

                    `OPC_BEQ,
                    `OPC_BNE: begin
                        alu_op_o = `ALU_OP_CMP;
                    end

                    default: begin
                        alu_op_o = `ALU_OP_ADD;
                    end
                endcase

                if ((opcode_i == `OPC_BEQ &&  alu_zero_i) ||
                    (opcode_i == `OPC_BNE && !alu_zero_i) ||
                    (opcode_i == `OPC_JMP)) begin
                    pc_wr_en_o      = 1'b1;
                    pc_src_branch_o = 1'b1;
                end
            end

            `CPU_ST_MEM: begin
                dmem_wr_en_o = (opcode_i == `OPC_STORE);
            end

            `CPU_ST_WB: begin
                regfile_wr_en_o = (opcode_i == `OPC_LOAD) ||
                                   (opcode_i == `OPC_ADD)  ||
                                   (opcode_i == `OPC_SUB)  ||
                                   (opcode_i == `OPC_ADDI) ||
                                   (opcode_i == `OPC_MOVI);
            end

            default: begin
                // No control outputs asserted by default.
            end
        endcase
    end

    // Next-state logic
    always @(*) begin
        next_state = `CPU_ST_FETCH;

        case (state_o)
            `CPU_ST_FETCH: begin
                next_state = `CPU_ST_DECODE;
            end

            `CPU_ST_DECODE: begin
                next_state = `CPU_ST_EXEC;
            end

            `CPU_ST_EXEC: begin
                if ((opcode_i == `OPC_BEQ) ||
                    (opcode_i == `OPC_BNE) ||
                    (opcode_i == `OPC_JMP)) begin
                    next_state = `CPU_ST_FETCH;
                end else begin
                    next_state = `CPU_ST_MEM;
                end
            end

            `CPU_ST_MEM: begin
                next_state = `CPU_ST_WB;
            end

            `CPU_ST_WB: begin
                next_state = `CPU_ST_FETCH;
            end

            default: begin
                next_state = `CPU_ST_FETCH;
            end
        endcase
    end

    // FSM state register
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            state_o <= `CPU_ST_FETCH;
        end else begin
            state_o <= next_state;
        end
    end

endmodule
