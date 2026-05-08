#!/usr/bin/env bash
set -e

echo "======================================"
echo "Running all Icarus Verilog tests"
echo "======================================"

mkdir -p build

for program in tests/programs/*.hex; do

    test_name=$(basename "$program" .hex)

    # Skip default memory init and IPC benchmark
    if [[ "$test_name" == "mem_init" || "$test_name" == "ipc_smoke" ]]; then
        continue
    fi

    echo
    echo "--------------------------------------"
    echo "Running: $test_name"
    echo "--------------------------------------"

    rm -f build/a.out

    iverilog -g2012 \
        -Irtl \
        -DIMEM_INIT_FILE=\""$program"\" \
        -o build/a.out \
        rtl/*.v \
        tb/tb_datapath.sv

    vvp build/a.out

done

echo
echo "======================================"
echo "All tests passed"
echo "======================================"
