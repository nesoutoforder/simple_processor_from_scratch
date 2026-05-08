`include "defs.vh"
`timescale 1ns/1ps

module datapath(
    input clk,
    input rst_n
);

    // REGISTERS
    reg [6:0]   pc;
    reg [15:0]  ir;
    reg [15:0]  result;

    // CONTROL UNIT
    wire [2:0] state;
    wire       pc_write;
    wire       ir_write;
    wire       result_write;
    wire       pc_src;
    wire       we_mem;
    wire       we_reg;
    wire [1:0] alu_op;

    // MEMORY
    wire [6:0]  dir_mem;
    wire [15:0] mem_data_in;
    wire [15:0] mem_data_out;

    // REGISTER FILE
    wire [1:0]  rd_addr;
    wire [1:0]  rs1_addr;
    wire [1:0]  rs2_addr;
    wire [15:0] rd_in;
    wire [15:0] rs1_out;
    wire [15:0] rs2_out;

    // ALU
    wire [15:0] A;
    wire [15:0] B;
    wire [15:0] res;
    wire c;
    wire b;
    wire z;

    // DECODE SIGNALS
    wire [3:0]      opcode;
    wire [1:0]      rd;
    wire [1:0]      rs1;
    wire [1:0]      rs2;
    wire [6:0]      addr;
    wire [5:0]      imm1;
    wire [9:0]      imm2;

    control_unit CU(
        .clk(clk),
        .rst_n(rst_n),
        .opcode(opcode),
        .z(z),

        .state(state),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .result_write(result_write),
        .pc_src(pc_src),
        .we_mem(we_mem),
        .we_reg(we_reg),
        .alu_op(alu_op)
    );

    mem MEMORY(
        .clk(clk),
        .wr_en(we_mem),
        .address(dir_mem),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );

    regfile RF(
        .clk(clk),
        .rst_n(rst_n),
        .we(we_reg),
        .rd_addr(rd_addr),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_in(rd_in),
        .rs1_out(rs1_out),
        .rs2_out(rs2_out)  
    );

    alu ALU(
        .op(alu_op),
        .A(A),
        .B(B),
        .result(res),
        .c(c),
        .b(b),
        .z(z)
    );

    assign  opcode      =   ir[15:12];
    assign  rd          =   ir[11:10];
    assign  rs1         =   ir[9:8];
    assign  rs2         =   ir[7:6];
    assign  addr        =   ir[6:0];
    assign  imm1        =   ir[5:0];
    assign  imm2        =   ir[9:0];


    // FETCH/MEM
    assign dir_mem  =   (state == `FETCH || state == `DECODE) ? pc :
                        ((opcode == `LOAD || opcode == `STORE) &&
                        (state == `EXEC || state == `MEM || state == `WB)) ? addr :
                                                                        7'b0;
    assign mem_data_in = (state == `MEM && opcode == `STORE) ? rs1_out : 16'b0;

    // DECODE
    assign rs1_addr = rs1;
    assign rs2_addr = rs2;

    // EXEC
    assign A =  (opcode == `MOVI) ? 16'b0 : rs1_out;
    assign B =  (opcode == `ADDI) ? {10'b0, imm1} :
            (opcode == `MOVI) ? {6'b0, imm2}  :
                                 rs2_out;

    // WB
    assign  rd_addr =   rd;
    assign  rd_in   =   (state == `WB && opcode == `LOAD) ? mem_data_out : result;
                

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc     <= 0;
            ir     <= 0;
            result <= 0;
        end else begin
            if(ir_write)
                ir <= mem_data_out;

            if(result_write)
                result <= res;

            if(pc_write) begin
                if(pc_src)
                    pc <= addr;
                else
                    pc <= pc + 1;
            end
        end
    end

endmodule
