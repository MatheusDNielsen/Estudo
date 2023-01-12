    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $F000

START:
    ;CLEAN_START         ; Macro to clear memory 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set background color to yellow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    lda #$1E            ; load color yellow (NTSC) to register A
    sta COLUBK          ; store A to background color address $09

    jmp START           ; repeat from start


    org $FFFC
    .word START
    .word START
