  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000

START:
  CLEAN_START         ;Macro to safely clear memory and TIA
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NextFrame:
  lda #2              ; Same binary value as 10
  sta VBLANK          ; turn on vblank
  sta VSYNC           ; turn on vsync

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  sta WSYNC           ; wait for next scan lines
  sta WSYNC           ; wait for next scan lines
  sta WSYNC           ; wait for next scan lines

  lda #0
  sta VSYNC           ; turn off vsync

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 37 lines of Vertical Blank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldx #37
VBlankLoop:
  sta WSYNC             ; wait for next scan lines
  dex                   ; decrement x by one
  bne VBlankLoop        ; loop until x == 0

  lda #0                
  sta VBLANK            ; turn off vblank


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 192 visible scan lines (kernel)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ldx #192
ScanlineLoop:
  stx COLUBK           ; set background color to 192
  sta WSYNC             ; wait for next scan lines
  dex                   ; decrement x by one
  bne ScanlineLoop      ; loop until x == 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 30 scanlines of overscan Vblank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lda #2              ; Same binary value as 10
  sta VBLANK          ; turn on vblank
  ldx #30             ; count 30 scanlines
OverscanLoop:
  sta WSYNC           ; hit WSYNC to wait for next scanline
  dex                 ; decrement x
  bne OverscanLoop    ; loop until x == 0

  lda #0
  jmp NextFrame      ;Creates new frame

  org $FFFC
  .word START
  .word START
    
