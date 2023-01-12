    processor 6502
    seg Code
    org $F000

Start:
    LDA #$A                ; Load the A register with the hexadecimal value $A 
    LDX %1010              ; Load the X register with the binary value %1010 
     
    STA $80                 ; Store the value in the A register into (zero page) memory address $80 
    STX $81                 ; Store the value in the X register into (zero page) memory address $81 
     
    LDA #10                 ; Load A with the decimal value 10 
    CLC
    ADC $80                 ; Add to A the value inside RAM address $80 
    CLC
    ADC $81                 ; Add to A the value inside RAM address $81 
                            ; A should contain (#10 + $A + %1010) = #30 (or $1E in hexadecimal) 
    STA $82                 ; Store the value of A into RAM position $82

    org $FFFC
    .word Start
    .word Start
    