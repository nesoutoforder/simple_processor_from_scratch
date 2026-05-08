#!/usr/bin/env bash
set -e

run_test() {
    local test_name=$1
    local exp_r0=$2
    local exp_r1=$3
    local exp_r2=$4
    local exp_r3=$5
    local exp_pc=$6

    echo "======================================"
    echo "Running test: ${test_name}"
    echo "Expected: r0=${exp_r0}, r1=${exp_r1}, r2=${exp_r2}, r3=${exp_r3}, pc=${exp_pc}"
    echo "======================================"

    rm -rf work transcript vsim.wlf sim.log
    vlib work > /dev/null

    vlog -sv \
        +define+IMEM_INIT_FILE=\"tests/programs/${test_name}.hex\" \
        +define+EXP_R0=${exp_r0} \
        +define+EXP_R1=${exp_r1} \
        +define+EXP_R2=${exp_r2} \
        +define+EXP_R3=${exp_r3} \
        +define+EXP_PC=${exp_pc} \
        -f filelist.f \
        > /dev/null

    if vsim -c tb_datapath -do "run -all; quit -f" > sim.log; then
        echo "PASS: ${test_name}"
    else
        echo "FAIL: ${test_name}"
        cat sim.log
        exit 1
    fi

    echo
}

run_test movi_add          8  5 3 0 3
run_test sub               5  9 4 0 3
run_test addi              12 5 0 0 2
run_test load_store        7  7 0 7 3
run_test branch_taken      9  5 5 0 6
run_test branch_not_taken  1  5 3 0 6
