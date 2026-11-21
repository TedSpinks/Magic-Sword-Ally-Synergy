lorom
; Wizard perk: faster magic-bar recharge.
; Original: each frame $0689 = ($0689+1) & mask; when it wraps to 0 the bar steps once (mask 7 normally, 3 when low on life).
; The step routine needs $0689 == 0 at that moment (it compares the 16-bit word $0688/$0689 with 10), so we keep that contract.
; With the Wizard as ally we sometimes advance $0689 more than once per frame.  Extra increments come from a quarter-unit
; accumulator in $077C: L1..L8 = +2,3,4,5,11,12,13,14 quarter units per frame (bar refill 55 frames -> 42,40,33,33,25,22,22,22).
macro WizPace(mask, rtsaddr, lab)
    php
    rep #$10
    phx
    sep #$30
    ldy #$00
    lda $0424
    cmp #$09
    bne .go_<lab>
    lda $042E
    bne .go_<lab>
    lda $0412
    and #$07
    tax
    lda.l StepTbl,x
    tay
.go_<lab>:
    tya
    clc
    adc $077C
    sta $077C
    lsr a
    lsr a
    tax                     ; number of extra increments this frame
    lda $077C
    and #$03
    sta $077C
.l_<lab>:
    lda $0689
    inc a
    and #<mask>
    sta $0689
    beq .trig_<lab>
    cpx #$00
    beq .done_<lab>
    dex
    bra .l_<lab>
.done_<lab>:
    rep #$10
    plx
    plp
    jml <rtsaddr>
.trig_<lab>:
    rep #$10
    plx
    plp
    jml $80AE10             ; step the bar
endmacro

org $80ADF6                 ; orig: LDA $0689 / INC A / AND #$07 / STA $0689 / BEQ $AE10
    jml WizSlow
    nop #7
org $80AE04                 ; orig: LDA $0689 / INC A / AND #$03 / STA $0689 / BEQ $AE10
    jml WizFast
    nop #7

org $82F200
WizSlow:
    %WizPace($07, $80AE01, s)
WizFast:
    %WizPace($03, $80AE0F, f)
StepTbl:
    db 2,3,4,5,11,12,13,14
