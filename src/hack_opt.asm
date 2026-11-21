lorom
!IcBase = $7FE7C0   ; byte: offset of this icon's 4 cache records in the object (door hints $EC, exit row $C0/$D0/$E0/$F0)
!IcPh   = $7FE7C1   ; byte: dither phase this frame (0/1)
!IcDX   = $7FE7C2   ; word: added to the object's x
!IcDY   = $7FE7C4   ; word: added to the object's y
!IcRes  = $7FE7C6   ; word: sprite-pool slots that must stay free for the game
!IcNeed = $7FE7C8   ; byte: new slots this draw would take
!IcTmp  = $7FE7CA   ; word
!StX    = $7FE7E0   ; v86: word, star centre x on screen
!IcGrp  = $7FE7CE   ; byte: 0 = door hint, 1 = exit row
!Cool   = $7FE7D0   ; per group: +0 frame of the last forced release ($0601), +1 cooling flag (door $D0/$D1, exit $D2/$D3)
!CoolLen = 120      ; frames a group waits before taking slots again after giving them back
!DoorRes = 8        ; door hints draw only while at least this many pool slots stay free
; Magic Sword Ally Perks: Thief door hint + Big Man block, built on top of the FastROM base ROM
; Thief door hint v6: skull on trap doors, ally head on ally doors, fairy on fairy doors (FLICKER only since v67; the DITHER mode and its option were removed).
; Hook: door draw tail $02:C3E5 (orig: SEP #$30 / LDY #$0B)
org $02C3E5
    jml HintHook

org $82EE00      ; NOT $02:EC85: the stair-walk routine over-reads its table at $EC6D into this area
HintHook:
    sep #$30
    lda $0424
    cmp #$15            ; Thief active?
    bne .rel
    lda $042E           ; ally dying?
    bne .rel
    lda $0601
    and #$0C
    beq .orig           ; flicker off-phase (keep the cached graphics); v67: DITHER mode removed
.dith:
    ldy #$A6
    lda [$00],y
    cmp #$21            ; only real cell doors (the tail is shared with other objects)
    bne .orig
    ldy #$AB
    lda [$00],y         ; door contents id
    tax
    lda.l ContentsIcon,x
    beq .orig           ; nothing to show
    jsl DoorIconL
    bra .orig
.rel:                   ; no Thief: a door gives back any pool slots its hint still holds
    ldy #$A6
    lda [$00],y
    cmp #$21
    bne .orig
    lda #$EC
    sta.l !IcBase
    jsl ReleaseAllL
.orig:
    sep #$30
    ldy #$0B
    jml $82C3E9

; per icon code 0..10
IconEntry: db 0, 0, 10,15,20,25,30,35,40,45, 50, 60, 65   ; v86: 11 = hidden-door star (palette 7), 12 = same star in palette 0
IconTwo:   db 0, 1, 0,0,0,0,0,0,0,0, 1, 0, 0
IconFrame: dw 0, SkullFrame, FrameP0, FrameP0, FrameP2, FrameP2, FrameP0, FrameP2, FrameP0, FrameP0, FairyFrame, StarFrame, StarFrame0

SkullFrame:
    db $02
    db $08,$00,$D8,$00,$22   ; skull top    (x+8, y-40), palette 1
    db $08,$00,$E8,$00,$22   ; skull bottom (y-24)
FairyFrame:
    db $02
    db $08,$00,$D8,$00,$22   ; fairy top  (x+8, y-40), palette 1
    db $08,$00,$E8,$00,$22   ; fairy legs (y-24)
FrameP0: db $01, $08,$00,$E2,$00,$20   ; 16x16 icon, palette 0
FrameP1: db $01, $08,$00,$E2,$00,$22   ; palette 1
FrameP2: db $01, $08,$00,$E2,$00,$24   ; palette 2
StarFrame: db $01, $F8,$FF,$F8,$00,$2E   ; v86: 16x16 star centred on the point (dx word, dy byte, size, attr), palette 7
StarFrame0: db $01, $F8,$FF,$F8,$00,$20  ; v86: fallback star, palette 0

; graphics table: 5-byte entries (descriptor pointer, graphic id); entries 0-11 phase A, 12-23 phase B (+60 bytes)
HintTable:
    dl SkullTopDescA : dw $7E00
    dl SkullBotDescA : dw $7E01
    dl IconDescA0 : dw $7E02
    dl IconDescA1 : dw $7E03
    dl IconDescA2 : dw $7E04
    dl IconDescA3 : dw $7E05
    dl IconDescA4 : dw $7E06
    dl IconDescA5 : dw $7E07
    dl IconDescA6 : dw $7E08
    dl IconDescA7 : dw $7E09
    dl IconDescA8 : dw $7E0A
    dl IconDescA9 : dw $7E0B
    dl SkullTopDescB : dw $7E10
    dl SkullBotDescB : dw $7E11
    dl IconDescB0 : dw $7E12
    dl IconDescB1 : dw $7E13
    dl IconDescB2 : dw $7E14
    dl IconDescB3 : dw $7E15
    dl IconDescB4 : dw $7E16
    dl IconDescB5 : dw $7E17
    dl IconDescB6 : dw $7E18
    dl IconDescB7 : dw $7E19
    dl IconDescB8 : dw $7E1A
    dl IconDescB9 : dw $7E1B

; FLICKER mode: full graphics, ids $7E20.. (5-byte entries, same order as entries 0-11 above)
HintTableF:
    dl SkullTopDescF : dw $7E20
    dl SkullBotDescF : dw $7E21
    dl IconDescF0 : dw $7E22
    dl IconDescF1 : dw $7E23
    dl IconDescF2 : dw $7E24
    dl IconDescF3 : dw $7E25
    dl IconDescF4 : dw $7E26
    dl IconDescF5 : dw $7E27
    dl IconDescF6 : dw $7E28
    dl IconDescF7 : dw $7E29
    dl IconDescF8 : dw $7E2A
    dl IconDescF9 : dw $7E2B
    dl StarDesc : dw $7E2C       ; v86: entry 12 (offset 60)
    dl StarDesc0 : dw $7E2D      ; v86: entry 13 (offset 65)

; descriptor = 2 words per 16x16 graphic: (bank<<9) | ((addr-$8000)>>6), top tile row then bottom
macro desc(addr)
    dw (((<addr>>>16)&$7F)<<9)|(((<addr>)&$7FFF)>>6), (((<addr>>>16)&$7F)<<9)|((((<addr>)+$40)&$7FFF)>>6)
endmacro
SkullTopDescA: %desc(GfxSkullA)
SkullBotDescA: %desc(GfxSkullA+$80)
SkullTopDescB: %desc(GfxSkullB)
SkullBotDescB: %desc(GfxSkullB+$80)
IconDescA0: %desc(GfxIconsA+0)
IconDescA1: %desc(GfxIconsA+128)
IconDescA2: %desc(GfxIconsA+256)
IconDescA3: %desc(GfxIconsA+384)
IconDescA4: %desc(GfxIconsA+512)
IconDescA5: %desc(GfxIconsA+640)
IconDescA6: %desc(GfxIconsA+768)
IconDescA7: %desc(GfxIconsA+896)
IconDescA8: %desc(GfxIconsA+1024)
IconDescA9: %desc(GfxIconsA+1152)
IconDescB0: %desc(GfxIconsB+0)
IconDescB1: %desc(GfxIconsB+128)
IconDescB2: %desc(GfxIconsB+256)
IconDescB3: %desc(GfxIconsB+384)
IconDescB4: %desc(GfxIconsB+512)
IconDescB5: %desc(GfxIconsB+640)
IconDescB6: %desc(GfxIconsB+768)
IconDescB7: %desc(GfxIconsB+896)
IconDescB8: %desc(GfxIconsB+1024)
IconDescB9: %desc(GfxIconsB+1152)
SkullTopDescF: %desc(GfxSkullF)
SkullBotDescF: %desc(GfxSkullF+$80)
IconDescF0: %desc(GfxIconsF+0)
IconDescF1: %desc(GfxIconsF+128)
IconDescF2: %desc(GfxIconsF+256)
IconDescF3: %desc(GfxIconsF+384)
IconDescF4: %desc(GfxIconsF+512)
IconDescF5: %desc(GfxIconsF+640)
IconDescF6: %desc(GfxIconsF+768)
IconDescF7: %desc(GfxIconsF+896)
IconDescF8: %desc(GfxIconsF+1024)
IconDescF9: %desc(GfxIconsF+1152)
StarDesc: %desc(GfxStar)
StarDesc0: %desc(GfxStar0)

; contents id -> icon code
ContentsIcon:
    db $00,$00,$00,$02,$00,$00,$03,$00,$00,$04,$00,$00,$05,$00,$00,$06
    db $00,$00,$07,$00,$00,$08,$00,$00,$09,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$00
    db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $0A,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

org $16AD00
GfxSkullA: incbin "skull_a.bin"
GfxSkullB: incbin "skull_b.bin"
GfxIconsA: incbin "icons_a.bin"       ; 10 x 128 bytes: heads (type 0-7), fairy top, fairy legs
GfxIconsB: incbin "icons_b.bin"
GfxSkullF: incbin "skull_copy.bin"    ; FLICKER mode (full graphics)
GfxIconsF: incbin "icons.bin"
GfxStar: incbin "star.bin"       ; v86: hidden-door star, 16x16, palette 7 indices
GfxStar0: incbin "star0.bin"     ; v86: same star in palette 0 (used when palette 7 holds something else)

; Big Man perk: absorbs every other hit that would damage the player.
; Toggle/pending byte lives at $0771 (bit0 = absorb this hit, bit1 = ally must take a hit).
!Flags = $0771

; --- player damage: skip the life subtraction when the hit is absorbed ---
org $019CA8
    jml AbsorbHook          ; orig: SEC / LDA $0431 / SBC $12BB / STA $0431 (10 bytes, M=16)
    nop #6
; (BPL at $019CB2 follows; N flag must reflect a positive life)

; --- Big Man per-frame AI: apply a pending absorbed hit to the ally, then run his normal hit check ---
org $01AE05
    db $20 : dw BigPend      ; JSR BigPend (orig: JSR $8125)

; --- Big Man (re)recruit init: reset the toggle ---
org $01AD0B
    jsl BigInit             ; orig: JSL $018432

org $81FF00
AbsorbHook:
    sep #$20
    lda $0424
    cmp #$06
    beq .big
    bra .normal             ; (v31: the Ninja's evade moved earlier, ninja.asm $019B9C)
.big:
    lda $042E
    bne .normal
    lda !Flags
    eor #$01
    sta !Flags
    and #$01
    beq .normal             ; every other hit is absorbed
    lda !Flags
    ora #$02                ; tell the ally AI to take a hit
    sta !Flags
    rep #$20
    lda $0431               ; life untouched, N=0 so BPL falls through
    jml $819CB2
.normal:
    rep #$20
    sec
    lda $0431
    sbc $12BB
    sta $0431
    jml SecondWind

; Ninja Evasion: random dodge. Chance (of 256) = 13 + 7*level (level 0..7) => ~5% .. ~24%
BigInit:                    ; A = new ally id ($06) must reach $01:8432 intact (it compares A with $0424)
    sep #$20
    pha
    lda $0424
    cmp #$06
    beq .skip               ; already Big Man: keep state
    lda #$00
    sta !Flags
.skip:
    pla
    jsl $818432
    rtl

BigPend:
    sep #$20
    lda !Flags
    and #$02
    beq .norm
    lda !Flags
    and #$01
    sta !Flags              ; clear pending bit
    lda $042E
    bne .norm
    lda $0430
    bne .norm
    jsr $8163               ; ally takes one hit (life -1, death handling)
.norm:
    jsr $8125
    rts

; --- Amazon perk: Second Wind.  Once per floor, a hit that would kill you leaves you with (level+3)/16 of max life. ---
; Entered with M=16 and N = sign of the new life.  Uses $0772 (floor+1 when already used) and $0774-$0778 as scratch.
org $89A929
SecondWind:
    bpl .ok
    php
    sep #$20
    lda $0424
    cmp #$03
    bne .die                ; only with the Amazon
    lda $042E
    bne .die                ; not while she is dying
    lda $0403
    inc a
    cmp $0772
    beq .die                ; already used on this floor
    sta $0772
    lda #$03 : jsl $82F600   ; REVIVED!
    rep #$20
    lda $042B               ; max life
    lsr #4
    sta $0775
    stz $0777
    sep #$20
    lda $0412               ; level (0-based)
    clc
    adc #$03
    sta $0774
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
    sta $0431
    plp
    lda $0431               ; positive: N=0
    jml $819CB2
.die:
    plp
    lda $0431               ; negative: N=1
    jml $819CB2
.ok:
    jml $819CB2

; Thief trapped-chest reveal follows the THIEF VISION option too (v57).
; Orig at $02:DC0D (Thief active, chest is trapped): LDA $0601 / AND #$0C / BNE $DC1D (show the skull chest).
org $02DC0D
    jml ChestVis
    nop : nop : nop

org $82FD00
ChestVis:                       ; A = 8 bit; replaces LDA $0601 / AND #$0C / BNE $DC1D
    lda $0601
    and #$0C                    ; the game's own flicker timing (v67: DITHER mode removed)
.t:
    bne .show
    jml $02DC14                 ; normal chest
.show:
    jml $02DC1D                 ; skull chest


; ===== v62/v63: sprite-pool reserve for the door hints (the v62 exit look-ahead row was removed in v63) =====

org $86D000
DoorIconL:
    jsr DoorIcon
    rtl
ReleaseAllL:
    jsr ReleaseAll
    rtl

; A = icon code, M/X 8-bit, DP = object.  Door hint wrapper: records at +$EC, no offset, door reserve.
DoorIcon:
    pha
    lda #$EC
    sta.l !IcBase
    rep #$20
    lda #$0000
    sta.l !IcDX
    sta.l !IcDY
    lda.w #!DoorRes
    sta.l !IcRes
    sep #$20
    lda #$00
    sta.l !IcGrp
    pla
    jmp DrawIcon

; X = group (0 door; 1 was the v62 exit row).  Start the cooldown after a forced release.
CoolStart:
    txa
    asl
    tax
    lda $0601
    sta.l !Cool,x
    lda #$01
    sta.l !Cool+1,x
    rts
; X = group.  Carry set while the group is still cooling down.
CoolBlocked:
    txa
    asl
    tax
    lda.l !Cool+1,x
    beq .no
    lda $0601
    sec
    sbc.l !Cool,x
    cmp #!CoolLen
    bcc .yes
    lda #$00
    sta.l !Cool+1,x
.no:
    clc
    rts
.yes:
    sec
    rts

; Y = record base + (phase ? 8 : 0).  Keeps X.
PhaseRec:
    lda.l !IcPh
    beq +
    lda #$08
+:
    clc
    adc.l !IcBase
    tay
    rts

; Give back the pool slots held by the 4 cache records at !IcBase.  M/X 8-bit, DP = object.
ReleaseAll:
    lda.l !IcBase           ; quick exit when none of the 4 records is in use (the common case)
    tay
    rep #$20
    lda [$00],y
    iny : iny : iny : iny
    ora [$00],y
    iny : iny : iny : iny
    ora [$00],y
    iny : iny : iny : iny
    ora [$00],y
    sep #$20
    bne +
    rts
+:
    phb
    lda #$00
    pha
    plb
    lda.l !IcBase : tay : jsr RelRec
    lda.l !IcBase : clc : adc #$04 : tay : jsr RelRec
    lda.l !IcBase : clc : adc #$08 : tay : jsr RelRec
    lda.l !IcBase : clc : adc #$0C : tay : jsr RelRec
    plb
    rts
RelRec:                     ; Y = record (id word, slot byte, spare byte); same release as $80:8EE4
    phy
    iny
    iny
    lda [$00],y
    beq .clr
    tax
    rep #$20
    lda $1480,x
    beq .free
    dec a
    beq .free
    sta $1480,x
    bra .c16
.free:
    stz $1400,x
    stz $1480,x
    inc $06DD
.c16:
    sep #$20
.clr:
    ply
    rep #$20
    lda #$0000
    sta [$00],y
    iny
    iny
    sta [$00],y
    sep #$20
    rts

; A = icon code (1 skull, 2-9 ally heads by type, 10 fairy), M/X 8-bit, DP = object.
; Uses !IcBase (cache records: phase 0 at +0/+4, phase 1 at +8/+12), !IcDX/!IcDY, !IcRes.
; Translucency by temporal dither: two complementary checkerboard copies of every icon, alternated each frame.
DrawIcon:
    phb
    pha                 ; icon      -> 3,s
    lda $1552
    pha                 ; old $1552 -> 2,s
    lda #$00            ; v67: always phase 0 with the full (undithered) graphics table
.ph0:
    pha                 ; phase     -> 1,s
    sta.l !IcPh
    ; --- sprite-pool reserve: below it, give our slots back and draw nothing ---
    rep #$20
    lda $06DD
    cmp.l !IcRes
    sep #$20
    bcs .room
    jsr ReleaseAll
    lda.l !IcGrp
    tax
    jsr CoolStart
    jmp .done
.room:
    lda #$00
    sta.l !IcNeed
    jsr PhaseRec
    iny : iny
    lda [$00],y
    bne .n1
    lda #$01
    sta.l !IcNeed
.n1:
    lda $03,s
    tax
    lda.l IconTwo,x
    beq .n2
    jsr PhaseRec
    iny : iny : iny : iny : iny : iny
    lda [$00],y
    bne .n2
    lda.l !IcNeed
    inc a
    sta.l !IcNeed
.n2:
    lda.l !IcNeed
    beq .chk
    lda.l !IcGrp
    tax
    jsr CoolBlocked
    bcc .chk
    jmp .done           ; gave slots back recently: wait before taking new ones
.chk:
    rep #$20
    lda.l !IcNeed
    and #$00FF
    clc
    adc.l !IcRes
    sta.l !IcTmp
    lda $06DD
    cmp.l !IcTmp
    sep #$20
    bcs .alloc
    jmp .done           ; not room for new graphics this frame: draw nothing
.alloc:
    stz $1552
    rep #$20
    stz $1262
    lda.w #HintTableF   ; v67: DITHER mode removed
.ts:
    sta $0A98
    sep #$20
    lda.b #HintTable>>16
    sta $0A9A
    lda $01,s : beq .pa
    lda $03,s : tax : lda.l IconEntry,x : clc : adc #60 : tax
    bra .c1
.pa:
    lda $03,s : tax : lda.l IconEntry,x : tax
.c1:
    jsr PhaseRec
    jsl $808DD2
    sep #$30
    lda $03,s : tax
    lda.l IconTwo,x
    beq .one
    lda $01,s : beq .pb
    lda.l IconEntry,x : clc : adc #65 : tax
    bra .c2
.pb:
    lda.l IconEntry,x : clc : adc #$05 : tax
.c2:
    jsr PhaseRec
    iny : iny : iny : iny
    jsl $808DD2
    sep #$30
.one:
    jsr PhaseRec
    iny : iny
    lda [$00],y : beq .fail                 ; pool slot 0 = allocation failed
    lda $03,s : tax
    lda.l IconTwo,x
    beq .ok
    jsr PhaseRec
    iny : iny : iny : iny : iny : iny
    lda [$00],y : beq .fail
.ok:
    rep #$20
    ldy #$04 : lda [$00],y : clc : adc.l !IcDX : sta $125C
    ldy #$06 : lda [$00],y : clc : adc.l !IcDY : sta $125E
    sep #$30
    lda $03,s : asl : tax
    lda.l IconFrame,x : sta $0AA1
    lda.l IconFrame+1,x : sta $0AA2
    lda.b #FrameP0>>16 : sta $0AA3
    jsl $80938A
    bra .done
.fail:
    sep #$30
    jsr ReleaseAll      ; give back whatever this icon got, retry next frame
.done:
    rep #$20
    stz $1262
    lda #$0A83          ; restore object DP
    tcd
    sep #$30
    pla                 ; phase
    pla
    sta $1552
    pla                 ; icon
    plb
    rts



; ===== v86: Thief marker on the hidden warp doors (floors 1, 7, 14, 17, 34, 39) =====
; The door object (class $0156) waits in state 2 ($05:9686) until the player's sword hits a 32x32 zone:
; left = +A0 * 8 - $132C (screen), top = +AC.  While the Thief is the active ally, a star (the door's own
; crest, in the door's own palette 7) twinkles at the centre of that zone, on the hidden-chest timing.
org $059686
    jml StarHook                ; orig: SEP #$20 / LDA $001B,Y
    nop

org $86FA00
StarHook:                       ; M=8, X/Y=16, DB=$7E, DP=$0A83, Y = object
    php
    phb
    phy
    sep #$30
    lda #$D0                    ; cache records at +D0..+DF (unused by this object)
    sta.l !IcBase
    lda #$01
    sta.l !IcGrp
    ldy #$1B
    lda [$00],y                 ; already triggered: the door takes over
    beq +
    jmp .rel
+:
    lda $0424
    cmp #$15                    ; Thief?
    beq +
    jmp .rel
+:
    lda $042E                   ; dying?
    beq +
    jmp .rel
+:
    rep #$20
    ldy #$A0
    lda [$00],y
    asl : asl : asl
    sec
    sbc $132C
    clc
    adc #$0010                  ; zone centre x
    sta.l !StX
    clc
    adc #$0010
    cmp #$0120                  ; on screen (with a 16 px margin)?
    bcc +
    jmp .rel16
+:
    lda.l !StX
    sec
    ldy #$04
    sbc [$00],y
    sta.l !IcDX
    ldy #$AC
    lda [$00],y
    clc
    adc #$0010                  ; zone centre y
    sec
    ldy #$06
    sbc [$00],y
    sta.l !IcDY
    lda.w #!DoorRes
    sta.l !IcRes
    sep #$30
    jsr StarPal                 ; A = icon code: 11 (palette 7) or 12 (palette 0 fallback)
    pha
    asl
    tax
    rep #$20
    lda.l StarIds-22,x          ; graphic id this code uses
    ldy #$D0
    cmp [$00],y                 ; cache record holds the other star? give it back first
    beq +
    lda [$00],y
    beq +
    sep #$20
    jsr ReleaseAll
+:
    sep #$30
    lda $0601
    and #$1E                    ; hidden-chest blink: 2 frames in every 32
    bne .pop
    pla
    jsr DrawIcon
    bra .out
.pop:
    pla
    bra .out
.rel16:
    sep #$30
.rel:
    jsr ReleaseAll
.out:
    rep #$10
    ply
    plb
    plp
    sep #$20
    lda $001B,y
    jml $85968B

StarIds: dw $7E2C, $7E2D
; Palette 7 holds the door's colours: use it (11).  Palette 7 empty: load the door's colours, palette 0 this frame (12).
; Palette 7 holds something else (floor 14 has an enemy that uses it): leave it alone, palette 0 (12).
StarPal:
    rep #$20
    lda $0DF4                   ; colour 10 of palette 7 (WRAM copy)
    cmp #$6B5A
    bne .notdoor
    lda $0DFE                   ; colour 15
    cmp #$2082
    bne .notdoor
    sep #$30
    lda #11
    rts
.notdoor:
    lda $0DE2                   ; empty palette 7?
    ora $0DF4
    ora $0DFE
    beq .load
    sep #$30
    lda #12
    rts
.load:
    rep #$30
    lda.l $9F81FA               ; same source the door uses ($05:974A)
    asl : asl : asl : asl : asl
    tax
    ldy #$01E0
    jsl $80A923
    sep #$30
    lda #12
    rts

; ===== v87: floor 1 Cleric <-> floor 2 Thief, so a Thief can reach the floor-1 hidden door =====
; Door records (22 bytes, contents id at +$0B): floor 1 second door $1E:839C (was $18 Cleric), floor 2 first door $1E:8596 (was $15 Thief).
org $1E83A7
    db $15                      ; floor 1: Thief
org $1E85A1
    db $18                      ; floor 2: Cleric
