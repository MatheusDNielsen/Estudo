  processor 6502

  .include "macro.h"
  .include "vcs.h"
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Create an unitialized segment for storing variables.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg.u Variables
  .org $80
PlayerHeight .equ 9         ; hard-codes player height to 9
PlayerYPos byte             ; declares variable for player Y coordinate
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start ROM code segment starting at $F000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg Code
  .org $F000

Reset:
  CLEAN_START

  ldx #$00            ; Black background color
  stx COLUBK          ; Set background color

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Initialize Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
  lda #180
  sta PlayerYPos      ; PlayerYPos = 180

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
;; Generate 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldx #192

Scanline:
  txa                   ; transfer x to a
  sec
  sbc PlayerYPos        ; subtracts player's y position
  cmp PlayerHeight     ; checks to see if inside player height bounds
  bcc LoadBitmap        ; if result < PlayerHeight, call LoadBitmap
  lda #0

LoadBitmap:
  tay
  lda PlayerBitmap,Y    ; load playerbitmap slice of data
  sta WSYNC             ; wait for next scanline
  sta GRP0              ; set graphics to player 0 slice

  lda PlayerColor,Y     ; load playercolor slice of data
  sta COLUP0            ; set color to player 0 slice


  dex
  bne Scanline          ; repeat next scanline until finished

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Generate the 30 lines of Overscan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  lda #2
  sta VBLANK
  REPEAT 30
    sta WSYNC           ; 37 scanlines for vblank
  REPEND

  lda #0                
  sta VBLANK            ; turn off vblank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Decrement PlayerYPos each frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  dec PlayerYPos

  jmp StartFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lookup table for player graphics.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerBitmap:
  byte #%00000000
  byte #%00101000
  byte #%01110100
  byte #%11111010
  byte #%11111010
  byte #%11111010
  byte #%11111110
  byte #%01101100
  byte #%00110000
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Lookup table for player colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlayerColor:
  byte #$00
  byte #$40
  byte #$40
  byte #$40
  byte #$40
  byte #$42
  byte #$42
  byte #$44
  byte #$D2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define ROM as 4kb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  .org $FFFC
  .word Reset
  .word Reset
  