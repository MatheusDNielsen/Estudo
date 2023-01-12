    processor 6502
    seg Code 
    org $F000

Start:
    LDA #1
Loop:
    CLC
    ADC #1                  ; Increment A 
    CMP #10                 ; Compare the value in A with the decimal value 10 
    BNE	Loop                ; Branch back to loop if the comparison was not equals (to zero)

    jmp Start

    org $FFFC
    .word Start
    .word Start