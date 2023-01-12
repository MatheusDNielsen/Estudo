    processor 6502

    include "vcs.h"
    include "macro.h"

    seg Code
    org $F000

START:


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start new frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
NEXT_FRAME:
    lda #2
    sta VBLANK      ; turn on Vblank
    sta VSYNC       ; turn on VSync

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three scanlines of Vsync
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    sta WSYNC       ; first scanline
    sta WSYNC       ; second scanline
    sta WSYNC       ; third scanline

    lda #0
    sta VSYNC       ; turn off Vsync

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 37 scanlines ofVblank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #37         ; count 37 scanlines
LoopVblank:
    sta WSYNC       ; hit WSYNC to wait for next scanline
    dex             ; decrement x
    bne LoopVblank  ; loop until x == 0

    lda #0
    sta VBLANK      ; turn off VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 30 scanlines of overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ldx #30         ; count 37 scanlines
LoopOverscan:
    sta WSYNC       ; hit WSYNC to wait for next scanline
    dex             ; decrement x
    bne LoopVblank  ; loop until x == 0

    lda #0
    jmp NEXT_FRAME  ;Creates new frame



    org $FFFC
    .word START
    .word START
    