# Hidden warp doors

Found from the floor object lists. Object class `$0156`, handler `$05:9639` (jump table `$05:964D`: st0 `$966D` init, st2 `$9686` trigger wait, st4 `$980A` door).

| Floor | Record trigger | x | y | +C (zone top) | +E | Lands on |
|---|---|---|---|---|---|---|
| 1 | $0086 | $7F | $B0 | $04 | 3 | 4 |
| 7 | $0001 | $10 | $70 | $04 | 10 | 11 |
| 14 | $0064 | $70 | $90 | $80 | 18 | 19 |
| 17 | $00F2 | $F6 | $B0 | $40 | 19 | 20 |
| 34 | $0050 | $42 | $B0 | $30 | 35 | 36 |
| 39 | $007E | $78 | $70 | $A0 | 41 | 42 |

The door writes record byte `$0E` (object `+$AE`) to `$0403` at `$05:98D7`, and the next floor is that value + 1. Tested: forcing `+AE` = N-1 on the floor-7 door landed on floor N.

## How it works
- st2 (`$9686`): every other frame, sets a 32x32 hit box (table `$05:97D1` = 0,$20,0,$20) at left = (`+$A0` x 8) - `$132C`, top = `+$AC` (screen), and calls `JSL $00B329` with X=8: the player's sword hitbox (slot `$1608-$160E`). So the trigger is the sword touching the zone, usually with a jump attack. Floor 17: zone above-left of the gold disc. Floor 7: top-left corner of the first room.
- When it fires: `+$1B`=1, `$0713/$0715`=`$FF`, state -> 4.
- st4 (`$980A`): the door rises, then waits for UP (`$1244` & 8) while the player overlaps the door box (table `$05:97D9`). Entering sets `$0A40`=1, `JSL $02C2B2`, and at frame `$0A` jumps to `$98D7` (`$0403` = `+$AE`, `$1253` = 2).
- The door is drawn by this same object (graphics table `$05:9B48` / `$05:9B43`), in OBJ palette 7 (source `$1F:81FA`, loaded with `$00:A923`, Y=`$01E0`).
- Palette 7: empty on floors 1, 7, 17, 34, 39 until the door appears; floor 14 has an enemy that loads its own palette into 7.

## Thief star
While the Thief is the active ally, a 16x16 star (the door's crest) blinks at the zone centre on the hidden-chest timing (2 frames in 32). Palette 7 if it holds the door's colours or is empty (then loaded), otherwise a silver palette-0 copy. Hook `$05:9686` -> `StarHook` `$86:FA00` (`src/hack_opt.asm`).
