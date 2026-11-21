# Thief's Log in the pause screen: research (2026-11-15)

Tools: `s9x_tw3.so` (see tests/README.md) adds `tw_fillram()` (Snes9x `Memory.FillRAM`: last values written to $2100-$21FF / $4200-$420D), `tw_ppu()`, `tw_oam()`, watch flag 8 = log every DMA (source bank:address, B-bus register, direction, byte count), and watch flag 16 = touched-WRAM bitmap (see the sweep below). Source edits in `src/snes9x/libretro/libretro.cpp`, `dma.cpp`, `ppu.cpp`, `getset.h` (rebuild every object that includes getset.h after changing it).

## How the game pauses
- `$00:8A31`: if `$0430` = 0 and START is newly pressed (`$1246 & $10`), `$1298` ^= 1 (pause flag).
- Main loop `$00:84F4`: while `$1298` is set, the object update (`JSR $B138` / `$B16C`) is skipped; everything is frozen.
- `$00:A108`: draws / removes the "PAUSE" text in BG3 (VRAM $5D6E, 5 tiles) when `$1298` changes.
- While paused only ~280 instructions run per frame; the only pad read is the START check, so Select is free.
- The OAM buffer (`$00:1000-$121F`, DMA'd to OAM every NMI) does not change while paused.

## Display during play (floors 7 and 17)
- Mode 1 with BG3 priority ($2105 = $09), main screen BG1+BG2+BG3+OBJ ($212C = $17; only written at init and $00:C482).
- VRAM: BG3 chars $0000 (same font as the menus: A-Z, 0-9, ' and ? identical), BG1 chars $1000, BG2 chars $3000, BG1 map $5000 (64x32), BG2 map $5800, BG3 map $5C00 (the HUD), OBJ $6000-$7FFF (OBSEL $63). Every area is in use.
- NMI (`$00:8A46`): writes BG1/BG2 horizontal scroll from shadows `$1302-$1305`, and `$420C` = `$0EF3 & 1` when `$0ED2` is set. HDMA channel 0 = BG1 HOFS parallax (indirect, table at `$00:0ED2`), used on some floors (17 yes, 7 no). Channels 1-4 are used for DMA; 5-7 are free.
- DMA sources during play: low WRAM `$0000-$0FFF` (VRAM and CGRAM), `$1000` (OAM), and ROM graphics (sprite pool).

## Design notes
- Hook the pause check: while paused, Select opens the log; Select goes back to the pause screen; START unpauses.
- Back up what the view borrows into `$7E:2600-$6FFF` (see the sweep), restore on close: BG map(s), the char tiles it adds, OBJ tiles for the icons, the OAM buffer, CGRAM palettes it changes.
- Tile-step version: BG2 for the strips (map $5800 2 KB + ~10 strip tiles), BG3 for text (map 2 KB), 12 icon sprites (1.5 KB), BG1 hidden via $212C. About 8 KB of backup.
- Smooth version: BG2 64x32 map placed over BG1's map area ($5000, 4 KB, BG1 hidden), strip text drawn on BG2 with font tiles converted to 4bpp, HDMA channel 6 on BG2 HOFS for the selected strip, and the NMI's `$420C` write patched to keep bit 6 while the view is open. About 11 KB of backup.

## Memory sweep, all floors (v97, 2026-11-15)
Tool: `s9x_tw3.so` watch flag 16 marks every WRAM byte touched in a 128 KB bitmap (`tw_bitmap`, `tw_bmclear`): CPU reads and writes (byte and word), whole DMA ranges with a WRAM A-bus (A bus fixed = 1 byte), HDMA table and data reads, and the WMDATA port ($2180). Scripts: `scripts/mem2.py` (floors 1-55: each reached through the floor-7 hidden door with its destination forced, so the floor load is included, then 5500 frames of invincible play with a walker that jumps and attacks when stuck, then 1500 frames without invincibility, START pressed now and then), `scripts/mem3.py` (attract loop, title, every CODEX page, slot screen, new game from the BEGINNING, floor 0 and its boss, dying, continue screen). Union: `mem2_all.bin`.
- First attempt was wrong: `getset.h` is inlined, and make did not rebuild the objects that include it, so most CPU accesses were not marked. Fixed by touching every source that includes it; checked against the read/write log (every logged address is in the bitmap).
- Untouched everywhere: `$7E:0300-$03FF` (256 B), **`$7E:2600-$6FFF` (18,944 B)**, `$7F:78D0-$8FFF` (5,936 B), `$7F:FD92-$FFFE`.
- `$7E:2000-$25FF` is the level's background layout, read while scrolling (`$00:9EEF`, `LDA [$00],Y` column streaming). Not usable.
- Coverage limits: the walker reached less than 80% of floors 11, 33 and 34, did not move on floor 55, and boss fights may not all have been finished. Every floor load ran in full (that is where level data is written).
- Static check: no long-addressed access to `$7E:2000-$6FFF` in code banks 00-07 (the hits are in graphics banks); the MVNs into bank $7E copy object pages. Absolute-addressed hits can't be separated from data without a full disassembly.

## Canary check build (v97c, 2026-11-15): clean
- `asm/canary.asm` (check build only, a separate check build): fills `$7E:2600-$6FFF` with `$5AA5` once, checks 64 words per main-loop pass (hook `$00:8A31`); a changed word flickers the screen for 2 s, is put back, and is recorded at SRAM `$70:0520` ('CN', count, first/last floor, first/last address). Detection verified with a planted write on floor 7.
- Speed: 67 main-loop passes in 300 frames vs 70 for v97, the same with a 1-word check, so the per-pass check is not the cost (the one-time fill / different random path).
- Author's playtest with save files made for it (scripts/mksav.py, mksav50.py: warp from the floor-7 state with `!Slot` set, so the game's own autosave writes the slot): floors 11, 12, 24, 29, 33, 34, 36, 49 and 50 (Drokmar with the Knight, both endings). No flicker, and the record at `$70:0520` is empty in all five returned .srm files.
- Floor 55 is a black screen when reached by a forced warp: not a playable floor (the log lists 1-50). So the earlier "coverage gap" there is not a gap.
- Conclusion: `$7E:2600-$6FFF` is free for the pause-screen view's backups.

## Built (v99)
See V31_CHANGES.md v99. In-play facts found on the way: the gameplay brightness is `$0E` (fade-in writes `$1252` then increments, stopping at `$0F`); `$0ED2` is the first byte of the HDMA ch0 table and the NMI's "HDMA on" test; the paused main loop is `$00:86C6` (OAM setup `$95BB`, `$9FFE`, `$858C`, pause check `$8A31`), with the OAM DMA (channel 2, `$88B2`) after the next NMI; `$00:A108` draws/erases PAUSE when `$1298` changes (compares with `$1299`). Game PPU defaults (`$00:8AF2`): `$2105` = `$09`, `$2107` = `$51`, `$2108` = `$58`, `$2109` = `$5C`, `$210B` = `$31`, `$212C` = `$17`, `$2130` = `$30`, `$2132` = `$E0`, scrolls 0, `$4200` = `$81` in play (no IRQs). Runtime writers: BG1 VOFS only by a shake object (`$03:A652`), BG3 VOFS by `$00:F102/F1B0` (not reachable while paused).
