`include "defs.vh"
`timescale 1ns/1ps

//------------------------------------------------------------------------------
// CPU Datapath
//------------------------------------------------------------------------------
module datapath (
    input clk_i,
    input rst_ni
);

    // -------------------------------------------------------------------------
    // Core state registers
    // -------------------------------------------------------------------------
    reg [`CPU_ADDR_WIDTH-1:0] pc_q;
    reg [`CPU_DATA_WIDTH-1:0] instr_q;
    reg [`CPU_DATA_WIDTH-1:0] alu_result_q;

    // -------------------------------------------------------------------------
    // Decoded instruction fields
    // -------------------------------------------------------------------------
    wire [`CPU_OPCODE_WIDTH-1:0]   opcode;
    wire [`CPU_REG_ADDR_WIDTH-1:0] rd_addr;
    wire [`CPU_REG_ADDR_WIDTH-1:0] rs1_addr;
    wire [`CPU_REG_ADDR_WIDTH-1:0] rs2_addr;
    wire [`CPU_ADDR_WIDTH-1:0]     instr_addr;
    wire [5:0]                    imm6;
    wire [9:0]                    imm10;

    assign opcode     = instr_q[15:12];
    assign rd_addr    = instr_q[11:10];
    assign rs1_addr   = instr_q[9:8];
    assign rs2_addr   = instr_q[7:6];
    assign instr_addr = instr_q[6:0];
    assign imm6       = instr_q[5:0];
    assign imm10      = instr_q[9:0];

    // -------------------------------------------------------------------------
    // Control signals
    // -------------------------------------------------------------------------
    wire [`CPU_STATE_WIDTH-1:0]  ctrl_state;
    wire                         pc_wr_en;
    wire                         ir_wr_en;
    wire                         alu_result_wr_en;
    wire                         pc_src_branch;
    wire                         dmem_wr_en;
    wire                         regfile_wr_en;
    wire [`CPU_ALU_OP_WIDTH-1:0] alu_op;

    // -------------------------------------------------------------------------
    // Instruction memory interface
    // -------------------------------------------------------------------------
    wire [`CPU_ADDR_WIDTH-1:0]     imem_addr;
    wire [`CPU_DATA_WIDTH-1:0]     imem_instr;

    // -------------------------------------------------------------------------
    // Data memory interface
    // -------------------------------------------------------------------------
    wire [`CPU_ADDR_WIDTH-1:0]     dmem_addr;
    wire [`CPU_DATA_WIDTH-1:0]     dmem_wr_data;
    wire [`CPU_DATA_WIDTH-1:0]     dmem_rd_data;

    // -------------------------------------------------------------------------
    // Register file interface
    // -------------------------------------------------------------------------
    wire [`CPU_DATA_WIDTH-1:0]     regfile_wr_data;
    wire [`CPU_DATA_WIDTH-1:0]     rs1_data;
    wire [`CPU_DATA_WIDTH-1:0]     rs2_data;

    // -------------------------------------------------------------------------
    // ALU interface
    // -------------------------------------------------------------------------
    wire [`CPU_DATA_WIDTH-1:0]     alu_op_a;
    wire [`CPU_DATA_WIDTH-1:0]     alu_op_b;
    wire [`CPU_DATA_WIDTH-1:0]     alu_result;
    wire                           alu_zero;
    wire                           alu_carry;
    wire                           alu_borrow;

    // -------------------------------------------------------------------------
    // Control unit
    // -------------------------------------------------------------------------
    control_unit u_control_unit (
        .clk_i                (clk_i),
        .rst_ni               (rst_ni),
        .opcode_i             (opcode),
        .alu_zero_i           (alu_zero),

        .state_o              (ctrl_state),
        .pc_wr_en_o           (pc_wr_en),
        .ir_wr_en_o           (ir_wr_en),
        .alu_result_wr_en_o   (alu_result_wr_en),
        .pc_src_branch_o      (pc_src_branch),
        .dmem_wr_en_o         (dmem_wr_en),
        .regfile_wr_en_o      (regfile_wr_en),
        .alu_op_o             (alu_op)
    );

    // -------------------------------------------------------------------------
    // Memories
    // -------------------------------------------------------------------------
    imem u_imem (
        .clk_i   (clk_i),
        .addr_i  (imem_addr),
        .instr_o (imem_instr)
    );

    dmem u_dmem (
        .clk_i     (clk_i),
        .wr_en_i   (dmem_wr_en),
        .addr_i    (dmem_addr),
        .wr_data_i (dmem_wr_data),
        .rd_data_o (dmem_rd_data)
    );

    // -------------------------------------------------------------------------
    // Register file
    // -------------------------------------------------------------------------
    regfile u_regfile (
        .clk_i      (clk_i),
        .rst_ni     (rst_ni),
        .wr_en_i    (regfile_wr_en),
        .wr_addr_i  (rd_addr),
        .wr_data_i  (regfile_wr_data),
        .rs1_addr_i (rs1_addr),
        .rs2_addr_i (rs2_addr),
        .rs1_data_o (rs1_data),
        .rs2_data_o (rs2_data)
    );

    // -------------------------------------------------------------------------
    // ALU
    // -------------------------------------------------------------------------
    alu u_alu (
        .alu_op_i  (alu_op),
        .op_a_i    (alu_op_a),
        .op_b_i    (alu_op_b),
        .result_o  (alu_result),
        .zero_o    (alu_zero),
        .carry_o   (alu_carry),
        .borrow_o  (alu_borrow)
    );

    // -------------------------------------------------------------------------
    // Datapath muxing
    // -------------------------------------------------------------------------
    assign imem_addr = ((ctrl_state == `CPU_ST_FETCH) ||
                        (ctrl_state == `CPU_ST_DECODE)) ? pc_q :
                                                          {`CPU_ADDR_WIDTH{1'b0}};

    assign dmem_addr = (((opcode == `OPC_LOAD) || (opcode == `OPC_STORE)) &&
                        ((ctrl_state == `CPU_ST_EXEC) ||
                         (ctrl_state == `CPU_ST_MEM)  ||
                         (ctrl_state == `CPU_ST_WB))) ? instr_addr :
                                                        {`CPU_ADDR_WIDTH{1'b0}};

    assign dmem_wr_data = (opcode == `OPC_STORE) ? rs1_data :
                                                   {`CPU_DATA_WIDTH{1'b0}};

    assign alu_op_a = (opcode == `OPC_MOVI) ? {`CPU_DATA_WIDTH{1'b0}} :
                                              rs1_data;

    assign alu_op_b = (opcode == `OPC_ADDI) ? {{10{1'b0}}, imm6}  :
                      (opcode == `OPC_MOVI) ? {{6{1'b0}}, imm10}  :
                                              rs2_data;

    assign regfile_wr_data = (opcode == `OPC_LOAD) ? dmem_rd_data :
                                                    alu_result_q;

    // -------------------------------------------------------------------------
    // Datapath state registers
    // -------------------------------------------------------------------------
    always @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            pc_q         <= {`CPU_ADDR_WIDTH{1'b0}};
            instr_q      <= {`CPU_DATA_WIDTH{1'b0}};
            alu_result_q <= {`CPU_DATA_WIDTH{1'b0}};
        end else begin
            if (ir_wr_en) begin
                instr_q <= imem_instr;
            end

            if (alu_result_wr_en) begin
                alu_result_q <= alu_result;
            end

            if (pc_wr_en) begin
                if (pc_src_branch) begin
                    pc_q <= instr_addr;
                end else begin
                    pc_q <= pc_q + {{(`CPU_ADDR_WIDTH-1){1'b0}}, 1'b1};
                end
            end
        end
    end

endmodule