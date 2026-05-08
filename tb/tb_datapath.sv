`timescale 1ns/1ps

module tb_datapath();

    reg clk = 0;
    reg rst_n;

    always #0.5 clk = ~clk;

    datapath DUT (
        .clk_i(clk),
        .rst_ni(rst_n)
    );

    initial begin
        #1;
        rst_n = 0;
        #1;
        rst_n = 1;
        #1000;
    end

endmodule
