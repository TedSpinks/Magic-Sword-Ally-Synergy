lorom
; ---- Save system core (v30): battery SRAM, 3 slots, autosave at each floor start, resume ----
; SRAM (2 KB, $70:0000): slot n (1-3) at $70:0n00: +0 valid marker $A6 (v71), +1..+6 name, +$0E checksum (16-bit sum of +$10..+$9E),
;                        +$10..+$9E = WRAM $0403-$0491 (the run state: floor, ally and all ally levels, life, lives, keys, items,
;                        score, King's staff countdown, ...). $0460 (frame counter) is saved but never restored.
org $00FFD6 : db $02        ; cartridge type: ROM + RAM + battery
org $00FFD8 : db $01        ; SRAM size: 2 KB

!Slot   = $04A5             ; 0 = no slot (no autosave), 1-3 = active slot
!Resume = $04A6             ; nonzero: restore the slot at the next floor start

org $8082EF
    jml FloorStart          ; orig: REP #$20 / LDA #$0000 (start of the floor-start routine)
    nop

org $86E000
; v71: the run snapshot holds run state only.  The option bytes that live inside $0403-$0491 (the button masks $0464-$0468) are written to the slot as 0 and never restored, so a resumed run keeps the current OPTION MODE settings.
; The slot layout is unchanged (+$10 = $0403), the checksum sums what is stored.  $0460 (frame counter) is saved, not restored.
FloorStart:
    php
    sep #$20
    rep #$10
    lda !Slot
    beq .done
    rep #$20
    and #$0003
    xba                     ; A = slot*256
    tax                     ; X = slot*256 -> $70:0n00
    sep #$20
    lda !Resume
    beq .save
    stz !Resume
    ldy #$0000              ; restore WRAM $0403.. from SRAM +$10..
.r: jsr OptByte
    bcs .rs                 ; option byte: leave the current value
    cpy.w #$005D            ; skip $0460
    beq .rs
    lda.l $700010,x
    sta $0403,y
.rs:
    inx
    iny
    cpy.w #$008F
    bne .r
    bra .done
.save:
    phx
    ldy #$0000
    rep #$20
    lda #$0000
    sta $0776               ; checksum accumulator
    sep #$20
.w: jsr OptByte
    bcs .z
    lda $0403,y
    bra .st
.z: lda #$00                ; option byte: not part of the save
.st:
    sta.l $700010,x
    rep #$20
    and #$00FF
    clc
    adc $0776
    sta $0776
    sep #$20
    inx
    iny
    cpy.w #$008F
    bne .w
    plx
    rep #$20
    lda $0776
    sta.l $70000E,x
    sep #$20
    lda #$A6                ; v71 format marker (v30-v70 saves used $A5 and are ignored)
    sta.l $700000,x
.done:
    jsl $89C3D0            ; after a resume the saved TOP is back in WRAM: raise it to the table's best score
    plp
    rep #$20
    lda #$0000              ; replaced instructions
    jml $8082F4
OptByte:                    ; Y = offset from $0403; C = 1 if it is an option byte (button masks).  v73: GAME LEVEL ($0409) is part of the run again
    cpy.w #$0061
    bcc .n
    cpy.w #$0066
    bcc .y
.n: clc
    rts
.y: sec
    rts

; Start-point menu: while resuming, take floor/section from the slot and confirm at once (same as pressing START).
org $80BF7C
    jml ResumeCheck         ; orig: LDA $1245 / ORA $1246 (6 bytes)
    nop
    nop
org $82FB80
ResumeCheck:                ; M=8 X=8
    lda !Resume
    beq .norm
    rep #$10
    rep #$20
    lda !Slot
    and #$0003
    xba
    tax
    sep #$20
    lda.l $700010,x
    sta $0403
    lda.l $700011,x
    sta $0404
    lda.l $700012,x
    sta $0405
    sep #$10
    jml $80BF8D             ; confirm
.norm:
    lda $1245
    ora $1246
    jml $80BF82

; After the floor set-up has picked the ally (both paths join at $80:83D0): record ally id/level and credits
; for the slot screen at +$A0..+$A2 (display only, outside the checksum).
org $8083D0
    jml InfoSave            ; orig SEP #$20 / LDA $0403
    nop
org $82FBC0
InfoSave:
    sep #$20
    lda !Slot
    beq .x
    rep #$30
    and #$0003
    xba
    tax
    sep #$20
    lda $0424 : sta.l $7000A0,x
    lda $0412 : sta.l $7000A1,x
    lda $042D : sta.l $7000A2,x
.x:
    sep #$20
    lda $0403
    jml $8083D5
