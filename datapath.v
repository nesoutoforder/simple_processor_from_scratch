`timescale 1ns/1ps

module datapath(
    input clk,
    input rst_n
);

    reg [6:0]   pc;
    reg [15:0]  ir;
    reg [15:0]  reg_f;
    reg [15:0]  reg_d;   
    reg         z;
    
    wire            wr_en;  
    wire [1:0]      opcode;
    wire [6:0]      address;
    wire [15:0]     data_in;
    wire [15:0]     data_out;
    wire [6:0]      dir_d;
    wire [6:0]      dir_f;
    wire [6:0]      immediate;

    parameter [1:0] FETCH   = 2'b00,
                    LOAD_D  = 2'b01,
                    LOAD_F  = 2'b10,
                    WRITE   = 2'b11;

    reg [1:0] state;

    mem MEM(
        .clk(clk),
        .wr_en(wr_en),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    assign  opcode      =   ir[15:14];
    assign  dir_d       =   ir[13:7];
    assign  dir_f       =   ir[6:0];
    assign  immediate   =   ir[6:0];

    assign  data_in =   (opcode == 2'b00) ? (reg_d + reg_f) :
                        (opcode == 2'b01) ? reg_f :
                        16'b0;
    assign  address =   (state == FETCH)  ? pc :
                        (state == LOAD_D) ? dir_d :
                        (state == LOAD_F) ? dir_f  :
                        (state == WRITE)  ? dir_d :
                                            7'b0;
                
    assign wr_en    =   (state == WRITE) &&
                        ((opcode == 2'b00) || (opcode == 2'b01));

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            pc <= 0;
            state <= FETCH;
            z <= 0;
            reg_d <= 0;
            reg_f <= 0;
        end else begin
            case(state)
                            FETCH   :   begin
                                            pc <= pc + 1;
                                            ir <= data_out;
                                            state <= LOAD_D;
                                        end
                            LOAD_D  :   begin
                                            reg_d <= data_out;
                                            state <= LOAD_F;
                                        end
                            LOAD_F  :   begin
                                            if(opcode == 2'b11) begin    // BEQ
                                                if(z) begin
                                                    pc <= immediate;
                                                end
                                                state <= FETCH;
                                            end else begin
                                                reg_f <= data_out;
                                                state <= WRITE;
                                            end
                                            z <= 0;
                                        end
                            WRITE   :   begin
                                            if(opcode == 2'b10)               // CMP
                                                z <= (reg_d == reg_f);   
                                            else begin
                                                z <= 0;
                                            end
                                            state <= FETCH;
                                        end
            endcase
        end

    end

endmodule
