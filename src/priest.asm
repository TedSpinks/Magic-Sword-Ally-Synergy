lorom
; Priest perk: the healer.
;  1) Healing items restore more life: + amount*HealTbl[level]/32  (+12% at L1 ... +75% at L8, v116; was +100%).
;  2) Slow life trickle for the player: +1 life unit every 480 (L1) ... 120 (L8) frames while he is your ally.
;  3) His own ally-life regen row (table $01:8AD6) is brought close to the Wizard's.
; Scratch RAM: $0774 count, $0775-76 amount, $0777-78 accum, $0779-7A trickle timer.

; --- 1) healing items: common routine $02:D64D adds A to $0431 (orig at D64F: AND #$00FF / CLC) ---
org $02D64F
    jml PriestHeal

; --- 2) trickle: Priest AI calls JSR $877F every frame at $01:DFCA ---
org $01DFCA
    db $20 : dw PriestTick

; --- 3) Priest regen row: frames per block at levels 1..8 ---
org $018B46
    dw 960,840,720,600,480,380,300,220

org $81FE00
PriestHeal:
    and #$00FF
    sta $0775
    sep #$20
    lda $0424
    cmp #$18
    bne .done
    lda $042E
    bne .done
    phx
    rep #$20
    lda $0412
    and #$0007
    tax
    sep #$20
    lda.l HealTbl,x
    sta $0774
    plx
    rep #$20
    stz $0777
.loop:
    rep #$20
    lda $0777
    clc
    adc $0775
    sta $0777
    sep #$20
    dec $0774
    bne .loop
    rep #$20
    lda $0777
    lsr #5
    clc
    adc $0775
    sta $0775
.done:
    rep #$20
    lda $0775
    clc
    jml $82D653

PriestTick:
    jsr $877F               ; original call
    php
    rep #$30
    lda $042E
    and #$00FF
    bne .out
    lda $0430
    and #$00FF
    bne .out
    inc $0779
    lda $0412
    and #$00FF
    asl a
    tax
    lda $0779
    cmp.l IntTbl,x
    bcc .out
    stz $0779
    lda $0431
    cmp $042B
    bcs .out
    inc a
    sta $0431
    jsl $00B067             ; refresh HUD
.out:
    plp
    rts

IntTbl:
    dw 480,420,360,300,240,190,150,120

HealTbl:                    ; bonus in 32nds per level L1..L8: 12.5%, 22%, 31%, 41%, 47%, 56%, 66%, 75%
    db 4,7,10,13,15,18,21,24
assert pc() <= $81FF80
