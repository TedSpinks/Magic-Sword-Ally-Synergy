lorom
; v112: the Magic Items page text, clearer descriptions (Golden Pot, Crystal Ball, Magic Potion, Diamond Ring, Scroll).
; The page drew two lists ($07:BA07, $12C bytes and $07:BB2F, $270 bytes; entries = VRAM word address, tile, attribute,
; read by $00:C3F8).  They are rebuilt as one list (scripts/mkitems.py -> items.bin) at $8B:E000 (free since v63).
; The list routine at $00:D933 draws it, the second call is cut off.
org $00D935
    lda.w #$8B00            ; bank $8B ($1381 = $00, $1382 = $8B)
org $00D93B
    lda.w #ItemListEnd-ItemList
org $00D941
    lda.w #ItemList
org $00D94A
    rts                     ; (was: the second list)
org $8BE000
ItemList: incbin "items.bin"
ItemListEnd:
assert pc() <= $8BE800
