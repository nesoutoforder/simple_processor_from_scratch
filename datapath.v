`timescale 1ns/1ps

module datapath(
    input clk,
    input rst_n
);

    // REGISTERS
    reg [6:0]   pc;
    reg [15:0]  ir;
    reg [15:0]  result;
    
    // INSTRUCTIONS
    localparam [3:0]
        LOAD    = 4'b0000,
        STORE   = 4'b0001,
        ADD     = 4'b0010,
        SUB     = 4'b0011,
        ADDI    = 4'b0100,
        MOVI    = 4'b0101,
        BEQ     = 4'b0110,
        BNE     = 4'b0111,
        JMP    = 4'b1000;

    // STATES
    parameter [2:0] FETCH   = 3'b000,
                    DECODE  = 3'b001,
                    EXEC    = 3'b010,
                    MEM     = 3'b011,
                    WB      = 3'b100;
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

    // DECODE SIGNALS
    wire [3:0]      opcode;
    wire [1:0]      rd;
    wire [1:0]      rs1;
    wire [1:0]      rs2;
    wire [6:0]      addr;
    wire [5:0]      imm1;
    wire [9:0]     imm2;

    assign  opcode      =   ir[15:12];
    assign  rd          =   ir[11:10];
    assign  rs1         =   ir[9:8];
    assign  rs2         =   ir[7:6];
    assign  addr        =   ir[6:0];
    assign  imm1        =   ir[5:0];
    assign  imm2        =   ir[9:0];


    // FETCH/MEM
    assign dir_mem  =   (state == FETCH || state == DECODE) ? pc :
                        ((opcode == LOAD || opcode == STORE) &&
                        (state == EXEC || state == MEM || state == WB)) ? addr :
                                                                        7'b0;
    assign we_mem   =   (state == MEM) && (opcode == STORE);
    assign mem_data_in = (state == MEM && opcode == STORE) ? rs1_out : 16'b0;

    // DECODE
    assign rs1_addr = rs1;
    assign rs2_addr = rs2;

    // WB
    assign  rd_addr =   rd;
    assign  we_reg  =   (state == WB) && (opcode == LOAD || opcode == ADD ||
                            opcode == SUB || opcode == ADDI || opcode == MOVI);
    assign  rd_in   =   (state == WB && opcode == LOAD) ? mem_data_out : result;
                

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= 0;
            ir <= 0;
            state <= FETCH;
        end else begin
            case(state)
                            FETCH   :   begin
                                            state <= DECODE;
                                        end
                            DECODE  :   begin
                                            pc <= pc + 1;
                                            ir <= mem_data_out;            
                                            state <= EXEC;
                                        end
                            EXEC    :   begin
                                            state <= MEM;
                                            if(opcode == ADD)
                                                result <= rs1_out + rs2_out;
                                            else if(opcode == SUB)
                                                result <= rs1_out - rs2_out;
                                            else if(opcode == ADDI)
                                                result <= rs1_out + {9'b0, imm1};
                                            else if(opcode == MOVI)
                                                result <= {6'b0, imm2};
                                            else if(opcode == BEQ) begin
                                                if(rs1_out == rs2_out) begin
                                                    pc <= ir[6:0];
                                                end
                                                state <= FETCH;
                                            end else if(opcode == BNE) begin
                                                if(rs1_out != rs2_out) begin
                                                    pc <= ir[6:0];
                                                end
                                                state <= FETCH;
                                            end else if(opcode == JMP) begin
                                                pc <= ir[6:0];
                                                state <= FETCH;
                                            end    
                                        end
                            MEM     :   begin                        
                                            state <= WB;
                                        end
                            WB      :   begin                                
                                            state <= FETCH;
                                        end
            endcase
        end

    end

endmodule
