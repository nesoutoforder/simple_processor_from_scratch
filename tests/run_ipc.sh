#!/usr/bin/env bash
set -e

echo "======================================"
echo "Running IPC smoke test"
echo "======================================"

rm -rf work transcript vsim.wlf sim.log
vlib work > /dev/null

vlog -sv \
    +define+IMEM_INIT_FILE=\"tests/programs/ipc_smoke.hex\" \
    +define+EXP_FINAL_PC=15 \
    +define+EXP_R0=9 \
    +define+EXP_R1=9 \
    +define+EXP_R2=2 \
    +define+EXP_R3=3 \
    +define+EXP_MIN_INSTR=10 \
    -f filelist.f \
    > /dev/null

vsim -c tb_ipc -do "run -all; quit -f"