  processor 6502
  include "vcs.h"
  include "macro.h"

  seg code
  org $F000

Reset:
  CLEAN_START         ; Macro to safely clear memory and TIA
  
  ldx #$80
  stx COLUBK          ; Set background color to blue

  lda #$1C
  sta COLUPF          ; Set playfield color to yellow

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartFrame:
  lda #02
  sta VBLANK          ; turn VBlank on
  sta VSYNC           ; turn Vsync on

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  REPEAT 3
    sta WSYNC         ; three scanlines for vsync
  REPEND

  lda #0
  sta VSYNC           ; turn off vsync

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 37 lines of Vertical Blank
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  REPEAT 37
    sta WSYNC           ; 37 scanlines for vblank
  REPEND

  lda #0                
  sta VBLANK            ; turn off vblank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set CTRLPF register to allow playfield reflection
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldx %00000001         
  stx CTRLPF            ; CTRLPF register(D0 means reflect)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; Skip 7 scanliens with no PF set
  ldx #0
  stx PF0
  stx PF1
  stx PF2

  REPEAT 7
    sta WSYNC
  REPEND

  ; Set the PF0 to 1110(Left side bit first) and PF1-PF2 as FF (1111 1111)
  ldx #%11100000
  stx PF0
  ldx #$FF
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND
  ; Set the next 164 scanlines only with PF0 third bit enabled
  ldx %00110000
  stx PF0
  ldx #0
  stx PF1
  ldx #%00000001
  stx PF2

  REPEAT 164
    sta WSYNC
  REPEND

  ; Set the PF0 to 1110 (LSB first) and PF1-PF2 as FF (1111 1111)
  ldx #%11100000
  stx PF0
  ldx #$FF
  stx PF1
  stx PF2
  REPEAT 7
    sta WSYNC
  REPEND

  ; Skip 7 scanliens with no PF set
  ldx #0
  stx PF0
  stx PF1
  stx PF2

  REPEAT 7
    sta WSYNC
  REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render 30 vblank overscan lines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  lda #2
  sta VBLANK          ; turn on vblank

  REPEAT 30
    sta WSYNC         ; create 30 Vblank overscan lines
  REPEND

  lda #0
  sta VBLANK          ; turn off vblank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jump to next frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill 4kb memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  org $FFFC
  .word Reset
  .word Reset
  