# FastROM base, stairs bug, translucent hint (Nov 2026)

## FastROM
The author's `Magic Sword - Fastrom.ips` (third-party) changes ~4200 bytes: it adds 0x80 to the bank byte of every JSL/JSR-long/JML target and
reroutes reset through a stub at $00:FFB5 that sets $420D. Header speed byte stays $20.
Our patches are therefore built on the FastROM-patched ROM (apply the fastrom IPS to the clean ROM, then assemble `hack.asm` / `hackD.asm`):
hook code lives at $82:EE00 and $81:FF00, calls use $80:/$81: banks, and the shipped IPS files are diffs against the CLEAN ROM (fastrom included).
Music breakage reported for some levels with FastROM patches is NOT checked (no audio in the test harness).
asar gotchas: `label+2*4` is evaluated left to right (use separate labels); a `jsr` from bank $01 to a label in bank $81 needs `db $20 : dw label`.

## Stairs bug (Thief hint v5-v7 made characters vanish / jump when Y or B speeds up the between-floors stair scene)
Cause: the stair-walk code at $02:EC2x ends with `ADC $EC6D,X` on a 16-byte table at $02:EC6D, but with the speed-up X runs past the table
and reads the $FF fill after it. The first byte of the hook code at $02:EC85 changed those reads. Fix: never start code or data right at the start of a
free region; hook code moved to $02:EE00 (margin >= 0x17B bytes, X is 8-bit so reach is <= $ED6C), Big Man code at $01:FF00, data at $16:AD00.
Lesson for the free-space sweep: the first ~0x100 bytes of any "free" region may be over-read by a neighbouring table.
Also: the hint hook now only runs for real doors (+A6 == $21), because $02:C3E5 is a shared draw tail.

## Translucency
Hardware color math only affects OBJ palettes 4-7 (shared with allies/enemies, vary by level) and would need the game's CGWSEL/CGADSUB/TS setup changed,
so it was not used. Instead `hackD.asm` alternates two complementary checkerboard copies of every icon each frame (temporal dither, cache records
+EC/+F0 for phase 0 and +F4/+F8 for phase 1, ids $7E00-0B and $7E10-1B). Costs twice the sprite-pool slots per hinted door.
