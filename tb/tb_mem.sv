`timescale 1ns/1ps

module tb_mem();

    reg         clk = 0;
    reg         wr_en;
    reg  [6:0]  address;
    reg  [15:0] data_in;  
    wire [15:0] data_out;

    integer i;

    mem MEM(
        .clk(clk),
        .wr_en(wr_en),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #0.5 clk = ~clk;

    initial begin

        wr_en = 1;
        #1;
        wr_en = 0;

        for(i = 0; i < 128; i++) begin
            #1;
            address = i;
        end

    end

endmodule
