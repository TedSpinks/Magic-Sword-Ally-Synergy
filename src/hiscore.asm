; ---- High score table ("HALL OF HEROES"), v39 ----
; Included from slot.asm inside the bank-89 block (uses its UI helpers: PutStr, PutChr, PutBig, Clear, Upload, TextPal,
; OamUp, SndTick, NextChar, PrevChar, CallLow/%call, PortIdx, PortPal, TwRamp).
;
; SRAM table at $70:0400: +0 marker $5C, +2 16-bit checksum of +$10..+$AF, +$10 + 16*i = entry i (i = 0..9, best first):
;   name[6] ASCII, score[7] digits most significant first, floor (display number), ally id, ally level (0-7)
; Per-slot best credit of the current run: slot +$B0 marker $B5, +$B1..+$B7 score digits, +$B8 floor, +$B9 ally, +$BA level
;
; Entry points (all reach HiScene with the screen faded out):
;   HiMode 0: title menu item HIGH SCORES (view; A+B+X+Y+START resets the table)
;   HiMode 1: end of the attract loop (demo -> title), 10 s or any button
;   HiMode 2: end of a saved run (game over or ending): enter the run's best credit, then the save is deleted


; ---------------- scene ----------------
HiScene:                      ; from Dispatch / the title menu: M=8 X=16
    sep #$20
    rep #$10
    lda #$FF : sta.l !HiRow
    lda #$00 : sta.l !HiEd : sta.l !HiDone : sta.l !HiTw
    rep #$20 : lda #$0000 : sta.l !HiT : sep #$20
    jsr HtLoad                ; valid table (defaults if missing/corrupt)
    lda.l !HiMode : cmp #$02 : bne +
    jsr RunEnd                ; record, insert, delete the save
+   %call($C4E5)              ; floor-select tower background
    %call($C515)
    %call($C649)
    %call($E3CB)              ; font
    sep #$20
    rep #$10
    jsr TextPal
    lda #$17 : sta $212C      ; BG1 (tower) + BG2 (star field instead of clouds) + BG3 + sprites
    stz $212D
    stz $2125
    stz $2130                 ; colour math everywhere (no window)
    stz $2131                 ; no colour math: the darkening is baked into the tower palette
    lda #$20 : sta $2121      ; BG palette 2 (the tower) -> arcade-style lavender blue (same brightness steps)
    ldx #$0000
-   lda.l TowerPal,x : sta $2122
    inx : cpx #$0020 : bne -
    stz $2121                 ; backdrop: dark navy behind the stars
    lda #$00 : sta $2122
    lda #$10 : sta $2122
    ldx #$0000                ; text palettes: two-tone letters (HiPalTab; HiFont splits each glyph)
.hp: lda.l HiPalTab,x
    cmp #$FF : beq .hpd
    sta $2121
    lda.l HiPalTab+1,x : sta $2122
    lda.l HiPalTab+2,x : sta $2122
    lda.l HiPalTab+3,x : sta $2122
    lda.l HiPalTab+4,x : sta $2122
    lda.l HiPalTab+5,x : sta $2122
    lda.l HiPalTab+6,x : sta $2122
    inx : inx : inx : inx : inx : inx : inx
    bra .hp
.hpd:
    stz $420C
    jsr HiFont                ; lower half of the small letters/digits -> colour 3 (two-tone)
    jsr HiGfx                 ; portraits + star tiles + sprite palettes
    jsr HiDraw
    jsr Upload
    jsr HiOam
    jsr OamUp
    lda #$09 : sta $2105
    %call($81C6)              ; start the fade-in
    lda.l !CodexCut : beq +
    lda #$0E : sta $1252      ; CODEX page change: the fade-in is one step from the end
    stz $124F
+
    sep #$20                  ; the fade itself is the game's $8211 loop minus its object code (which kept redrawing the title cursor
    rep #$10                  ; and held back our portraits until the fade was over): same brightness stepping, our sprites + twinkle
.fade:
    lda $1242
    bne .fade
    jsr HiOam
    jsr OamUp
    jsr SndTick
    lda $124F : beq +
    dec $124F
    bra .fs
+   lda $1251 : sta $124F
    lda $1252 : sta $2100
    inc $1252
.fs:
    lda #$01 : sta $1242
    lda $1252 : cmp #$0F : bne .fade
    stz $1253
.loop:
    sep #$20
    lda $1242
    bne .loop
    jsr Upload
    jsr HiOam
    jsr OamUp
    jsr SndTick
    %call($89D5)              ; pads
    sep #$20
    rep #$10
    lda $1245 : sta.l !HiPad
    lda $1246 : sta.l !HiPad+1
    lda $1243 : sta.l !HiHeld
    lda $1244 : sta.l !HiHeld+1
    rep #$20
    lda.l !HiT : inc a : sta.l !HiT
    sep #$20
    jsr HiInput
    lda #$01 : sta $1242
    lda.l !HiDone
    beq .loop
    lda.l !HiMode : bne .fo
    lda.l !HiDone : cmp #$02 : bcc .fo
    sep #$30                ; v81: screen blank like $8299, but without its JSL $80F3BD (that starts the silent song $19 and would end the CODEX music)
    lda #$80 : sta $2100
    lda #$00 : sta $4200
    stz $1253
    rep #$30
    lda.w #$0000
    tcd
    sep #$20
    bra .fd
.fo: %call($8257)              ; fade out
    %call($826F)
.fd:
    sep #$20
    stz $2131
    stz $2130
    lda #$E0 : sta $2132
    lda #$FF : sta.l !LastSc  ; so Dispatch does not send the title straight back here
    stz !Slot
    stz !Resume
    lda.l !HiMode : bne .tt
    lda.l !HiDone : cmp #$02 : bcc .tt
    jml CodexFromHall         ; CODEX: LEFT / RIGHT on the Hall of Heroes (HiDone 2 / 3)
.tt: lda #$02 : sta $0401
    stz $0402
    jml $80814D

HiInput:                      ; M=8 X=16
    lda.l !HiEd
    beq +
    jmp HiName
+   lda.l !HiMode
    bne .notview
    ; CODEX page 0: L / R turn the page (v96), START leaves
    rep #$20
    lda.l !HiPad
    bit #$1000 : bne .exitv
    bit #$0020 : bne .prevv
    bit #$0010 : bne .nextv
    sep #$20
    rts
.exitv:
    sep #$20
    lda #$01 : sta.l !HiDone
    rts
.prevv:
    sep #$20
    lda #$03 : sta.l !HiDone
    rts
.nextv:
    sep #$20
    lda #$02 : sta.l !HiDone
    rts
.notview:
    rep #$20
    lda.l !HiMode : and #$00FF : cmp #$0001 : bne +
    lda.l !HiPad : and #$1000 : bne .exit    ; v96: the attract loop leaves on START only
    bra ++
+   lda.l !HiPad : and #$F0F0 : bne .exit    ; any face button or START
++
    lda.l !HiT : cmp.w #600 : bcs .exit       ; 10 s
    sep #$20
    rts
.exit:
    sep #$20
    lda #$01 : sta.l !HiDone
    rts

HiName:                       ; editing the new entry's name (row !HiRow), cursor !NPos, buffer !Name
    rep #$20
    lda.l !HiPad
    bit #$0800 : bne .up
    bit #$0400 : bne .down
    bit #$0200 : bne .left
    bit #$0100 : bne .right
    bit #$1000 : bne .done
    and.l !AtkM : bne .right2
    lda.l !HiPad
    and.l !JmpM : bne .left
    sep #$20
    rts
.up:
    sep #$20
    jsr NameIdx : lda.l !Name,x : jsr NextChar : sta.l !Name,x
    jmp .rd
.down:
    sep #$20
    jsr NameIdx : lda.l !Name,x : jsr PrevChar : sta.l !Name,x
    jmp .rd
.right:
    sep #$20
    lda.l !NPos : cmp #$05 : bcs .rd
    inc a : sta.l !NPos
    bra .rd
.right2:
    sep #$20
    lda.l !NPos : cmp #$05 : bcs .done8
    inc a : sta.l !NPos
    bra .rd
.left:
    sep #$20
    lda.l !NPos : beq .rd
    dec a : sta.l !NPos
    bra .rd
.done:
    sep #$20
.done8:
    ; blank name -> HERO; copy into the table and save
    rep #$10
    ldx #$0000
-   lda.l !Name,x : cmp #$20 : bne .named
    inx : cpx #$0006 : bne -
    ldx #$0000
-   lda.l DefName,x : sta.l !Name,x
    inx : cpx #$0006 : bne -
.named:
    jsr HiRowOff               ; X = SRAM offset of the entry
    ldy #$0000
-   phx : tyx : lda.l !Name,x : plx
    sta.l !HTE,x
    inx : iny : cpy #$0006 : bne -
    jsr HtWrite
    lda #$00 : sta.l !HiEd
    rep #$20 : lda #$0000 : sta.l !HiT : sep #$20
.rd:
    jsr HiDraw
    rts

HiRowOff:                     ; X = 16 * !HiRow
    rep #$20
    lda.l !HiRow : and #$00FF
    asl a : asl a : asl a : asl a
    tax
    sep #$20
    rts

; ---------------- run end ----------------
RunEnd:                       ; M=8 X=16: !Slot = the run's slot
    lda.l !HiClr : bne +      ; v111: an ending recorded it when it started (its scenes change $0424)
    jsl RecordBest            ; the last credit (an ending has no death to record it)
+
    rep #$30
    lda !Slot : and #$0003 : xba : tax       ; X = slot offset
    sep #$20
    lda.l $7000B0,x : cmp #$B6 : beq +
    jmp .del                  ; no record: nothing to enter
+
    ; candidate: slot name, best score/floor/ally/level
    phx
    ldy #$0000
-   lda.l $700001,x
    cmp #$20 : bcc .bad
    cmp #$5B : bcc .ok
.bad: lda #$20
.ok:
    phx : tyx : sta.l !HiCand,x : plx
    inx : iny : cpy #$0006 : bne -
    plx
    phx
    ldy #$0000
-   lda.l $7000B1,x
    phx : tyx : sta.l !HiCand+6,x : plx
    inx : iny : cpy #$000A : bne -           ; 7 digits + floor + ally + level
    plx
    lda.l !HiCand+13 : cmp #$33 : bcc +
    lda #$32 : sta.l !HiCand+13       ; the ending floors (52, 55) read as floor 50
+   lda.l !HiClr : beq .nofl          ; game beaten: bit 7 = 1CC (no continue), bit 6 = star (continued)
    lda.l $7000BB,x : and #$F1 : cmp #$C1 : beq .star
    lda.l !HiCand+13 : ora #$80 : sta.l !HiCand+13
    bra .nofl
.star:
    lda.l !HiCand+13 : ora #$40 : sta.l !HiCand+13
.nofl:
    ; insertion point: first entry with a lower score (ties stay above the new one)
    lda #$00 : sta.l !HiRow
.find:
    jsr HiRowOff
    ldy #$0000
-   phx : tyx : lda.l !HiCand+6,x : plx
    cmp.l !HTE+6,x
    bcc .next                 ; candidate digit lower: not here
    bne .ins                  ; higher: insert here
    inx : iny : cpy #$0007 : bne -
.next:                        ; lower or equal
    lda.l !HiRow : inc a : sta.l !HiRow
    cmp #$0A : bcc .find
    lda #$FF : sta.l !HiRow   ; not in the top 10
    bra .delx
.ins:
    ; shift entries row..8 down one (copy backwards from entry 8 to entry 9)
    rep #$30
    ldx.w #16*9-1
-   lda.l !HiRow : and #$00FF : asl a : asl a : asl a : asl a
    sta $0776
    txa : cmp $0776 : bcc .shdone
    sep #$20
    lda.l !HTE,x : sta.l !HTE+16,x
    rep #$20
    dex
    bpl -
.shdone:
    sep #$20
    rep #$10
    jsr HiRowOff
    ldy #$0000
-   phx : tyx : lda.l !HiCand,x : plx
    sta.l !HTE,x
    inx : iny : cpy #$0010 : bne -
    jsr HtWrite
    ; name entry starts from the slot's name, cursor on the first letter
    ldx #$0000
-   lda.l !HiCand,x : sta.l !Name,x
    inx : cpx #$0006 : bne -
    lda #$00 : sta.l !NPos
    lda #$01 : sta.l !HiEd
.delx:
    rep #$30
    lda !Slot : and #$0003 : xba : tax
    sep #$20
.del:                         ; the run is over: delete its save (Dead Cells style)
    lda #$00
    sta.l $700000,x
    sta.l $70000E,x
    sta.l $70000F,x
    sta.l $7000B0,x
    rts

; ---------------- table in SRAM ----------------
HtLoad:                       ; make sure the SRAM table is valid
    lda.l !HT : cmp #$5C : bne .def
    jsr HtSum
    rep #$20
    cmp.l !HT+2
    sep #$20
    beq .ok
.def:
    jsr HtDefault
    jsr HtWrite
.ok:
    rts
HtSum:                        ; A (16) = sum of +$10..+$AF; returns M=16? no: leaves M=16 for the caller's compare
    rep #$30
    ldx #$0000
    lda #$0000
    sta $0776
-   lda.l !HTE,x : and #$00FF
    clc : adc $0776 : sta $0776
    inx : cpx #$00A0 : bne -
    lda $0776
    sep #$20
    rts
HtWrite:                      ; marker + checksum
    jsr HtSum
    rep #$20
    sta.l !HT+2
    sep #$20
    lda #$5C : sta.l !HT
    rts
HtDefault:
    rep #$10
    ldx #$0000
-   lda.l HtDefData,x : sta.l !HTE,x
    inx : cpx #$00A0 : bne -
    rts
HiFont:                       ; screen off. Tiles $A1-$CC (digits, letters): rows 4-7, body pixels (colour 2) -> colour 3
    php
    sep #$20
    rep #$10
    lda #$80 : sta $2115
    ldx.w #$A1*8
.w: txa : and #$04 : beq .skip      ; only rows 4-7 of each tile (word address bit 2)
    stx $2116
    lda $2139 : sta $0776             ; plane 0
    lda $213A : sta $0777             ; plane 1 (the address advances)
    stx $2116
    lda $0776 : ora $0777 : sta $2118
    lda $0777 : sta $2119
.skip: inx
    cpx.w #$CC*8 : bne .w
    ldx.w #$9B*8 : stx $2116          ; star glyph at '*' (tile $9B)
    ldx #$0000
-   lda.l StarGlyph,x : sta $2118
    inx
    lda.l StarGlyph,x : sta $2119
    inx : cpx #$0010 : bne -
    plp
    rts
StarGlyph: db $00,$00,$00,$10,$00,$38,$00,$FE,$7C,$7C,$38,$38,$6C,$6C,$44,$44
HiPalTab:                     ; CGRAM index, colours 1-3 of a text palette (top of the letters, bottom of the letters)
    db $01 : dw $2800,$7AF2,$722C
    db $05 : dw $5000,$7FFF,$7B16
    db $09 : dw $000E,$3B9F,$025E
    db $0D : dw $2800,$7B9A,$7B9A
    db $11 : dw $2800,$6ED3,$6ED3
    db $15 : dw $2800,$7A90,$71EB
    db $FF
TowerPal: dw $7E10, $1400, $6B38, $5EB4, $5231, $45CF, $356D, $352A, $38E7, $34A5, $2C64, $2422, $2022, $2022, $2021, $2021
HtDefData:                    ; name, score digits, floor, ally, level (the eight heroes of the attract loop)
    db "SARA  ", 0,5,0,0,0,0,0, 1, $03, 0
    db "UUMA  ", 0,4,5,0,0,0,0, 1, $06, 0
    db "LOTHAR", 0,4,0,0,0,0,0, 1, $0C, 0
    db "RYUGO ", 0,3,5,0,0,0,0, 1, $0F, 0
    db "GAI   ", 0,3,0,0,0,0,0, 1, $12, 0
    db "ARIOL ", 0,2,5,0,0,0,0, 1, $18, 0
    db "DEREK ", 0,2,0,0,0,0,0, 1, $15, 0
    db "NIURA ", 0,1,5,0,0,0,0, 1, $09, 0
    db "CAPCOM", 0,1,0,0,0,0,0, 1, $03, 0
    db "CAPCOM", 0,0,5,0,0,0,0, 1, $12, 0

; ---------------- drawing ----------------
!HCRank = $2000               ; P0 blue (same as the scores)
!HCVal  = $2000               ; P0 blue
!HCNew  = $2400               ; P1 white
!HCNewL = $2800               ; P2 gold
HiDraw:
    jsr Clear
    rep #$30
    lda.w #!ColDV : sta $0776
    ldx.w #TxtHall : ldy.w #1*32+2 : jsr PutBig
    rep #$30
    ldx #$0000                ; bottom row of the big title: palette 4 (deeper blue)
-   lda.l !Shadow+128,x : beq +
    clc : adc #$0400 : sta.l !Shadow+128,x
+   inx : inx : cpx #$0040 : bne -
    sep #$20
    lda #$00
-   pha
    jsr HiLine
    pla : inc a : cmp #$0A : bne -
    ; footer
    rep #$30
    lda.l !HiEd : and #$00FF : beq +
    lda.w #!ColF : sta $0776
    ldx.w #TxtNameHelp : ldy.w #26*32+3 : jsr PutStr
    bra .f
+   lda.l !HiMode : and #$00FF : bne .f
    lda.w #!ColF : sta $0776
    ldx.w #TxtMore : ldy.w #25*32+8 : jsr PutStr
    lda.w #!ColF : sta $0776
    ldx.w #TxtExit : ldy.w #26*32+9 : jsr PutStr
.f: sep #$20
    rts

HiLine:                       ; A = entry 0-9 -> row 5+2i
    sep #$20
    rep #$10
    sta.l !DSlot
    rep #$20
    and #$00FF
    asl a : asl a : asl a : asl a : tax       ; X = entry offset
    lda.l !DSlot : and #$00FF : asl a : clc : adc.w #5
    asl a : asl a : asl a : asl a : asl a : sta.l !Row   ; first cell of the row
    ; colours: the new entry is white with a gold rank
    lda.w #!HCRank : sta.l !LAt
    lda.w #!HCVal : sta.l !VAt
    sep #$20
    lda.l !DSlot : cmp.l !HiRow : bne +
    rep #$20
    lda.w #!HCNewL : sta.l !LAt
    lda.w #!HCNew : sta.l !VAt
    sep #$20
+   ; rank: "1ST" .. "10TH" right-aligned at cols 1-4
    jsr SetL
    rep #$20
    lda.l !Row : clc : adc.w #2 : tay
    sep #$20
    lda.l !DSlot : inc a : cmp #$0A : bcc +
    dey
    lda #$31 : jsr PutChr
    lda #$30 : jsr PutChr
    bra .suf
+   clc : adc #$30 : jsr PutChr
.suf:
    phx
    rep #$20
    lda.l !DSlot : and #$00FF : cmp.w #3 : bcc +
    lda.w #3
+   asl a : tax
    lda.l Suffix,x : sta $0779
    sep #$20
    lda $0779 : jsr PutChr
    lda $077A : jsr PutChr
    plx
    ; score: 7 digits at cols 6-12, leading zeros as spaces
    jsr SetV
    rep #$20
    lda.l !Row : clc : adc.w #6 : tay
    sep #$20
    phx
    lda #$00 : sta $0779      ; set once a digit has been printed
    lda #$07 : sta $077A
-   lda.l !HTE+6,x
    ora $0779 : bne +
    lda $077A : cmp #$01 : beq +
    lda #$20 : jsr PutChr     ; leading zero -> blank
    bra .nx
+   lda #$01 : sta $0779
    lda.l !HTE+6,x : clc : adc #$30 : jsr PutChr
.nx:
    inx
    dec $077A : bne -
    plx
    ; floor field, cols 14-16: "1CC" (bit 7), or an optional star (bit 6) and the floor right-aligned
    rep #$20
    lda.l !Row : clc : adc.w #14 : tay
    sep #$20
    lda.l !HTE+13,x
    bit #$80 : beq .nocc
    lda #$31 : jsr PutChr
    lda #$43 : jsr PutChr
    lda #$43 : jsr PutChr
    bra .lv
.nocc:
    bit #$40 : beq .nostar
    and #$3F : cmp #$0A : bcs .st2
    pha : lda #$20 : jsr PutChr       ; single digit: blank, star, digit (star hugs the number)
    lda #$2A : jsr PutChr : pla
    clc : adc #$30 : jsr PutChr
    bra .lv
.st2:
    pha : lda #$2A : jsr PutChr : pla
    jsr PutDec2
    bra .lv
.nostar:
    pha : lda #$20 : jsr PutChr : pla
.fl:
    and #$3F
    cmp #$0A : bcs +
    pha : lda #$20 : jsr PutChr : pla
    clc : adc #$30 : jsr PutChr
    bra .lv
+   jsr PutDec2
.lv:
    ; level "L8" at cols 21-22 (only with an ally)
    lda.l !HTE+14,x : beq .nm
    rep #$20
    lda.l !Row : clc : adc.w #21 : tay
    sep #$20
    lda #$4C : jsr PutChr
    lda.l !HTE+15,x : inc a : clc : adc #$30 : jsr PutChr
.nm:
    ; name at cols 24-29 (while editing: the buffer, cursor letter gold, blanks as "-")
    rep #$20
    lda.l !Row : clc : adc.w #24 : tay
    sep #$20
    lda.l !HiEd : beq .plain
    lda.l !DSlot : cmp.l !HiRow : bne .plain
    phx
    ldx #$0000
-   jsr SetV
    txa : cmp.l !NPos : bne +
    jsr SetL
+   lda.l !Name,x
    cmp #$20 : bne +
    lda #$2D
+   jsr PutChr
    inx : cpx #$0006 : bne -
    plx
    rts
.plain:
    phx
    lda #$06 : sta $077A
-   lda.l !HTE,x : jsr PutChr
    inx : dec $077A : bne -
    plx
    rts
Suffix: db "ST","ND","RD","TH"
TxtHall:  db "HALL OF HEROES",0
TxtReset: db "A B X Y START TO RESET",0
TxtMore:  db "L OR R FOR MORE",0
TxtExit:  db "START TO EXIT",0

; ---------------- sprites: portraits + stars ----------------
HiGfx:                        ; screen off
    php
    sep #$20
    rep #$10
    lda #$63 : sta $2101
    lda #$80 : sta $2121       ; sprite palette 0: portraits
    ldx #$0000
-   lda.l PortPal,x : sta $2122
    inx : cpx #$0020 : bne -
    ; zero sprite tiles $00-$7F (VRAM $6000-$67FF)
    lda #$80 : sta $2115
    ldx #$6000 : stx $2116
    lda #$09 : sta $4370       ; fixed source, 2 regs
    lda #$18 : sta $4371
    ldx.w #ZeroW : stx $4372
    lda.b #ZeroW>>16 : sta $4374
    ldx #$1000 : stx $4375
    lda #$80 : sta $420B
    ; the 8 portraits: picture k -> sprite tiles 2k (top row) / 2k+16 (bottom row)
    lda #$00
.p: pha
    rep #$20
    and #$00FF
    xba : lsr a : clc : adc.w #$C000 : sta $0776      ; source $9F:C000 + 128k
    lda $01,s : and #$00FF : asl a : asl a : asl a : asl a : asl a : clc : adc.w #$6000
    sta $0778
    sep #$20
    ldx $0778 : stx $2116
    ldy #$0040 : jsr PortSetup_dma
    rep #$20
    lda $0778 : clc : adc.w #$0100 : tax
    sep #$20
    stx $2116
    ldy #$0040 : jsr PortSetup_dma
    pla : inc a : cmp #$08 : bne .p
    ; star tiles at sprite tiles $40/$42/$44 (top-left 8x8 of each 16x16; the rest stays blank)
    ldx #$6400 : stx $2116 : ldx.w #StarGfx : jsr .star
    ldx #$6420 : stx $2116 : ldx.w #StarGfx+32 : jsr .star
    ldx #$6440 : stx $2116 : ldx.w #StarGfx+64 : jsr .star
    lda #$90 : sta $2121       ; sprite palette 1 colour 0
    stz $2122 : stz $2122
    ; BG2 star field: blank the map, load the star tiles at BG2's character base ($3000), palette 3 (CGRAM $30)
    lda #$09 : sta $4370
    lda #$18 : sta $4371
    ldx.w #ZeroW : stx $4372
    lda.b #ZeroW>>16 : sta $4374
    ldx #$5800 : stx $2116
    ldx #$0800 : stx $4375
    lda #$80 : sta $420B
    lda #$01 : sta $4370
    ldx.w #BgStarGfx : stx $4372
    lda.b #BgStarGfx>>16 : sta $4374
    ldx #$3000 : stx $2116
    ldx.w #BgStarGfxEnd-BgStarGfx : stx $4375
    lda #$80 : sta $420B
    lda #$30 : sta $2121
    ldx #$0000
.bp: lda.l BgStarPal,x : sta $2122
    inx : cpx #$0010 : bne .bp
    ldx #$0000
.bm: rep #$20
    lda.l BgStarMap,x
    cmp #$FFFF : beq .bd
    clc : adc #$5800 : sta $2116
    lda.l BgStarMap+2,x : sta $2118
    inx : inx : inx : inx
    sep #$20
    bra .bm
.bd: sep #$20
    plp
    rts
.star:                         ; X = source (bank 89), 32 bytes
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    stx $4372
    lda.b #StarGfx>>16 : sta $4374
    ldx #$0020 : stx $4375
    lda #$80 : sta $420B
    rts
ZeroW: dw 0

HiOam:                         ; portraits for the 10 rows + twinkling stars; also cycles the star colours
    php
    sep #$20
    rep #$10
    ldx #$0000
-   lda #$00 : sta.l !OamBuf2,x
    lda #$F0 : sta.l !OamBuf2+1,x
    lda #$00 : sta.l !OamBuf2+2,x : sta.l !OamBuf2+3,x
    inx : inx : inx : inx : cpx #$0200 : bne -
    lda #$00
-   sta.l !OamBuf2,x : inx : cpx #$0220 : bne -
    ; portraits: OAM entry i at x 144, y 8*(5+2i)-5
    lda #$00
.e: pha
    rep #$20
    and #$00FF : asl a : asl a : asl a : asl a : tax  ; entry offset
    lda.l !HTE+14,x : and #$00FF : beq .ne            ; no ally
    phx : tax : lda.l PortIdx-3,x : and #$00FF : plx
    asl a : sta $0776                                 ; tile = 2*picture
    lda $01,s : and #$00FF : asl a : asl a : tax      ; OAM offset
    sep #$20
    lda #144 : sta.l !OamBuf2,x
    lda $01,s : asl a : clc : adc #$05 : asl a : asl a : asl a : sec : sbc #$05
    sta.l !OamBuf2+1,x
    lda $0776 : sta.l !OamBuf2+2,x
    lda #$30 : sta.l !OamBuf2+3,x
.ne:
    sep #$20
    pla : inc a : cmp #$0A : bne .e
    ; stars: OAM 10.. from HiStars (x, y, tile)
    rep #$30
    ldx #$0000
    ldy.w #10*4
-   lda.l HiStars,x : and #$00FF : cmp #$00FF : beq .sd
    phx : tyx : sep #$20 : sta.l !OamBuf2,x : rep #$20 : plx
    lda.l HiStars+1,x : and #$00FF
    phx : tyx : sep #$20 : sta.l !OamBuf2+1,x : rep #$20 : plx
    lda.l HiStars+2,x : and #$00FF
    phx : tyx : sep #$20 : sta.l !OamBuf2+2,x : lda #$12 : sta.l !OamBuf2+3,x : rep #$20 : plx   ; sprite palette 1, priority 1: behind the tower
    inx : inx : inx
    iny : iny : iny : iny
    bra -
.sd:
    ; star colours: sprite palette 1 colours 1-3 through the twinkle ramp
    sep #$30
    lda.l !HiTw : inc a : sta.l !HiTw
    lda #$91 : sta $2121
    ldx #$00
-   lda.l !HiTw : lsr a : lsr a
    clc : adc.l TwOff,x
    and #$0F : clc : adc #$08     ; the bright half of the ramp
    asl a : sta $0779
    phx
    ldx $0779
    lda.l TwRamp,x : sta $2122
    lda.l TwRamp+1,x : sta $2122
    plx
    inx : cpx #$03 : bne -
    lda #$31 : sta $2121          ; the BG2 star field: same ramp, shifted phase
    ldx #$00
-   lda.l !HiTw : lsr a : lsr a
    clc : adc.l TwOff,x
    clc : adc #$07
    and #$0F : clc : adc #$08
    asl a : sta $0779
    phx
    ldx $0779
    lda.l TwRamp,x : sta $2122
    lda.l TwRamp+1,x : sta $2122
    plx
    inx : cpx #$03 : bne -
    plp
    rts

incsrc "starbg.inc"
StarGfx:
    db $00,$00,$00,$00,$00,$00,$10,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$10,$00,$38,$00,$10,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$00,$00,$00,$00,$00,$00
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
HiStars:
    db 243,111,$44
    db 9,139,$40
    db 248,60,$40
    db 97,140,$40
    db 15,166,$40
    db 5,207,$40
    db 25,119,$40
    db 197,38,$40
    db 234,52,$40
    db 2,21,$40
    db 247,30,$40
    db 76,100,$40
    db 241,180,$40
    db 48,196,$40
    db 48,126,$40
    db 69,36,$40
    db 79,170,$40
    db 183,106,$40
    db 41,143,$40
    db 122,200,$40
    db 53,24,$44
    db 203,127,$40
    db 25,179,$40
    db 32,213,$40
    db 47,154,$40
    db 200,138,$40
    db 11,47,$40
    db 55,107,$44
    db 91,159,$40
    db 81,195,$40
    db 12,180,$40
    db 186,196,$40
    db 43,66,$40
    db 138,123,$40
    db 118,61,$42
    db 39,34,$40
    db 87,33,$40
    db 189,164,$40
    db 245,125,$40
    db 97,58,$40
    db 118,51,$40
    db 124,90,$40
    db 70,65,$42
    db 224,106,$40
    db 221,214,$40
    db 73,144,$40
    db 178,65,$40
    db 123,160,$40
    db 66,185,$40
    db 91,90,$40
    db 214,46,$40
    db 224,196,$42
    db 246,41,$44
    db 241,142,$40
    db 243,191,$42
    db 45,177,$44
    db 5,70,$40
    db 48,76,$40
    db 221,140,$40
    db 30,101,$40
    db 222,171,$40
    db 62,203,$40
    db 53,91,$42
    db 77,159,$44
    db $FF
