lorom
!IntroOn    = $7FE7D6       ; 1 from power-on until the title
!CodexMus = $7FE7A8          ; v83: CODEX MUSIC: 0 = NONE, 1-26 = Music Test number 00-25 plus one (default 6 = song 05)
!RstMode = $7FE7A2          ; v74: RESET SCORES row: 0 idle, 1 asking, 2 done
!RstSel  = $7FE7A9          ; v115: RESET CODEX choice: 0 CHOOSE, 1 HALL OF HEROES, 2 THIEF'S LOG, 3 EVERYTHING
!IntroLatch = $7FE7D7       ; START was seen during the intro (set in vblank, so a quick tap during a fade still counts)
; OPTION MODE (v68): rows are tightened so each label sits right above its value:
;   GAME LEVEL 6 / value 7, CONTROL PAD 9, ATTACK/JUMP/SPECIAL 10-12, MUSIC TEST 14 / 15, SOUND TEST 17 / 18, EXIT 20.
; CONTROL PAD > SPECIAL has 12 states: the six buttons (A B X Y L R), then the same six as "ONLY" (the Attack+Jump shortcut
; no longer fires the special action).  On the option screen the state is $13A6 (0-5 button, 6-11 button + ONLY); in the game
; the button stays in $0497 and the ONLY flag is $04A4 (0 = shortcut works, 1 = ONLY).  SRAM +6 stores $04A4 << 1 (see slot.asm).
; --- move every text entry of the option screen (static labels and all value/label draw lists, bank 07) ---
org $07CD05 : dw $5CCB
org $07CD09 : dw $5CCC
org $07CD0D : dw $5CCD
org $07CD11 : dw $5CCE
org $07CD15 : dw $5CD0
org $07CD19 : dw $5CD1
org $07CD1D : dw $5CD2
org $07CD21 : dw $5CD3
org $07CD25 : dw $5CD4
org $07CD29 : dw $5D2B
org $07CD2D : dw $5D2C
org $07CD31 : dw $5D2D
org $07CD35 : dw $5D2E
org $07CD39 : dw $5D2F
org $07CD3D : dw $5D30
org $07CD41 : dw $5D31
org $07CD45 : dw $5D33
org $07CD49 : dw $5D34
org $07CD4D : dw $5D35
org $07CD51 : dw $5E2B
org $07CD55 : dw $5E2C
org $07CD59 : dw $5E2D
org $07CD5D : dw $5E2E
org $07CD61 : dw $5E2F
org $07CD65 : dw $5E31
org $07CD69 : dw $5E32
org $07CD6D : dw $5E33
org $07CD71 : dw $5E34
org $07CD75 : dw $5E8B
org $07CD79 : dw $5E8C
org $07CD7D : dw $5E8D
org $07CD81 : dw $5E8E
org $07CD85 : dw $5E8F
org $07CD89 : dw $5E91
org $07CD8D : dw $5E92
org $07CD91 : dw $5E93
org $07CD95 : dw $5E94
org $07CDE7 : dw $5CED
org $07CDEB : dw $5CEE
org $07CDEF : dw $5CEF
org $07CDF3 : dw $5CF0
org $07CDF7 : dw $5CF1
org $07CDFB : dw $5CF2
org $07CE01 : dw $5CED
org $07CE05 : dw $5CEE
org $07CE09 : dw $5CEF
org $07CE0D : dw $5CF0
org $07CE11 : dw $5CF1
org $07CE15 : dw $5CF2
org $07CE1B : dw $5CED
org $07CE1F : dw $5CEE
org $07CE23 : dw $5CEF
org $07CE27 : dw $5CF0
org $07CE2B : dw $5CF1
org $07CE2F : dw $5CF2
org $07CE35 : dw $5CED
org $07CE39 : dw $5CEE
org $07CE3D : dw $5CEF
org $07CE41 : dw $5CF0
org $07CE45 : dw $5CF1
org $07CE49 : dw $5CF2
org $07CE4F : dw $5CED
org $07CE53 : dw $5CEE
org $07CE57 : dw $5CEF
org $07CE5B : dw $5CF0
org $07CE5F : dw $5CF1
org $07CE63 : dw $5CF2
org $07CE69 : dw $5CED
org $07CE6D : dw $5CEE
org $07CE71 : dw $5CEF
org $07CE75 : dw $5CF0
org $07CE79 : dw $5CF1
org $07CE7D : dw $5CF2
org $07CE83 : dw $5D4C
org $07CE87 : dw $5D4D
org $07CE8B : dw $5D4E
org $07CE8F : dw $5D4F
org $07CE93 : dw $5D50
org $07CE97 : dw $5D51
org $07CE9D : dw $5D4C
org $07CEA1 : dw $5D4D
org $07CEA5 : dw $5D4E
org $07CEA9 : dw $5D4F
org $07CEAD : dw $5D50
org $07CEB1 : dw $5D51
org $07CEB7 : dw $5D6C
org $07CEBB : dw $5D6D
org $07CEBF : dw $5D6E
org $07CEC3 : dw $5D6F
org $07CEC9 : dw $5D6C
org $07CECD : dw $5D6D
org $07CED1 : dw $5D6E
org $07CED5 : dw $5D6F
org $07CEDB : dw $5D8C
org $07CEDF : dw $5D8D
org $07CEE3 : dw $5D8E
org $07CEE7 : dw $5D8F
org $07CEEB : dw $5D90
org $07CEEF : dw $5D91
org $07CEF3 : dw $5D92
org $07CEF9 : dw $5D8C
org $07CEFD : dw $5D8D
org $07CF01 : dw $5D8E
org $07CF05 : dw $5D8F
org $07CF09 : dw $5D90
org $07CF0D : dw $5D91
org $07CF11 : dw $5D92
org $07CF17 : dw $5F4E
org $07CF1B : dw $5F4F
org $07CF1F : dw $5F50
org $07CF23 : dw $5F51
org $07CF29 : dw $5F4E
org $07CF2D : dw $5F4F
org $07CF31 : dw $5F50
org $07CF35 : dw $5F51
org $07CF5F : dw $5D55
org $07CF65 : dw $5D55
org $07CF6B : dw $5D55
org $07CF71 : dw $5D55
org $07CF77 : dw $5D55
org $07CF7D : dw $5D55
org $07CF83 : dw $5D55
org $07CF89 : dw $5D55
org $07CF8F : dw $5D55
org $07CF95 : dw $5D55
org $07CF9B : dw $5D55
org $07CFA1 : dw $5D55
org $07CFA7 : dw $5D75
org $07CFAD : dw $5D75
org $07CFB3 : dw $5D75
org $07CFB9 : dw $5D75
org $07CFBF : dw $5D75
org $07CFC5 : dw $5D75
org $07CFCB : dw $5D75
org $07CFD1 : dw $5D75
org $07CFD7 : dw $5D75
org $07CFDD : dw $5D75
org $07CFE3 : dw $5D75
org $07CFE9 : dw $5D75
org $07CFF5 : dw $5D95
org $07CFFB : dw $5D95
org $07D001 : dw $5D95
org $07D007 : dw $5D95
org $07D00D : dw $5D95
org $07D013 : dw $5D95
org $07D019 : dw $5D95
org $07D01F : dw $5D95
org $07D025 : dw $5D95
org $07D02B : dw $5D95
org $07D031 : dw $5D95
org $07D037 : dw $5D95
; music / sound test digits (immediates in $00:E525 / $00:E53E)
org $00E52E : dw $5E4F   ; was $5E4F
org $00E534 : dw $5E50   ; was $5E50
org $00E547 : dw $5EAF   ; was $5ECF
org $00E54D : dw $5EB0   ; was $5ED0

; --- v74: RESET SCORES is item 6, EXIT becomes item 7 (eight items) ---
org $80E4BC : jsr (OptTable,x)
org $80E4D1 : jsr (OptTable,x)
org $80E4E7 : jsr (OptTable,x)
org $00E1ED : cmp #$08          ; START on EXIT (v83: item 8; 6 = CODEX MUSIC, 7 = RESET SCORES)
org $00E22F : cmp #$08
org $00E23B : cmp #$08
org $00E24D : cmp #$08
org $00E256 : jml NavUp : nop     ; v84: UP/DOWN follow the on-screen order (CODEX MUSIC, item 6, sits between SPECIAL and MUSIC TEST)
org $00E263 : jml NavDown : nop
org $80E277 : jmp OptLeft : nop     ; orig CMP #$06 / BEQ $E22B
org $80E295 : jmp OptRight : nop
org $80E076 : jsr OptInitLast   ; orig STZ $13A1: draw the 8th item at screen setup too
org $00E1D3 : jml OptInput : nop  ; orig SEP #$30 / LDA $1246 (input handler of OPTION MODE)
org $00DFD4 : jml PowerOnHook : nop : nop   ; orig LDA #$02 / STA $0497 / RTL (power-on option defaults)

org $80F76C
PowerOnHook:
    lda #$02
    sta $0497
    lda #$00
    sta $04A4                   ; SPECIAL ACTION defaults to X OR Y+B
    sta.l !IntroLatch           ; v64: intro skip - nothing pressed yet
    lda #$01
    sta.l !IntroOn              ; the vblank check watches for START until the title
    jml $89F000                 ; LoadOptions (slot.asm): saved options from SRAM, if any; ends with RTL
OptTable: dw $E4FB,$E50A,$E513,$E51C,$E525,$E53E,OptMusDrawS,OptRstDrawS,$E59F
OptLeft:  jml OptLeftL          ; (bank 80 has little room here: the real code is in bank 86)
OptRight: jml OptRightL
OptMusDrawS:
    jsl OptMusDraw
    rts
OptRstDrawS:
    jsl OptRstDraw
    rts
OptInitLast:
    lda #$00
    sta.l !RstMode
    sta.l !RstSel               ; v115: RESET CODEX starts on CHOOSE every time (set before the row is drawn)
    inc $13A1
    jsr $E4E0                   ; item 7 (RESET CODEX)
    jsr $E5E6
    inc $13A1
    jsr $E4E0                   ; item 8 (EXIT)
    jsr $E5E6
    stz $13A1
    rts
assert pc() <= $80F7D0          ; $80:F7D0 = the CODEX ally-text stub (slot.asm), F800+ = message-box sprites
; ---- v64: START skips the intro (LICENSED BY NINTENDO + CAPCOM logo) ----
; Part 1 (Nintendo screen, 128-frame wait loop at $00:C163) and the CAPCOM fade-in ($00:C24E, a JSR from $00:C1D2) never read
; the pad; the CAPCOM hold loop at $00:C1DD already jumps to $00:C216 on any button.  Both hooks take the same exit:
; $00:C216 sets scene 2 (title), fades out and restarts the main loop at $00:814D.
org $00C168                 ; part 1, after the frame wait. orig: REP #$20 / INC $0460
    jml IntroSkip1
org $00C253                 ; CAPCOM fade-in, after the frame wait. orig: LDA $0460 / CMP #$3C
    jml IntroSkip2

org $86D300
IntroSkip1:                 ; M=8
    jsr IntroStart
    bcc +
    jml $80C216
+:
    rep #$20
    inc $0460
    jml $80C16D
IntroSkip2:                 ; M=8, inside JSR $C24E
    jsr IntroStart
    bcc +
    rep #$20
    pla                     ; drop the return address of JSR $C24E (same stack depth as the game's own skip)
    sep #$20
    jml $80C216
+:
    lda $0460
    cmp #$3C
    jml $80C258
; Carry set when START is down.  Also stores the pad in $1243/$1244 (as $80:88CA does), so the title sees START
; as already held and needs a fresh press.
IntroStart:
    lda.l !IntroLatch
    bne .yes
-:
    lda $4212
    and #$01
    bne -                   ; wait for the automatic joypad read
    lda $4218
    sta $1243
    lda $4219
    sta $1244
    and #$10
    cmp #$10
    rts
.yes:
    lda $4218               ; keep the title from reading a held START as a new press
    sta $1243
    lda $4219
    sta $1244
    sec
    rts

; Vblank: during the intro, remember a START press (the fades and the screen change do not read the pad).
NmiHook:
    php
    sep #$20
    pha
    lda.l !IntroOn
    beq +
    lda.l $004219
    and #$10
    beq +
    sta.l !IntroLatch
+:
    pla
    plp
    jml $808A46             ; the game's vblank handler (the vector's original target)

; Every way into the title passes here: stop watching.
IntroEnd:
    lda #$00
    sta.l !IntroOn
    sta.l !IntroLatch
    sta $0402               ; replaced: LDA #$00 / STA $0402
    jml $80C21B

org $00FFB1                 ; native vblank vector stub (orig: JML $808A46)
    jml NmiHook
org $00C216                 ; orig: LDA #$00 / STA $0402 (then scene 2, fade out, JMP $814D)
    jml IntroEnd

; ---- v68: CONTROL PAD > SPECIAL gets "ONLY" variants ----
; The game's "ally special action" test ($01:9694) fires when the SPECIAL button is newly pressed (it then fakes jump held +
; attack pressed) OR when ATTACK is pressed in the same frame as JUMP (the Y+B combo, $01:96DF).  With ONLY the second route is skipped.
; Replaces the 12 bytes at $01:96A4-96AF (LDA $1245 / AND $0466 / BNE / LDA $1246 / AND $0467 / BNE / BRA $96DF).
org $0196A4
    jml SpcCheck
    db $EA,$EA,$EA,$EA,$EA,$EA,$EA,$EA
; option screen: 12 states for item 3
org $00E6B9 : db $0C                    ; state count of item 3 (was 6)
org $00E02C                             ; orig LDA $0497 / STA $13A6 (screen setup)
    jsl SpcLoad : nop : nop
org $00E0D6                             ; orig LDA $13A6 / STA $0497 / ASL A / TAX (leaving the screen)
    jsl SpcSave : nop : nop : nop : nop
org $00E177                             ; orig: CLC / ADC $13A6 / CLC / ADC $13A6 / ASL (9 bytes); the code from $E180 on (TAX / table lookup / draw) is shared with the ATTACK and JUMP letters and stays
    jml SpcLetter
    db $EA,$EA,$EA,$EA,$EA
org $00E351                             ; orig STA $13A6 / RTS: pressing a button on the SPECIAL row keeps the ONLY mode
    jml SpcAssign
org $00E375                             ; duplicate-button check for SPECIAL, stepping up (ends at the RTS at $006398)
    jml SpcFixUp
org $00E3AB                             ; same, stepping down (ends at the RTS at $0063CA)
    jml SpcFixDown

org $86D600
SpcCheck:                       ; M = 8
    lda $1245 : and $0466 : bne .syn
    lda $1246 : and $0467 : bne .syn
    lda $04A4
    bne .no                     ; ONLY: no ATTACK-while-JUMP combo
    jml $0196DF
.no:
    jml $019720                 ; return 0 (no special action)
.syn:
    jml $0196BB
SpcLoad:                        ; M = X = 8
    lda $0497
    ldx $04A4
    beq .s
    clc
    adc #$06
.s: sta $13A6
    rtl
SpcSave:                        ; M = X = 8; returns A = button, X = button * 2, as the original code did
    lda $13A6
    ldx #$00
    cmp #$06
    bcc .s
    sbc #$06
    ldx #$01
.s: stx $04A4
    sta $0497
    asl a
    tax
    rtl
SpcLetter:                      ; A = $24 (normal) / $25 (highlighted); M = X = 8
    and #$01
    pha
    lda $13A6
    asl a
    clc
    adc $01,s
    sta $01,s
    pla
    asl a
    tax
    rep #$20
    lda.l SpcTab,x
    sta $1380
    jml $00E189                 ; continues with SEP #$20 / LDA #$07 / STA $1382 / JSR $E617
SpcAssign:                      ; A = pressed button 0-5, M = 8
    ldx $13A6
    cpx #$06
    bcc .s
    clc
    adc #$06
.s: sta $13A6
    jml $00E321                 ; an RTS
SpcFixUp:                       ; M = 8: step SPECIAL up until its button differs from ATTACK ($13A4) and JUMP ($13A5)
.l: lda $13A6
    cmp #$06
    bcc .b
    sbc #$06
.b: cmp $13A4
    beq .bump
    cmp $13A5
    beq .bump
    jml $00E398
.bump:
    lda $13A6
    inc a
    cmp #$0C
    bcc .w
    lda #$00
.w: sta $13A6
    bra .l
SpcFixDown:
.l: lda $13A6
    cmp #$06
    bcc .b
    sbc #$06
.b: cmp $13A4
    beq .bump
    cmp $13A5
    beq .bump
    jml $00E3CA
.bump:
    lda $13A6
    dec a
    bpl .w
    lda #$0B
.w: sta $13A6
    bra .l
SpcTab:                         ; (state * 2 + highlight) -> draw list in bank 07
    dw SpcL0, SpcL1, SpcL2, SpcL3, SpcL4, SpcL5, SpcL6, SpcL7, SpcL8, SpcL9, SpcL10, SpcL11, SpcL12, SpcL13, SpcL14, SpcL15, SpcL16, SpcL17, SpcL18, SpcL19, SpcL20, SpcL21, SpcL22, SpcL23

org $07D800
; SPECIAL row draw lists: 6 characters each at columns 21-26 of row 12 ("X" + blank + "ONLY" / blanks), normal ($30) and highlighted ($20)
SpcL0: dw $001A, $5D95, $30B2, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL1: dw $001A, $5D95, $20B2, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL2: dw $001A, $5D95, $30B3, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL3: dw $001A, $5D95, $20B3, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL4: dw $001A, $5D95, $30C9, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL5: dw $001A, $5D95, $20C9, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL6: dw $001A, $5D95, $30CA, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL7: dw $001A, $5D95, $20CA, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL8: dw $001A, $5D95, $30BD, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL9: dw $001A, $5D95, $20BD, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL10: dw $001A, $5D95, $30C3, $5D96, $3091, $5D97, $3091, $5D98, $3091, $5D99, $3091, $5D9A, $3091
SpcL11: dw $001A, $5D95, $20C3, $5D96, $2091, $5D97, $2091, $5D98, $2091, $5D99, $2091, $5D9A, $2091
SpcL12: dw $001A, $5D95, $30B2, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL13: dw $001A, $5D95, $20B2, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA
SpcL14: dw $001A, $5D95, $30B3, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL15: dw $001A, $5D95, $20B3, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA
SpcL16: dw $001A, $5D95, $30C9, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL17: dw $001A, $5D95, $20C9, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA
SpcL18: dw $001A, $5D95, $30CA, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL19: dw $001A, $5D95, $20CA, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA
SpcL20: dw $001A, $5D95, $30BD, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL21: dw $001A, $5D95, $20BD, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA
SpcL22: dw $001A, $5D95, $30C3, $5D96, $3091, $5D97, $30C0, $5D98, $30BF, $5D99, $30BD, $5D9A, $30CA
SpcL23: dw $001A, $5D95, $20C3, $5D96, $2091, $5D97, $20C0, $5D98, $20BF, $5D99, $20BD, $5D9A, $20CA

; ======================= v74/v75: RESET SCORES (OPTION MODE item 6) =======================
; Single step: with the cursor on the row, hold A, B, X and Y and press START; the Hall of Heroes table is cleared when START is released
; (the row then says DONE until the next button press).  Draw lists: label on row 20 (cols 9-22), value on row 21 (cols 6-25).
org $07DB00
RstL0: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $3091, $5F07, $3091, $5F08, $3091, $5F09, $3091, $5F0A, $3091, $5F0B, $3091, $5F0C, $3091, $5F0D, $3091, $5F0E, $3091, $5F0F, $3091, $5F10, $3091, $5F11, $3091, $5F12, $3091, $5F13, $3091, $5F14, $3091, $5F15, $3091, $5F16, $3091, $5F17, $3091, $5F18, $3091, $5F19, $3091
RstL1: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $20C1, $5F07, $20C3, $5F08, $20B6, $5F09, $20C4, $5F0A, $20C4, $5F0B, $2091, $5F0C, $20B2, $5F0D, $2091, $5F0E, $20B3, $5F0F, $2091, $5F10, $20C9, $5F11, $2091, $5F12, $20CA, $5F13, $2091, $5F14, $20C4, $5F15, $20C5, $5F16, $20B2, $5F17, $20C3, $5F18, $20C5, $5F19, $2091
RstL2: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $30C1, $5F07, $30C3, $5F08, $30B6, $5F09, $30C4, $5F0A, $30C4, $5F0B, $3091, $5F0C, $30B2, $5F0D, $3091, $5F0E, $30B3, $5F0F, $3091, $5F10, $30C9, $5F11, $3091, $5F12, $30CA, $5F13, $3091, $5F14, $30C4, $5F15, $30C5, $5F16, $30B2, $5F17, $30C3, $5F18, $30C5, $5F19, $3091
RstL3: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $20C1, $5F07, $20C3, $5F08, $20B6, $5F09, $20C4, $5F0A, $20C4, $5F0B, $2091, $5F0C, $20B2, $5F0D, $2091, $5F0E, $20B3, $5F0F, $2091, $5F10, $20C9, $5F11, $2091, $5F12, $20CA, $5F13, $2091, $5F14, $20C4, $5F15, $20C5, $5F16, $20B2, $5F17, $20C3, $5F18, $20C5, $5F19, $2091
RstL4: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $3091, $5F07, $3091, $5F08, $3091, $5F09, $3091, $5F0A, $3091, $5F0B, $3091, $5F0C, $3091, $5F0D, $3091, $5F0E, $30B5, $5F0F, $30C0, $5F10, $30BF, $5F11, $30B6, $5F12, $3091, $5F13, $3091, $5F14, $3091, $5F15, $3091, $5F16, $3091, $5F17, $3091, $5F18, $3091, $5F19, $3091
RstL5: dw $008A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30C4, $5EF1, $30B4, $5EF2, $30C0, $5EF3, $30C3, $5EF4, $30B6, $5EF5, $30C4, $5EF6, $3091, $5F06, $2091, $5F07, $2091, $5F08, $2091, $5F09, $2091, $5F0A, $2091, $5F0B, $2091, $5F0C, $2091, $5F0D, $2091, $5F0E, $20B5, $5F0F, $20C0, $5F10, $20BF, $5F11, $20B6, $5F12, $2091, $5F13, $2091, $5F14, $2091, $5F15, $2091, $5F16, $2091, $5F17, $2091, $5F18, $2091, $5F19, $2091

org $86EA00
RstLists: dw RstL0,RstL1,RstL2,RstL3,RstL4,RstL5
OptRstDraw:                     ; v115: RESET CODEX (RstDraw below); the v74 lists above are no longer used
    jml RstDraw
OptRstDrawOld:
    sep #$30
    lda.l !RstMode
    cmp #$03                    ; power-on RAM is random: the screen set-up draws this item before anything has initialised it
    bcc +
    lda #$00
    sta.l !RstMode
+   asl a
    clc
    adc $13A9
    asl a
    tax
    rep #$20
    lda.l RstLists,x
    sta $13AB
    stz $13AD
    sep #$20
    rtl
OptInput:                       ; M/X unknown on entry; replaces SEP #$30 / LDA $1246 at $00:E1D3
    sep #$30
    lda $13A1
    cmp #$07
    bne .norm
    lda.l !RstMode
    beq .idle
    cmp #$02
    beq .done
    lda $1244                   ; armed: wait until START is released (the cursor cannot move meanwhile)
    and #$10
    bne .out
    jsl RstDo                   ; v115: the chosen reset
    lda #$02
    sta.l !RstMode
    bra .redraw
.done:
    lda $1245
    ora $1246
    beq .out
    lda #$00
    sta.l !RstMode
    sta.l !RstSel               ; v115: back to CHOOSE
    lda #$08 : sta $13A2
    lda $1246 : and #$03        ; LEFT / RIGHT: go on from CHOOSE at once
    bne .norm
    bra .out
.idle:
    lda $1246                   ; START newly pressed with A B X Y held: armed
    and #$10
    beq .norm
    lda.l !RstSel               ; v115: only with something chosen
    beq .norm
    lda $1243
    and #$C0
    cmp #$C0
    bne .out
    lda $1244
    and #$C0
    cmp #$C0
    bne .out
    lda #$01
    sta.l !RstMode
    bra .out
.redraw:
    lda #$08                    ; "previous item" = EXIT forces the row to be redrawn
    sta $13A2
.out:
    jml $00E22B
.norm:
    lda $1246
    jml $00E1D8

; ---- v83: CODEX MUSIC (item 6): label rows 20 / value row 21; the label lists are in bank 07, the value list is built in WRAM at $138D
;      (like the Music Test's: [length][VRAM address, tile] x 4 = 4 cells, cols 14-17)
org $07DF00
MusLblN: dw $002E, $5DCA,$30B4, $5DCB,$30C0, $5DCC,$30B5, $5DCD,$30B6, $5DCE,$30C9, $5DCF,$3091, $5DD0,$30BE, $5DD1,$30C6, $5DD2,$30C4, $5DD3,$30BA, $5DD4,$30B4
MusLblH: dw $002E, $5DCA,$20B4, $5DCB,$20C0, $5DCC,$20B5, $5DCD,$20B6, $5DCE,$20C9, $5DCF,$2091, $5DD0,$20BE, $5DD1,$20C6, $5DD2,$20C4, $5DD3,$20BA, $5DD4,$20B4
org $86EB00
OptLeftL:                       ; A = $13A1, M = X = 8 bit (from OptLeft)
    cmp #$08
    beq .ret
    cmp #$07
    bne +
    jml RstLeft                 ; v115
+   cmp #$06
    beq .mus
    tax
    jml $80E27C
.mus:
    lda.l !CodexMus
    dec a
    bpl +
    lda #$1A                    ; NONE (0), then the Music Test numbers 00-25 (values 1-26)
+   sta.l !CodexMus
    lda #$08
    sta $13A2                   ; "previous item" = EXIT: forces this row to be redrawn
.ret:
    jml $00E22B                 ; an RTS
OptRightL:
    cmp #$08
    beq .ret
    cmp #$07
    bne +
    jml RstRight                ; v115
+   cmp #$06
    beq .mus
    tax
    jml $80E29A
.mus:
    lda.l !CodexMus
    inc a
    cmp #$1B
    bcc +
    lda #$00
+   sta.l !CodexMus
    lda #$08
    sta $13A2
.ret:
    jml $00E22B
OptMusDraw:                     ; point $13AB (label) and $13AD (value) at this item's draw lists; $13A9 = highlighted
    sep #$30
    lda.l !CodexMus
    cmp #$1B
    bcc +
    lda #$06                    ; power-on RAM is random: the screen set-up draws this item before anything has initialised it
    sta.l !CodexMus
+   ldx #$30
    ldy $13A9
    beq +
    ldx #$20
+   rep #$20
    lda #$0012 : sta $138D
    lda #$5DEE : sta $138F
    lda #$5DEF : sta $1393
    lda #$5DF0 : sta $1397
    lda #$5DF1 : sta $139B
    sep #$20
    stx $1392 : stx $1396 : stx $139A : stx $139E   ; attribute (red / green) of the four cells
    lda.l !CodexMus
    bne .num
    lda #$BF : sta $1391                            ; N O N E
    lda #$C0 : sta $1395
    lda #$BF : sta $1399
    lda #$B6 : sta $139D
    bra .lbl
.num:
    dec a                                           ; Music Test number 0-25 as two decimal digits
    ldy #$00
-   cmp #$0A
    bcc +
    sbc #$0A
    iny
    bra -
+   clc : adc #$A1 : sta $1399                       ; ones
    tya : clc : adc #$A1 : sta $1395                 ; tens
    lda #$91 : sta $1391 : sta $139D                 ; blanks on both sides
.lbl:
    rep #$20
    lda $13A9 : and #$00FF
    beq +
    lda #MusLblH : bra .sl
+   lda #MusLblN
.sl: sta $13AB
    lda #$138D : sta $13AD
    sep #$20
    rtl

org $86EC00
NavUp:                          ; M = X = 8; orig LDA $13A1 / STA $13A2 / DEC / BPL / LDA #8 ... ($E270 stores A in $13A1)
    lda $13A1
    sta $13A2
    tax
    lda.l PrevTab,x
    jml $00E270
NavDown:
    lda $13A1
    sta $13A2
    tax
    lda.l NextTab,x
    jml $00E270
PrevTab: db 8,0,1,2,6,4,3,5,7       ; screen order of the items: 0 1 2 3 6 4 5 7 8
NextTab: db 1,2,3,6,5,7,4,8,0

; v107: CODEX MUSIC is kept in $7F:E7A8, which the game overwrites in play, and a soft reset doesn't run the power-on
; defaults again: after playing, reset (or a long session) the CODEX loaded a garbage song id and hung in the song loader.
; At every title start (Dispatch, JSL $86E700) the value is read back from SRAM ($70:0018 value, $70:0019 = value xor $A5),
; else the default 6 (song 05).  OPTION MODE and the CODEX are only entered from the title.
org $86E700
MusTitle:                       ; JSL $86E700 from Dispatch (every scene start).  Any M/X; keeps A, X, Y
    php
    sep #$20
    pha
    jml EndRec                      ; v111

org $86E710
MusLoad:                        ; JSL $86E710 from the CODEX entry (slot.asm): the same without the title check
    php
    sep #$20
    pha
MusRead:
    lda #$06 : sta.l !CodexMus
    lda.l $700018 : eor #$A5 : cmp.l $700019 : bne MusDone
    lda.l $700018 : cmp #$1B : bcs MusDone
    sta.l !CodexMus
MusDone:
    pla
    plp
    rtl

; v107: a soft reset finds the game's "CAPC" signature and takes the warm-boot path ($00:8105), which skips the power-on
; defaults ($80:DFC3, where PowerOnHook sets these).  Play leaves $7F:E7xx full of game data, so set them here too:
; without it the intro skipped itself after a reset ($7F:E7D7 was $FF) and the CODEX song was garbage.
org $008105
    jml WarmHook            ; orig SEP #$30 / STZ $0612
    nop
org $86E740
WarmHook:
    sep #$30
    stz $0612
    lda #$00 : sta.l !IntroLatch
    lda #$01 : sta.l !IntroOn
    jsl $86E710             ; MusLoad: CODEX MUSIC from SRAM
    sep #$30
    jml $80810A

; v108: START during the attract loop's gameplay demo goes straight back to the title, without the Hall of Heroes
; (the demo running out of time still shows it).  The flag lives in $7E:6FF0, which the game never touches (the
; demo is play, and play overwrites our $7F:E7xx variables).
!DemoQ = $7E6FF0
org $00895F
    jml DemoStart           ; orig LDA #$02 / STA $1253 (the demo's START exit)
    nop
org $86E760
DemoQuit:                   ; JSL from Dispatch (title after the demo): C = 1 (and the flag cleared) if START ended it.  M=8
    lda.l !DemoQ
    cmp #$C5 : bne +
    lda #$00 : sta.l !DemoQ
    sec
    rtl
+   clc
    rtl
DemoStart:
    lda #$C5 : sta.l !DemoQ
    lda #$02 : sta $1253
    jml $808964             ; RTS
assert pc() <= $86EA00

; v109: CODEX ally pages in the order the allies first turn up in the game: Big Man, Amazon (floor 0), Ninja, Thief
; (floor 1), Cleric, Wizard (floor 2), Knight (floor 9), Lizardman (floor 17).  $0462 is the game's ally-screen
; number (the attract loop's order: 0 Big Man, 1 Knight, 2 Ninja, 3 Cleric, 4 Amazon, 5 Wizard, 6 Lizardman, 7 Thief).
org $86E7A0
AllyOrder:                  ; JSL from CodexEnter: A (8-bit) = CODEX page 3-10 -> $0462.  M=8 X=16; keeps X
    phx
    rep #$30
    and #$00FF : sec : sbc #$0003 : tax
    sep #$20
    lda.l .ord,x : sta.l $000462
    plx
    rtl
.ord: db 0, 4, 2, 7, 3, 5, 1, 6

; v111: the run's ally for the Hall of Heroes is taken when an ending starts.  The good ending's scenes reuse $0424 to
; show the allies one by one (Big Man... ending on the Knight), and the entry used to be recorded at the title after it,
; so a Thief run went into the table with the Knight's head.  Scene $16 (good ending) / $18 (bad ending) are the
; first ending scenes; RunEnd (hiscore.asm) no longer records again after an ending (!HiClr set).
org $86E7C0
EndRec:                         ; from MusTitle: M=8, A and P pushed
    lda $0401
    cmp #$16 : beq .rec
    cmp #$18 : beq .rec
    cmp #$02 : bne +
    jml MusRead
+   jml MusDone
.rec:
    phx : phy
    jsl $82FB00                     ; RecordBest (slot.asm): best credit of the run, with the ally still in $0424
    ply : plx
    jml MusDone

; ======================= v115: RESET CODEX (was RESET SCORES; OPTION MODE item 7, rows 23-25) =======================
; LEFT/RIGHT choose CHOOSE -> HALL OF HEROES -> THIEF'S LOG -> EVERYTHING (wrapping); CHOOSE again every time OPTION MODE opens.
; With a choice made and the cursor on the item, hold A, B, X and Y and press START; the reset happens when START is released,
; then the row says DONE until the next press.  Label row 23 (bank 07 list); value row 24 and hint row 25 are built at WRAM
; $0300 (read through the bank-07 mirror of low WRAM; $7E:0300-$03FF is untouched by the game everywhere).
org $07E500
RstLblN: dw $003A, $5EE9, $3091, $5EEA, $30C3, $5EEB, $30B6, $5EEC, $30C4, $5EED, $30B6, $5EEE, $30C5, $5EEF, $3091, $5EF0, $30B4, $5EF1, $30C0, $5EF2, $30B5, $5EF3, $30B6, $5EF4, $30C9, $5EF5, $3091, $5EF6, $3091
RstLblH: dw $003A, $5EE9, $2091, $5EEA, $20C3, $5EEB, $20B6, $5EEC, $20C4, $5EED, $20B6, $5EEE, $20C5, $5EEF, $2091, $5EF0, $20B4, $5EF1, $20C0, $5EF2, $20B5, $5EF3, $20B6, $5EF4, $20C9, $5EF5, $2091, $5EF6, $2091

org $86E800
RstDraw:                        ; $13A9 = highlighted.  Ends M = X = 8 (as OptRstDraw did)
    sep #$30
    lda.l !RstMode : cmp #$03 : bcc +
    lda #$00 : sta.l !RstMode   ; (random RAM at power-on: the screen set-up draws this item early)
+   lda.l !RstSel : cmp #$04 : bcc +
    lda #$00 : sta.l !RstSel
+   ldx #$30
    lda $13A9 : beq +
    ldx #$20
+   stx $03F0                   ; attribute: highlighted or not
    lda.l !RstSel
    ldx $13A9 : beq +           ; the hint only on the highlighted row, with a choice made, not after DONE
    cmp #$00 : beq +
    ldx #$01
    lda.l !RstMode : cmp #$02 : bne ++
+   ldx #$00
++  stx $03F2
    lda.l !RstMode : cmp #$02 : bne +
    lda #$04 : bra ++
+   lda.l !RstSel
++  sta $4202
    lda #20 : sta $4203
    rep #$10
    lda #$A2 : sta $0300        ; list length: 2 + 40 cells x 4
    stz $0301
    nop : nop : nop : nop
    ldx $4216                   ; the value text
    ldy #$0000
.v: rep #$20
    tya : lsr a : lsr a : clc : adc #$5F06 : sta $0302,y
    sep #$20
    lda.l RstTxt,x : sta $0304,y
    lda $03F0 : sta $0305,y
    inx
    iny : iny : iny : iny
    cpy #$0050 : bne .v
    ldx.w #100                  ; the hint
    lda $03F2 : bne +
    ldx.w #120                  ; blank
+   ldy #$0000
.h: rep #$20
    tya : lsr a : lsr a : clc : adc #$5F26 : sta $0352,y
    sep #$20
    lda.l RstTxt,x : sta $0354,y
    lda $03F0 : sta $0355,y
    inx
    iny : iny : iny : iny
    cpy #$0050 : bne .h
    rep #$20
    lda $13A9 : and #$00FF : beq +
    lda #RstLblH : bra ++
+   lda #RstLblN
++  sta $13AB
    lda #$0300 : sta $13AD
    sep #$30
    rtl

RstLeft:                        ; M = X = 8, from OptLeftL
    lda.l !RstMode : cmp #$01 : beq .r      ; armed: the cursor and the choice are locked
    lda #$00 : sta.l !RstMode
    lda.l !RstSel : dec a : and #$03 : sta.l !RstSel
    lda #$08 : sta $13A2        ; redraw the row
.r: jml $00E22B
RstRight:
    lda.l !RstMode : cmp #$01 : beq .r
    lda #$00 : sta.l !RstMode
    lda.l !RstSel : inc a : and #$03 : sta.l !RstSel
    lda #$08 : sta $13A2
.r: jml $00E22B

RstDo:                          ; M = 8: 1 Hall of Heroes, 2 Thief's Log, 3 both
    lda.l !RstSel : and #$01 : beq +
    jsl $89F2C0                 ; ResetScoresL (slot.asm): the table back to the defaults
+   sep #$30
    lda.l !RstSel : and #$02 : beq +
    lda #$7A : sta.l $700500    ; the Thief's Log: a valid empty record (thieflog.asm layout)
    lda #$00
    ldx #$06
-   sta.l $700501,x
    dex : bpl -
    lda #$A5 : sta.l $700508    ; check = (sum of nothing) xor $A5
    lda #$FF : sta.l $700509    ; no warp pending
+   sep #$30
    rtl
RstTxt:   ; v115: value row texts (20 tiles each): CHOOSE, HALL OF HEROES, THIEF'S LOG, EVERYTHING, DONE, the hint, blank
    db $91,$91,$91,$91,$91,$91,$91,$B4,$B9,$C0,$C0,$C4,$B6,$91,$91,$91,$91,$91,$91,$91   ; "       CHOOSE       "
    db $91,$91,$91,$B9,$B2,$BD,$BD,$91,$C0,$B7,$91,$B9,$B6,$C3,$C0,$B6,$C4,$91,$91,$91   ; "   HALL OF HEROES   "
    db $91,$91,$91,$91,$C5,$B9,$BA,$B6,$B7,$98,$C4,$91,$BD,$C0,$B8,$91,$91,$91,$91,$91   ; "    THIEF'S LOG     "
    db $91,$91,$91,$91,$91,$B6,$C7,$B6,$C3,$CA,$C5,$B9,$BA,$BF,$B8,$91,$91,$91,$91,$91   ; "     EVERYTHING     "
    db $91,$91,$91,$91,$91,$91,$91,$91,$B5,$C0,$BF,$B6,$91,$91,$91,$91,$91,$91,$91,$91   ; "        DONE        "
    db $C1,$C3,$B6,$C4,$C4,$91,$B2,$91,$B3,$91,$C9,$91,$CA,$91,$C4,$C5,$B2,$C3,$C5,$91   ; "PRESS A B X Y START "
    db $91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91,$91   ; "                    "
assert pc() <= $86EA00
