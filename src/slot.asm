lorom
; BG3 text colours (palette << 10, priority bit set): see TextPal
!ColT  = $2000              ; P0 title: floor-select blue
!ColV  = $2400              ; P1 selected panel: values (white)
!ColL  = $2800              ; P2 selected panel: labels (gold)
!ColDV = $2C00              ; P3 other panels: values (grey-blue)
!ColDL = $3000              ; P4 other panels: labels (dim gold)
!ColF  = $3400              ; P5 footer words (blue)
!ColB  = $3800              ; P6 button letters (gold)
!ColW  = $3C00              ; P7 white (EMPTY, ENTER YOUR NAME)
!ColBS = $2400              ; selected panel frame: P1 colours 3 (line) / 1 (inner shadow)
!ColBD = $2C00              ; other panel frames: P3
!BoxVOfs = $00
if not(defined("LivesFrac"))
!LivesFrac = 0             ; v33: decimal (the fraction variant was too wide)
endif
; ---- Save system: slot select screen (scene $40), name entry, saved options ----
; Title START -> scene $40 (this screen) -> start-point menu (new game) or straight into the saved floor (resume).
!Slot   = $04A5
!HiMode = $7FE780
!LastSc = $7E6FF8             ; v121: was $7F:E781, which a floor load can overwrite (game over then skipped the high score table); $7E:2600-$6FFF is never touched by the game
!HiRow  = $7FE782             ; row being entered ($FF none)
!HiEd   = $7FE783             ; 1 while the name is being edited
!HiT    = $7FE784             ; 16-bit frame timer
!HiDone = $7FE786
!HiTw   = $7FE787
!HiPad  = $7FE788             ; 16-bit new presses
!HiHeld = $7FE78A             ; 16-bit held
!HiClr  = $7FE78C             ; 1 = the run just ended in an ending scene (the game was beaten)
!HiCand = $7FE790             ; 16-byte candidate entry
!CodexOn   = $7FE7A0          ; v74: 1 while the CODEX (title menu) is open
!CodexPage = $7FE7A1
!CodexMus  = $7FE7A8          ; v83: CODEX MUSIC option: 0 = NONE, 1-26 = Music Test number 00-25 plus one (default 6 = song 05); saved at SRAM $70:0018/19
!CodexCut  = $7FE7A4          ; v76: 1 = the next CODEX page starts without fades (page change or replay)
!FastOn    = $7FE7A3          ; v75: 1 after A/B/X/Y was pressed on an ally page: the description types out fast          ; 0 Hall of Heroes, 1-8 allies (Big Man .. Thief), 9 magic items
!HT     = $700400
!HTE    = $700410
!Resume = $04A6
!Call   = $04A7             ; 2 bytes: target of the CallLow trampoline (a bank-00 subroutine)
!Shadow = $7FE000           ; BG3 tilemap shadow, 32x28 words, DMA'd to VRAM $5C00 every frame
; UI state (bank 7F, never used by the game)
!Cur    = $7FE700           ; selected slot 0-2
!Mode   = $7FE701           ; 0 list, 1 continue?, 2 overwrite?, 3 name entry
!NPos   = $7FE702           ; name cursor 0-5
!Name   = $7FE703           ; 6 chars (ASCII)
!Egg    = $7FE7E4           ; v88: EggCheck result (menu only: $7F:E000+ is overwritten at floor load, so StartNewGame stores it in the slot at +$BC)
!EggT   = $7FE7E5           ; v88: type counter while matching
!EggBad = $7FE7E6           ; v88: mismatch flag while matching
!AtkM   = $7FE70A           ; 16-bit attack mask (joypad format)
!JmpM   = $7FE70C           ; 16-bit jump mask
!Done   = $7FE70E           ; 0 running, 1 new game, 2 resume, 3 back to title
!Pad    = $7FE710           ; 16-bit new presses this frame
!DSlot  = $7FE712           ; slot being drawn
!Row    = $7FE714           ; 16-bit: first cell of the slot panel
!Tmp    = $7FE716           ; 4 bytes scratch (PutDec)
!SpcM   = $7FE71A           ; 16-bit SPECIAL mask
!Tw     = $7FE71C           ; twinkle frame counter
!VAt    = $7FE71E           ; value colour of the panel being drawn
!LAt    = $7FE720           ; label colour
!LvB    = $7FE722           ; lives: whole bars (16-bit)
!LvT    = $7FE724           ; lives: tenths
!BoxMap = $7FE800           ; BG1 tilemap shadow for the boxes (32x32 words)

macro call(addr)
    rep #$30
    lda.w #<addr>
    sta !Call
    ldx.w #$0000
    sep #$20
    jsl CallLow
    rep #$30
    lda.w #$0000
    tcd                     ; some screen routines leave D changed
    sep #$20
endmacro

!Pend   = $04A3             ; set by title START: show the slot screen before the start-point menu
org $80CB9E
    jml TitleStart          ; orig LDA #$04 / STA $0401 (title START -> start-point menu)
    nop

org $808198
    jml Dispatch            ; orig LDX $0401 / JMP ($819E,X)
    nop
    nop

; v31: nothing of ours lives at $80:F8A0 any more: $80:F800-$FBBF is the graphics sheet of the in-game
; message box (weapon awards, boss speeches); its $FF filler tiles are the box's black interior.
org $80C02A
    jml TitleMenu
org $80CB75
    jml TitleLoop
    nop
org $80CB32
    jml TitleText
    nop
org $019080
    jml CreditEnd           ; orig SEP #$20 / LDA #$09 at the start of the player-death handler (credit ends)
org $82FC00
CreditEnd:
    jsl RecordBest
    php                       ; a credit ended: remember that this run used a continue (slot +$BB: tag $C0, bit 0)
    sep #$20
    rep #$10
    rep #$30
    lda $04A5 : and #$00FF : beq +
    and #$0003 : xba : tax
    sep #$20
    lda #$C1 : sta.l $7000BB,x
+   plp
    sep #$20
    lda #$09
    jml $819084
RecordBest:                 ; keep the best credit of the run in the slot (+$B0..): score, floor, ally, level. Any M/X; RTL
    php
    sep #$20
    rep #$30
    lda $04A5 : and #$00FF : beq .x
    and #$0003 : xba : tax
    sep #$20
    lda.l $7000B0,x : cmp #$B6 : bne .new
    ; compare current score (digits $0447 .. $0441) with the stored one (+$B1.., most significant first)
    phx
    ldy #$0006
-   lda $0441,y
    cmp.l $7000B1,x
    bcc .keep               ; lower: keep the old best
    bne .better
    inx
    dey : bpl -
.keep:
    plx
    bra .x
.better:
    plx
.new:
    lda #$B6 : sta.l $7000B0,x
    phx
    ldy #$0006
-   lda $0441,y : sta.l $7000B1,x
    inx
    dey : bpl -
    plx
    lda $0403 : sta.l $7000B8,x
    lda $0424 : sta.l $7000B9,x
    lda $0412 : sta.l $7000BA,x
.x: plp
    rtl
org $89C3D0
SyncTopL:                   ; any M/X, keeps A/X/Y/flags; RTL.  Runs at every floor start ($82:FB00 .done)
    php
    rep #$30
    pha : phx : phy
    sep #$20
    jsr SyncTop
    rep #$30
    ply : plx : pla
    plp
    rtl
org $89C400
CallLow:                    ; JSL here (M=8, X=16) with !Call = a bank-80 routine ending in RTS
    pea $8E50               ; its RTS lands on the RTL at $80:8E51, which returns to our caller
    lda #$80
    pha
    rep #$20
    lda !Call
    dec a
    pha
    sep #$20
    rtl                     ; "jump" to $80:!Call
Dispatch:                   ; M=8, X=16
    jsl $86E700             ; v107: MusTitle (options.asm): CODEX MUSIC back from SRAM at the title (play overwrites it)
    lda $0401
    cmp #$02
    bne .track
    ; the title is about to start: after a saved run (floor scene 6 = game over, ending scenes $16-$2F (the good ending runs through $26)) show the
    ; high score entry; after the attract demo (scene $10) show the table
    lda !Slot : beq .attr
    cmp #$04 : bcs .attr      ; only slots 1-3 are real: after power-on the game's own use of $04A5 / the RAM fill pattern can leave other values
    lda.l !LastSc
    cmp #$06 : beq .runend
    cmp #$04 : beq .runend  ; a run started from the start-point menu / slot screen plays inside scene 4 (also resumes, which skip floor select)
    cmp #$00 : beq .runend
    cmp #$16 : bcc .attr
    cmp #$30 : bcs .attr
.runend:
    ldy #$0000                ; A = last scene: $16 and up = an ending
    cmp #$16 : bcc +
    iny
+   tya : sta.l !HiClr
    lda #$02 : sta.l !HiMode
    jml HiScene
.attr:
    lda.l !LastSc
    cmp #$10 : bne .track
    jsl $86E760             ; v108: DemoQuit (options.asm): C = 1 if START ended the demo -> straight to the title
    bcs .track
    lda #$01 : sta.l !HiMode
    jml HiScene
.track:
    lda $0401 : sta.l !LastSc
    cmp #$03
    bcs +
    stz !Slot               ; boot / title / attract: no active slot, so demo floors never autosave
    lda.l !CodexOn
    cmp #$01 : bne .nq      ; v82: back from the CODEX: drop the attack sounds its ally pages queued (nothing played them)
    phb
    pea $8080 : plb : plb
    jsl $80F40C
    plb
.nq:
    lda #$00 : sta.l !CodexOn   ; power-on RAM is random
    sta.l !CodexCut
    stz !Resume
    lda #$00 : sta.l !HiEd  ; power-on RAM is not zero: no name entry in progress
+   nop                     ; (TOP is synced at floor start, see SyncTopL: doing it here broke the title START with some saved tables)
+   lda !Pend
    cmp #$C3                ; magic value (power-on RAM is random)
    bne .orig
    stz !Pend
    jml SlotScene
.orig:
    ldx $0401               ; original: LDX $0401 / JMP ($819E,X) in bank 80
    lda #$80
    pha
    rep #$20
    lda.l $80819E,x
    dec a
    pha
    sep #$20
    rtl
SyncTop:                    ; M=8, X=16. If the saved table's best score beats the game's TOP ($0449-$044F, least significant first), copy it
    lda.l !HT : cmp #$5C : bne .x       ; table not initialised yet
    lda $0450 : bne .x
    ldx #$0000              ; table digit (most significant first, entry 0 +6)
    ldy #$0006              ; TOP digit
-   lda.l !HTE+6,x
    cmp $0449,y
    bcc .x                  ; table lower: keep the game's value
    bne .copy
    inx : dey : bpl -
.x: rts
.copy:
    ldx #$0000
    ldy #$0006
-   lda.l !HTE+6,x : sta $0449,y
    inx : dey : bpl -
    rts
TitleStart:
    lda #$04
    sta $0401
    lda #$C3
    sta !Pend
    jml $80CBA3
SlotScene:
    sep #$20
    rep #$10
    ; v35: the floor-select (tower) background: BG1/BG2 use palettes 2-3, BG3 text palettes 0-7 (colours 0-31)
    %call($C4E5)
    %call($C515)
    %call($C649)
    %call($E3CB)            ; OPTION MODE font (small + big letters)
    sep #$20
    lda #$17 : sta $212C    ; main screen: BG1, BG2, BG3, sprites (portraits)
    stz $212D
    ; masks for the configured attack and jump buttons
    rep #$30
    lda $0495 : and #$0007 : asl a : tax
    lda.l $80E154,x : sta.l !AtkM
    lda $0498 : and #$0007 : asl a : tax
    lda.l $80E154,x : sta.l !JmpM
    lda $0497 : and #$0007 : asl a : tax          ; SPECIAL: delete a save
    lda.l $80E154,x : sta.l !SpcM
    sep #$20
    lda #$00
    sta.l !Cur
    sta.l !Mode
    sta.l !Done
    jsr DrawAll
    jsr Upload              ; screen is still off: copy the shadow now
    jsr TextPal             ; BG3 text colours
    jsr PanelSetup          ; border tiles, darkened panels (colour window + HDMA)
    jsr PortSetup           ; ally portraits (sprites)
    jsr OamUp
    lda #$09 : sta $2105
    %call($81C6)            ; start the fade-in
    sep #$20                ; same stepping as the game's $8211 loop, without its object code (it redraws its own OAM buffer every
    rep #$10                ; frame, which kept our portraits hidden until the fade was over)
.fade:
    lda $1242
    bne .fade
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
    jsr Upload              ; vblank: shadow -> VRAM
    jsr OamUp               ; portraits
    jsr SndTick             ; send one queued sound command to the SPC (the game's objects normally do this)
    jsr PanelTint           ; panel tint follows the selection
    %call($89D5)            ; read the pads ($1245/$1246 = new presses)
    sep #$20
    rep #$10
    lda $1245 : sta.l !Pad
    lda $1246 : sta.l !Pad+1
    jsr Input
    lda #$01 : sta $1242
    lda.l !Done
    beq .loop
    %call($8257)            ; fade out
    %call($826F)
    jsr PanelOff            ; HDMA, window and colour math off before the next scene
    sep #$20
    lda.l !Done
    cmp #$03
    beq .title
    cmp #$02
    beq .resume
    lda #$04 : sta $0401    ; new game: start-point menu
    stz $0402
    jml $80814D
.resume:                    ; straight into the saved floor, as the start-point menu does on confirm ($80:C4CF)
    rep #$30
    lda !Slot : and #$0003 : xba : tax
    sep #$20
    lda.l $700010,x : sta $0403
    lda.l $700011,x : sta $0404
    lda.l $700012,x : sta $0405
    lda #$02 : sta $0402
    lda #$06 : sta $0401
    %call($9BC3)            ; floor data pointers from $0403
    sep #$20
    jml $80814D
.title:
    lda #$02 : sta $0401
    stz $0402
    jml $80814D

; ---------- input ----------
Input:                      ; M=8 X=16
    rep #$20
    lda.l !Pad
    beq .none
    sep #$20
    lda.l !Mode
    beq InList
    cmp #$03
    bne +
    jmp InName
+   jmp InPrompt
.none:
    sep #$20
    rts

InList:
    rep #$20
    lda.l !Pad
    bit #$0800 : bne .up
    bit #$0400 : bne .down
    and.l !JmpM : bne .back
    lda.l !Pad
    and.l !AtkM : bne .ok
    lda.l !Pad
    bit #$1000 : bne .ok       ; START also selects
    and.l !SpcM : bne .del
    sep #$20
    rts
.del:
    sep #$20
    jsr SlotValid
    bcc +                      ; nothing to delete
    lda #$04 : sta.l !Mode     ; DELETE THIS SAVE?
    bra .redraw
+   rts
.up:
    sep #$20
    lda.l !Cur : dec a : bpl +
    lda #$02
+   sta.l !Cur
    jsr Beep
    bra .redraw
.down:
    sep #$20
    lda.l !Cur : inc a : cmp #$03 : bcc +
    lda #$00
+   sta.l !Cur
    jsr Beep
    bra .redraw
.back:
    sep #$20
    lda #$03 : sta.l !Done
    rts
.ok:
    sep #$20
    jsr SlotValid
    bcc .empty
    lda #$01 : sta.l !Mode   ; used: CONTINUE?
    bra .redraw
.empty:
    jsr NameStartDefault
    lda #$03 : sta.l !Mode
.redraw:
    jsr DrawAll
    rts

InPrompt:                   ; Mode 1 (continue?) or 2 (start over?)
    rep #$20
    lda.l !Pad
    and.l !AtkM : bne .yes
    lda.l !Pad
    bit #$1000 : bne .yes
    and.l !JmpM : bne .no
    sep #$20
    rts
.yes:
    sep #$20
    lda.l !Mode
    cmp #$04
    beq .delete
    cmp #$01
    bne .over
    lda.l !Cur : inc a : sta !Slot   ; resume this slot
    lda #$01 : sta !Resume
    lda #$02 : sta.l !Done
    rts
.delete:
    jsr SlotBase
    lda #$00 : sta.l $700000,x     ; drop the valid marker
    sta.l $7000B0,x                ; and the best-credit record
    rep #$20 : sta.l $70000E,x : sep #$20   ; and the checksum
    lda #$00 : sta.l !Mode
    jsr DrawAll
    rts
.over:
    jsr NameStartSaved             ; keep the old name as the starting point
    lda #$03 : sta.l !Mode
    jsr DrawAll
    rts
.no:
    sep #$20
    lda.l !Mode
    cmp #$01
    bne .back
    lda #$02 : sta.l !Mode         ; not continuing -> offer to start over
    jsr DrawAll
    rts
.back:
    lda #$00 : sta.l !Mode
    jsr DrawAll
    rts

InName:
    rep #$20
    lda.l !Pad
    bit #$0800 : bne .up
    bit #$0400 : bne .down
    bit #$0200 : bne .left
    bit #$0100 : bne .right
    bit #$1000 : beq +
    jmp .done
+
    and.l !AtkM : bne .right2
    lda.l !Pad
    and.l !JmpM : bne .left2
    sep #$20
    rts
.up:
    sep #$20
    jsr NameIdx : lda.l !Name,x : jsr NextChar : sta.l !Name,x
    bra .rd
.down:
    sep #$20
    jsr NameIdx : lda.l !Name,x : jsr PrevChar : sta.l !Name,x
    bra .rd
.right:
    sep #$20
    lda.l !NPos : cmp #$05 : bcs .rd
    inc a : sta.l !NPos
    bra .rd
.right2:                       ; attack: next letter, or done after the last one
    sep #$20
    lda.l !NPos : cmp #$05 : bcs .done8
    inc a : sta.l !NPos
    bra .rd
.left:
    sep #$20
    lda.l !NPos : beq .rd
    dec a : sta.l !NPos
    bra .rd
.left2:                        ; jump: previous letter, or cancel from the first one
    sep #$20
    lda.l !NPos : beq .cancel
    dec a : sta.l !NPos
    bra .rd
.cancel:
    lda #$00 : sta.l !Mode
    bra .rd
.done:
    sep #$20
.done8:
    jsr StartNewGame
    rts
.rd:
    jsr DrawAll
    rts

SndTick:
    php
    phb
    pea $8080 : plb : plb
    jsl $80F3EE
    plb
    plp
    rts

Beep:                          ; the start-point menu's cursor sound ($02); keeps A/X/Y and the register widths
    php
    rep #$30
    pha : phx : phy
    sep #$30
    lda #$02
    jsl $80F3D1
    rep #$30
    ply : plx : pla
    plp
    rts

NameIdx:                       ; X = name cursor
    rep #$20
    lda.l !NPos : and #$00FF : tax
    sep #$20
    rts
NextChar:                      ; space -> A..Z -> space
    cmp #$20 : bne +
    lda #$41 : rts
+   cmp #$5A : bcc +
    lda #$20 : rts
+   inc a : rts
PrevChar:
    cmp #$20 : bne +
    lda #$5A : rts
+   cmp #$42 : bcs +
    lda #$20 : rts
+   dec a : rts

NameStartDefault:              ; blank name (START on a blank name gives "HERO")
    rep #$10
    ldx #$0000
-   lda #$20 : sta.l !Name,x
    inx : cpx #$0006 : bne -
    lda #$00 : sta.l !NPos
    rts
NameStartSaved:                ; the slot's stored name
    jsr SlotBase               ; X = SRAM offset of the slot
    ldy #$0000
-   lda.l $700001,x
    cmp #$20 : bcc .bad
    cmp #$5B : bcs .bad
    phx : tyx : sta.l !Name,x : plx
    inx : iny : cpy #$0006 : bne -
    lda #$00 : sta.l !NPos
    rts
.bad:
    jmp NameStartDefault

StartNewGame:                  ; write the name, invalidate the old save, start a new game in this slot
    rep #$10
    ldx #$0000
-   lda.l !Name,x : cmp #$20 : bne .named
    inx : cpx #$0006 : bne -
    ldx #$0000                 ; all blank: "HERO"
-   lda.l DefName,x : sta.l !Name,x
    inx : cpx #$0006 : bne -
.named:
    jsr EggCheck               ; v88: an ally's name starts the run with that ally
    jsr SlotBase
    lda.l !Egg : sta.l $7000BC,x   ; v88: easter-egg ally (1 + type) for the run's first floor
    lda #$FF : sta.l $7000BD,x     ; v88: that floor, set when it starts ($FF = not yet)
    lda #$00 : sta.l $700000,x ; not valid until the first autosave
    sta.l $7000B0,x            ; no best credit yet
    sta.l $7000BB,x            ; and no continue used
    ldy #$0000
-   phx : tyx : lda.l !Name,x : plx
    sta.l $700001,x
    inx : iny : cpy #$0006 : bne -
    lda.l !Cur : inc a : sta !Slot
    stz !Resume
    lda #$01 : sta.l !Done
    rts

SlotBase:                      ; X = SRAM offset of the selected slot, M=8 X=16
    lda.l !Cur
SlotOff:                       ; A (8-bit) = slot 0-2 -> X = (slot+1)*256
    rep #$20
    and #$0003 : inc a : xba : tax
    sep #$20
    rts

SlotValid:                     ; C = 1 if the selected slot holds a valid save
    lda.l !Cur
SlotValidA:                    ; A = slot 0-2; returns C, X = SRAM offset
    jsr SlotOff
    lda.l $700000,x
    cmp #$A6
    bne .no
    phx
    rep #$20
    lda #$0000
    sta $0776
    ldy #$0000
-   lda.l $700010,x : and #$00FF
    clc : adc $0776
    sta $0776
    inx : iny : cpy #$008F : bne -
    plx
    lda $0776
    cmp.l $70000E,x
    sep #$20
    bne .no
    sec
    rts
.no:
    sep #$20
    clc
    rts

; ---------- drawing (into the shadow tilemap) ----------
; text at row/col: Y = row*32+col (word index), A = attr ($30 red / $20 green), string from long pointer in $00-$02
Upload:                        ; DMA shadow -> VRAM $5C00 (call in vblank or with the screen off)
    php
    sep #$20
    rep #$10
    lda #$80 : sta $2115
    ldx #$5C00 : stx $2116
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx.w #!Shadow : stx $4372
    lda.b #!Shadow>>16 : sta $4374
    ldx #$0700 : stx $4375
    lda #$80 : sta $420B
    plp
    rts

Clear:
    rep #$30
    ldx #$0000
    lda #$0000
-   sta.l !Shadow,x
    inx : inx : cpx #$0700 : bne -
    sep #$20
    rts

; PutStr: X = string address (bank 89), Y = cell index (row*32+col), $0776 = attr high byte
PutStr:
    rep #$30
    tya : asl a : tay
-   sep #$20
    lda.l StrBank,x
    beq .end
    rep #$20
    and #$00FF
    clc : adc #$0071
    ora $0776
    phx : tyx : sta.l !Shadow,x : plx
    inx : iny : iny
    bra -
.end:
    rep #$20
    tya : lsr a : tay
    sep #$20
    rts
StrBank = $890000              ; strings live in bank 89: X holds the 16-bit address

PutBig:                        ; big 16x16 letters of the OPTION MODE title font (A-Z at tiles 1+4k: TL,TR,BL,BR)
    rep #$30                   ; X = string (bank 89), Y = top-left cell, $0776 = attr
    tya : asl a : tay
-   sep #$20
    lda.l StrBank,x
    beq .end
    cmp #$20
    beq .sp
    rep #$20
    and #$00FF
    sec : sbc #$0041
    asl a : asl a : inc a      ; 1+4k
    ora $0776
    phx : tyx
    sta.l !Shadow,x : inc a
    sta.l !Shadow+2,x : inc a
    sta.l !Shadow+64,x : inc a
    sta.l !Shadow+66,x
    plx
.sp:
    rep #$20
    inx : iny : iny : iny : iny
    bra -
.end:
    sep #$20
    rts

PutChr:                        ; A (8-bit) = ASCII, Y = cell index, $0776 = attr; advances Y; keeps X
    rep #$30
    phx
    and #$00FF
    clc : adc #$0071
    ora $0776
    pha
    tya : asl a : tax
    pla
    sta.l !Shadow,x
    iny
    plx
    sep #$20
    rts

PutDec2:                       ; A (8-bit) = value 0-99, two digits; keeps X
    rep #$10
    phx
    ldx #$0000
-   cmp #$0A : bcc +
    sbc #$0A : inx : bra -
+   pha
    txa : clc : adc #$30 : jsr PutChr
    pla : clc : adc #$30 : jsr PutChr
    plx
    rts

PutDec:                        ; A (16-bit) = 0..999 -> 1-3 digits, no leading zeros; keeps X. Called with M=16.
    rep #$30
    phx
    ldx #$0000
-   cmp #$0064 : bcc +
    sbc #$0064 : inx : bra -
+   sta.l !Tmp                    ; remainder < 100
    txa : sta.l !Tmp+2            ; hundreds digit (0 = none)
    sep #$20
    beq +
    clc : adc #$30 : jsr PutChr
+   rep #$30
    lda.l !Tmp
    ldx #$0000
-   cmp #$000A : bcc +
    sbc #$000A : inx : bra -
+   sta.l !Tmp
    txa
    sep #$20
    bne .p                        ; tens digit non-zero: print it
    lda.l !Tmp+2 : beq .u         ; zero tens with no hundreds: skip
    lda #$00
.p: clc : adc #$30 : jsr PutChr
.u: lda.l !Tmp : clc : adc #$30 : jsr PutChr
    plx
    rts

DrawAll:
    jsr PortOam
    jsr Clear
    rep #$30
    lda.w #!ColT : sta $0776
    ldx.w #TxtTitle : ldy.w #1*32+3 : jsr PutBig
    sep #$20
    lda #$00
-   pha
    jsr DrawSlot
    pla : inc a : cmp #$03 : bne -
    jsr DrawFooter
    rts

DrawSlot:                      ; A = slot 0-2
    ; v34 layout (content cols 3-28 inside the box):
    ;   NAME    FLOOR 08    NORMAL
    ;   L2 LIZARDMAN     CREDITS 1
    ;   SCORE 0151640    LIVES 2.0
    sep #$20
    rep #$10
    sta.l !DSlot
    rep #$20
    lda.w #!ColDV : sta.l !VAt         ; not selected: dim value / dim label colours
    lda.w #!ColDL : sta.l !LAt
    sep #$20
    lda.l !DSlot
    cmp.l !Cur
    bne +
    rep #$20
    lda.w #!ColV : sta.l !VAt
    lda.w #!ColL : sta.l !LAt
+   rep #$20
    lda.l !DSlot : and #$00FF
    sta.l !Row
    asl a : clc : adc.l !Row : asl a     ; *6
    clc : adc #$0005
    asl a : asl a : asl a : asl a : asl a ; *32: first cell of the panel (col 0)
    sta.l !Row
    jsr Border
    sep #$20
    lda.l !DSlot
    jsr SlotValidA                      ; X = SRAM offset
    bcs .used
    jsr SetV                            ; white when selected, blue otherwise
    rep #$20
    lda.l !Row : clc : adc.w #32+14 : tay
    ldx.w #TxtEmpty : jsr PutStr
    rts
.used:
    ; row 1: name (col 3), FLOOR nn (col 12), game level right-aligned (cols 23-28)
    jsr SetV
    rep #$20
    lda.l !Row : clc : adc.w #6 : tay
    sep #$20
    phx
    lda #$06 : sta $0779
-   lda.l $700001,x : jsr PutChr
    inx : dec $0779 : bne -
    plx
    jsr SetL
    rep #$20
    lda.l !Row : clc : adc.w #13 : tay
    phx : ldx.w #TxtFloor : jsr PutStr : plx
    jsr SetV
    lda.l $700010,x : jsr PutDec2
    rep #$20
    lda.l !Row : clc : adc.w #23 : tay
    lda.l $700016,x : and #$0003 : asl a
    phx : tax : lda.l LvlNames,x : tax
    jsr PutStr
    plx
    ; row 2: L<n> ALLY (col 3), CREDITS n right-aligned (cols 20-28)
    rep #$20
    lda.l !Row : clc : adc.w #32+6 : tay
    lda.l $7000A0,x : and #$00FF
    beq .noally
    pha
    sep #$20
    lda #$4C : jsr PutChr                ; "L"
    lda.l $7000A1,x : inc a : clc : adc #$30 : jsr PutChr
    lda #$20 : jsr PutChr
    rep #$20
    pla
    phx
    tax : lda.l AllyNames-3,x : tax
    jsr PutStr
    plx
    bra .cred
.noally:
    sep #$20
    phx : ldx.w #TxtNoAlly : jsr PutStr : plx
.cred:
    jsr SetL
    rep #$20
    lda.l !Row : clc : adc.w #32+20 : tay
    phx : ldx.w #TxtCred : jsr PutStr : plx
    jsr SetV
    lda.l $70003A,x : and #$0F : clc : adc #$30 : jsr PutChr   ; $042D continues left
    ; row 3: SCORE (col 3), LIVES n.n right-aligned (ends col 28)
    jsr SetL
    rep #$20
    lda.l !Row : clc : adc.w #64+6 : tay
    phx : ldx.w #TxtScore : jsr PutStr : plx
    jsr SetV
    phx
    rep #$20
    txa : clc : adc #$0006 : tax
    sep #$20
    lda #$07 : sta $0779
-   lda.l $70004E,x : and #$0F : clc : adc #$30 : jsr PutChr
    dex : dec $0779 : bne -
    plx
    ; lives = life ($0431, slot +$3E) in HUD bars: 80 per bar, tenths = remainder / 8 (the HUD's half-cells)
    rep #$30
    lda.l $70003E,x
    phx
    ldx #$0000
-   cmp #$0050 : bcc +
    sbc #$0050 : inx : bra -
+   lsr a : lsr a : lsr a
    sta.l !LvT                           ; tenths
    txa : sta.l !LvB                     ; whole bars (max 10: the game caps life at 800)
    ldy.w #64+20                         ; "LIVES n.n" = 9 cells -> col 20
    cmp #$000A : bcc +
    ldy.w #64+21                         ; "LIVES 10" (the cap; no decimal)
+   tya : clc : adc.l !Row : tay
    jsr SetL
    ldx.w #TxtLivesB : jsr PutStr
    jsr SetV
    rep #$20
    lda.l !LvB : jsr PutDec
    rep #$20
    lda.l !LvB : cmp.w #$000A : bcs .l10
    sep #$20
    lda #$2E : jsr PutChr
    lda.l !LvT : clc : adc #$30 : jsr PutChr
.l10:
    sep #$20                             ; callers expect M=8
    plx
    rts

Border:                                  ; frame around the panel at !Row (rows -1..+3, cols 1-30) on BG3. M=16 X=16
    rep #$30
    lda.w #!ColBD : sta $0776
    sep #$20
    lda.l !DSlot : cmp.l !Cur : bne +
    rep #$20 : lda.w #!ColBS : sta $0776
+   rep #$30
    lda.l !Row : sec : sbc.w #32-1 : asl a : tax   ; top-left cell (byte offset)
    lda.w #$0170 : ora $0776 : sta.l !Shadow,x
    lda.w #$0172 : ora $0776 : sta.l !Shadow+58,x
    lda.w #$0175 : ora $0776 : sta.l !Shadow+256,x
    lda.w #$0177 : ora $0776 : sta.l !Shadow+256+58,x
    ldy #$001C                           ; 28 cells of top/bottom edge
    lda.w #$0171 : ora $0776
-   sta.l !Shadow+2,x
    pha : lda.w #$0176 : ora $0776 : sta.l !Shadow+258,x : pla
    inx : inx : dey : bne -
    lda.l !Row : asl a : clc : adc.w #2 : tax      ; left edge, 3 rows
    ldy #$0003
-   lda.w #$0173 : ora $0776 : sta.l !Shadow,x
    lda.w #$0174 : ora $0776 : sta.l !Shadow+58,x
    txa : clc : adc.w #64 : tax
    dey : bne -
    rts

SetV:                                    ; $0776 = value colour of the panel being drawn (keeps A/X/Y, any M)
    php : rep #$20 : pha
    lda.l !VAt : sta $0776
    pla : plp : rts
SetL:
    php : rep #$20 : pha
    lda.l !LAt : sta $0776
    pla : plp : rts

DrawFooter:
    sep #$20
    rep #$10
    lda.l !Mode
    bne .m
    ; list: "<atk> SELECT  <jmp> BACK  <spc> DELETE" (cols 3-28, row 23)
    ldy.w #23*32+3
    jsr ColB : lda $0495 : jsr BtnChr
    jsr ColF : ldx.w #TxtSelect : jsr PutStr
    jsr ColB : lda $0498 : jsr BtnChr
    jsr ColF : ldx.w #TxtBack : jsr PutStr
    jsr ColB : lda $0497 : jsr BtnChr
    jsr ColF : ldx.w #TxtDel : jsr PutStr
    rts
.m: cmp #$03
    beq .name
    ldx.w #TxtContinue : ldy.w #22*32+4
    cmp #$01
    beq +
    ldx.w #TxtDelete : ldy.w #22*32+7
    cmp #$04
    beq +
    ldx.w #TxtOver : ldy.w #22*32+5
+   rep #$20 : lda.w #!ColV : sta $0776 : sep #$20
    jsr PutStr
    ldy.w #24*32+10                     ; "<atk> YES  <jmp> NO"
    jsr ColB : lda $0495 : jsr BtnChr
    jsr ColF : ldx.w #TxtYes : jsr PutStr
    jsr ColB : lda $0498 : jsr BtnChr
    jsr ColF : ldx.w #TxtNo : jsr PutStr
    rts
.name:
    rep #$20 : lda.w #!ColW : sta $0776 : sep #$20
    ldx.w #TxtName : ldy.w #22*32+8 : jsr PutStr
    rep #$10
    ldy.w #24*32+13
    ldx #$0000
-   phx
    rep #$20 : lda.w #!ColDV : sta $0776 : sep #$20
    txa : cmp.l !NPos : bne +
    rep #$20 : lda.w #!ColV : sta $0776 : sep #$20
+   lda.l !Name,x
    cmp #$20 : bne +
    lda #$2D                            ; show blanks as "-"
+   jsr PutChr
    plx
    inx : cpx #$0006 : bne -
    jsr ColF
    ldx.w #TxtNameHelp : ldy.w #26*32+3 : jsr PutStr
    rts
ColB:
    php : rep #$20 : lda.w #!ColB : sta $0776 : plp : rts
ColF:
    php : rep #$20 : lda.w #!ColF : sta $0776 : plp : rts

BtnChr:                        ; A = button setting 0-5 -> letter at Y (green), then a space
    rep #$20
    and #$0007
    tax
    sep #$20
    lda.l BtnLetters,x : jsr PutChr
    lda #$20 : jsr PutChr
    rts

BtnLetters: db "ABXYLR"
DefName:    db "HERO  "
TxtTitle:   db "SELECT A SLOT",0
TxtEmpty:   db "EMPTY",0
TxtFloor:   db "FLOOR ",0
TxtLivesB:  db "LIVES ",0
TxtCred:    db "CREDITS ",0
TxtScore:   db "SCORE ",0
TxtNoAlly:  db "NO ALLY",0
TxtSelect:  db "SELECT  ",0
TxtBack:    db "BACK  ",0
TxtContinue: db "CONTINUE THIS ADVENTURE?",0
TxtOver:    db "START A NEW GAME HERE?",0
TxtDelete:  db "DELETE THIS SAVE?",0
TxtDel:     db "DELETE",0
TxtYes:     db "YES  ",0
TxtNo:      db "NO",0
TxtName:    db "ENTER YOUR NAME",0
TxtNameHelp: db "UP DOWN LETTER  START DONE",0
TxtEasy:    db "  EASY",0
TxtNormal:  db "NORMAL",0
TxtHard:    db "  HARD",0
LvlNames:   dw TxtEasy, TxtNormal, TxtHard, TxtNormal
TxtAmazon:  db "AMAZON ",0
TxtBigMan:  db "BIG MAN ",0
TxtWizard:  db "WIZARD ",0
TxtKnight:  db "KNIGHT ",0
TxtLizard:  db "LIZARDMAN",0
TxtNinja:   db "NINJA ",0
TxtThief:   db "THIEF ",0
TxtCleric:  db "CLERIC ",0
AllyNames:  ; indexed by id-3 with id = 3,6,...,24: entries 3 bytes apart -> use dw + padding byte
    dw TxtAmazon : db 0
    dw TxtBigMan : db 0
    dw TxtWizard : db 0
    dw TxtKnight : db 0
    dw TxtLizard : db 0
    dw TxtNinja : db 0
    dw TxtThief : db 0
    dw TxtCleric : db 0

; ---------- slot boxes (BG1, 4bpp; the tower background is not used on this screen) ----------
; VRAM: tiles at word $2000 (BG1 chr base), tilemap at $3000. The next scene's set-up reloads both areas.
BoxSetup:                       ; screen off, M=8 X=16
    php
    phb
    phk
    plb                                ; DB = $89 for BoxKinds (WRAM and I/O are mirrored in this bank)
    sep #$20
    rep #$10
    lda #$80 : sta $2115
    ldx #$2000 : stx $2116
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx.w #BoxGfx : stx $4372
    lda.b #BoxGfx>>16 : sta $4374
    ldx.w #BoxGfxEnd-BoxGfx : stx $4375
    lda #$80 : sta $420B
    rep #$30
    ldx #$0000 : lda #$0000
-   sta.l !BoxMap,x : inx : inx : cpx #$0800 : bne -
    lda #$0000 : sta.l !Tmp            ; slot 0-2
.slot:
    lda.l !Tmp : asl a : clc : adc.l !Tmp : asl a   ; 6*slot
    clc : adc #$0004                   ; top row 4, 10, 16
    xba : lsr a : lsr a : tax          ; *64 = byte offset of the row
    lda.l !Tmp : clc : adc #$0004 : xba : asl a : asl a : sta $0776   ; palette (4+slot) << 10
    ldy #$0000 : jsr BoxRow
    txa : clc : adc #$0040 : tax
    ldy #$0003 : jsr BoxRow
    txa : clc : adc #$0040 : tax
    ldy #$0003 : jsr BoxRow
    txa : clc : adc #$0040 : tax
    ldy #$0003 : jsr BoxRow
    txa : clc : adc #$0040 : tax
    ldy #$0006 : jsr BoxRow
    lda.l !Tmp : inc a : sta.l !Tmp
    cmp #$0003 : bne .slot
    ldy #$0000                         ; starfield around the boxes
-   lda.w StarMap,y : tax
    lda.w StarMap+2,y : sta.l !BoxMap,x
    iny : iny : iny : iny
    cpy.w #StarMapEnd-StarMap : bne -
    sep #$20
    ldx #$3000 : stx $2116
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx.w #!BoxMap : stx $4372
    lda.b #!BoxMap>>16 : sta $4374
    ldx #$0800 : stx $4375
    lda #$80 : sta $420B
    lda #$30 : sta $2107               ; BG1 tilemap $3000, 32x32
    lda #$02 : sta $210B               ; BG1 tiles at $2000
    stz $210D : stz $210D
    lda #!BoxVOfs : sta $210E : stz $210E
    lda #$05 : sta $212C               ; main screen: BG1 + BG3
    plb
    plp
    rts

BoxRow:                         ; X = row byte offset, Y = 0 top / 3 middle / 6 bottom, $0776 = attr; cols 1-30. M=X=16
    phx
    phy
    lda.w BoxKinds,y : and #$00FF : ora $0776 : sta.l !BoxMap+2,x
    lda.w BoxKinds+1,y : and #$00FF : ora $0776
    ldy #$001C
-   sta.l !BoxMap+4,x
    inx : inx : dey : bne -
    ply
    lda.w BoxKinds+2,y : and #$00FF : ora $0776 : sta.l !BoxMap+4,x
    plx
    rts
BoxKinds: db 1,2,3, 4,9,5, 6,7,8

BoxPal:                         ; colours 1-2 of BG palettes 4-6: selected box bright line + blue fill, others dim line
    php
    sep #$30
    ldy #$00
-   tya : asl a : asl a : asl a : asl a : clc : adc #$41 : sta $2121
    ldx #$00
    tya : cmp.l !Cur : bne +
    ldx #$04
+   lda.l BoxCols,x : sta $2122
    lda.l BoxCols+1,x : sta $2122
    lda.l BoxCols+2,x : sta $2122
    lda.l BoxCols+3,x : sta $2122
    iny : cpy #$03 : bne -
    ; twinkling stars: colours 1-3 of BG palette 7 run through a brightness ramp, out of phase
    lda.l !Tw : inc a : sta.l !Tw
    lda #$71 : sta $2121
    ldy #$00
    phb : phk : plb
-   lda.l !Tw : lsr a : lsr a : clc : adc.w TwOff,y
    and #$1F : asl a : tax
    lda.l TwRamp,x : sta $2122
    lda.l TwRamp+1,x : sta $2122
    iny : cpy #$03 : bne -
    plb
    plp
    rts
TwOff:   db 0, 11, 21
TwRamp:  dw $0842,$0C63,$1084,$18C6,$2108,$294A,$318C,$39CE,$4210,$4A52,$5294,$5AD6,$6318,$6B5A,$739C,$7BDE
         dw $7FFF,$7BDE,$739C,$6B5A,$6318,$5AD6,$5294,$4A52,$4210,$39CE,$318C,$294A,$2108,$18C6,$1084,$0C63
; ---------- panels: frame tiles on BG3, darkened inside via the colour window ----------
; Window 1 (colour window only) covers x 12-243 on the panel lines (HDMA ch 5 -> $2126/$2127); colour math subtracts
; a fixed colour from BG1/BG2/backdrop inside it, darker and bluer for the selected panel (HDMA ch 6 -> $2132 x2).
!WinTab = $7FEA00
!ColTab = $7FEA40
PanelSetup:                     ; screen off, M=8 X=16
    php
    sep #$20
    rep #$10
    lda #$80 : sta $2115           ; frame tiles -> BG3 tiles $170-$177 (VRAM words $0B80-$0BFF; blank in this font)
    ldx #$0B80 : stx $2116
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx.w #FrameGfx : stx $4372
    lda.b #FrameGfx>>16 : sta $4374
    ldx.w #FrameGfxEnd-FrameGfx : stx $4375
    lda #$80 : sta $420B
    ldx #$0000                     ; window table (static)
-   lda.l WinData,x : sta.l !WinTab,x
    inx : cpx.w #WinDataEnd-WinData : bne -
    jsr PanelTint
    lda #$20 : sta $2125           ; colour window = window 1
    lda #$10 : sta $2130           ; colour math only inside the colour window; fixed colour
    lda #$A3 : sta $2131           ; subtract, on BG1 + BG2 + backdrop (not the text)
    lda #$01 : sta $4350           ; ch 5: 2 regs ($2126/$2127)
    lda #$26 : sta $4351
    ldx.w #!WinTab : stx $4352
    lda.b #!WinTab>>16 : sta $4354
    lda #$02 : sta $4360           ; ch 6: 1 reg written twice ($2132)
    lda #$32 : sta $4361
    ldx.w #!ColTab : stx $4362
    lda.b #!ColTab>>16 : sta $4364
    lda #$60 : sta $420C
    plp
    rts
PanelOff:
    php
    sep #$20
    stz $420C
    stz $2125
    stz $2130
    stz $2131
    lda #$E0 : sta $2132
    plp
    rts
PanelTint:                      ; window + fixed-colour tables for the current selection and mode (HDMA reads them each frame)
    php
    sep #$20
    rep #$10
    ldx #$0000
-   lda.l TintLines,x : sta.l !ColTab,x
    lda.l WinData,x : sta.l !WinTab,x
    inx : cpx.w #TintLinesEnd-TintLines : bne -
    ; footer band, centred on its text with 4 lines of margin: list = row 23, prompts = rows 22-24, name entry = rows 22-26
    lda.l !Mode
    rep #$20 : and #$00FF : asl a : tax : sep #$20
    lda.l BandGap,x   : sta.l !WinTab+18 : sta.l !ColTab+18
    lda.l BandGap+1,x : sta.l !WinTab+21 : sta.l !ColTab+21
    ldy #$0000
.p: rep #$20
    tya : asl a : tax
    lda.l PanelOfs,x : tax
    sep #$20
    lda #$EC : sta.l !ColTab+1,x   ; other panels: subtract R=G=B=12 (neutral darkening)
    sta.l !ColTab+2,x              ; ($2132: bit 7 = blue, 6 = green, 5 = red)
    tya : cmp.l !Cur : bne +
    lda #$72 : sta.l !ColTab+1,x   ; selected: R=G=18
    lda #$88 : sta.l !ColTab+2,x   ;   B=8 (darker, bluish)
+   iny : cpy #$0003 : bne .p
    plp
    rts
PanelOfs: dw 3, 9, 15
BandGap:  db 16,16, 8,32, 8,32, 8,48, 8,32   ; per mode: lines after panel 3, band height
!PTop = 36                      ; first darkened line of panel 0 (calibrated against the BG3 frame)
WinData:  db !PTop,255,0, 32,12,243, 16,255,0, 32,12,243, 16,255,0, 32,12,243, 8,255,0, 44,12,243, 1,255,0, 0
WinDataEnd:                     ; (the 4th band darkens the footer / prompt rows 22-26)
TintLines: db !PTop,$E0,$E0, 32,$E0,$E0, 16,$E0,$E0, 32,$E0,$E0, 16,$E0,$E0, 32,$E0,$E0, 8,$E0,$E0, 44,$EE,$EE, 1,$E0,$E0, 0
TintLinesEnd:
FrameGfx:
incsrc "framegfx.inc"
FrameGfxEnd:

; ---------- ally portraits: the HUD's 16x16 pictures ($9F:C000 + 128*index, tiles TL,TR,BL,BR) as sprites ----------
!OamBuf2 = $7FEB00              ; 544-byte OAM image for this screen
PortSetup:                      ; screen off, M=8 X=16
    php
    sep #$20
    rep #$10
    lda #$63 : sta $2101           ; 16x16 sprites, tiles at VRAM $6000 (as in the game)
    lda #$80 : sta $2121           ; sprite palette 0 = the HUD portrait colours
    ldx #$0000
-   lda.l PortPal,x : sta $2122
    inx : cpx #$0020 : bne -
    lda #$00
.s: pha
    jsr SlotValidA                 ; C = valid, X = SRAM offset
    bcc .n
    lda.l $7000A0,x : beq .n       ; no ally
    rep #$20
    and #$00FF
    phx : tax                      ; X = ally id (3..24, multiple of 3)
    lda.l PortIdx-3,x : and #$00FF ; picture index
    plx
    xba : lsr a                    ; *128
    clc : adc.w #$C000
    sta $0776                      ; source address in bank $9F
    lda $01,s : and #$00FF
    asl a : asl a : asl a : asl a : asl a     ; *32 words = 2 tiles
    clc : adc.w #$6000
    sta $0778                      ; destination (top row)
    sep #$20
    lda #$80 : sta $2115
    ldx $0778 : stx $2116
    ldy #$0040 : jsr .dma          ; TL, TR
    rep #$20
    lda $0778 : clc : adc.w #$0100 : tax
    sep #$20
    stx $2116
    ldy #$0040 : jsr .dma          ; BL, BR (next sprite tile row)
.n: pla
    inc a : cmp #$03 : bne .s
    plp
    rts
.dma:                           ; Y = bytes from $9F:($0776), advances $0776
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx $0776 : stx $4372
    lda #$9F : sta $4374
    sty $4375
    lda #$80 : sta $420B
    rep #$20
    tya : clc : adc $0776 : sta $0776
    sep #$20
    rts

PortOam:                        ; build the OAM image: sprite k = portrait of slot k (if it holds a save with an ally)
    php
    sep #$20
    rep #$10
    ldx #$0000
-   lda #$00 : sta.l !OamBuf2,x    ; x
    lda #$F0 : sta.l !OamBuf2+1,x  ; y off screen
    lda #$00 : sta.l !OamBuf2+2,x
    sta.l !OamBuf2+3,x
    inx : inx : inx : inx : cpx #$0200 : bne -
    lda #$00
-   sta.l !OamBuf2,x : inx : cpx #$0220 : bne -
    lda #$00
.s: pha
    jsr SlotValidA
    bcc .n
    lda.l $7000A0,x : beq .n
    rep #$20
    lda $01,s : and #$00FF : asl a : asl a : tax   ; OAM entry = slot (clear B before TAX)
    sep #$20
    lda #24 : sta.l !OamBuf2,x               ; x: columns 3-4
    lda $01,s : sta $0779                    ; y = 43 + 48*slot (centred on the panel's 3 text rows)
    asl a : clc : adc $0779 : asl a : asl a : asl a : asl a  ; *48
    clc : adc #43 : sta.l !OamBuf2+1,x
    lda $01,s : asl a : sta.l !OamBuf2+2,x   ; tile 2*slot
    lda #$30 : sta.l !OamBuf2+3,x            ; priority 3, palette 0
.n: pla
    inc a : cmp #$03 : bne .s
    plp
    rts

OamUp:                          ; OAM image -> OAM (vblank)
    php
    sep #$20
    rep #$10
    ldx #$0000 : stx $2102
    lda #$00 : sta $4370
    lda #$04 : sta $4371
    ldx.w #!OamBuf2 : stx $4372
    lda.b #!OamBuf2>>16 : sta $4374
    ldx #$0220 : stx $4375
    lda #$80 : sta $420B
    plp
    rts
PortIdx:   db 3,0,0, 4,0,0, 6,0,0, 2,0,0, 0,0,0, 7,0,0, 5,0,0, 1   ; by ally id 3,6,...,24 (Amazon, Big Man, Wizard, Knight, Lizardman, Ninja, Thief, Cleric)
PortPal:   dw $0000, $4C40, $6260, $6318, $25B1, $4ED8, $630F, $0013, $0138, $61A0, $1CE7, $3718, $2638, $0067, $110C, $0000

TextPal:                        ; BG3 palettes 0-7 (colour 1 = letter shadow, 2 = letter body)
    php
    sep #$20
    rep #$10
    stz $2121
    ldx #$0000
-   lda.l TextCols,x : sta $2122
    inx : cpx #$0040 : bne -
    plp
    rts
TextCols:
    dw $0000, $5000, $7B00, $7BDE   ; P0 title and unselected frames: the floor-select blue
    dw $0000, $5000, $7FFF, $7FE0   ; P1 selected values: white; frame line bright cyan
    dw $0000, $000E, $031F, $031F   ; P2 selected labels: orange-gold
    dw $0000, $5000, $7B00, $3080   ; P3 other values: the floor-select blue; frame line dim blue
    dw $0000, $000E, $00DE, $00DE   ; P4 other labels: the floor-select red
    dw $0000, $5000, $7B00, $7B00   ; P5 footer words: blue
    dw $0000, $000E, $031F, $031F   ; P6 button letters: orange-gold
    dw $0000, $5000, $7FFF, $7FE0   ; P7 selected frame: white with a cyan inner line
BoxCols: dw $3500, $0000, $7EE0, $2800   ; dim blue line, black / bright cyan line, deep blue fill
BoxGfx:
incsrc "boxgfx.inc"
BoxGfxEnd:
incsrc "stars.inc"

incsrc "hiscore.asm"

; ---------- title menu: a third item, CODEX (v74; was HIGH SCORES) ----------
TitleMenu:                    ; replaces $80:C02A-C080 (cursor + START handling of the title menu object)
    php
    sep #$30
    lda $1246
    bit #$20 : bne .dn        ; SELECT
    bit #$04 : bne .dn        ; DOWN
    bit #$08 : bne .up
    bra .pos
.dn: lda $045F : inc a : cmp #$03 : bcc + : lda #$00
+   sta $045F
    bra .pos
.up: lda $045F : dec a : bpl + : lda #$02
+   sta $045F
.pos:
    lda $045F : and #$03 : asl a : asl a : tax
    rep #$20
    lda.l TitleCur,x : ldy #$04 : sta [$00],y
    lda.l TitleCur+2,x : ldy #$06 : sta [$00],y
    sep #$20
    lda $1246 : bit #$10 : beq .out
    lda $045F
    beq .start
    cmp #$01 : beq .opt
    lda #$12 : bra .set       ; HIGH SCORES
.opt: lda #$10 : bra .set
.start: lda #$06
.set: sta $045E
    ldy #$52 : lda #$00 : sta [$00],y
.out:
    plp
    jml $80BEBF
TitleCur: dw $0040,$0078, $0040,$0088, $0040,$0098   ; 16 px apart, like the text rows (the original OPTION was 4 px low)

TitleLoop:                    ; replaces $80:CB75 LDA $045E / CMP #$06 in the title scene loop
    lda $045E
    cmp #$12
    beq .hs
    cmp #$06
    jml $80CB7A
.hs:
    %call($8257)              ; fade out, like the other exits
    %call($826F)
    sep #$20
    lda #$01 : sta.l !CodexOn
    lda #$00 : sta.l !CodexPage
    sta.l !HiMode
    jsl $86E710               ; v107: MusLoad (options.asm): the saved CODEX MUSIC, not the RAM copy (play overwrites it)
    lda.l !CodexMus
    beq .nomus                ; NONE: the CODEX stays silent
    lda #$80 : sta $4200      ; v81: the song loader waits for the NMI, which the fade-out has switched off
    sep #$30
    lda.l !CodexMus
    dec a
    tax
    lda.l $80E6D8,x           ; Music Test number -> song id
    jsl $80F3A9               ; the CODEX plays the chosen song (the screen is black while the song loads)
    rep #$10
    lda #$00 : sta $4200
.nomus:
    jml HiScene

TitleText:                    ; replaces $80:CB32 SEP #$30 / JSR $81C6 (screen still off): add HIGH SCORES, move the copyright down
    php
    sep #$20
    rep #$10
    lda #$80 : sta $2115
    ldx #$0000
.l: rep #$20
    lda.l TitleRows,x : beq .d   ; row records: dw vram address, count; then count tile words
    lda.l TitleRows,x : sta $2116
    lda.l TitleRows+2,x : tay
    inx : inx : inx : inx
-   lda.l TitleRows,x : sta $2118
    inx : inx
    dey : bne -
    sep #$20
    bra .l
.d: sep #$20
    plp
    sep #$30
    %call($81C6)
    sep #$30
    jml $80CB37
assert pc() <= $89F000      ; v96: the $89:C400 block must end before LoadOptions ($89:F000)
org $89F100                 ; v96: own spot (free $89:F06C-$F2C0): the block above had no room left
TitleRows:
    dw $5800+(21*32)+14, 5         ; CODEX (title font: tile = ASCII - $20 + $1D00), lined up with START / OPTION
    dw $1D23,$1D2F,$1D24,$1D25,$1D38
    dw $5800+(22*32), 32          ; copyright "(C) CAPCOM 1990,1992" moves from row 22 to row 25
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw $5800+(25*32), 32
    dw 0,0,0,0,0,0,0,$1D03,0,$1D23,$1D21,$1D30,$1D23,$1D2F,$1D2D,0,$1D11,$1D19,$1D19,$1D10,$1D0C,$1D11,$1D19,$1D19,$1D12,0,0,0,0,0,0,0
    dw $5800+(24*32), 32          ; the CAPCOM U.S.A. line is dropped
    dw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    dw 0

; ---------- saved options (SRAM $70:0010: +0 marker $5A, +1 game level $0409, +2..+5 buttons $0495-$0498,
;            +6 SPECIAL ACTION $04A4 << 1, +7 checksum = low byte of the sum of +1..+6) ----------
org $80E122
    jml OptSave             ; orig LDA $13A3 / STA $0409 (leaving OPTION MODE)
    nop
    nop


org $89F000

LoadOptions:                ; called at power-on after the defaults; M=8
    php
    sep #$30
    lda #$06 : sta.l !CodexMus       ; v83: CODEX MUSIC default = song 05
    lda.l $700018 : eor #$A5 : cmp.l $700019 : bne .nm   ; saved CODEX MUSIC (value, value xor $A5), independent of the rest
    lda.l $700018 : cmp #$1B : bcs .nm
    sta.l !CodexMus
.nm:
    lda.l $700010
    cmp #$5A
    bne .xx
    jsr OptSum
    cmp.l $700017
    bne .xx
    lda.l $700011 : cmp #$03 : bcc .ok
.xx:
    jmp .x
.ok:
    sta $0409
    lda.l $700012 : sta $0495
    lda.l $700013 : sta $0496
    lda.l $700014 : sta $0497
    lda.l $700015 : sta $0498
    lda.l $700016 : lsr a : and #$01 : sta $04A4   ; v67: SPECIAL ACTION is bit 1 (old THIEF VISION bit 0 is ignored)
    jsl ApplyMasks          ; button masks, as the game computes them when leaving OPTION MODE
.x:
    plp
    rtl

org $89F300
ApplyMasks:                 ; any M/X: ATTACK/SPECIAL/JUMP masks ($0464/$0466/$0468) from the buttons in $0495/$0497/$0498.
    php                     ; Used at power-on (saved options) and after a saved run is restored, which brings back the
    rep #$30                ; masks that were saved with the run (v69 fix: the Control Pad setting was being overridden).
    pha : phx : phy         ; leaves every register as it found it
    sep #$30
    rep #$20
    lda $0495 : and #$0007 : asl a : tax : lda.l $80E154,x : sta $0464
    lda $0497 : and #$0007 : asl a : tax : lda.l $80E154,x : sta $0466
    lda $0498 : and #$0007 : asl a : tax : lda.l $80E154,x : sta $0468
    sep #$20
    ldy #$00                ; the face button left unassigned also attacks
.l: cpy $0495 : beq .n
    cpy $0497 : beq .n
    cpy $0498 : beq .n
    tya : asl a : tax
    rep #$20
    lda.l $80E154,x : ora $0464 : sta $0464
    sep #$20
.n: iny
    cpy #$04
    bcc .l
    rep #$30
    ply : plx : pla
    plp
    rtl

OptSum:                     ; A = low byte of the sum of SRAM +$11..+$16
    lda.l $700011
    clc : adc.l $700012
    clc : adc.l $700013
    clc : adc.l $700014
    clc : adc.l $700015
    clc : adc.l $700016
    rts

OptSave:                    ; M=8 X=8
    lda $13A3
    sta $0409               ; replaced instructions
    sta.l $700011
    lda $0495 : sta.l $700012
    lda $0496 : sta.l $700013
    lda $0497 : sta.l $700014
    lda $0498 : sta.l $700015
    lda $04A4 : asl a : sta.l $700016
    jsr OptSum
    sta.l $700017
    lda #$5A
    sta.l $700010
    lda.l !CodexMus : sta.l $700018   ; v83: CODEX MUSIC
    eor #$A5 : sta.l $700019
    jml $80E128


; ======================= v74: CODEX =======================
; Title item CODEX: pages 0 Hall of Heroes (HiScene mode 0), 1-8 the ally description screens (scene $0A with $0462 = ally),
; 9 the Magic Items screen (scene $0C).  LEFT / RIGHT turn the page (wrapping), START returns to the title.  The attract loop
; is untouched: every hook below falls back to the original code when !CodexOn is 0.
org $00D535
    jsr $F7D0              ; orig JSR $D722 (the ally screen's per-frame typing / level / timer routine)
org $81FA54
    jml CodexStep           ; orig CMP #$04 / BNE $81FA5E (the ally level animation: step counter reached 4 = done)
org $00D579
    jml CodexReplay         ; orig JSR $8257 / JSR $82AD (fade out before the ally screen restarts)
    nop : nop
org $008211
    jml CodexFadeIn         ; orig LDA $1242 / BNE $8211 (start of the fade-in loop that finishes every scene start-up)
    nop
org $00D550
    jml CodexAllyPad        ; orig LDA $1246 / ORA $1245 / BNE $D58E
    nop : nop : nop : nop
org $00D73B
    jml CodexAllyTimer      ; orig LDA $0462 / INC A  (the ally screen advancing to the next ally)
org $00893C                 ; v96: the attract loop's gameplay demo ends on START only
    lda $4219 : and #$10 : nop  ; orig LDA $4218 / ORA $4219 (then BNE: end the demo)
org $00D896
    jml CodexItemPad        ; orig LDA $1246 / ORA $1245 / BNE $D8CB
    nop : nop : nop : nop
org $00D8A7
    jml CodexItemLimit      ; orig CMP #$0200 / BEQ $D8B5  (the item screen's 512-loop timeout)
    nop

org $86E400
CodexStep:                  ; A = the animation step counter (just incremented and stored at [$00],Y)
    cmp #$04
    beq .four
    bcc .lv
    bra .lv
.four: lda.l !CodexOn : beq .done
    lda #$00 : sta [$00],Y      ; v79: end of the last level's cycle: in the CODEX the whole animation starts over at level 1 (the text stays)
    rep #$20
    stz $0413 : stz $0415 : stz $0417 : stz $0419
    sep #$20
    stz $0412
.done: jml $81FA58
.lv: jml $81FA5E

CodexFadeIn:                ; M=8 X=8
    lda.l !CodexCut : beq .w
    lda #$0E : sta $1252    ; the fade-in is one step from the end: the page appears at once
    stz $124F
.w: lda $1242 : bne .w
    jml $008216

CodexReplay:                ; M=8 X=8: the ally screen restarts (after its text and level animation)
    lda.l !CodexOn : beq .o
    lda #$01 : sta.l !CodexCut
    lda #$00 : sta.l !FastOn
    %call($8299)            ; blank, no fade
    sep #$30
    jml $00D57F
.o: %call($8257)
    %call($82AD)
    sep #$30
    jml $00D57F

CodexAllyPad:               ; M=8 X=8
    lda.l !CodexOn : beq .orig
    lda $1245
    and #$C0 : bne .fast    ; A or X
    lda $1246
    and #$C0 : bne .fast    ; B or Y
    bra .nf
.fast: lda $06F4
    bne .nf                 ; text already done: nothing (the level animation loops by itself, see CodexStep)
    lda #$01 : sta.l !FastOn  ; still typing: print the rest fast
.nf: lda $1246
    bit #$10 : bne .exit    ; START
    lda $1245
    bit #$20 : bne .prev    ; L (v96; was LEFT)
    bit #$10 : bne .next    ; R (was RIGHT)
.cont: jml $00D558
.orig: lda $1246 : and #$10 : beq .cont   ; v96: the attract loop leaves on START only
.exit: jml $00D58E
.prev: lda #$03 : bra .go
.next: lda #$02
.go: jsl CodexNav
    jml $00D558

CodexAllyTimer:             ; M=8 X=8: the ally has been shown for its time
    lda.l !CodexOn : beq .orig
    jml $00D75D             ; v77: the CODEX page stays frozen at the end; A/B/X/Y restarts it (CodexAllyPad)
.orig: lda $0462 : inc a
    jml $00D73F

CodexItemPad:               ; M=8 X=8
    lda.l !CodexOn : beq .orig
    lda $1246
    bit #$10 : bne .exit
    lda $1245
    bit #$20 : bne .prev    ; L
    bit #$10 : bne .next    ; R
.cont: jml $00D89E
.orig: lda $1246 : and #$10 : beq .cont   ; v96: START only
.exit: jml $00D8CB
.prev: lda #$03 : bra .go
.next: lda #$02
.go: jsl CodexNav
    jml $00D89E

CodexItemLimit:             ; M=16 (A = the loop counter), X=8
    pha
    sep #$20
    lda.l !CodexOn
    beq .n
    rep #$20
    pla
    jml $00D8AC             ; no timeout in the CODEX
.n: rep #$20
    pla
    cmp.w #$0200
    beq .e
    jml $00D8AC
.e: jml $00D8B5

CodexNav:                   ; A = 2 next page, 3 previous page.  M=8 X=8 inside a scene loop: fade out, then enter the new page
    cmp #$03 : beq .p
    lda.l !CodexPage : inc a
    cmp #$0B : bcc .s           ; v101: pages 0 Hall, 1 Thief's Log, 2 magic items, 3-10 allies (v90-v100: 2-9 allies, 10 items)
    lda #$00 : bra .s
.p: lda.l !CodexPage : dec a
    bpl .s
    lda #$0A
.s: sta.l !CodexPage
    rep #$10
    lda #$01 : sta.l !CodexCut
    sep #$30                ; v81: screen blank like $8299, but without its JSL $80F3BD (that starts the silent song $19 and would end the CODEX music)
    lda #$80 : sta $2100
    lda #$00 : sta $4200
    stz $1253
    rep #$30
    lda.w #$0000
    tcd
    sep #$20
    jml CodexEnter

CodexFromHall:              ; from the Hall of Heroes (screen already faded and cleaned up): HiDone 2 = next, 3 = previous
    lda #$01 : sta.l !CodexCut
    lda.l !HiDone
    cmp #$03 : beq .p
    lda #$01 : bra .s       ; page 0 -> 1 (Thief's Log)
.p: lda #$0A                ; page 0 -> 10 (the last ally)
.s: sta.l !CodexPage
    jml CodexEnter

CodexEnter:                 ; M=8 X=16, screen faded out: start the scene for page !CodexPage
    sep #$20
    rep #$10
    phb
    pea $8080 : plb : plb
    jsl $80F40C             ; v82: empty the sound-effect queue ($0B20-$0BFF): the ally pages queue their attack sounds, which nothing plays there, and the Hall of Heroes played them all when it started
    plb
    lda #$00 : sta.l !FastOn
    stz $2131
    stz $2130
    lda #$E0 : sta $2132
    lda.l !CodexPage
    bne .pg
    lda #$00 : sta.l !HiMode
    jml HiScene
.pg:
    cmp #$01 : bne .pg2
    jml LogScene            ; v90
.pg2:
    rep #$20
    stz $0413 : stz $0415 : stz $0417 : stz $0419
    sep #$20
    lda #$00
    sta $0412 : sta $045F : sta $0402 : sta $046C : sta $0424 : sta $046A
    lda.l !CodexPage
    cmp #$02 : beq .item            ; v101: magic items right after the Thief's Log
    jsl $86E780                     ; v109: AllyOrder (options.asm): pages 3-10 in the order the allies first appear
    lda #$0A : sta $045E
    sta $0401               ; scene $0A: ally description
    jml $80814D
.item:
    lda #$0A : sta $045E
    lda #$0C : sta $0401    ; scene $0C: magic items
    jml $80814D

org $89F2C0
ResetScoresL:               ; v74: RESET SCORES in OPTION MODE: the Hall of Heroes table back to the defaults.  JSL from bank 86.
    php
    sep #$20
    rep #$10
    jsr HtDefault
    jsr HtWrite
    plp
    rtl

org $80F7D0
CodexType:                  ; M=8 X=8, replaces JSR $D722 in the ally scene loop.  In the CODEX, after A/B/X/Y: while the text is still being typed
    lda.l !CodexOn          ; ($06F4 = 0) run the routine six times per frame, each time forcing a character (the routine types one every 4th call)
    beq .n
    lda.l !FastOn
    beq .n
    lda $06F4
    bne .n
    ldx #$05
.l: lda #$03
    sta $06F6
    phx
    jsr $D722
    plx
    dex
    bpl .l
    rts
.n: jmp $D722

org $89F800                    ; v88: own block (the $89:C400 block has no room left before $89:F000)
; v88 easter egg: !Egg = 1 + ally type when the name is one of these, else 0.  M=8, X=16.
EggCheck:
    lda #$00 : sta.l !Egg : sta.l !EggT
    ldx #$0000                 ; X walks the name table
.ent:
    ldy #$0000                 ; Y = character 0-5
    lda #$00 : sta.l !EggBad
.ch:
    phx : tyx : lda.l !Name,x : plx
    cmp.l EggNames,x
    beq +
    lda #$01 : sta.l !EggBad
+   inx : iny : cpy #$0006 : bne .ch
    lda.l !EggBad : bne .next
    lda.l !EggT : inc a : sta.l !Egg
    rts
.next:
    lda.l !EggT : inc a : sta.l !EggT
    cmp #$08 : bne .ent
    rts
EggNames:                      ; by ally type 0-7
    db "AMAZON","BIGMAN","WIZARD","KNIGHT","LIZARD","NINJA ","THIEF ","CLERIC"

; v88: starting-ally pick on a later start floor ($00:838C, orig LDA $07F000,X: the type from the floor/door-counter table).  M=8, X=16.
EggAlly:
    jsr EggGet
    beq .norm
    dec a                      ; the named type, used once
    bra .out
.norm:
    lda.l $07F000,x
.out:
    rep #$20
    and #$00FF                 ; Y = type (16-bit), ally id = type * 3 + 3, as the original code
    tay
    sep #$20
    sta.l !EggT                ; ($13E0 holds floor * 8 for the level lookup that follows)
    asl
    clc
    adc.l !EggT
    clc
    adc #$03
    sta $0424
    rtl

; A = the active slot's easter-egg ally (1-8), or 0 (Z set).  It applies on the run's first floor only, including a resume of
; that floor (the save snapshot is taken before the ally is picked, so a resume picks again).  M=8; X kept.
EggGet:
    phx
    php
    rep #$30
    lda.w $04A5                ; !Slot: 1-3, 0 = no slot
    and #$00FF
    beq .none
    cmp #$0004
    bcs .none
    xba
    tax
    sep #$20
    lda.l $7000BC,x
    beq .none8
    cmp #$09
    bcs .clr
    lda.l $7000BD,x
    cmp #$FF
    bne +
    lda $0403                  ; first floor of the run starts now
    sta.l $7000BD,x
    bra .yes
+   cmp $0403
    bne .clr                   ; a later floor: the egg is spent
.yes:
    lda.l $7000BC,x
    plp
    plx
    cmp #$00
    rts
.clr:
    lda #$00
    sta.l $7000BC,x
.none:
    sep #$20
.none8:
    plp
    plx
    lda #$00
    rts

; v88: floor start with no ally and no start-floor ally pending (a new game from the BEGINNING): give the named ally,
; at the floor's normal level for it (level table $07:F1B0, as the game does for a start-floor ally).  Called with M=8.
EggFloor:
    sep #$30
    lda $0424
    bne .x                     ; already has an ally
    lda $045F
    bne .x                     ; later start floor: the game picks its ally, EggAlly swaps the type
    jsr EggGet
    beq .x
    dec a
    sta.l !EggT                ; type 0-7
    rep #$30
    lda $0403
    and #$003F
    asl : asl : asl
    sta $13E0
    lda.l !EggT
    and #$00FF
    clc
    adc $13E0
    tax
    sep #$20
    lda.l $07F1B0,x            ; level - 1
    pha
    lda.l !EggT
    tay
    pla
    sta $0413,y
    sta $0412
    lda.l !EggT
    sta $13E0
    asl
    clc
    adc $13E0
    clc
    adc #$03
    sta $0424                  ; ally id = type * 3 + 3
.x:
    sep #$30
    lda $0424
    rtl

; v88: easter egg hooks
org $008351
    jsl EggFloor               ; orig SEP #$30 / LDA $0424 (then BNE: spawn the ally in $0424)
    nop
org $00838C
    jsl EggAlly                ; orig LDA $07F000,X / TAY / ASL / CLC / ADC $07F000,X / CLC / ADC #$03 / STA $0424 (to $839C)
    nop #13

incsrc "logpage.asm"          ; v90: THIEF'S LOG page

; v111: fixed entry to RecordBest for options.asm (EndRec): JSL $82FB00 ($82:FB00-$FB7F was free)
org $82FB00
    jml RecordBest
