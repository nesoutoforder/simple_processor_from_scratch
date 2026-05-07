# simple_processor_from_scratch
## ISA

```
0000 LOAD  rd, addr        ; rd = mem[addr]
0001 STORE rs, addr        ; mem[addr] = rs

0010 ADD   rd, rs1, rs2    ; rd = rs1 + rs2
0011 SUB   rd, rs1, rs2    ; rd = rs1 - rs2

0100 ADDI  rd, rs1, imm    ; rd = rs1 + imm
0101 MOVI  rd, imm         ; rd = imm

0110 BEQ   rs1, rs2, imm   ; if rs1 == rs2 pc = imm
0111 BNE   rs1, rs2, imm   ; if rs1 != rs2 pc = imm
1000 JMP   imm             ; pc = imm 
```

## Primer programa simple
```
MOVI R0, 5        ; R0 = 5
MOVI R1, 7        ; R1 = 7

ADD  R2, R0, R1   ; R2 = R0 + R1 = 12

STORE R2, 20      ; mem[20] = R2

LOAD R3, 20       ; R3 = mem[20]

SUB  R3, R3, R0   ; R3 = R3 - R0 = 7
ADDI R3, R3, 5    ; R3 = R3 + 5 = 12

BEQ  R3, R2, 9   ; si R3 == R2

JMP  8            ; error loop
JMP  9            ; success loop
```

