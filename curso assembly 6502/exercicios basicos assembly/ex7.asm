    processor 6502
    seg Code
    org $F000

Start:
    LDA #10                ; Load the A register with the decimal value 10 
    STA $80                ; Store the value from A into memory position $80 
     
    INC $80                ; Increment the value inside a (zero page) memory position $80 
    DEC $80                ; Decrement the value inside a (zero page) memory position $80

    org $FFFC
    .word Start
    .word Start
    