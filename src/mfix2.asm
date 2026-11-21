lorom
; Music fix for the FastROM build (v21). After a song upload the SPC's resident loader ends with
; MOV $F1,#$31 (SPC $0F35), which clears the CPU->SPC input ports. The game writes the "play" command
; ($01 to $2140) right after the last handshake; with FastROM the CPU is fast enough that the write can
; land before that clear, so the command is wiped and the floor starts silent. Wait one frame first.
org $088080
    jsr PlayCmd             ; orig: LDA #$01 / STA $2140
    nop
    nop
org $08F600
PlayCmd:
    jsr $825E               ; wait for the next NMI (one frame)
    lda #$01
    sta $2140
    rts
