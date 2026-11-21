lorom
; Attract-loop ally descriptions (v26). Text is ASCII, $00 = new line, $FF = end. Up to 6 lines of ~25 chars.
; The 8 long pointers (name sprite list, text) live at $00:D813; Knight keeps its original text (v80: Lizardman has its own copy, with a comma added).
org $00D816 : dl TxtBIGMAN   ; BIG MAN
org $00D822 : dl TxtNINJA   ; NINJA
org $00D828 : dl TxtCLERIC   ; CLERIC
org $00D82E : dl TxtAMAZON   ; AMAZON
org $00D834 : dl TxtWIZARD   ; WIZARD
org $00D840 : dl TxtTHIEF   ; THIEF
org $00D83A : dl TxtLIZARD  ; LIZARDMAN
org $89C000
TxtBIGMAN: db "HIS BOOMERANG AXE IS" : db $00 : db "POWERFUL BUT SLOW." : db $00 : db "A PROTECTOR, HE TAKES" : db $00 : db "EVERY OTHER HIT FOR YOU." : db $00 : db "HE HEALS SLOWLY AT FIRST," : db $00 : db "FASTER AS HE LEVELS UP." : db $FF
TxtNINJA: db "THROWS REBOUNDING STARS" : db $00 : db "THAT ARE FAST BUT WEAK." : db $00 : db "HE GIVES YOU A CHANCE TO" : db $00 : db "EVADE ATTACKS OR LAND" : db $00 : db "CRITICAL HITS, AND LONGER" : db $00 : db "INVINCIBILITY WHEN HIT." : db $FF
TxtCLERIC: db "HIS WEAK MAGIC BULLETS DO" : db $00 : db "GRAVE DAMAGE TO UNDEAD." : db $00 : db "A HEALER, HE ENHANCES" : db $00 : db "FOOD AND SLOWLY RESTORES" : db $00 : db "YOUR LIFE." : db $FF
TxtAMAZON: db "FIRES A SWIFT BUT WEAK" : db $00 : db "CROSSBOW. A GREAT LEADER," : db $00 : db "SHE CARRIES YOUR PREVIOUS" : db $00 : db "ALLY'S LEVEL TO THE NEXT." : db $00 : db "ONCE A FLOOR, SHE GIVES A" : db $00 : db "SECOND WIND IF YOU FALL." : db $FF
TxtWIZARD: db "HIS POWERFUL MISSILES" : db $00 : db "CAN BE AIMED ANYWHERE," : db $00 : db "BUT HE HEALS SLOWLY. HE" : db $00 : db "SHARES HIS POWER, SO YOUR" : db $00 : db "MAGIC BAR FILLS FASTER." : db $FF   ; v117
TxtTHIEF: db "HIS BOMB HAS A SHORT" : db $00 : db "RANGE. HE SPOTS TRAPS," : db $00 : db "SECRETS, AND ALLIES. A" : db $00 : db "SCOUT, HE KEEPS A" : db $00 : db "DETAILED LOG OF EVERY" : db $00 : db "FLOOR HE REACHES." : db $FF   ; v112
TxtLIZARD: db "BECOMES AN ALLY ONLY" : db $00 : db "WHEN BRIBED WITH A" : db $00 : db "DIAMOND RING. HE IS A" : db $00 : db "BRUTE WITH GREAT PHYSICAL" : db $00 : db "STRENGTH, SPEED AND" : db $00 : db "ATTACKING POWER." : db $FF
