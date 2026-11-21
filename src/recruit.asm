lorom
; Amazon perk (v60): the carrier.  Replaces the v14-v59 Recruiter (+1/+2/+3 by her level).
;  - She joins at the higher of her own join level and your previous ally's level.
;  - When you swap her for a different ally, it joins at the higher of her level and its own join level + 1 (cap L8).
;    Same as: new level = max(Amazon level, table level + 1).  Early on that is a +1 bonus, later it carries your level.
;  - Nothing passes when the current ally is dying (`$042E`), and freeing the type you already have is the original +2 (not this path).
; Hook is the "new ally level" step of $01:8432 (different type only).
; Entry: A = table level of the new ally (0-based, 8-bit M), Y = new ally type (0 = Amazon), $0424 = OLD ally id, $0412 = old level.
org $018457                 ; orig: SEP #$10 / TYX / BRA $01846C
    jml RecruitBonus
    nop

org $81FF80
RecruitBonus:
    sep #$10
    tyx                     ; X = new ally type (as the original code leaves it)
    sta $0774               ; scratch: level to give
    lda $042E
    bne .done               ; the old ally is dying: it passes nothing
    lda $0424
    beq .done               ; no old ally
    cmp #$03
    beq .handoff            ; the Amazon hands off to a new ally
    cpx #$00
    bne .done               ; new ally is not the Amazon
    lda $0412               ; the Amazon joins: take the old ally's level if higher
    cmp $0774
    bcc .done
    sta $0774
    bra .done
.handoff:
    lda $0774
    inc a                   ; join level + 1
    cmp $0412
    bcs .cap                ; keep join+1 when it is at least her level
    lda $0412               ; otherwise she carries her level
.cap:
    cmp #$08
    bcc .set
    lda #$07                ; cap L8 (0-based 7)
.set:
    sta $0774
.done:
    lda $0774
    jml $81846C
