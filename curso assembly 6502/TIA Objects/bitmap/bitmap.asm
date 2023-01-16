  processor 6502
  include "vcs.h"
  include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start an unitialized segment for variable declaration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  seg.u Variables
  org $80
P0Height ds 1       ; defines one byte for player zero height
P1Height ds 1       ; defines one byte for player one height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ROM Space
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  seg code
  org $F000

Reset:
  CLEAN_START         ; Macro to safely clear memory and TIA
  
  ldx #$80
  stx COLUBK          ; Set background color to blue

  lda #$0F
  sta COLUPF          ; Set playfield color to yellow

  lda #10
  sta P0Height
  sta P1Height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set P0 and P1 colors
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  lda #$48
  sta COLUP0          ; Set P0 color to light red

  lda #$C6
  sta COLUP1          ; Set P1 colot to light green

  ldy #%00000010
  sty CTRLPF	      ; Defines the PF as the players' score
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
;; Render 192 visible scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VisibleScanlines:
  REPEAT 10
    sta WSYNC           ; Draws 10 empty scanlines
  REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Displays the score number's 10 scanlines
;; pulls data from an array of bytes difined at NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldy #0
ScoreboardLoop:
  lda NumberBitmap,Y    
  sta PF1
  sta WSYNC
  iny
  cpy #10               ; Compares Y to #10. Sets equal flag if equal
  bne ScoreboardLoop    ; loops to ScoreboardLoop if equal flag not 1

  lda #0
  sta PF1               ; Disables playfield

  REPEAT 50
    sta WSYNC           ; Draws 50 scanlines
  REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Displays the player 0's 10 scanlines
;; pulls data from an array of bytes difined at PlayerBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldy #0
Player0Loop:
  lda PlayerBitmap,Y
  sta GRP0              
  sta WSYNC
  iny
  cpy P0Height
  bne Player0Loop

  lda #0
  sta GRP0              ; Disables player 0's graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Displays the player 1's 10 scanlines
;; pulls data from an array of bytes difined at PlayerBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ldy #0
Player1Loop:
  lda PlayerBitmap,Y
  sta GRP1              
  sta WSYNC
  iny
  cpy P1Height
  bne Player1Loop

  lda #0
  sta GRP1              ; Disables player 0's graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Render remaining scanlines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  REPEAT 102
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
;; Defines Player's Bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  org $FFE8
PlayerBitmap:
  .byte #%01111110    ;  ######
  .byte #%11111111    ; ########
  .byte #%10011001    ; #  ##  #
  .byte #%11111111    ; ########
  .byte #%11111111    ; ########
  .byte #%11111111    ; ########
  .byte #%10111101    ; # #### #
  .byte #%11000011    ; ##    ##
  .byte #%11111111    ; ########
  .byte #%01111110    ;  ######

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defines Scoreboards Bitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  org $FFF2
NumberBitmap:
  .byte #%00001111    ; ########
  .byte #%00001111    ; ########
  .byte #%00000011    ;      ###
  .byte #%00000011    ;      ###
  .byte #%00001111    ; ########
  .byte #%00001111    ; ########
  .byte #%00001100    ; ###
  .byte #%00001100    ; ###
  .byte #%00001111    ; ########
  .byte #%00001111    ; ########

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Fill 4kb memory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  org $FFFC
  .word Reset
  .word Reset
  