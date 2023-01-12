    processor 6502
    seg Code
    org $F000

Start:
    LDY #10
Loop:
    TYA
    STA $80,Y
    DEY
    BPL Loop

    JMP Start

    org $FFFC
    .word Start
    .word Start