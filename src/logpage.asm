; ======================= v90: THIEF'S LOG (CODEX page 1) =======================
; Included from slot.asm (bank 89, uses its helpers: Clear, Upload, TextPal, OamUp, SndTick, HiGfx, %call).
; One framed strip per floor (5 on screen), drawn from the floor object lists in ROM:
;   ally heads (cell doors), hidden chests (class $42 with +$0B bit 1), hidden warp doors (class $0156 -> the star),
;   the exit door (class $4E), a start arrow, and the boss's name on boss floors.
; Floors appear once the Thief has finished them (SRAM $70:0500, see thieflog.asm); others show "???".
; UP / DOWN scroll the floors, LEFT / RIGHT scroll along them (at the left / right edge they turn the CODEX page), START: title.
;
; VRAM: BG3 font $0000 (map $5C00, the shared shadow), BG1 strip tiles $2000 (map $4000), BG2 star field $3000 (map $5800),
; sprites $6000 (OBSEL $63: 16x16).  Positions: strip tile u = trigger / 7 + 1 (the record's word 0 & $3FFF).

!LgBg   = $7FF000           ; BG1 tilemap shadow, 32x32 words
!LgV    = $7FF800           ; variables
!LgTop  = !LgV+0            ; first floor on screen
!LgX    = !LgV+1            ; horizontal offset (tiles)
!LgDone = !LgV+2            ; 0 run, 1 title, 2 next page, 3 previous page
!LgMax  = !LgV+3            ; longest strip on screen (tiles)
!LgK    = !LgV+4            ; strip 0-4
!LgFl   = !LgV+5            ; its floor
!LgLt   = !LgV+6            ; its length (tiles)
!LgRow  = !LgV+7            ; its top row
!LgRev  = !LgV+8            ; 1 = the floor runs right to left
!LgDim  = !LgV+9            ; 1 = not mapped
!LgOam  = !LgV+10           ; word: next OAM offset
!LgLast = !LgV+12           ; word: u of the last icon placed ($8000 none)
!LgLmax = !LgV+14           ; word: largest position
!LgExit = !LgV+16           ; word: exit position ($FFFF none)
!LgU    = !LgV+18           ; word scratch
!LgIc   = !LgV+20           ; icon code
!LgDirty = !LgV+21          ; 1 = shadows changed: upload BG1 + BG3
!LgHeld = !LgV+22           ; word: frames a direction has been held
!LgCnt  = !LgV+24           ; word scratch
!LgTo   = !LgV+26           ; LogText: row below the strip's top row
!LgSel  = !LgV+27           ; selected list entry (floor - 1)
!LgXs   = !LgV+28           ; horizontal offset of the strip being drawn (!LgX on the selected one, else 0)
!LgOn   = !LgV+29           ; 1 = the strip being drawn is the selected one
!LgDest = !LgV+30           ; warp destination floor
!LgW    = !LgV+31           ; tiles the next icon takes
!LgOcc  = !LgV+32           ; 8 bytes: strip tiles taken (one bit each, 64 tiles)
!LgEnd  = !LgV+40           ; last strip tile an icon takes
!LgLp   = !LgV+41           ; v98: 6 = the strip being drawn is a looping floor in the log (loop end caps, tiles 10-15), else 0
!LgPz   = !LgV+42           ; v99: 1 = the pause view (in play), 0 = the CODEX page
!LgCur  = !LgV+43           ; v99: pause view: the floor being played (1-50; 0 = none: no screen box)
!LgBx   = !LgV+44           ; v99: word: pause view: the screen box's left edge in strip pixels (u = 0 at 0)
!LgBU   = !LgV+46           ; v102: word: strip tile of the boss's B ($FFFF none yet)

!LvBuf  = $7E6000           ; v120: the floor being played, copied from the game's live list $7E:FA00 with an end mark (up to $7E:6FEF)
!LvMk   = $7E5FF0           ; v120: +0 that floor, +1 $A5 = !LvBuf is valid (both in $7E:2600-$6FFF, which the game never touches)
!LgQLen = 13                ; v97: a floor not in the log: strip length (odd, so "???" is centred)
!LgFloors = 50              ; floors 1-50 (list entry n = floor n + 1; no Thief on floor 0)
!Log     = $700500          ; the log record (thieflog.asm)
!LgAttrT = $2800            ; title / boss names: gold
!LgAttrN = $2400            ; floor numbers: white
!LgAttrQ = $2C00            ; "???": grey-blue

org $89B600
LogScene:                   ; M=8 X=16, screen off (from CodexEnter)
    sep #$20
    rep #$10
    lda #$00
    sta.l !LgTop : sta.l !LgX : sta.l !LgDone : sta.l !LgSel
    sta.l !LgPz : sta.l !LgCur
    rep #$20 : lda #$0000 : sta.l !LgHeld : sep #$20
    %call($E3CB)            ; font (BG3 chars at $0000)
    sep #$20
    rep #$10
    jsr TextPal
    jsr HiGfx               ; BG2 star field, OBSEL $63 (also loads the Hall's portraits: replaced below)
    jsr LogGfx
    jsr LogClrRows
    lda #$15 : sta $212C    ; BG1, BG3, sprites (no star field: a plain black background)
    stz $212D
    stz $2130 : stz $2131
    lda #$40 : sta $2107    ; BG1 map $4000, 32x32
    lda #$58 : sta $2108    ; BG2 map $5800
    lda #$5C : sta $2109    ; BG3 map $5C00
    lda #$32 : sta $210B    ; BG1 chars $2000, BG2 chars $3000
    stz $210C               ; BG3 chars $0000
    ldx #$0000
-   stz $210D,x : stz $210D,x
    inx : cpx #$0008 : bne -
    stz $2121               ; backdrop: black
    stz $2122 : stz $2122
    jsr LogDraw
    jsr Upload
    jsr LogUpBg
    jsr OamUp
    lda #$09 : sta $2105
    %call($81C6)            ; start the fade-in
    lda.l !CodexCut : beq +
    lda #$0E : sta $1252    ; CODEX page change: the fade-in is one step from the end
    stz $124F
+   sep #$20
    rep #$10
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
    lda.l !LgDirty
    beq +
    jsr Upload
    jsr LogUpBg
    lda #$00 : sta.l !LgDirty
+   jsr OamUp
    jsr SndTick
    %call($89D5)            ; pads
    sep #$20
    rep #$10
    jsr LogInput
    lda #$01 : sta $1242
    lda.l !LgDone
    beq .loop
    lda.l !LgDone
    cmp #$01
    beq .title
    ; page turn: blank like CodexNav, then the next / previous page
    sep #$30
    lda #$80 : sta $2100
    lda #$00 : sta $4200
    stz $1253
    jsr LogRegs
    rep #$30
    lda.w #$0000
    tcd
    sep #$20
    lda #$01 : sta.l !CodexCut
    lda.l !LgDone
    cmp #$03 : beq .pv
    lda #$02 : bra .pg      ; -> the magic items page (v101)
.pv: lda #$00               ; -> the Hall of Heroes
.pg: sta.l !CodexPage
    rep #$10
    jml CodexEnter
.title:                     ; START: back to the title (as the Hall of Heroes does)
    %call($8257)
    %call($826F)
    sep #$20
    jsr LogRegs             ; after the fade: the page stays on screen until it is dark
    stz $2131
    stz $2130
    lda #$E0 : sta $2132
    lda #$FF : sta.l !LastSc
    stz !Slot
    stz !Resume
    lda #$02 : sta $0401
    stz $0402
    jml $80814D

; ---------- input ----------
; L / R: CODEX page (v96).  UP / DOWN: select a floor (the list follows).  LEFT / RIGHT: scroll the selected floor's strip.
LogInput:                   ; M=8 X=16
    lda.l !LgPz : beq .cdx
    lda $1246                       ; v99 pause view: START unpauses, SELECT goes back to the pause screen, no CODEX pages
    bit #$10 : beq +
    lda #$04 : sta.l !LgDone
    rts
+   bit #$20 : beq .dirs
    lda #$01 : sta.l !LgDone
    rts
.cdx:
    lda $1246
    bit #$10 : beq +
    lda #$01 : sta.l !LgDone        ; START
    rts
+   lda $1245
    bit #$20 : beq +
    lda #$03 : sta.l !LgDone        ; L
    rts
+   bit #$10 : beq +
    lda #$02 : sta.l !LgDone        ; R
    rts
+
.dirs:
    lda $1244 : and #$0F            ; held directions
    bne +
    rep #$20 : lda #$0000 : sta.l !LgHeld : sep #$20
    rts
+   and #$03 : beq .vert
    rep #$20                        ; LEFT / RIGHT: a tile now, then one every 2 frames after 8
    lda.l !LgHeld : inc a : sta.l !LgHeld
    cmp #$0001 : beq .act
    cmp #$0008 : bcc .no
    and #$0001 : beq .act
    bra .no
.vert:
    rep #$20                        ; UP / DOWN: repeat after 16 frames, then every 6
    lda.l !LgHeld : inc a : sta.l !LgHeld
    cmp #$0001 : beq .act
    cmp #$0010 : bcc .no
    sec : sbc #$0010
-   cmp #$0006 : bcc +
    sbc #$0006
    bra -
+   cmp #$0000 : beq .act
.no: sep #$20
    rts
.act:
    sep #$20
    lda $1244
    bit #$08 : bne .up
    bit #$04 : bne .down
    bit #$02 : bne .l
    bit #$01 : bne .r
    rts
.up:
    lda.l !LgSel : beq .x
    dec a : sta.l !LgSel
    cmp.l !LgTop : bcs .nx
    sta.l !LgTop
    bra .nx
.down:
    lda.l !LgSel : cmp #!LgFloors-1 : bcs .x
    inc a : sta.l !LgSel
    sec : sbc #$04
    bcc .nx
    cmp.l !LgTop : bcc .nx
    beq .nx
    sta.l !LgTop
.nx: lda #$00 : sta.l !LgX          ; a newly selected strip starts at its left end
    bra .redraw
.l: lda.l !LgX : beq .x
    dec a : sta.l !LgX
    bra .redraw
.r: lda.l !LgX : clc : adc #28
    cmp.l !LgMax : bcs .x
    lda.l !LgX : inc a : sta.l !LgX
.redraw:
    jsr LogDraw
.x: rts

; ---------- drawing ----------
LogDraw:                    ; rebuild the BG3 shadow, the BG1 shadow and the OAM image.  M=8 X=16
    php
    jsr Clear
    rep #$30
    ldx #$0000
    lda #$0000
-   sta.l !LgBg,x
    inx : inx : cpx #$0800 : bne -
    ldx #$0000              ; OAM: all off screen
-   lda #$F000 : sta.l !OamBuf2,x
    lda #$0000 : sta.l !OamBuf2+2,x
    inx : inx : inx : inx : cpx #$0200 : bne -
-   sta.l !OamBuf2,x : inx : inx : cpx #$0220 : bne -
    lda #$0000 : sta.l !LgOam
    lda.l !LgPz : and #$00FF : beq +
    lda #$0018 : sta.l !LgOam       ; v99 pause view: OAM slots 0-5 are the screen box's (on top of the icons)
+   sep #$20
    lda #$00 : sta.l !LgMax
    rep #$20                ; title in the big letters, like HALL OF HEROES (the big font has no apostrophe: a small one)
    lda.w #$2C00 : sta $0776
    ldx.w #LgTitle1 : ldy.w #1*32+5 : jsr PutBig
    ldx.w #LgTitle2 : ldy.w #1*32+16 : jsr PutBig
    rep #$20
    lda.w #$2C00 : sta $0776
    ldy.w #1*32+15
    sep #$20
    lda #$27 : jsr PutChr
    rep #$20
    sep #$20
    lda #$00 : sta.l !LgK
.strip:
    lda.l !LgK
    clc : adc.l !LgTop
    pha
    inc a
    sta.l !LgFl
    pla
    ldx #$0000
    cmp.l !LgSel : bne +
    inx
+   txa : sta.l !LgOn
    beq +
    lda.l !LgX
+   sta.l !LgXs
    lda.l !LgK              ; top row = 3 + 5k
    asl a : asl a : clc : adc.l !LgK : clc : adc #$04   ; v97: strips on rows 4, 9, 14, 19, 24 (3 rows each)
    sta.l !LgRow
    jsr LogStrip
    lda.l !LgK : inc a : sta.l !LgK
    cmp #$05 : bne .strip
    lda #$01 : sta.l !LgDirty
    plp
    rts

LogStrip:                   ; one floor.  M=8 X=16
    ; floor number (2 digits) in the strip's middle row, columns 1-2 (v114: column 0 can be in a CRT's overscan)
    rep #$20
    lda.w #$3000 : sta $0776        ; other floors: dim grey (text palette 4)
    sep #$20
    lda.l !LgOn : beq +
    rep #$20 : lda.w #!LgAttrN : sta $0776 : sep #$20   ; the selected floor: white
+   lda.l !LgRow : inc a
    rep #$20 : and #$00FF : asl a : asl a : asl a : asl a : asl a : inc a : tay : sep #$20
    lda.l !LgFl
    ldx #$0000
-   cmp #10 : bcc +
    sbc #10 : inx
    bra -
+   pha
    txa : clc : adc #$30 : jsr PutChr
    pla : clc : adc #$30 : jsr PutChr
    ; mapped?
    jsr LogMapped
    bcs .map
    lda #$01 : sta.l !LgDim
    lda #!LgQLen : sta.l !LgLt
    jsr LogFrame
    rep #$20
    lda.w #!LgAttrQ : sta $0776
    sep #$20
    rep #$20 : lda.w #(!LgQLen-3)/2 : sta.l !LgU : sep #$20   ; "???" in the middle
    lda #$01 : sta.l !LgTo
    ldx.w #LgQ : jsr LogText
    rts
.map:
    lda #$00 : sta.l !LgDim
    jsr LogScan
    jsr LogIcons
    lda.l !LgEnd            ; icons pushed past the end: the strip grows to hold them
    inc a
    cmp.l !LgLt : bcc +
    cmp #61 : bcc ++
    lda #61
++  sta.l !LgLt
+   jsr LogFrame
    jsr LogBoss
    jsr LogBox
    rts

LogMapped:                  ; C = 1 if floor !LgFl is in the log.  M=8 X=16
    lda.l !Log
    cmp #$7A : bne .no
    jsr LgCalc
    cmp.l !Log+8 : bne .no
    lda.l !LgFl
    rep #$20 : and #$00FF : pha : lsr a : lsr a : lsr a : tax : pla : and #$0007 : tay : sep #$20
    lda.l !Log+1,x
-   cpy #$0000 : beq +
    lsr a : dey
    bra -
+   lsr a                   ; bit -> carry
    rts
.no: clc
    rts

LogPtr:                     ; $00-$02 = the record list of floor !LgFl.  M=8 X=16
    lda.l !LgPz : beq LogRomPtr             ; v120: the pause view draws the floor being played from the live copy
    lda.l !LvMk+1 : cmp #$A5 : bne LogRomPtr ; (LiveList, built when the view opens), which has this run's door shuffle
    lda.l !LgFl : cmp.l !LvMk : bne LogRomPtr
    rep #$20 : lda.w #!LvBuf : sta $00 : sep #$20
    lda.b #!LvBuf>>16 : sta $02
    rts
LogRomPtr:                  ; $00-$02 = floor !LgFl's list in ROM
    rep #$20
    lda.l !LgFl : and #$00FF
    sta $0776 : asl a : clc : adc $0776 : tax
    lda.l $80B98A,x : sta $00
    sep #$20
    lda.l $80B98C,x : sta $02
    rts

LogScan:                    ; direction, largest position, exit, length.  M=8 X=16
    jsr LogPtr
    rep #$30
    ldy #$0000
    lda [$00],y : and #$3FFF : sta.l !LgU       ; first position
-   lda [$00],y : cmp #$FFFF : beq +
    tya : clc : adc #$0016 : tay
    bra -
+   tya : sec : sbc #$0016 : tay                ; last record
    sep #$20 : lda #$00 : sta.l !LgRev : rep #$20
    lda [$00],y : and #$3FFF
    cmp.l !LgU : bcs +
    sep #$20 : lda #$01 : sta.l !LgRev : rep #$20   ; the floor runs right to left
+   jsr LogStart : clc : adc #$0020 : sta.l !LgLmax  ; v122: the start screen's right edge is on the strip
    lda #$FFFF : sta.l !LgExit
    ldy #$0000
.l: lda [$00],y
    cmp #$FFFF : beq .e
    jsr LogX : sta.l !LgCnt                     ; v122: where the object really is (was the record's trigger position)
    cmp.l !LgLmax : bcc +
    sta.l !LgLmax
+   iny : iny : iny : iny : iny : iny
    lda [$00],y
    dey : dey : dey : dey : dey : dey
    cmp #$004E : bne +
    lda.l !LgCnt : sta.l !LgExit
+   tya : clc : adc #$0016 : tay
    bra .l
.e: lda.l !LgLmax : jsr Div7
    clc : adc #$0004
    cmp.w #64-3 : bcc +
    lda.w #64-3
+   sep #$20
    sta.l !LgLt
    rts

Div7:                       ; A (16-bit) = A / 7.  M=16
    sta $4204
    sep #$20
    lda #$07 : sta $4206
    nop : nop : nop : nop : nop : nop : nop : nop
    rep #$20
    lda $4214
    rts

LogFrame:                   ; the strip's frame tiles in BG1, u = 0 .. Lt-1.  M=8 X=16
    jsr LogLoop
    lda.l !LgOn : beq +
    lda.l !LgLt : sta.l !LgMax      ; R scrolls the selected strip up to its end
+   rep #$30
    lda.l !LgXs : and #$00FF : sta.l !LgU   ; only the columns on screen (v96: faster redraws)
.u: lda.l !LgU
    jsr LogCol              ; A = screen column or carry clear
    bcc .nx
    sta.l !LgCnt            ; column
    lda.l !LgRow : and #$00FF : asl a : asl a : asl a : asl a : asl a
    clc : adc.l !LgCnt : asl a : tax          ; shadow offset of the top tile
    lda.l !LgU : beq .left
    inc a
    sep #$20 : cmp.l !LgLt : rep #$20
    beq .right
    lda #$0001 : jsr .put
    lda #$0002 : jsr .put
    lda #$0003 : jsr .put
    bra .nx
.left: lda #$0004 : bra .cap
.right: lda #$0007
.cap:                       ; v98: A = the cap's top tile; a looping floor uses its own caps (+6)
    sta.l !LgCnt
    lda.l !LgLp : and #$00FF : clc : adc.l !LgCnt : sta.l !LgCnt : jsr .put
    lda.l !LgCnt : inc a : sta.l !LgCnt : jsr .put
    lda.l !LgCnt : inc a : jsr .put
.nx: lda.l !LgU : inc a : sta.l !LgU
    sec : sbc $077C : cmp.w #28 : bcs .done   ; past the right edge of the screen
    lda.l !LgU
    sep #$20 : cmp.l !LgLt : rep #$20
    bcs .done
    jmp .u
.done:
    sep #$20
    rts
.put:                       ; A = tile, X = shadow offset; next row
    ora #$1800              ; BG palette 6: a floor in the log
    pha
    lda.l !LgOn : and #$00FF : beq +
    pla : and #$E3FF : ora #$1000 : pha    ; palette 4: the selected floor (bright)
    bra ++
+   lda.l !LgDim : and #$00FF : beq ++
    pla : and #$E3FF : ora #$1400 : pha    ; palette 5: not in the log
++  pla
    sta.l !LgBg,x
    txa : clc : adc #$0040 : tax
    rts

LogCol:                     ; A (16-bit) = u -> A = screen column 4..31, C = 1 if on screen (v114: was 3..31).  M=16
    pha
    lda.l !LgXs : and #$00FF : sta $077C
    pla
    sec : sbc $077C
    bmi .no
    cmp.w #28 : bcs .no
    clc : adc #$0004
    sec
    rts
.no: clc
    rts

LogIcons:                   ; start arrow, then every ally / hidden chest / warp / exit in list order.  M=8 X=16
    rep #$20
    lda #$8000 : sta.l !LgLast
    sep #$20 : lda #$00 : sta.l !LgEnd : rep #$20
    lda #$0000 : sta.l !LgOcc : sta.l !LgOcc+2 : sta.l !LgOcc+4 : sta.l !LgOcc+6
    sep #$20
    lda.l !LgRev : bne +
    rep #$20 : lda #$0001 : bra .st
+   rep #$20 : lda.l !LgLt : and #$00FF : sec : sbc #$0003
.st: sta.l !LgU
    sep #$20
    lda #$03 : sta.l !LgW
    lda #11 : jsr LogPut    ; start
    jsr LogPtr
    rep #$30
    ldy #$0000
.l: lda [$00],y
    cmp #$FFFF : bne +
    sep #$20
    rts
+   jsr LogX : jsr Div7 : inc a : sta.l !LgU   ; v122: the object's real tile
    phy
    tya : clc : adc #$0006 : tay
    lda [$00],y : sta.l !LgCnt                 ; class
    tya : clc : adc #$0005 : tay
    lda [$00],y : and #$00FF                   ; +$0B: contents / flags
    ply
    sta $0778
    lda.l !LgCnt
    cmp #$0021 : beq .door
    cmp #$0042 : beq .chest
    cmp #$0156 : beq .warp
    cmp #$004E : beq .exit
    jsr LogBossRec          ; v102: the boss's B
    bra .nx
.door:                      ; ally ids 3,6,..,24 -> head 0-7
    lda $0778
    cmp #$0003 : bcc .nx
    cmp #$0019 : bcs .nx
    sta $4204
    sep #$20
    lda #$03 : sta $4206
    nop : nop : nop : nop : nop : nop : nop : nop
    lda $4216 : bne .nx8   ; not a multiple of 3
    lda $4214 : dec a
    bra .put
.chest:
    lda $0778 : and #$0002 : beq .nx
    sep #$20 : lda #9 : bra .put
.warp:                      ; the star, then the floor the door leads to (record +$0E is that floor - 1)
    phy
    tya : clc : adc #$000E : tay
    lda [$00],y : and #$00FF : inc a : sta.l !LgCnt
    ply
    sep #$20
    lda.l !LgCnt : sta.l !LgDest
    lda #$05 : sta.l !LgW   ; star + 2 digits + a gap
    lda #8
    phy
    jsr LogPut
    lda #$03 : sta.l !LgW
    jsr LogDestNum
    rep #$30
    ply
    jmp .nx
.exit:
    sep #$20 : lda #10
.put:
    phy
    jsr LogPut
    rep #$30
    ply
.nx: rep #$30
    tya : clc : adc #$0016 : tay
    jmp .l
.nx8: rep #$30
    bra .nx

LogText:                    ; X = string (bank 89), at strip tile !LgU, row !LgRow + !LgTo, clipped.  M=8 X=16
-   sep #$20
    lda.l StrBank,x
    beq +
    jsr LogCh
    inx
    bra -
+   rts

LogCh:                      ; A (8-bit) = character at strip tile !LgU, row !LgRow + !LgTo (if on screen); !LgU + 1.  Keeps X.
    pha
    rep #$20
    lda.l !LgU : jsr LogCol
    bcc .sk
    sta.l !LgCnt
    lda.l !LgRow : clc : adc.l !LgTo : and #$00FF
    asl a : asl a : asl a : asl a : asl a : clc : adc.l !LgCnt : tay
    sep #$20
    pla
    jsr PutChr
    bra .n
.sk: sep #$20
    pla
.n: rep #$20
    lda.l !LgU : inc a : sta.l !LgU
    sep #$20
    rts

LogDestNum:                 ; the warp's destination floor, 2 digits right of the star just placed.  M=8 X=16
    rep #$20
    lda.l !LgLast : inc a : inc a : sta.l !LgU
    lda.w #!LgAttrN : sta $0776
    sep #$20
    lda #$01 : sta.l !LgTo                  ; the strip's middle row
    lda.l !LgDest
    ldx #$0000
-   cmp #10 : bcc +
    sbc #10 : inx
    bra -
+   pha
    txa : clc : adc #$30 : jsr LogCh
    pla : clc : adc #$30 : jsr LogCh
    rts

; ---------- VRAM ----------
assert pc() <= $89C000      ; $89:C000 holds the ally description text (text.asm)
org $89AA00                 ; graphics set-up, tables and strings (free space $89:A995-$AFFF)
LogUpBg:                    ; BG1 shadow -> VRAM $4000 (vblank or screen off)
    php
    sep #$20
    rep #$10
    lda #$80 : sta $2115
    ldx #$4000
    lda.l !LgPz : beq +
    ldx #$5000              ; v99 pause view: the game's own BG1 map (first 32x32 screen)
+   stx $2116
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    ldx.w #!LgBg : stx $4372
    lda.b #!LgBg>>16 : sta $4374
    ldx #$0700 : stx $4375
    lda #$80 : sta $420B
    plp
    rts

LogRegs:                    ; the game's defaults ($00:8B12): BG1 map $5000 64x32, BG1 chars $1000 (the Hall's tower relies on them)
    php
    sep #$20
    lda #$51 : sta $2107
    lda #$31 : sta $210B
    plp
    rts

LogClrRows:                 ; BG3 and BG1 map rows 28-31: the shadows only cover rows 0-27 (VOFS 0 shows a line of row 28)
    lda #$80 : sta $2115
    ldx #$5C00+(28*32) : stx $2116
    ldx.w #ZeroW : lda.b #ZeroW>>16 : ldy #$0100 : jsr LogGfx_dma0
    ldx #$4000+(28*32)
    lda.l !LgPz : beq +
    ldx #$5000+(28*32)
+   stx $2116
    ldx.w #ZeroW : lda.b #ZeroW>>16 : ldy #$0100 : jsr LogGfx_dma0
    rts

LogGfx:                     ; screen off: strip tiles, icon sprites, palettes.  M=8 X=16
    lda #$80 : sta $2115
    ldx #$2000
    lda.l !LgPz : beq +
    ldx #$1000              ; v99 pause view: tiles 0-15 of the game's BG1 character area
+   stx $2116
    ldx.w #LogBgGfx : lda.b #LogBgGfx>>16 : ldy.w #LogBgGfxEnd-LogBgGfx : jsr .dma
    ; icon k: top half -> sprite tile (k&7)*2 + (k>>3)*32, bottom half 16 tiles further
    lda #$00
.i: pha
    rep #$20
    and #$00FF
    pha
    and #$0007 : asl a : sta $0778
    lda $01,s : and #$0008 : asl a : asl a : clc : adc $0778     ; tile
    asl a : asl a : asl a : asl a : clc : adc #$6000 : sta $0778 ; VRAM word
    pla : xba : lsr a : clc : adc.w #LogObjGfx : sta $077A      ; source = + 128k
    sep #$20
    ldx $0778 : stx $2116
    ldx $077A : lda.b #LogObjGfx>>16 : ldy #$0040 : jsr .dma
    rep #$20
    lda $0778 : clc : adc #$0100 : tax
    lda $077A : clc : adc #$0040 : sta $077A
    sep #$20
    stx $2116
    ldx $077A : lda.b #LogObjGfx>>16 : ldy #$0040 : jsr .dma
    pla : inc a : cmp #14 : bne .i      ; v99: + the screen box's corner and edge (tiles $28 / $2A)
    ; palettes: OBJ 0-2 (the game's), OBJ 3 (chest / door / start), OBJ 7 (the hidden door's), BG 4-5 (strips)
    lda #$80 : sta $2121
    ldx #$0000
-   lda.l LogPal,x : sta $2122
    inx : cpx #$0080 : bne -
    lda #$F0 : sta $2121
-   lda.l LogPal,x : sta $2122
    inx : cpx #$00A0 : bne -
    lda #$40 : sta $2121
-   lda.l LogPal,x : sta $2122
    inx : cpx #$0100 : bne -
    lda #$10 : sta $2121    ; BG3 text palette 4: dim grey (floor numbers that aren't selected)
    ldx #$0000
-   lda.l LgDimTxt,x : sta $2122
    inx : cpx #$0008 : bne -
    rts
.dma:                       ; X = source address, A = bank, Y = bytes (to $2118)
    sta $4374
    stx $4372
    sty $4375
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    lda #$80 : sta $420B
    rts
LogGfx_dma0:                ; the same with a fixed source (fill)
    sta $4374
    stx $4372
    sty $4375
    lda #$09 : sta $4370
    lda #$18 : sta $4371
    lda #$80 : sta $420B
    rts


LgDimTxt: dw $0000, $1063, $356B, $356B
LgIcTile: db $00,$02,$04,$06,$08,$0A,$0C,$0E, $20,$22,$24,$26
LgIcAttr: db $30,$30,$34,$34,$30,$34,$30,$30, $3E,$36,$36,$36   ; priority 3; palettes 0/2 (heads), 7 (star), 3 (ours)
LgLoopFl: db 9, 19, 22, 33, $FF     ; v98: floors whose ends join (walking off one end comes back in at the other)
LgBossFl:
    db 0 : dw LgB0
    db 4 : dw LgB4
    db 12 : dw LgB12
    db 24 : dw LgB24
    db 29 : dw LgB29
    db 36 : dw LgB36
    db 49 : dw LgB49
    db 50 : dw LgB50
    db $FF
LgB0:  db "CHIMERA",0
LgB4:  db "GOLD DRAGON",0
LgB12: db "SKULL CHIMERA",0
LgB24: db "CELESTIAL SERPENTS",0
LgB29: db "EMERALD DRAGON",0
LgB36: db "HYDRA",0
LgB49: db "QUEEN CHIMERA",0
LgB50: db "LORD DROKMAR",0
LgTitle1: db "THIEF",0
LgTitle2: db "S LOG",0
LgHint1: db "LEFT OR RIGHT TO SCROLL",0
LgQ:   db "???",0

LgCalc:                     ; A = (sum of the log's 7 bytes) xor $A5.  M=8 X=16
    phx
    ldx #$0000
    lda #$00
    clc
-   adc.l !Log+1,x
    inx
    cpx #$0007
    bne -
    eor #$A5
    plx
    rts

assert pc() <= $89B000
org $96C000
LogObjGfx: incbin "log_obj.bin"     ; 14 icons x 128 bytes: heads (type 0-7), star, chest, exit door, start arrow, box corner, box edge
LogBgGfx: incbin "log_bg.bin"       ; strip tiles 0-11
LogBgGfxEnd:
LogPal: incbin "log_pal.bin"        ; OBJ 0-2, OBJ 3, OBJ 7, BG 4, BG 5

; ======================= v99: the Thief's Log in the pause screen =======================
; While the game is paused, SELECT opens the log at the floor being played (list starting there), with a gold box over
; the strip where the screen is.  SELECT goes back to the pause screen, START unpauses.  Same drawing code as the CODEX
; page (!LgPz = 1 picks the in-play VRAM spots).  Everything the view borrows is copied to WRAM $7E:2600-$6FFF first
; (never touched by the game on any floor: PAUSE_LOG_NOTES.md) and put back on the way out:
;   WRAM $7F:E000-$F82F (our shadows, OAM image, variables: game data in play), $00-$0F, $0776-$0787, $04A7-$04A8,
;   $1302-$1303 (BG1 HOFS shadow), $0ED2 (HDMA on/off); CGRAM (all); VRAM BG3 map $5C00-$5FFF, BG1 map $5000-$53FF,
;   BG1 tiles 0-15 ($1000-$10FF), OBJ tiles 0-63 ($6000-$63FF).
; Registers: the view sets all BG scrolls to 0, $212C = $15 (BG2 off), $420C = 0; on the way out $212C = $17, BG1/BG2 VOFS and
; BG3 scroll 0 (the game's values in play), BG1/BG2 HOFS and $420C come back from the NMI (shadows restored).
; The game's BG3 font has the menu font's letters, digits and big title letters at the same tiles (checked), so no font upload.

!PzW  = $7E2600             ; $7F:E000-$F82F ($1830 bytes)
!PzC  = $7E3E30             ; CGRAM ($200)
!PzB3 = $7E4030             ; VRAM $5C00-$5FFF ($800)
!PzB1 = $7E4830             ; VRAM $5000-$53FF ($800)
!PzT1 = $7E5030             ; VRAM $1000-$10FF ($200)
!PzO  = $7E5230             ; VRAM $6000-$63FF ($800)
!PzS  = $7E5A30             ; small WRAM pieces ($27)

org $008A31
    jml PauseHook           ; orig LDA $0430 / BNE $8A45 (then: START newly pressed -> toggle $1298)

org $89FA00
PauseHook:                  ; M=8 (both callers)
    jsl $86D7C0             ; v100: ThiefSeenL (thieflog.asm): the Thief on this floor puts it in the log
    lda $0430 : bne .no
    lda $1298 : beq .orig
    lda $1246 : and #$20 : beq .orig    ; paused + SELECT
    jsl LogPauseL
    cmp #$04 : bne .no
    stz $1298                           ; START in the view: unpause
.no: jml $808A45
.orig:
    lda $1246 : and #$10 : beq .no
    jml $808A3D

macro vrd(vaddr, dest, size)
    ldx.w #<vaddr> : stx $2116
    lda $2139 : lda $213A   ; one dummy word: a read reloads the buffer from the address before it steps (hardware, Snes9x, bsnes alike)
    ldx.w #<dest> : stx $4372
    lda.b #<dest>>>16 : sta $4374
    ldx.w #<size> : stx $4375
    lda #$81 : sta $4370    ; B -> A, two registers ($2139/$213A)
    lda #$39 : sta $4371
    lda #$80 : sta $420B
endmacro
macro vwr(vaddr, src, size)
    ldx.w #<vaddr> : stx $2116
    ldx.w #<src> : stx $4372
    lda.b #<src>>>16 : sta $4374
    ldx.w #<size> : stx $4375
    lda #$01 : sta $4370
    lda #$18 : sta $4371
    lda #$80 : sta $420B
endmacro

LogPauseL:                  ; JSL from PauseHook.  Returns A (8-bit) = 1 back to the pause screen, 4 unpause.
    php
    phb
    phd
    rep #$30
    lda #$0000 : tcd
    pea $8989 : plb : plb
    sep #$20
    lda #$80 : sta $2100
    stz $420C
    jsr LpSave
    stz $0ED2                           ; the NMI leaves HDMA off
    stz $420C                           ; (again: an NMI during the copy may have switched it back on)
    stz $1302 : stz $1303               ; and puts BG1 HOFS at 0
    lda #$01 : sta.l !LgPz
    lda #$00 : sta.l !LgDone : sta.l !LgX : sta.l !LgCur
    rep #$20 : lda #$0000 : sta.l !LgHeld : sep #$20
    lda $0403                           ; the floor being played: selected, at the top of the list
    beq .lo
    cmp #!LgFloors+1 : bcs .hi
    sta.l !LgCur
    bra .sel
.lo: lda #$01 : bra .sel
.hi: lda #!LgFloors
.sel:
    dec a : sta.l !LgSel
    cmp #!LgFloors-5 : bcc +
    lda #!LgFloors-5
+   sta.l !LgTop
    rep #$20                            ; screen box: left edge = scroll / 8 level tiles / 7 per strip tile + strip tile 1
    lda $132C : jsr Div7 : clc : adc #$0008 : sta.l !LgBx
    lsr a : lsr a : lsr a : sec : sbc #$000C   ; start the strip about 12 tiles left of the box
    bpl +
    lda #$0000
+   sep #$20
    sta.l !LgX
    ldx #$0000
-   stz $210D,x : stz $210D,x
    inx : cpx #$0008 : bne -
    lda #$15 : sta $212C                ; BG1, BG3, sprites
    jsr LiveList                        ; v120
    jsr TextPal
    jsr LogGfx
    jsr LogClrRows
    stz $2121 : stz $2122 : stz $2122   ; backdrop black
    jsr LogDraw
    lda.l !LgX : clc : adc #28          ; not past the strip's end
    cmp.l !LgMax : bcc +
    beq +
    lda.l !LgMax : sec : sbc #28 : bcs ++
    lda #$00
++  sta.l !LgX
    jsr LogDraw
+   jsr Upload
    jsr LogUpBg
    jsr OamUp
    lda #$00 : sta.l !LgDirty
    jsr LpWait
    lda #$0F : sta $2100
.loop:
    jsr LpWait
    lda.l !LgDirty : beq +
    jsr Upload
    jsr LogUpBg
    lda #$00 : sta.l !LgDirty
+   jsr OamUp
    %call($89D5)            ; pads
    sep #$20
    rep #$10
    jsr LogInput
    lda.l !LgDone : beq .loop
    pha                     ; (the variables go back to the game's data below)
    lda #$80 : sta $2100
    jsr LpRestore
    lda #$17 : sta $212C
    stz $210E : stz $210E
    stz $2110 : stz $2110
    stz $2111 : stz $2111
    stz $2112 : stz $2112
    lda $1302 : sta $210D : lda $1303 : sta $210D
    ldx #$0000              ; OAM: the game's own transfer, as set up for this frame (channel 2), copied to channel 7
-   lda $4320,x : sta $4370,x
    inx : cpx #$0007 : bne -
    stz $2102 : stz $2103
    lda #$80 : sta $420B
    lda #$80 : sta $2115
    jsr LpWait
    lda $1252 : beq +       ; the game's brightness: its fade-in stops with $1252 one step past the value it wrote ($0E)
    dec a
+   sta $2100
    pla
    pld
    plb
    plp
    rtl

LpWait:                     ; the next NMI (vblank starts)
    lda #$01 : sta $1242
-   lda $1242 : bne -
    rts

LpSave:                     ; M=8 X=16, D=0, DB=$89, screen off
    phb
    rep #$30
    lda.w #$182F : ldx.w #$E000 : ldy.w #$2600
    db $54,$7E,$7F          ; MVN $7F:E000.. -> $7E:2600..
    plb
    sep #$20
    ldx #$0000
-   lda $00,x : sta.l !PzS,x
    inx : cpx #$0010 : bne -
    ldx #$0000
-   lda $0776,x : sta.l !PzS+$10,x
    inx : cpx #$0012 : bne -
    lda $04A7 : sta.l !PzS+$22
    lda $04A8 : sta.l !PzS+$23
    lda $1302 : sta.l !PzS+$24
    lda $1303 : sta.l !PzS+$25
    lda $0ED2 : sta.l !PzS+$26
    lda #$80 : sta $2115
    %vrd($5C00, !PzB3, $0800)
    %vrd($5000, !PzB1, $0800)
    %vrd($1000, !PzT1, $0200)
    %vrd($6000, !PzO, $0800)
    stz $2121
    ldx.w #!PzC : stx $4372
    lda.b #!PzC>>16 : sta $4374
    ldx #$0200 : stx $4375
    lda #$80 : sta $4370    ; B -> A, one register
    lda #$3B : sta $4371
    lda #$80 : sta $420B
    rts

LpRestore:                  ; M=8 X=16, D=0, DB=$89, screen off
    lda #$80 : sta $2115
    %vwr($5C00, !PzB3, $0800)
    %vwr($5000, !PzB1, $0800)
    %vwr($1000, !PzT1, $0200)
    %vwr($6000, !PzO, $0800)
    stz $2121
    ldx.w #!PzC : stx $4372
    lda.b #!PzC>>16 : sta $4374
    ldx #$0200 : stx $4375
    lda #$00 : sta $4370
    lda #$22 : sta $4371
    lda #$80 : sta $420B
    ldx #$0000
-   lda.l !PzS,x : sta $00,x
    inx : cpx #$0010 : bne -
    ldx #$0000
-   lda.l !PzS+$10,x : sta $0776,x
    inx : cpx #$0012 : bne -
    lda.l !PzS+$22 : sta $04A7
    lda.l !PzS+$23 : sta $04A8
    lda.l !PzS+$24 : sta $1302
    lda.l !PzS+$25 : sta $1303
    lda.l !PzS+$26 : sta $0ED2
    phb
    rep #$30
    lda.w #$182F : ldx.w #$2600 : ldy.w #$E000
    db $54,$7F,$7E          ; MVN $7E:2600.. -> $7F:E000..
    plb
    sep #$20
    rts

LogBox:                     ; pause view: the gold screen box over the floor being played (OAM slots 0-5).  M=8 X=16
    lda.l !LgPz : beq .x
    lda.l !LgCur : beq .x
    cmp.l !LgFl : beq +
.x: rts
+   rep #$20
    lda.l !LgXs : and #$00FF : asl a : asl a : asl a : sta $0778
    lda.l !LgBx : clc : adc #$0020 : sec : sbc $0778 : sta $077A      ; screen x of its left edge (strip column 0 = 32 px)
    lda.l !LgRow : and #$00FF : asl a : asl a : asl a : sec : sbc #$0005 : sta $077C   ; OAM y: 4 px above the strip
    ldx #$0000
.p: lda.l LgBoxT,x : and #$00FF : clc : adc $077A
    bmi .n
    cmp #$0020 : bcc .n                 ; left of the strips (over the floor numbers): hidden
    cmp #$0100 : bcs .n
    sep #$20
    sta.l !OamBuf2,x
    lda.l LgBoxT+1,x : clc : adc $077C : sta.l !OamBuf2+1,x
    lda.l LgBoxT+2,x : sta.l !OamBuf2+2,x
    lda.l LgBoxT+3,x : sta.l !OamBuf2+3,x
    rep #$20
.n: inx : inx : inx : inx
    cpx #$0018 : bne .p
    sep #$20
    rts
LgBoxT:                     ; dx, dy, tile, attr (priority 3, palette 3, flips): 37 x 32 px from 3 x 2 16x16 pieces
    db 0,0,$28,$36,   10,0,$2A,$36,   21,0,$28,$76
    db 0,16,$28,$B6,  10,16,$2A,$B6,  21,16,$28,$F6
; moved here from the $89:B600 block (v99: room for the pause-view changes there)
LogLoop:                    ; v98: !LgLp = 6 if floor !LgFl loops and is in the log, else 0.  M=8 X=16
    lda #$00 : sta.l !LgLp
    lda.l !LgDim : bne .x
    phx
    ldx #$0000
-   lda.l LgLoopFl,x
    cmp #$FF : beq +
    inx
    cmp.l !LgFl : bne -
    lda #$06 : sta.l !LgLp
+   plx
.x: rts

LogBoss:                    ; the boss's name in the gap row above the strip, at its left end (v112; v103-v111 centred).  M=8 X=16
    lda.l !LgFl
    ldx #$0000
-   lda.l LgBossFl,x
    cmp #$FF : beq .no
    cmp.l !LgFl : beq .y
    inx : inx : inx
    bra -
.no: rts
.y: rep #$20
    lda.l LgBossFl+1,x : sta $0778          ; string
    ldx $0778 : jsr LogLen                  ; A = length
    sta.l !LgCnt
    lda #$FFFF : sta.l !LgBU
    lda #$0001                              ; v113: starts over the box (column 1; column 0 is the end orb)
    sta.l !LgU
.put:
    sep #$20 : lda #$FF : sta.l !LgTo : rep #$20     ; the gap row above the strip (row 27 holds the hint)
    lda.w #!LgAttrT : sta $0776
    sep #$20
    ldx $0778
    jmp LogText

LogLen:                     ; X = string (bank 89) -> A (16) = length.  M=16
    phx
    ldy #$0000
-   sep #$20
    lda.l StrBank,x
    rep #$20
    beq +
    inx : iny
    bra -
+   tya
    plx
    rts

assert pc() <= $8A0000
org $89F400                 ; v102: own block (free $89:F3D2-$F7FF; $89:F800 holds the easter egg)
; moved here from the $89:B600 block (v102)
; A (8-bit) = icon code 0-11 at strip tile !LgU (moved right to clear the last icon).  M=8 X=16
LogPut:                     ; !LgW = tiles it takes (icon + a gap): moved to the nearest free run of them (v123: to the left on a
    sta.l !LgIc             ; right-to-left floor, whose records come right to left, so the order on the strip stays right)
    rep #$20
    lda.l !LgU : sta $0786          ; where it belongs
    lda.l !LgRev : and #$00FF : sta $0784   ; 1 = look left first
.try:
    lda.l !LgU : sta $0780
    lda.l !LgW : and #$00FF : sta $077E
-   lda $0780 : jsr LogOcc : bcs .bump
    inc $0780 : dec $077E : bne -
    bra .free
.bump:
    lda $0784 : beq .right
    lda.l !LgU : dec a : beq .flip  ; (tile 0 is the end cap: no room on the left, look right instead)
    sta.l !LgU
    bra .try
.flip: stz $0784
    lda $0786 : sta.l !LgU
.right:
    lda.l !LgU : inc a : sta.l !LgU
    cmp #$003C : bcc .try           ; (past the longest strip: place it anyway)
.free:
    lda.l !LgU : sta $0780
    lda.l !LgW : and #$00FF : sta $077E
-   lda $0780 : jsr LogOcc
    sep #$20 : ora.l !LgOcc,x : sta.l !LgOcc,x : rep #$20
    inc $0780 : dec $077E : bne -
    lda.l !LgU : sta.l !LgLast
    clc : adc.l !LgW : and #$00FF : dec a
    sep #$20
    cmp.l !LgEnd : bcc +
    sta.l !LgEnd
+   rep #$20
    lda.l !LgIc : and #$00FF : cmp #$00FF : beq .off     ; v102: $FF = reserve the tiles only (the boss's B, drawn as text)
    lda.l !LgU
    jsr LogCol : bcc .off
    cmp.w #31 : bcs .off              ; 16 px wide: needs column + 1 on screen too
    asl a : asl a : asl a : sta.l !LgCnt     ; x
    lda.l !LgOam : cmp #$0200 : bcs .off
    tax
    sep #$20
    lda.l !LgCnt : sta.l !OamBuf2,x
    lda.l !LgRow : asl a : asl a : asl a : clc : adc #$03 : sta.l !OamBuf2+1,x   ; 4 px down into the strip (OAM y is one less)
    lda.l !LgIc : rep #$20 : and #$00FF : phx : tax
    lda.l LgIcTile,x : and #$00FF : sta $0778
    lda.l LgIcAttr,x : and #$00FF : sta $077A
    jsr LogFlip                         ; v122
    plx
    sep #$20
    lda $0778 : sta.l !OamBuf2+2,x
    lda $077A : sta.l !OamBuf2+3,x
    rep #$20
    txa : clc : adc #$0004 : sta.l !LgOam
.off: sep #$20
    rts

LogOcc:                     ; A (16-bit) = strip tile -> X = byte of !LgOcc, A (8-bit part) = its bit, C = 1 if taken.  M=16
    and #$003F
    pha
    lsr a : lsr a : lsr a : tax
    pla : and #$0007 : tay
    lda #$0001
-   cpy #$0000 : beq +
    asl a : dey
    bra -
+   pha
    sep #$20
    and.l !LgOcc,x
    rep #$20
    beq +
    pla
    sec
    rts
+   pla
    clc
    rts


LogBossRec:                 ; v102, from LogIcons: A (16) = the record's class, !LgU = its strip tile, Y = record.  M=16 X=16
    sta.l !LgCnt
    ldx #$0000
-   lda.l LgBossCl,x : and #$00FF
    cmp #$00FF : beq .x
    sep #$20 : cmp.l !LgFl : rep #$20 : beq +
    inx : inx : inx
    bra -
+   lda.l LgBossCl+1,x
    cmp.l !LgCnt : bne .x
    phy
    sep #$20
    lda #$02 : sta.l !LgW   ; the B and a gap
    lda #$FF : jsr LogPut
    lda #$03 : sta.l !LgW
    rep #$20
    lda.l !LgLast : sta.l !LgBU : sta.l !LgU
    lda.w #!LgAttrT : sta $0776
    sep #$20
    lda #$01 : sta.l !LgTo  ; the strip's middle row, like the warp numbers
    lda #'B' : jsr LogCh
    rep #$30
    ply
.x: rep #$30
    rts
LgBossCl:                   ; floor, the boss's object class (found in play: the object alive while the boss is on screen)
    db 4 : dw $00F9         ; Gold Dragon
    db 12 : dw $010B        ; Skull Chimera
    db 24 : dw $014A        ; Twin Worms
    db 29 : dw $00BA        ; Dragon
    db 36 : dw $0123        ; Hydra
    db 49 : dw $0174        ; Queen Chimera
    db 50 : dw $0186        ; Drokmar
    db $FF
; v120: the game shuffles some cell doors' contents (ally, trap, key) and some chests when a floor loads ($00:B597:
; records whose position word has bit 14/15 set; positions stay, record bytes 6-21 move).  Its live copy of the floor's
; list at $7E:FA00 has no end mark on that path, so copy it to !LvBuf, as long as the ROM list (same length), and add one.
; Every record's position bytes (0-5, word 0 without the flags) must match the ROM list, or the copy is not used.
LiveList:                   ; M=8 X=16, D=0
    lda #$00 : sta.l !LvMk+1
    lda.l !LgCur : beq .x
    sta.l !LgFl
    jsr LogRomPtr
    rep #$30
    ldy #$0000
.l: tyx
    lda [$00],y : cmp #$FFFF : beq .end
    and #$3FFF : cmp.l $7EFA00,x : bne .x
    iny : iny : lda [$00],y : cmp.l $7EFA02,x : bne .x
    iny : iny : lda [$00],y : cmp.l $7EFA04,x : bne .x
    lda.w #11 : sta $0776
-   lda.l $7EFA00,x : sta.l !LvBuf,x
    inx : inx : dec $0776 : bne -
    txy
    cpy.w #$0FD0 : bcs .x                  ; room for one more record and the end mark below $7E:6FF0
    bra .l
.end: lda #$FFFF : sta.l !LvBuf,x
    sep #$20
    lda.l !LgCur : sta.l !LvMk
    lda #$A5 : sta.l !LvMk+1
.x: sep #$20
    rep #$10
    rts

; v122: where a record's object really is, in level tiles (8 px).  The game makes an object when the screen's right
; edge (tile $1328 = scroll / 8 + 32) passes the record's position (word 0), at screen x = record +2 (signed px): about
; 250 for objects that come in from the right, about -40 on the floors that run right to left (10, 20), where they come
; in from the left.  Records within reach of the first screen are made at once, at the floor's start scroll.  So
;   tile = max(position - 32, start) + (record +2) / 8   (min on a right-to-left floor), at least 0.
; Only cell doors, chests and the exit use this.  Hidden warp doors are placed by their own position (their trigger zone is at
; word 0 x 8), and the boss's B marks where the boss starts (as checked in play): both unchanged.
; Checked against the live objects on floors 1, 18 and 20 (within a tile).
LogX:                       ; Y = record offset, $00-$02 = list.  A (16) = tile.  M=16 X=16; keeps X, Y
    phx
    phy
    iny : iny : iny : iny : iny : iny
    lda [$00],y
    cmp #$0021 : beq +                          ; only cell doors, chests and the exit; everything else (hidden warp
    cmp #$0042 : beq +                          ; doors, bosses, enemies) keeps its position
    cmp #$004E : beq +
    ply : phy
    lda [$00],y : and #$3FFF
    bra .x
+   dey : dey : dey : dey
    lda [$00],y : sta $0784                     ; screen x it is made at (signed)
    ply : phy
    lda [$00],y : and #$3FFF : clc : adc.w #$4000-$20 : sta $0782   ; position - 32 (+$4000: no sign)
    jsr LogStart : clc : adc #$4000             ; start tile (+$4000)
    tax
    lda.l !LgRev : and #$00FF : bne .rev
    txa : cmp $0782 : bcc .b                    ; right-running: max(position - 32, start)
    sta $0782
    bra .b
.rev: txa : cmp $0782 : bcs .b                  ; right to left: min
    sta $0782
.b: lda $0784 : cmp #$8000 : ror a : cmp #$8000 : ror a : cmp #$8000 : ror a
    clc : adc $0782 : sec : sbc #$4000
    bpl .x
    lda #$0000
.x: ply
    plx
    rts
LogFlip:                    ; v122: X = icon code; the start arrow (11) on a right-to-left floor points left (H flip in $077A).  M=16
    cpx #$000B : bne +
    lda.l !LgRev : and #$00FF : beq +
    lda $077A : ora #$0040 : sta $077A
+   rts
LogStart:                   ; A (16) = the floor !LgFl's start scroll in tiles (measured: each floor's $132C when it starts).  M=16
    phx
    lda.l !LgFl : and #$00FF : tax
    lda.l LgStartT,x : and #$00FF
    plx
    rts
LgStartT:                   ; floors 0-50 ($132C / 8)
    db 0, 0,32, 0, 0, 0, 0, 0, 0, 0,156, 0, 0, 0, 0, 0, 0, 0,46, 0,145
    db 0, 0, 0, 0, 0, 0, 0, 0,32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0,128, 0

assert pc() <= $89F800
