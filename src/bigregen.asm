lorom
; Big Man perk part 2 (v59, row retuned in v85): his own life regenerates slowly at L1 and speeds up strongly with level.
; Regen table $01:8AD6 (frames per block, L1..L8), one 8-word row per ally type; Big Man is type 1 -> row at $01:8AE6.
; Original row 200..130 (3.3 s .. 2.2 s per block). v10-v58 ticked his timer at 1/4 speed (13.3 s .. 8.7 s, a flat curve).
; v59 writes a steep row instead, ending near the Wizard's L8 (240 frames = 4.0 s):
;   L1 13.3 s, L2 12.0, L3 10.6, L4 9.3, L5 8.0, L6 6.7, L7 5.3, L8 4.0 s per block.
; The old 1/4-speed hook at $01:87BE is gone, so the shared regen routine runs unmodified for every ally.
org $018AE6
    dw 660,600,540,480,420,360,300,240
; v85: the Big Man first appears on floor 0 at L2 and died too soon, so the row starts gentler: 660,600,540,480,420,360,300,240
;   L1 11.0 s, L2 10.0, L3 9.0, L4 8.0, L5 7.0, L6 6.0, L7 5.0, L8 4.0 s per block (v59 was 800..240: 13.3 s .. 4.0 s).
