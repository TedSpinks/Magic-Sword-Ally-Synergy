lorom
; ===== v89: Thief's Log, part 1: record the floors finished with the Thief =====
; SRAM $70:0500 (shared by all saves, like the high scores):
;   +0 marker $7A, +1..+7 one bit per floor (floor n: byte n>>3, bit n&7, floors 0-55),
;   +8 check = (sum of +1..+7) xor $A5,
;   +9 floor a hidden-door warp is heading for ($FF none; not in the check).
; A floor counts when the game moves on from it ($00:8730, both the normal exit and the warp path) while the Thief
; is the active ally and not dying.  A hidden-door warp first writes its destination - 1 into $0403 ($05:98DC), so the
; floor is marked there and $00:8730 skips the destination it finds.

!Log = $700500

org $008730
    jsl LogFloorEnd             ; orig LDA $0403 / INC A (then CMP #$33 / BEQ ending / STA $0403)

org $0598D9
    jsl LogWarp                 ; orig LDA $00AE,X / STA $0403 (the hidden door's destination - 1)
    nop : nop

org $86D700
LogFloorEnd:                    ; M=8 X=8
    lda.l !Log+9
    cmp $0403
    beq .warp                   ; arrived here through a hidden door: that floor was marked at the door
    lda $0403
    jsr LogMark
.warp:
    lda #$FF
    sta.l !Log+9
    lda $0403
    inc a
    rtl

LogWarp:                        ; M=8, X = door object (16-bit), DB = $7E
    lda $0403
    jsr LogMark                 ; the floor being left
    lda.w $00AE,x
    sta $0403
    sta.l !Log+9
    rtl

; A = floor.  Sets its bit when the Thief is the active ally.  Keeps A, X, Y, DB and the flags' M/X.
LogMark:
    php
    rep #$30
    pha
    phx
    phy
    sep #$30
    lda $0424
    cmp #$15                    ; Thief?
    bne .out
    lda $042E                   ; dying?
    bne .out
    jsr LogValid
    lda $05,s                   ; floor (low byte of the pushed A)
    cmp.b #51                   ; v118: floors 51-55 are the ending scenes, not logged (was 56)
    bcs .out
    and #$07
    tay
    lda $05,s
    lsr : lsr : lsr
    tax
    lda #$01                    ; bit = 1 << (floor & 7)
    cpy #$00
    beq +
-   asl
    dey
    bne -
+   ora.l !Log+1,x
    sta.l !Log+1,x
    jsr LogSum
.out:
    rep #$30
    ply
    plx
    pla
    plp
    rts

; Make the record valid: a bad marker or check clears it.  M=8 X=8.
LogValid:
    lda.l !Log
    cmp #$7A
    bne .init
    jsr LogCalc
    cmp.l !Log+8
    beq .ok
.init:
    ldx #$00
    lda #$00
-   sta.l !Log+1,x
    inx
    cpx #$07
    bne -
    lda #$FF
    sta.l !Log+9
    lda #$7A
    sta.l !Log
    jsr LogSum
.ok:
    rts

LogSum:                         ; store the check.  M=8 X=8
    jsr LogCalc
    sta.l !Log+8
    rts

LogCalc:                        ; A = (sum of +1..+7) xor $A5.  M=8 X=8
    ldx #$00
    lda #$00
    clc
-   adc.l !Log+1,x
    inx
    cpx #$07
    bne -
    eor #$A5
    rts

; ===== v100: a floor is in the log as soon as the Thief is on it =====
; Called every main-loop pass from PauseHook ($89:FA00, logpage.asm) with JSL $86D7C0.  Marks the floor being played when
; the Thief is the active ally in play ($0430 = 0) (however he got there: carried over, start-floor ally, resume, name, freed from a cell door,
; hidden door), not dying, and not in the attract demo ($0402 = 4).  Writes SRAM only the first time per floor.
assert pc() <= $86D7C0
org $86D7C0
ThiefSeenL:                     ; any M/X; keeps A, X, Y, DB
    php
    rep #$30
    pha
    phx
    phy
    sep #$30
    lda $0402 : cmp #$04 : beq .out
    lda $0430 : bne .out                    ; only in play (the same test as the pause button)
    lda $0424 : cmp #$15 : bne .out
    lda $042E : bne .out
    lda $0403 : cmp.b #51 : bcs .out        ; v118: 51+ = ending scenes (was 56)
    lda.l !Log : cmp #$7A : bne .mark       ; no record yet: LogMark sets one up
    lda.l !Log+9 : cmp $0403 : beq .out     ; a hidden door has written its destination - 1 into $0403 (not this floor)
    lda $0403 : and #$07 : tay
    lda $0403 : lsr : lsr : lsr : tax
    lda.l !Log+1,x
-   cpy #$00 : beq +
    lsr : dey
    bra -
+   lsr : bcs .out                          ; already in the log
.mark:
    lda $0403
    jsr LogMark
.out:
    rep #$30
    ply
    plx
    pla
    plp
    rtl
assert pc() <= $86E000
