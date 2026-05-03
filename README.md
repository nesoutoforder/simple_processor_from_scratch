# simple_processor_from_scratch
0: ADD 20,21     ; mem[20] += 1
1: CMP 20,22     ; ¿mem[20] == 32?
2: BEQ 6         ; si sí -> halt
3: CMP 21,21     ; z = 1 siempre
4: BEQ 0         ; salto incondicional a loop
6: CMP 21,21     ; z = 1
7: BEQ 7         ; halt

20: 1
22: 32
