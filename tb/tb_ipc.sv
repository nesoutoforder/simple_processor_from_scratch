`include "rtl/defs.vh"
`timescale 1ns/1ps

`ifndef EXP_FINAL_PC
`define EXP_FINAL_PC 15
`endif
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
`ifndef EXP_MIN_INSTR
`define EXP_MIN_INSTR 1
`endif

module tb_ipc;

    reg clk;
    reg rst_n;

    integer cycle_count;
    integer instr_count;
    real ipc;

    reg [6:0] last_pc;
    reg [15:0] last_ir;

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

    // Cycle counter
    always @(posedge clk) begin
        if (!rst_n)
            cycle_count <= 0;
        else
            cycle_count <= cycle_count + 1;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            instr_count <= 0;
            last_pc     <= 0;
            last_ir     <= 0;
        end else begin
            if (DUT.u_control_unit.state_o == `CPU_ST_FETCH ) begin
                if (DUT.pc_q != last_pc) begin
                    instr_count <= instr_count + 1;
                    last_pc     <= DUT.pc_q;
                    last_ir     <= DUT.instr_q;
                end
            end
        end
    end

    initial begin
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;

        fork
            begin
                wait(DUT.pc_q == `EXP_FINAL_PC);
            end

            begin
                repeat(500) @(posedge clk);
                $fatal(1, "Timeout waiting for final PC");
            end
        join_any

        disable fork;

        // Wait a couple of cycles so the final instruction is counted cleanly.
        repeat(2) @(posedge clk);

        ipc = instr_count * 1.0 / cycle_count;

        check("r0", DUT.u_regfile.regs_q[0], `EXP_R0);
        check("r1", DUT.u_regfile.regs_q[1], `EXP_R1);
        check("r2", DUT.u_regfile.regs_q[2], `EXP_R2);
        check("r3", DUT.u_regfile.regs_q[3], `EXP_R3);

        if (instr_count < `EXP_MIN_INSTR) begin
            $display("FAIL: instr_count = %0d, expected at least %0d",
                    instr_count, `EXP_MIN_INSTR);
            $fatal(1);
        end

        $display("--------------------------------------");
        $display("IPC smoke test finished");
        $display("Cycles       : %0d", cycle_count);
        $display("Instructions : %0d", instr_count);
        $display("IPC          : %0f", ipc);
        $display("--------------------------------------");

        $finish;
    end

endmodule
