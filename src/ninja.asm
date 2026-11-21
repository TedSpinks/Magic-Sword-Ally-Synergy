lorom
; Ninja "Critical strike": while the Ninja is the active ally, a player hit on an enemy
; has a (13 + 5*level)/256 chance (5%..19%) of doing double damage.
; v31: only the player's own weapon (enemy-damage result 3, damage from $069F) can crit.
; Ally projectiles (the Ninja's stars, Amazon bolts, Cleric bullets...) use the $1678 hit-box path and never crit.
org $038052
    jml Crit1               ; orig: REP #$20 / LDA $069F / STA $06A1 / JMP $80E1 (11 bytes)
    nop #7
org $0388B4
    jml Crit2               ; orig: REP #$20 / LDA $069F / STA $06A1 / JMP $8946
    nop #7

org $82F400
Crit1:
    rep #$20
    lda $069F
    sta $06A1
    jsr CritRoll
    jml $8380E1
Crit2:
    rep #$20
    lda $069F
    sta $06A1
    jsr CritRoll
    jml $838946

CritRoll:                   ; M=16 on entry; preserves flags/regs we care about
    php
    sep #$20
    lda $0424 : cmp #$12 : bne .out
    lda $042E : bne .out
    lda $077D
    asl : asl
    clc : adc $077D
    inc a
    clc : adc $0601
    sta $077D
    lda $0412 : sta $0774
    asl : asl
    clc : adc $0774
    clc : adc #$0D
    cmp $077D
    bcc .out
    beq .out
    rep #$20
    lda $06A1
    asl
    bcc .ok
    lda #$7FFF
.ok:
    sta $06A1
    sep #$20
    lda #$02 : jsl $82F600   ; CRITICAL!
.out:
    plp
    rts

; Ninja "Evasion" part 2: longer post-hit invincibility. Original: [$00]+$1C = $78 (120 frames).
; Ninja: 150 + 13*level frames (L1 +25% .. L8 +101%).
org $019BEF
    jsl NinjaInv            ; orig: LDA #$78 / STA [$00],Y  (Y = $1C, M = 8; A must return = timer)

org $82F480
NinjaInv:
    lda $0424 : cmp #$12 : bne .std
    lda $042E : bne .std
    lda $0412
    asl : asl
    sta $0775
    asl
    clc : adc $0775
    clc : adc $0412
    clc : adc #150
    sta [$00],y
    rtl
.std:
    lda #$78
    sta [$00],y
    rtl


; ---------------------------------------------------------------------------------
; On-screen messages (top right, row 2, columns 22-31, BG3 tilemap $5C00, white palette 1).
; $077E = message type (1 EVADED!, 2 CRITICAL!, 3 REVIVED!), $077F = frames left.
; Drawn each frame in the post-NMI VRAM update ($00:8A8E hook), so it runs during vblank.
; The "!" glyph is not in the game font; it is written into blank tile $E1 while a message shows.
; ---------------------------------------------------------------------------------
org $008A8E
    jml MsgHook             ; orig: SEP #$30 / LDA $0618
    nop
org $0095D1
    jml OamHook             ; orig: LDA #$00 / STA $4324 (OAM DMA source bank; end of the frame's OAM build)
    nop

; RAM: $077E/$077F top-right type/timer; $0780 pop-up type, $0781 pop-up timer, $0782 pop-up x, $0783 pop-up start y,
;      $0784 graphics upload pending (type), $0787 "!" glyph shown
!PopTime = 90               ; frames the pop-up is shown (rises for the first !PopRise frames, 1 pixel per frame)
!PopRise = 40
!OamBuf = $7FF000           ; private OAM copy: our 4 sprites in slots 0-3 (highest priority), the game's 0-123 after them
org $82F600
ShowMsg:                    ; A (low byte) = message type 1..3; any M/X. DP must hold the event object's pointer at $00
    php
    sep #$20
    sta $077E
    sta $0780
    sta $0784               ; ask the vblank hook to upload this word's graphics
    ; (v29: the top-right HUD copy is retired; $077F stays 0 so MsgDraw / the "!" HUD glyph never run)
    lda #!PopTime
    sta $0781
    rep #$30
    phy
    phx
    ; x: centre the word on the object's screen x ([$00]+4); all immediates below are explicit .w (M=16)
    sep #$20
    lda $0780
    asl a
    sep #$10
    tax                     ; X = type*2 (word table)
    rep #$20
    ldy.b #$04
    lda [$00],y
    sec
    sbc.l PopHalf-2,x
    bpl .x1
    lda.w #$0000
.x1:
    cmp.w #$00C0            ; keep the 64-pixel strip on screen
    bcc .x2
    lda.w #$00C0
.x2:
    sep #$20
    sta $0782
    ; y: start above the object's screen y ([$00]+6)
    rep #$20
    ldy.b #$06
    lda [$00],y
    sec
    sbc.w #$0028
    bpl .y1
    lda.w #$0000
.y1:
    cmp.w #!PopRise+24      ; leave room to rise without going under the HUD
    bcs .y2
    lda.w #!PopRise+24
.y2:
    cmp.w #$00B0
    bcc .y3
    lda.w #$00B0
.y3:
    sep #$20
    sta $0783
    rep #$30
    plx
    ply
    plp
    rtl

MsgHook:                    ; post-NMI VRAM update chain (vblank)
    sep #$30
    lda $0784
    beq .noup
    jsr PopUpload
    stz $0784
.noup:
    lda $077F
    bne .act
    lda $0787
    beq .orig
    stz $0787
    jsr GlyphBlank
    bra .orig
.act:
    lda #$01
    sta $0787
    jsr GlyphDraw
    dec $077F
    jsr MsgDraw
.orig:
    lda $0618
    jml $808A93

PopUpload:                  ; DMA the word's 16 tiles from ROM to sprite tiles $100-$103/$110-$113/$120-$123/$130-$133
    lda #$80                ; (second sprite table, VRAM words $7000-$733F; never used by the game on any floor start)
    sta $2115
    rep #$20
    lda $0784
    and #$00FF
    dec a
    xba                     ; *256
    asl a                   ; *512
    clc
    adc.w #PopGfx
    sta $0776
    lda.w #$7000
    jsr .chunk
    lda.w #$7100
    jsr .chunk
    lda.w #$7200
    jsr .chunk
    lda.w #$7300
    jsr .chunk
    sep #$20
    rts
.chunk:                     ; A = VRAM word address, $0776 = source; sends 128 bytes, advances source
    sta $2116
    lda $0776
    sta $4372
    clc
    adc.w #$0080
    sta $0776
    lda.w #$1801            ; mode 1 (2 regs, word), destination $2118
    sta $4370
    lda.w #$0080
    sta $4375
    sep #$20
    lda.b #PopGfx>>16
    sta $4374
    lda #$80
    sta $420B               ; DMA channel 7
    rep #$20
    rts

OamHook:                    ; main thread, M=8 X=8, OAM buffer $1000/$1200 is final for this frame
    lda #$00
    sta $4324               ; replaced instruction (DMA from $00:1000)
    lda $0781
    beq .out0
    lda $0784
    beq .go                 ; graphics uploaded
.out0:
    jml $8095D6
.go:
    dec $0781
    ; y = start - min(elapsed, !PopRise)
    lda #!PopTime
    sec
    sbc $0781
    cmp #!PopRise
    bcc .r
    lda #!PopRise
.r: sta $0774
    lda $0783
    sec
    sbc $0774
    sta $0775
    lda $0781
    eor #!PopTime-1         ; zero on the first shown frame
    php
    phb
    rep #$30
    ; the game's slots -> buffer slots +4 (low table) and high-table bytes +1. First frame: all 124 slots;
    ; later frames only the first 64 (the game uses at most ~42), to keep the per-frame cost small.
    bne .part
    ldx #$1000
    ldy.w #!OamBuf+16
    lda.w #$01EF
    db $54,$7F,$00          ; MVN: src bank $00, dest bank $7F
    ldx #$1200
    ldy.w #!OamBuf+$201
    lda.w #$001E
    db $54,$7F,$00
    bra .cp
.part:
    ldx #$1000
    ldy.w #!OamBuf+16
    lda.w #$00FF
    db $54,$7F,$00
    ldx #$1200
    ldy.w #!OamBuf+$201
    lda.w #$000F
    db $54,$7F,$00
.cp:
    plb
    sep #$30
    ; our four 16x16 sprites in slots 0-3
    ldx #$00
.s: lda $0782
    clc
    adc.l PopSpr,x          ; x offset
    sta.l !OamBuf,x
    lda $0775
    sta.l !OamBuf+1,x
    lda.l PopSpr+1,x        ; tile
    sta.l !OamBuf+2,x
    lda #$33                ; priority 3, palette 1 (as the score pop-ups), second sprite table (tile +$100)
    sta.l !OamBuf+3,x
    inx : inx : inx : inx
    cpx #$10
    bne .s
    lda #$00
    sta.l !OamBuf+$200      ; slots 0-3: small, x < 256
    rep #$20
    lda.w #!OamBuf
    sta $4322
    sep #$20
    lda.b #!OamBuf>>16
    sta $4324
    plp
.out:
    jml $8095D6

PopSpr:   db 0,$00,0,0, 16,$02,0,0, 32,$20,0,0, 48,$22,0,0   ; x offset, tile (low 8 bits; +$100 via attr bit 0), 4-byte stride
PopHalf:  dw 24, 28, 26     ; half of each word's pixel width (47, 56, 51)

GlyphDraw:                  ; "!" into blank HUD font tile $E1 (VRAM word $0708)
    jsr GlyphAddr
    ldx #$00
.g: lda.l Glyph,x
    sta $2118
    lda.l Glyph+1,x
    sta $2119
    inx : inx
    cpx #$10
    bne .g
    rts
GlyphBlank:
    jsr GlyphAddr
    ldx #$08
    lda #$00
.b: sta $2118
    sta $2119
    dex
    bne .b
    rts
GlyphAddr:
    lda #$80
    sta $2115
    lda #$08
    sta $2116
    lda #$07
    sta $2117
    rts

MsgDraw:                    ; top-right: row 2, columns 22-31 (word $5C56)
    lda #$56
    sta $2116
    lda #$5C
    sta $2117
    lda $077F
    beq .blankmap
    lda $077E
    dec a
    asl : sta $0774         ; *2
    asl : asl               ; *8
    clc : adc $0774         ; *10
    tax
    ldy #$0A
.m: lda.l MsgTbl,x
    sta $2118
    beq .hi0
    lda #$24                ; priority + palette 1 (white)
.hi0:
    sta $2119
    inx
    dey
    bne .m
    rts
.blankmap:
    stz $077E
    ldy #$0A
    lda #$00
.b: sta $2118
    sta $2119
    dey
    bne .b
    rts

Glyph:                      ; "!" in 2bpp: (plane0, plane1) per row
    db $00,$00, $08,$10, $08,$10, $08,$10, $08,$10, $00,$00, $08,$10, $18,$00

; tile ids: letters A..Z = $B2..$CB, "!" = $E1, 0 = blank; 10 columns (22..31)
MsgTbl:
    db $00,$00,$B6,$C7,$B2,$B5,$B6,$B5,$E1,$00     ; EVADED!
    db $B4,$C3,$BA,$C5,$BA,$B4,$B2,$BD,$E1,$00     ; CRITICAL!
    db $00,$C3,$B6,$C7,$BA,$C7,$B6,$B5,$E1,$00     ; REVIVED!

; Pop-up word graphics: 4bpp sprite tiles in the style of the score pop-ups (outline 1, dark blue B,
; light blue C, white 9 = sprite palette 1). Each word: 8 tiles top row + 8 tiles bottom row (512 bytes).
org $89B000
PopGfx:
incsrc "popgfx.inc"


; Ninja dodge (moved out of bank 81 in v19: in v17/v18 it pushed hack's bank-81 code into
; RecruitBonus at $81:FF80, which corrupted BigInit and crashed when recruiting Big Man).

; v31: the roll happens BEFORE the hit reaction (hit sound, stagger, sword drop, damage), right after the
; game has decided a hit lands ($12BB = damage, non-zero).  An evade returns through the routine's own
; "no hit" exit, so nothing of the hit sequence runs.  After an evade the player is untouchable for
; !EvadeCool frames (silently, no blink) so the same contact doesn't re-roll every frame.
; Chance (of 256) = 13 + 7*level (level 0..7) => ~5% .. ~24%
!EvadeCool = 40
!Cool = $077B
org $019B5B
    jml DmgEntry            ; orig: SEP #$20 / LDY #$1C  (top of the per-frame player-damage check)
org $019B9C
    jml NinjaDodge          ; orig: SEP #$20 / LDA $040B  (a hit with damage $12BB is about to be applied)
    nop

org $82FA00
DmgEntry:
    sep #$20
    lda !Cool
    beq .go
    dec !Cool
.go:
    ldy #$1C
    jml $819B5F
NinjaDodge:
    sep #$20
    lda $0424 : cmp #$12 : bne .hit
    lda $042E
    bne .hit
    lda !Cool
    bne .evade              ; still inside the post-evade window: silently evade
    lda $077D
    asl : asl
    clc : adc $077D
    inc a
    clc : adc $0601
    sta $077D               ; cheap LCG, mixed with frame counter
    lda $0412
    asl : asl : asl
    sec : sbc $0412
    clc : adc #$0D
    cmp $077D
    bcc .hit                ; random >= threshold: hit lands
    beq .hit
    lda #$01 : jsl ShowMsg  ; EVADED!
    lda #!EvadeCool
    sta !Cool
.evade:
    jml $819BFB             ; STZ $12BB / STZ $12BC / RTS  (the routine's no-hit exit)
.hit:
    lda $040B
    jml $819BA1             ; BEQ $9BAB ... (original flow)
