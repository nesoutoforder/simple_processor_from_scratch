`timescale 1ns/1ps

`ifndef EXP_R0
`define EXP_R0 0
`endif
`ifndef EXP_R1
`define EXP_R1 0
`endif
`ifndef EXP_R2
`define EXP_R2 0
`endif
`ifndef EXP_R3
`define EXP_R3 0
`endif
`ifndef EXP_PC
`define EXP_PC 0
`endif

module tb_datapath;

    reg clk;
    reg rst_n;

    datapath DUT (
        .clk_i  (clk),
        .rst_ni (rst_n)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task check;
        input string name;
        input [15:0] actual;
        input [15:0] expected;
    begin
        if (actual !== expected) begin
            $display("FAIL: %s = %0d, expected %0d", name, actual, expected);
            $fatal(1);
        end
    end
    endtask

    initial begin
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        // Wait until program reaches final PC
        fork
            begin
                wait(DUT.pc_q == `EXP_PC);
            end

            begin
                repeat(80) @(posedge clk);
                $fatal(1, "Timeout");
            end
        join_any

        disable fork;

        check("r0", DUT.u_regfile.regs_q[0], `EXP_R0);
        check("r1", DUT.u_regfile.regs_q[1], `EXP_R1);
        check("r2", DUT.u_regfile.regs_q[2], `EXP_R2);
        check("r3", DUT.u_regfile.regs_q[3], `EXP_R3);
        check("pc", DUT.pc_q, `EXP_PC);

        $display("PASS");
        $finish;
    end

endmodule
