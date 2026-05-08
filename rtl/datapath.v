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
    
    reg [2:0] state;


    // MEMORY
    wire        we_mem;
    wire [6:0]  dir_mem;
    wire [15:0] mem_data_in;
    wire [15:0] mem_data_out;

    mem MEMORY(
        .clk(clk),
        .wr_en(we_mem),
        .address(dir_mem),
        .data_in(mem_data_in),
        .data_out(mem_data_out)
    );

    // REGISTER FILE
    wire        we_reg;
    wire [1:0]  rd_addr;
    wire [1:0]  rs1_addr;
    wire [1:0]  rs2_addr;
    wire [15:0] rd_in;
    wire [15:0] rs1_out;
    wire [15:0] rs2_out;

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

    // ALU
    wire [1:0] alu_op;
    wire [15:0] A;
    wire [15:0] B;
    wire [15:0] res;
    wire c;
    wire b;
    wire z;

    alu ALU(
        .op(alu_op),
        .A(A),
        .B(B),
        .result(res),
        .c(c),
        .b(b),
        .z(z)
    );

    // DECODE SIGNALS
    wire [3:0]      opcode;
    wire [1:0]      rd;
    wire [1:0]      rs1;
    wire [1:0]      rs2;
    wire [6:0]      addr;
    wire [5:0]      imm1;
    wire [9:0]      imm2;

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
    assign we_mem   =   (state == `MEM) && (opcode == `STORE);
    assign mem_data_in = (state == `MEM && opcode == `STORE) ? rs1_out : 16'b0;

    // DECODE
    assign rs1_addr = rs1;
    assign rs2_addr = rs2;

    // EXEC
    assign A =  (opcode == `MOVI) ? 16'b0 : rs1_out;
    assign B =  (opcode == `ADDI) ? {10'b0, imm1} :
            (opcode == `MOVI) ? {6'b0, imm2}  :
                                 rs2_out;

    assign alu_op = ((opcode == `ADD)  ||
                        (opcode == `ADDI) ||
                        (opcode == `MOVI)) ? `ALU_ADD :
                    (opcode == `SUB) ? `ALU_SUB :
                    ((opcode == `BEQ) ||
                        (opcode == `BNE)) ? `ALU_COMP :
                    `ALU_ADD;

    // WB
    assign  rd_addr =   rd;
    assign  we_reg  =   (state == `WB) && (opcode == `LOAD || opcode == `ADD ||
                            opcode == `SUB || opcode == `ADDI || opcode == `MOVI);
    assign  rd_in   =   (state == `WB && opcode == `LOAD) ? mem_data_out : result;
                

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= 0;
            ir <= 0;
            state <= `FETCH;
        end else begin
            case(state)
                `FETCH   :   begin
                                state <= `DECODE;
                            end
                `DECODE  :   begin
                                pc <= pc + 1;
                                ir <= mem_data_out;            
                                state <= `EXEC;
                            end
                `EXEC    :   begin
                                state <= `MEM;
                                result <= res;
                                if(opcode == `BEQ) begin
                                    if(z)
                                        pc <= ir[6:0];
                                    state <= `FETCH;
                                end else if(opcode == `BNE) begin
                                    if(!z)
                                        pc <= ir[6:0];
                                    state <= `FETCH;
                                end else if(opcode == `JMP) begin
                                    pc <= ir[6:0];
                                    state <= `FETCH;
                                end
                            end
                `MEM     :   begin                        
                                state <= `WB;
                            end
                `WB      :   begin                                
                                state <= `FETCH;
                            end
            endcase
        end

    end

endmodule
