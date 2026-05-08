`timescale 1ns/1ps

module mem(
    input               clk,
    input               wr_en,
    input       [6:0]   address,
    input       [15:0]  data_in,
    output reg  [15:0]  data_out
);

    reg [15:0] mem [0:127];

    initial begin
        $readmemh("programs/mem_init.hex", mem, 0, 127);
    end

    always @ (posedge clk) begin
        if(wr_en)
            mem[address] <= data_in;

        data_out <= mem[address];
    end

endmodule
