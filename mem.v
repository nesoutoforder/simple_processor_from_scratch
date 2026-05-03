`timescale 1ns/1ps

module mem(
    input               clk,
    input               wr_en,
    input       [6:0]   address,
    input       [15:0]  data_in,
    output      [15:0]  data_out
);

    reg [15:0] regs [0:127];

    assign data_out = wr_en ? 16'b0 : regs[address];

    initial begin
        $readmemh("mem_init.hex", regs, 0, 127);
    end

    always @ (posedge clk) begin
        if(wr_en)
            regs[address] <= data_in;
    end

endmodule
