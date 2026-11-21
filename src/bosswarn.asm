lorom
; v65: boss warning on the floor before each boss. New text lives in free bank $86;
; the floor table at $00:CA78 is repointed for floors 3, 11, 23, 35, 48 (v106: and 28).
; Each message: lines separated by $00, a blank line is two $00 in a row, ends $FF.
org $86D400
Warn3: db "THE",$00,"POISONOUS",$00,"MUSHROOM",$00,"NUMBS YOU.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF
Warn11: db "I HEAR",$00,"WATER.",$00,"LET'S HURRY.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF
Warn23: db "THE",$00,"GAUNTLET",$00,"ENHANCES",$00,"SWORDPLAY.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF
Warn35: db "THE SWORD'S",$00,"LIGHTNING",$00,"RENDS THE",$00,"DARKNESS.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF
Warn28: db "THERE ARE",$00,"RUMORS OF",$00,"SECRET",$00,"DOORS.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF   ; v106 (was: THERE'S SAID TO BE A SECRET DOOR IN THE TOWER.)
Warn48: db "OPEN",$00,"DROKMAR'S",$00,"DOOR WITH",$00,"THE KEY.",$00,$00,"BOSS AFTER",$00,"THIS FLOOR!",$FF
org $00CA81 : dl Warn3
org $00CA99 : dl Warn11
org $00CABD : dl Warn23
org $00CAE1 : dl Warn35
org $00CB08 : dl Warn48
org $00CACC : dl Warn28            ; v106: floor 28 (before the Emerald Dragon)
