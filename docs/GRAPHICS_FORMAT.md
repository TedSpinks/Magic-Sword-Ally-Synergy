# Sprite graphic format

## Chain from object to VRAM
1. An object's draw code points `$0A98-$0A9A` at a **graphics table** (5-byte entries) and calls `$00:8DD2` with X = entry offset and Y = a 4-byte cache record offset in the object struct.
2. **Table entry (5 bytes):** 3-byte pointer to a **descriptor**, then a 16-bit **graphic id**. The id is what the sprite pool (`$1400,X`) stores and shares; it must be unique per graphic.
3. **Descriptor:** two 16-bit words per 16x16 graphic, the top tile row then the bottom tile row. Each word = `(bank << 9) | index`, index 0-511. Source address = `bank:$8000 + index * 64` (read by `$00:9038`).
4. **Upload:** `$00:8F22` queues two 64-byte DMA entries (at `$7E:7000+`): the top row to VRAM word `$6000 + tile*16`, the bottom row to `+$100` (16 tiles down).
5. **Tile data:** each 64-byte row is two standard SNES 4bpp 8x8 tiles (32 bytes each, left then right), so a 16x16 graphic is 128 bytes, 64-byte aligned within `$8000-$FFFF` of its bank.

Example (the game's skull): chest table `$02:DDDE`, entry `$3C` = descriptor `$07:9650`, id `$0298`; descriptor words `$2257`, `$2258` = `$11:95C0`, `$11:9600`.

## The hack's icons
The Thief's door icons (ally heads, fairy, skull) and the hidden-door star use their own descriptors and ids (`$7E00+`) with tiles in free ROM at `$16:AD00+` (`src/icons*.bin`, `src/skull_*.bin`, `src/star*.bin`). The sprite pool is shared with the game: the icons draw only while at least 8 of its 63 slots stay free.

## Free ROM used
Large `$FF` blocks in the original ROM: `$16:ABC0-$FFFF`, `$09:A929-$FFFF`, `$17:CC60-$FFFF`, `$1C:C20F-$FFFF`, `$06:CEF8-$EFFF`, `$0B:DED9-$FFFF`. Note: `$81:FD00-FDA2` looks free but is game data.
