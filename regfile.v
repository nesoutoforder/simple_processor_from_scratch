`timescale 1ns/1ps

module regfile(
    input               clk,
    input               rst_n,
    input               we,
    input       [1:0]   rd_addr,
    input       [1:0]   rs1_addr,
    input       [1:0]   rs2_addr,
    input       [15:0]  rd_in,
    output      [15:0]  rs1_out,
    output      [15:0]  rs2_out
);
    integer  i;
    reg [15:0] register [0:3];

    assign rs1_out = register[rs1_addr];
    assign rs2_out = register[rs2_addr];

    always @ (posedge clk or negedge clk) begin
        if(!rst_n) begin
            for(i = 0; i < 4; i = i + 1)
                register[i] <= 0;
        end
        if(we)
            register[rd_addr] <= rd_in;
    end

endmodule
