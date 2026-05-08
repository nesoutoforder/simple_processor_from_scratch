`include "defs.vh"
`timescale 1ns/1ps

module alu(
    input   [1:0]   op,
    input   [15:0]  A,
    input   [15:0]  B,
    output  reg     z,
    output  reg     c,
    output  reg     b,
    output  reg [15:0] result
);

    always @(*) begin
        z = 1'b0;
        b = 1'b0;
        c = 1'b0;
        result = 16'b0;
        case(op)
            `ALU_ADD  :   begin
                            {c, result} = A + B;
                        end
            `ALU_SUB  :   begin
                            if(B > A) 
                                b = 1'b1;
                            result = A - B;
                        end
            `ALU_COMP :   begin
                            z = (A == B);
                        end
        endcase
    end
endmodule
