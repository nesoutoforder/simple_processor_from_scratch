# simple_processor_from_scratch

## Architecture Overview

Current processor organization:

```text
FETCH -> DECODE -> EXEC -> MEM -> WB
```

Main modules:

```text
rtl/
├── datapath.v
├── control_unit.v
├── alu.v
├── regfile.v
├── imem.v
├── dmem.v
└── defs.vh
```

Features currently implemented:
- multicycle FSM-based execution
- separate instruction/data memories
- 4 general-purpose registers
- arithmetic and branch instructions
- immediate instructions
- synchronous memories
- automated regression tests

---

## ISA

### Instruction Encoding

```text
[15:12] opcode
[11:10] rd
[9:8]   rs1
[7:6]   rs2
[5:0]   imm / addr
```

---

### Supported Instructions

```text
0000 LOAD  rd, addr
     rd = mem[addr]

0001 STORE rs, addr
     mem[addr] = rs

0010 ADD   rd, rs1, rs2
     rd = rs1 + rs2

0011 SUB   rd, rs1, rs2
     rd = rs1 - rs2

0100 ADDI  rd, rs1, imm
     rd = rs1 + imm

0101 MOVI  rd, imm
     rd = imm

0110 BEQ   rs1, rs2, imm
     if (rs1 == rs2)
         pc = imm

0111 BNE   rs1, rs2, imm
     if (rs1 != rs2)
         pc = imm

1000 JMP   imm
     pc = imm
```

---

## Example Program

```assembly
MOVI R0, 5
MOVI R1, 7

ADD  R2, R0, R1

STORE R2, 20

LOAD R3, 20

SUB  R3, R3, R0
ADDI R3, R3, 5

BEQ  R3, R2, 9

JMP  8

JMP  9
```

---

## Verification

The processor includes automated regression tests.

Current test coverage:
- arithmetic operations
- immediates
- load/store
- taken branches
- non-taken branches
- PC updates
- register file state

Test infrastructure:

```text
tests/
├── programs/
├── run_tests.sh
└── tb_datapath.sv
```

Run all tests:

```bash
./tests/run_tests.sh
```

---

## Simulation

Compile and simulate manually with QuestaSim:

```bash
vlib work

vlog -sv -f filelist.f

vsim tb_datapath
```