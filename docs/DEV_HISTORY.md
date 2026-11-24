# Development history

Internal build numbers (v45 to v125). Build v123 is release 1.0.0; build v124 is release 1.0.1; build v125 is release 1.0.2. Addresses are SNES LoROM; "the author" is the project's author and playtester.

## v45
Fixed: save slot screen (and the recorded best-credit floor) read the floor from $0404 (ones digit shown by the HUD) instead of $0403 (the floor number). FLOOR 22 showed as 02. Slot screen now reads run-state byte +$10 ($0403); RecordBest stores $0403. Existing best-credit floors already saved in SRAM keep the old (ones digit) value until that slot is replayed.

## v46
Fixed: a real run (new game or resume) plays inside scene 4, so LastSc was 4 at game over and Dispatch never entered the high score / delete step (only scene 6 and endings counted). Dispatch now also treats LastSc 4 and 0 (with an active slot) as a run end. Verified end to end: new game, die with credits left, wait out continue -> save deleted. Note: v45 also carries the floor fix.

## v47
Wizard attract-loop description now mentions aiming: "HIS POWERFUL MAGIC / MISSILES CAN BE AIMED / ANYWHERE, BUT HE IS SLOW / AND FRAIL. HE RECHARGES / YOUR MAGIC BAR FASTER." (five lines, max 24 chars). Verified on the attract screen.

## v48
Hall of Heroes look pass toward the arcade screen: text periwinkle (#6890EA, shadow #010451) instead of saturated cyan; title paler grey-blue (palette 3); footer hint periwinkle (palette 5). Tower palette rebuilt as shadow-indigo / mauve / pale-grey highlights, darkening baked in, colour math off (backdrop navy #000020). BG2 (the old cloud layer) now holds a generated star field (243 tiles, 7 classes: 3 twinkle colours cycling through TwRamp, 4 static dim/pale blues), tile data starbg.inc via scripts/mkstarbg.py; the 64 sprite stars remain. BG2 char base $3000, map $5800, palette 3 (CGRAM $30).

## v49
Two-tone letters on the Hall of Heroes: HiFont moves the lower half (rows 4-7) of the small digit/letter tiles ($A1-$CB) from colour 2 to colour 3 in VRAM; HiPalTab sets colour 2 (top, lighter) and colour 3 (bottom, deeper) for text palettes 0 (periwinkle), 1 (white new entry), 2 (gold), 5 (hint). The big title uses palette 3 on its top tile row and palette 4 on the bottom row (attribute edit in the shadow map). The title row loop needs rep #$30 first (PutBig leaves M=8).

## v50 - star / 1CC marker on the Hall of Heroes
- Table columns shifted left one: rank cols 1-4, score cols 6-12, floor field cols 14-16.
- Floor byte of an entry: bit 7 = "1CC" (game beaten, never continued, shown instead of the floor), bit 6 = star then floor (game beaten after continuing); low 6 bits = floor (clamped to 50).
- Slot byte +$BB = $C1 once a credit ended (continue used); cleared on new game. !HiClr ($7FE78C) set by Dispatch when the last scene is $16+.
- Star glyph = tile $9B ('*'), two-tone, uploaded by HiFont. Tested by poking table entries; the real ending path is untested.

## v51 - good ending now reaches the table
- Playtest: after beating Drokmar, YES (bad ending, scenes $18..) showed the table with 1CC/star; NO (good ending) did not. The good ending runs scenes $16,$1A,$1E,$20,$22,$24,$26 and returns to the title with LastSc=$26, outside the old $16-$1F window. Window widened to $16-$2F. Verified: state6 + NO now deletes the save and enters a 1CC row (floor 50).

## v52 - HUD TOP score follows the saved table
- Cause: the game keeps TOP in WRAM ($0449-$044F, least significant first, default 500,000 at power-on) and the slot save stores/restores WRAM $0403-$0491, so a resume brought back an old/default TOP.
- Fix: `SyncTop` (slot.asm, bank 89) raises TOP to table entry 0 if the table is higher; called from `Dispatch` (scene changes) and, through the stub at $89:C3D0 (`SyncTopL`), at the end of `FloorStart` (save.asm .done) so it runs after a resume restore. Verified: table top 5,000,000 -> new game TOP 5,000,000; table 9,000,000 -> resumed game TOP 9,000,000.

## v53 - no table before the title at boot
- Cause (found from the author's pre-title state): after power-on `$04A5` (!Slot) held $20 (the RAM fill pattern / the game's own use of that byte), so the first title Dispatch with LastSc=0 looked like "a run just ended" and opened the table. Also HiEd was $55, which would show the name-entry help text on the title.
- Fix: Dispatch accepts only slots 1-3 for the run-end check; HiEd is cleared whenever a scene below 3 is dispatched.

## v54 - smoother title -> SCORES fade
- Cause: the game's fade-in loop ($80:8211) runs its object code every frame, which kept redrawing the title cursor into the OAM buffer ($7E:1000) and delayed our portrait sprites until the fade finished.
- Fix: HiScene runs its own fade-in loop (same stepping: $124F/$1251/$1252/$2100, ends at $0F, stz $1253) that draws our sprites (portraits, star twinkle) each frame.

## v55 - fix: title START gave a black screen with some saved tables
- The v52 TOP sync also ran from Dispatch (every scene change). With the author's table (best score above the default TOP) writing $0449-$044F from inside the scene-4 dispatch derailed the title START (Pend never cleared, black screen + music). Removed that call; TOP is now synced only at floor start (FloorStart -> SyncTopL), which covers new games and resumes (verified with the author's SRAM: resume shows TOP 2130330).
- Root cause of the write at Dispatch time not found; avoid touching $0449+ from the scene dispatcher.

## v56 - slot screen: portraits visible from the first fade frame
- Same fix as the SCORES screen (v54): SlotScene runs its own fade-in loop instead of the game's $8211 loop, so the portraits (our OAM) are drawn during the fade.

## v57 - trapped chests follow THIEF VISION
- The Thief's trapped-chest reveal (game code at `$02:DC0D`, skull chest vs normal chest) now reads the THIEF VISION option like the door hint: FLICKER keeps the game's original timing (`$0601 & $0C`), DITHER swaps normal/skull every frame. Hook `ChestVis` at `$82:FD00` (tools/hack_opt.asm). Checked on a floor-7 state with the Thief: FLICKER pattern identical to the original, DITHER alternates every frame.

## v58 - Thief description and between-level hints
- Thief description screen (tools/text.asm): "HIS BOMB HAS A SHORT RANGE. HE SEES INSIDE CELL DOORS TO SPOT ALLIES AND TRAPS. HE FINDS HIDDEN AND TRAPPED TREASURE CHESTS." (the original "packs a wallop" was wrong).
- The 51 NEXT FLOOR hints are re-written in place at `$07:C421` (tools/hints.asm, generated by genhints.py from hintdata.py). Floor to message table at `$00:CA78` (3-byte pointer per floor, index = floor & $3F) is repointed. 13 messages changed: Clerics are the undead killers (was "White Wizard ... even undead"), Chimera spelling, Thieves detect traps, Golden Book "turns", the Black Wizard line replaced by the Wizard replenishing the magic meter, and every end-of-line hyphen removed (re-wrapped).
- Dialog limits found by test: 12 characters per line (from tile column 20 to 31), 7 lines (the 8th collides with TIME BONUS). All 51 messages rendered in the game with a harness that points `$1CE0` at a test message and checked.

## v59 - Big Man heals faster with level
- tools/bigregen.asm: his regen row `$01:8AE6` is now 800,720,640,560,480,400,320,240 frames per block (13.3 s at L1 to 4.0 s at L8; the Wizard's L8 is 4.0 s). v10-v58 instead ticked his timer at 1/4 speed through a hook at `$01:87BE` (13.3 s to 8.7 s, a flat curve); that hook and its code at `$81:FFC0` are gone, so the shared regen routine is original again.
- Checked: v58 to v59 ROM diff is only the row, the restored `$01:87BE` bytes, the freed `$81:FFC0` code and the header checksum; resume and new-game runs identical to v58. The refill timing was not measured live (the test states would not tick the regen timer).

## v60 - Amazon carrier, Big Man description
- tools/recruit.asm (same hook `$01:8457`, code `$81:FF80`): the Recruiter's +1/+2/+3 is replaced by the carrier rule. When the Amazon joins she takes your old ally's level if it is higher than her join level. When you swap her for a different ally, it joins at max(her level, its join level + 1), capped at L8. Nothing passes from a dying ally; freeing the type you already have is still the original +2.
- Verified with scripts/sim65.py (a small 65816 interpreter running the assembled bytes): all 2,048 combinations of old ally, old level, dying flag, new type and join level give the expected level and return address. Not run through a real door: the door states no longer open doors in the harness.
- Big Man's description: "...EVERY OTHER HIT FOR YOU. HE HEALS SLOWLY AT FIRST, FASTER AS HE LEVELS UP." All description screens still fit (max 6 lines, 25 characters).
- Ally fire rate (exploration): allies only fire while the player attacks (idle = no shots). Wizard and Cleric shots need a charged magic bar. Counting was not conclusive yet.

## v61 - Amazon description
- Amazon's description: "FIRES A SWIFT BUT WEAK CROSSBOW. A GREAT LEADER, SHE CARRIES YOUR PREVIOUS ALLY'S LEVEL TO THE NEXT. ONCE A FLOOR, SHE GIVES A SECOND WIND IF YOU FALL." The early +1 is explained in the README instead. Only the Amazon's text changed; all screens fit (6 lines, 25 characters max). Resume and new-game runs unchanged.

## v62 - Thief exit look-ahead, sprite-pool reserve
- **Exit look-ahead:** with the Thief, a centred row of the next floor's allies (0-4 heads, floor-data order) floats over the exit door; nothing on floors whose next floor has no allies. Follows THIEF VISION (FLICKER / DITHER). The exit is object type `$4E` (handler `$00:BBBC`, per-frame state 4 at `$00:BC38`); hook `$00:BC3E` -> `ExitHook` after its scroll update. Next floor = floor + 1 (exits do `INC $0403` at `$00:EF7B`; warps use the table at `$00:BFA1` and are separate objects). The next-floor list is a build-time table (`$8B:E000`, scripts/gennext.py -> asm/nextallies.inc, regenerate after any door change). Cache records live in the exit object's unused `+$C0..+$FF` (checked: untouched by the game while walking to and through the exit). Row offsets 18 px per head; centre `!ExDX` = 12, height `!ExDY` = -4 (heads 30 px above that).
- **Sprite-pool reserve (door hints too):** DrawIcon moved to `$86:D000` (bank `$82` had 54 bytes left) and now takes a record base, x/y offset and reserve. The game's pool: ids `$1400,X`, refcounts `$1480,X`, free count `$06DD` (63 slots, reset to 63 at every floor start). Doors draw only while at least 8 slots stay free (`!DoorRes`), the exit row needs 12 (`!ExitRes`) and is all or nothing. Below the reserve a group gives its slots back (same release as `$80:8EE4`) and waits 120 frames before taking slots again (stops a release/re-take loop that cost heavy slowdown in the first build). Doors also give their slots back when the Thief leaves (before v62 they held them until the floor ended).
- **Checked:** row centred for 1-4 heads, correct allies on floors 7, 8, 9, 10, 14, 41 (playtest states + floor pokes); pool fully back to 63 after taking the exit; forced low free counts release the exit row first, then doors; extra CPU about 100-450 instructions per frame on busy screens and up to ~1,200 with four heads on a quiet screen (frames run ~15,000); trapped-door state identical to v61; resume, new game and all 52 floor hints unchanged.

## v63 - exit look-ahead removed, FLICKER by default
- The v62 exit look-ahead row is removed (performance risk at the end of floors for little gain: the Thief is behind only 5 doors, half the floors lead to a floor with no allies, and without door shuffling it shows what you see moments later). The hook at `$00:BC3E` is back to the original bytes and the `$8B:E000` table is gone. Kept from v62: the door hints' sprite-pool reserve (8 free slots), giving slots back when the Thief leaves, and the 120-frame wait after a forced release. Door-hint code is 614 bytes at `$86:D000`.
- THIEF VISION defaults to FLICKER on a fresh save (options.asm `PowerOnHook`); a saved setting still wins.
- Checked: fresh SRAM boots with FLICKER; exit-area screens pixel-identical to v61; the floor-10 door hint stays drawn 600/600 frames in both modes on the busy state (lowest free 10); door slots released when the Thief leaves; resume, new game, boot, SCORES and all 52 floor hints unchanged.
- Decision: no next-floor preview anywhere (not the NEXT FLOOR screen either). Seeing ahead only pays when you skipped doors and could use the next floor's doors for synergies.

## v64 - START skips the intro
- The power-on intro (LICENSED BY NINTENDO, then the CAPCOM logo, ~600 frames) can be skipped with START. Originally only the CAPCOM hold loop (`$00:C1DD`) read the pad (any button). Hooks in options.asm (code at `$86:D300`): Nintendo-screen wait loop `$00:C168` and CAPCOM fade-in `$00:C253` (inside JSR `$00:C24E`; the hook drops that return address) both take the game's own exit `$00:C216` (scene 2, fade out, `JMP $814D`). A vblank check (the native NMI stub at `$00:FFB1` now jumps to `NmiHook`, which then jumps to the original `$80:8A46`) remembers a START press while `!IntroOn` ($7FE7D6, set in the power-on hook, cleared at `$00:C216`), so taps during the fades count. The skip copies the pad into `$1243/$1244`, so the title needs a fresh START (no accidental game start).
- Checked: taps every 10 frames reach the title at once or at the next skip point (frame 112 or 339), except frames 0-60 (black, before the Nintendo screen), ~240-250 and ~300 (the screen change; the vblank does not see the pad there). Holding START always works. Title stays up after a skip and a fresh START opens the slot screen; the idle cycle (title, attract demo, story, title over 9,000 frames) is identical to v63; resume, new game, SCORES, door hints and all 52 floor hints unchanged.

## v65 - boss warning on the floor before each boss
Floors 3, 11, 16, 23, 35, 48 now end with a blank line and BOSS AFTER THIS FLOOR!. Wording changes: floor 3 NUMBS YOU., floor 16 BEGUILED BY BLACKORB'S POWER. (own copy, floor 30 unchanged), floor 35 THE SWORD'S LIGHTNING RENDS THE DARKNESS. New text at $86:D400 (asm/bosswarn.asm), floor table at $00:CA78 repointed. Render check: all 52 floors compared with v64, only these six differ. Boss-floor (B) warnings not built.

## v66 - floor 16 back to its original text
The SNES version has no boss on floor 17, so floor 16 no longer gets the BOSS AFTER THIS FLOOR! warning (floors 3, 11, 23, 35, 48 keep it). Render check vs v64: exactly floors 3, 11, 23, 35, 48 differ.

## v67 - DITHER removed, SPECIAL ACTION option
- THIEF VISION option (FLICKER/DITHER) is gone; door icons and the trapped-chest reveal always use FLICKER (the dither path doubled the sprite use). Visual check: door icons, trapped chest and trap door frames are pixel-identical to v66 in FLICKER.
- New item 6 SPECIAL ACTION: `X OR Y+B` (default, as the original) / `X ONLY`. Byte `$04A4` (0 / 1). The game's special test at `$01:9694` fires on the SPECIAL button, or on ATTACK pressed in the same frame as JUMP (jump already in the air does not count). X ONLY skips that second route (hook `$01:96A4` -> `SpcCheck` at `$86:D600`). The wording is literal, so it is only exact with the default button layout.
- Saved options: SRAM +6 now holds the flag shifted left one bit, so old saves (0/1 = FLICKER/DITHER) load as X OR Y+B. Saved, power-cycled and loaded back correctly.
- Tests: option menu render (both values, highlight, wrap), special action trial (B+Y together fires in X OR Y+B and not in X ONLY; X fires in both; v66 unchanged by the flag), saved/old-save loading, resume, fresh game, overlap check clean.

## v68 - SPECIAL ACTION folded into CONTROL PAD > SPECIAL
- The separate SPECIAL ACTION item (v67) is gone; CONTROL PAD > SPECIAL now has 12 states: the six buttons (A B X Y L R), then the same six with ONLY. ONLY means the Attack+Jump shortcut no longer fires the special action (only the assigned special button does). Left/Right cycle all 12 (buttons already used by Attack or Jump are skipped in both groups); pressing a button on the row assigns it and keeps the current mode.
- The menu is back to seven items (EXIT is item 6, row 20). The eight-item scaffolding (an item for INFORMATION) is saved in `asm/options_v67.asm` for when the Information screen is built.
- Save format: SRAM +4 = special button, +6 = `ONLY << 1`, so v67 saves (X ONLY) load as "X ONLY". Old FLICKER/DITHER saves load as shortcut on.
- Code: option screen state `$13A6` 0-11, split into `$0497` (button) and `$04A4` (ONLY) when leaving the screen; hooks at `$00:E02C`, `$E0D6`, `$E177`, `$E351`, `$E375`, `$E3AB`; code at `$86:D600`; draw lists at `$07:D800`.
- Tests: cycle all states, save and cold-boot reload, v67 save and old-save compatibility, assign by button press, shortcut test in play (B+Y together does nothing with ONLY; X works either way), door/chest frames identical to v67, resume, new game, overlap check.

## v69 - fix: Control Pad setting ignored after resuming a saved run
- Bug (present since saved runs were added): the run snapshot is WRAM `$0403-$0491`, which includes the button masks `$0464/$0466/$0468` (and game level `$0409`). Resuming a run put back the masks it had been saved with, so Attack/Jump/Special went back to the defaults (Special = X) whatever OPTION MODE said. New games were not affected. `$0495-$0498` (the buttons themselves) are outside the snapshot, so they were right all along.
- Fix: the masks are rebuilt from the current buttons at every floor start (`ApplyMasks` at `$89:F300`, called from `SyncTopL` at `$89:C3D0`, which runs at `.done` in `$82:FB00`; LoadOptions uses the same routine at power-on). The first attempt put a JSL inside `FloorStart` and pushed its last byte into `ResumeCheck` at `$82:FB80`; the overlap check does not catch that case, so check the byte after `FloorStart`'s final JML when editing it.
- Game level `$0409` is still restored with the run (unchanged).
- Tests on a resumed run: Special=L fires on L, not on X; A ONLY fires on A; X ONLY blocks B+Y; X OR Y+B default still fires on B+Y. Masks hold through the attract loop and story. Fresh game, resume, options save/load, door/chest frames unchanged.

## v70 - every option is independent of saved runs
- GAME LEVEL (`$0409`) was the last option stored inside the run snapshot. At every floor start (`SyncTopL`) it is now put back from the saved options record (SRAM +1, only if the record's marker and checksum are valid), after the button masks (v69). So a resumed run uses the current OPTION MODE settings for level, Attack, Jump, Special and ONLY.
- Code: `ApplyLevel` at `$86:DE00` called with JSL from `SyncTopL`. A first version placed before `org $89C400` ran into the code at `$89:C400` (the overlap check does not catch that); it is in bank $86 now.
- Caveat: with no valid saved record (OPTION MODE never visited), the level follows the run as before. Options are saved when leaving OPTION MODE.
- Tests: options level 0/2 with a saved run: in-game level follows the option; reg4, bt14, option save/load, Special=L on a resumed run.

## v71 - saved runs hold run state only (clean break); v70 ApplyLevel fix-up removed
- The run snapshot no longer carries option data. The bytes inside `$0403-$0491` that are options (GAME LEVEL `$0409`, button masks `$0464-$0468`) are stored as 0 and never restored, so a resumed run keeps the current OPTION MODE settings with no fix-up (`ApplyLevel` and the `ApplyMasks` call in `SyncTopL` are gone; `ApplyMasks` is still used by LoadOptions at power-on). Slot layout unchanged (+$10 = `$0403`); the checksum sums the stored bytes.
- `FloorStart` moved from `$82:FB00` to `$86:E000` (new `OptByte` helper: Y offset 6 and `$61-$65`); `$82:FB00-FB7F` is free again. `ResumeCheck` / `InfoSave` unchanged.
- Clean break: slot marker `$A5` -> `$A6` and best-credit marker `$B5` -> `$B6`, so every v30-v70 saved run shows EMPTY and any stale best credit is ignored. Not touched: the Hall of Heroes table (`$70:0400`) and the saved options (`$70:0010`). The slot DELETE now also clears the best-credit marker.
- Tests (v70 saves converted to the new format): resume at floor 7 follows the option level (0/1/2) and Special (X, L); an unconverted v70 slot shows empty and starts a new game; a new game autosaves with a valid checksum, marker `$A6` and zero option bytes; Hall of Heroes SRAM unchanged; frame counter, option save/load, TOP carry-over.

## v73 - difficulty is part of the saved run again
- v71 stopped saving GAME LEVEL with the run, so the Resume screen (which reads it from the slot) showed EASY for every run. The level is now saved and restored with the run again: a resumed run keeps the difficulty it was started on and the Resume screen shows it. The OPTION MODE difficulty applies to new games. The button settings (Attack, Jump, Special, ONLY) are still separate from saved runs.
- Runs saved with v71 stored a blank level and will resume as EASY; start a new run after updating.
- Tests: option 0 with a run saved at level 2 resumes at 2; option 2 with a run at 0 resumes at 0; a new game saves its level in the slot; frame counter, option save/load.

## v74 - CODEX on the title menu, RESET SCORES in OPTION MODE
- Title item SCORES is now CODEX. Pages (LEFT / RIGHT, wrapping): Hall of Heroes, the eight ally description screens (Big Man, Knight, Ninja, Cleric, Amazon, Wizard, Lizardman, Thief), the Magic Items screen. START returns to the title. Footer: LEFT OR RIGHT FOR MORE / START TO EXIT (the item screen has room for only the first line, on its last row).
- Ally pages have no timer: the typing and the level animation play through, then the page fades and replays for as long as it stays open. The attract loop is untouched (same scene sequence; hooks fall back to the original code when the CODEX flag `$7FE7A0` is 0, which the dispatcher clears at boot/title/attract).
- Code: hooks in the ally scene (`$00:D4E4` footer, `$D550` pad check, `$D73B` auto-advance) and the item scene (`$D84C`, `$D896`, `$D8A7` 512-loop timeout); page switch = fade out, set `$0401` ($0A allies with `$0462` = ally, $0C items) or HiScene mode 0, `jml $80:814D`. Routines at `$86:E400`; Hall of Heroes LEFT/RIGHT set `!HiDone` 2/3 (`CodexFromHall`).
- The old A+B+X+Y+START reset on the Hall of Heroes is gone. OPTION MODE has an eighth item, RESET SCORES (item 6, rows 20-21), EXIT is item 7 (row 23). START on the row asks PRESS A B X Y; holding all four clears the table (DONE); any other new press cancels. Code at `$86:EA00` (input hook at `$00:E1D3`), draw lists at `$07:DB00`, wrapper `ResetScoresL` at `$89:F2C0`.
- Tests: all ten pages both directions with wrap, START exit from allies/items/Hall, no timeout (8,000 frames on an ally page, 1,500 on items), attract loop sequence unchanged, cancel paths for RESET SCORES (L, direction), A only / A+B stay asking, A+B+X+Y resets, option save/load and Special tests repeated with the eight-item menu, resume.

## v75 - RESET SCORES in one step, footer on the Hall page only, fast typing on the ally pages
- RESET SCORES: with the cursor on the row (hint PRESS A B X Y START), pressing START while A, B, X and Y are held arms the reset; the table is cleared when START is released (DONE until the next press, cursor locked while armed). START alone, or with a button missing, does nothing. The two-step prompt of v74 is gone. Value row is now columns 6-25.
- CODEX footer (LEFT OR RIGHT FOR MORE / START TO EXIT) only on the Hall of Heroes page; the ally and item pages have none (their footer hooks were removed).
- Ally pages: A, B, X or Y makes the rest of the text type out fast (six characters per frame instead of one every four frames; about 20 frames for a full description instead of about 570). Stub `CodexType` at `$80:F7D0` replaces `JSR $D722` at `$00:D535` and only acts when `!CodexOn` and `!FastOn` (`$7FE7A3`) are set and the text is still being typed; the attract loop path is one extra test. The flag resets on every page change and replay.
- Tests: all reset variations (START alone, ABXY alone, three buttons + START, full combo held then released); typed text identical to the slow version for three allies and all four buttons; page navigation, START exit, no timeout, attract sequence, options save/load, resume.

## v76 - no fades between CODEX pages
- Changing page (LEFT / RIGHT) no longer fades out or in: the screen goes blank while the next page loads (about 18 frames, 0.3 s, mostly the game's own page load) and the page appears at once. The ally page's automatic replay (after its text and level animation) also has no fade. Entering the CODEX from the title and leaving it with START keep their fades; the attract loop is unchanged.
- Code: `!CodexCut` (`$7FE7A4`) is set by page changes and replays and cleared by the dispatcher at boot/title/attract. `CodexNav` / the Hall exit use `$80:8299` (blank, no fade) instead of `$8257`/`$826F`; `CodexFadeIn` at `$00:8211` and the Hall's own fade-in loop jump the brightness to one step from full when the flag is set; `CodexReplay` at `$00:D579`.

## v77 - ally CODEX pages freeze at the end; A/B/X/Y restarts them
- The ally page no longer replays by itself. When the text and the level animation are done it stays frozen on the last level (the character keeps idling) until LEFT / RIGHT / START, or A / B / X / Y, which restarts the page (no fade). While the level animation is still running A/B/X/Y do nothing; while the text is typing they print it fast.
- The game's level animation kept stepping the level after its "done" flag (it only never mattered because the attract scene left); `CodexStep` (hook at `$81:FA54`) keeps the step counter at 4 in the CODEX. `CodexAllyTimer` just returns; `CodexAllyPad` sets the restart (`$045E = $0B`) when `$06F4 = 2`.
- Tests: frozen for 1,500 frames with the level unchanged; A, X, Y and B each restart from frozen; B during the animation does nothing; RIGHT from frozen changes page; fast typing text identical; attract sequence, options, reset, saves unchanged.

## v78 - (withdrawn) full freeze on a resting pose
- Tried freezing the whole ally page on a calm moment. Wizard and Lizardman never stand still, so it looked wrong; replaced by v79. Not part of the final code.

## v79 - ally CODEX pages loop the whole animation, the text stays
- Replaces the v77 freeze/restart. Once the description has typed out it stays on screen, and the animation under it (level 1 -> 3 -> 5 -> 7, one attack cycle per level) repeats forever with no fade or blank screen.
- The game's "done" step fires exactly when the last level's cycle ends. `CodexStep` (hook `$81:FA54`) now, in the CODEX, sets the step counter back to 0 and clears the stored levels (`$0412`, `$0413-$041A`), so the next cycle is level 1 again; the ally's own animation just continues. Outside the CODEX nothing changes.
- A/B/X/Y now only speed up the typing; once the text is done they do nothing. LEFT / RIGHT / START as before. `CodexAllyTimer` still returns without the auto-advance. The v77/v78 restart and freeze code is gone (`CodexReplay` remains but is no longer reached from the CODEX).
- Tests: all 8 allies restart at frame 690 +- 1 and repeat every 864 frames; 4 of them are pixel-identical from loop to loop, the others differ only in a few mid-cycle frames (random attack paths); level reads 1 after the restart with the text unchanged; A/B/X/Y after the text does nothing; fast typing, LEFT/RIGHT/START, options, saves unchanged.

## v80 - Lizardman text: comma after STRENGTH
- "STRENGTH, SPEED AND". The line was one byte too tight to patch in place, so the Lizardman description now has its own copy (`TxtLIZARD`, after `TxtTHIEF` in bank `$89`) and its pointer at `$00:D83A` is repointed (the original at `$07:B309` is left untouched; the attract loop uses the same pointer, so it shows the comma too).

## Music per floor (information, not a patch)
- Floor start (`$80:F380`): song id = table at `$00:F421`, indexed by `$0403` (floor), 55 entries (floors 0-54); the id goes to the loader `$08:803A` (song pointers at `$08:8DD3`). Other songs are started by events through `$80:F3A9` (title, shop, bosses, story...).
- Floors per song id: `0F` 24 floors (2,4,5,8,10,12,13,15,16,18,21,23,24,25,27,29,30,35,36,37,40,42,44,47); `0D` 8 (3,7,19,22,33,39,46,48); `07` 4 (38,41,43,45); `04` 3 (6,9,20); `06` 3 (26,32,34); `0E` 3 (11,28,31); one floor each: `02` (0), `03` (1), `05` (14), `08` (17), `16` (49), `10` (50), `13` (51), `12` (52), `19` (53), `15` (54).
- Event-only ids (no floor): 01, 09, 0A, 0B, 0C, 11, 14 (3 calls), 17 (2 calls), 18, 1A. Ids that floors use AND events also call: 08, 13, 15, 19.

## v81 - the CODEX plays song 05
- Entering the CODEX from the title now starts song 05 (fixed, no option yet); it keeps playing through all pages (no restart on page changes) and stops with the fade when leaving; the title song restarts as before.
- Why the CODEX was silent: the game's screen-blank routine `$00:8299` calls `JSL $80:F3BD` (song `$19`, silence) and switches the NMI off (`$4200 = 0`). Every fade-out ends in it. The song loader `$08:803A` waits for the NMI (`$1242` is cleared by it), so calling it with the NMI off hangs the game.
- `TitleLoop` (after the fade-out) sets `$4200 = $80`, `lda #$05 : jsl $80F3A9`, then `$4200 = 0` again. The page-change blanks (`CodexNav` in slot.asm, the Hall exit in hiscore.asm) no longer call `$8299`; they do its other steps (`$2100 = $80`, `$4200 = 0`, `$1253 = 0`) inline so the song is not cut.
- Cost: song loading adds about 40 frames (0.7 s) of black when entering the CODEX (black for 60 frames instead of 20).
- Tests (audio level per 30-60 frames): continuous music over all 10 pages, wrap, items, START to the title and the title song coming back; loader argument checked (pointer `$08:BCC5` = song 05); regressions (lp4, cx1, fast75, op75, sv74) unchanged.

## v82 - stray sound in the Hall of Heroes (stale sound-effect queue)
- Cause: the game keeps a ring buffer of pending sound effects (write index `$0B20`, read index `$0B21`, entries `$0B22-$0BFF`; enqueue `JSL $80:F3D1`, dequeue/send to the SPC `JSL $80:F3EE`). The ally animations enqueue their attack sounds (Cleric 6, Wizard 5, Thief 9, each followed by 0), but nothing drains the queue on the ally pages, so the entries pile up (~2 per cycle). The next scene that does drain it (the Hall of Heroes) then sent them all, one per frame. Not a memory overwrite: the writes stay inside `$0B20-$0BFF` (the index wraps at `$DE`). On a very long stay on an ally page the write index wraps around to the read index and the queue would then look full of stale entries.
- Fix: the queue is emptied (`JSL $80:F40C`, with DB = $80) in `CodexEnter` (every CODEX page start) and in `Dispatch .track` when scene < 3 is reached from the CODEX (`!CodexOn = 1`), i.e. when leaving to the title. Before this, leaving after 4000 frames on the Cleric left 40 pending entries.
- Tests: with the author's save state (items page, 2 entries pending) RIGHT now gives no extra sound; queue indexes are 0/0 after every page change; the title shows 0/0 after leaving a long Cleric page; regressions unchanged.

## v83 - OPTIONS: CODEX MUSIC item
- New OPTIONS item 6 "CODEX MUSIC" (row 20 label, value row 21), before RESET SCORES. Values: NONE, 00-25 (decimal Music Test numbers). Default 05. LEFT/RIGHT cycle with wrap.
- RESET SCORES is now item 7 (rows 23/24); EXIT is item 8 (row 26).
- Saved with the other options: SRAM $70:0018 = value, $70:0019 = value xor $A5. Independent of the old checksum, so older saves stay valid and fall back to 05.
- Bank $80 free space ($F76C-$F7CF) was too small; OptLeft/OptRight bodies live in bank $86 ($86EB00) with stubs in bank 80 (assert pc() <= $80F7D0).
- Tests: default plays 05; NONE saved, silent, survives power cycle; bad/old SRAM -> 05; RESET combo, options save/load, audio continuity, no stray sound all pass.

## v84 - CODEX MUSIC moved between CONTROL PAD and MUSIC TEST
- Screen rows: GAME LEVEL 6/7, CONTROL PAD 9-12, CODEX MUSIC 14/15, MUSIC TEST 17/18, SOUND TEST 20/21, RESET SCORES 23/24, EXIT 26.
- Internal item numbers are unchanged (so the game's own handlers, the save format and the reset/exit code are untouched); only the cursor path changed: UP/DOWN use a screen-order table (NavUp/NavDown, bank $86 $EC00; order 0 1 2 3 6 4 5 7 8).
- Music Test / Sound Test draw addresses moved +$60 (3 rows); CODEX MUSIC label/value moved -$C0.
- Tests: cursor order both directions, Music Test still changes/plays, RESET combo, EXIT saves options, CODEX MUSIC default/NONE/power cycle/old-save/bad-value, audio continuity, no stray sound.

## v85 - Big Man regen retuned
- tools/bigregen.asm: row `$01:8AE6` is now 660,600,540,480,420,360,300,240 frames per block (11.0 s at L1, 10.0 s at L2 where he first appears on floor 0, 4.0 s at L8). v59 was 800..240 (13.3 s at L1, 12.0 s at L2).
- ROM diff v84 to v85: only that row and the header checksum.

## v86 - Thief star on the hidden warp doors
- While the Thief is the active ally, a star (the door's own crest, 16x16, trimmed from 20x17) twinkles at the centre of each hidden warp door's trigger zone, on the hidden-chest timing (`$0601 & $1E == 0`: 2 frames in every 32). It goes away once the door is triggered.
- Hidden doors: object class `$0156` on floors 1, 7, 14, 17, 34, 39 (see HIDDEN_DOORS.md). Trigger zone: 32x32, left = `+A0*8 - $132C`, top = `+AC`, hit by the sword (hitbox slot 8).
- Hook `$05:9686` (state 2 of the door object; orig `SEP #$20 / LDA $001B,Y`) to `StarHook` at `$86:FA00`. Draws through the door-hint `DrawIcon` (icon code 11, graphics entry 12 / id `$7E2C`, cache records at object `+D0..+DF`, cooldown group 1, door reserve). Releases its slot when the Thief is not active, the zone is off screen, or the door has triggered.
- Colours: loads the door's palette (`$1F:81FA` source, the same call the door makes) into OBJ palette 7 if it isn't there already. Palette 7 is empty on floor 17 before the door appears.
- Graphics: `asm/star.bin` (generated by `scripts/mkstar.py`), at `$16:BF00`.
- Tests (floor 17 state, Thief): star drawn at the zone centre in the door's colours, 2 frames per 32; trigger frame and every frame after the trigger identical to v85 (records released, pool count equal); non-Thief allies: 96 frames pixel-identical to v85.
- Not yet tested: floors 1, 7, 14, 34, 39 (need save states).

## v87 - floor 1 Thief; star palette fallback
- Door swap: floor 1's second door (`$1E:839C`) now holds the Thief (was Cleric), floor 2's first door (`$1E:8596`) the Cleric (was Thief), so a Thief can reach the floor-1 hidden door.
- Star palette fallback: if OBJ palette 7 holds something other than the door's colours (floor 14 has an enemy that loads its own palette there), the star leaves palette 7 alone and draws a silver copy in palette 0 (`asm/star0.bin`, icon code 12, id `$7E2D`). If palette 7 is empty it loads the door's colours (palette 0 for that one frame). Switching between the two copies gives the old graphic back first.
- Hidden door destinations: the door writes +AE to `$0403` and the next floor is +AE+1 (forcing +AE = N-1 on the floor-7 door landed on floor N). So: 1 -> 4, 7 -> 11, 14 -> 19, 17 -> 20, 34 -> 36, 39 -> 42.
- Tests: floor 17 unchanged from v86 (star, trigger, every frame after the trigger identical to v85). Floor 7 (stairs state): star at the top-left of the first room; a jump-attack there raised the door. Floors 1, 14, 34 (reached through the floor-7 door with +AE forced): star drawn in the door's colours at the zone, palette 7 loaded. Floor 14 with palette 7 overwritten by the enemy palette: star switched to the palette-0 copy and left palette 7 alone. Non-Thief: 96 frames identical to v85 on floor 17.
- Not tested: floor 39 (test walker could not get past the lava), triggering the door on floors 1, 14, 34 (zones are high up; the walker could not reach them).

## v88 - easter egg: start with the ally you name
- A new game whose name is AMAZON, BIGMAN, WIZARD, KNIGHT, LIZARD, NINJA, THIEF or CLERIC starts with that ally, at the level-table level for the start floor (`$07:F1B0`, the game's own start-floor rule). Documented in SECRETS.txt; README QOL points to it.
- slot.asm: `EggCheck` (called from `StartNewGame`) matches the name; the result goes into the slot record: `+$BC` = 1 + type, `+$BD` = the run's first floor ($FF until it starts). WRAM `$7F:E000+` can't hold it: the floor loader overwrites that whole area.
- `EggGet` returns the egg only on the run's first floor (sets `+$BD` the first time, clears `+$BC` on any other floor). A resume of the first floor applies it again, because the save snapshot is taken before the ally is picked.
- Hooks: `$00:8351` (`EggFloor`: floor start with no ally and no start-floor ally pending, i.e. a game from the BEGINNING, sets `$0424`, `$0412`, `$0413+type`), `$00:838C-$839C` (`EggAlly`: start-floor ally pick; the named type or the table's, then the original id calculation; `$13E0` is left alone, it holds floor*8 for the level lookup). Code at `$89:F800` (the `$89:C400` block has 16 bytes left before `$89:F000`).
- Tests: all 8 names from the BEGINNING (right ally, Big Man L2, others L1); THIEF/LIZARD/BIGMAN/CLERIC from floor 5 (table levels); HERO, THIEFX, lowercase: no change; HERO from the BEGINNING and from floor 5: 60 frames identical to v87; resume of the first floor keeps the named ally (floor 0 and floor 5); next floor with the ally gone: no ally given.

## v89 - Thief's Log, part 1: record the floors finished with the Thief
- New `asm/thieflog.asm` (added to the build list after bosswarn). SRAM `$70:0500` (shared by all saves): +0 marker `$7A`, +1..+7 one bit per floor 0-55, +8 check (sum xor `$A5`), +9 pending hidden-door destination.
- Floor completion point: `$00:8730` (`LDA $0403 / INC A / CMP #$33 / STA $0403`), reached by the normal exit and by hidden-door warps. Hook `LogFloorEnd` marks `$0403` when the Thief is the active ally (`$0424 = $15`, `$042E = 0`).
- Warps: `$05:98D9` writes the door's destination - 1 into `$0403` first, so hook `LogWarp` marks the floor being left and stores the destination in +9; `LogFloorEnd` skips that floor once.
- Tests: Thief warp 7 -> 11: log = {7}. Thief warp to 5 then walk out of floor 5: {5, 7}, check valid. Knight (forced) the same way: nothing recorded.
- CODEX room check: the slot screen already builds its own BG1 tile set ($2000) and 32x32 tilemap ($3000), BG3 text and sprite portraits with its own OAM upload, and the Hall of Heroes uses OBJ base $6000 with 16x16 sprites. The log page can be its own scene on the same pattern (BG1 64x32 tilemap for the strips, BG3 text, sprites for the icons).

## v90 - Thief's Log page (CODEX page 1)
- CODEX pages are now 0 Hall of Heroes, 1 Thief's Log, 2-9 allies, 10 magic items (CodexNav wraps at 11; CodexFromHall: next -> 1, previous -> 10; CodexEnter: page 1 -> `LogScene`, allies = page - 2, items = 10).
- `asm/logpage.asm` (incsrc'd at the end of slot.asm; code at `$89:B600-$BFC0`, graphics at `$96:C000`, generated by `scripts/mklog.py`): one framed strip per floor 0-50, five on screen. Drawn from the floor record lists at run time: ally heads (class $21, contents 3..24), hidden chests (class $42, +$0B bit 1), the star for hidden doors (class $0156), the exit door (class $4E), a start arrow (at the right end on floors that run right to left), boss names in the gap row under the strip (0, 4, 12, 24, 29, 36, 49, 50). Strip tile u = position / 7 + 1, length = largest position / 7 + 4 (max 61). Icons that would overlap move right.
- Floors not in the log: a short dim strip with "???".
- Controls: UP/DOWN one floor (held: repeats after 16 frames, every 6), LEFT/RIGHT 8 tiles; LEFT at the left edge -> Hall of Heroes, RIGHT at the right edge -> first ally page (fresh press only); START -> title.
- VRAM on this page: BG3 font $0000 / map $5C00 (the shared shadow), BG1 strips $2000 / map $4000 (shadow `$7F:F000`, uploaded only after a change), BG2 star field (HiGfx), sprites $6000 (OBSEL $63). On exit `$2107`/`$210B` go back to the game's defaults ($51/$31), or the Hall of Heroes' tower comes up garbled.
- asar note: decimal immediates in 16-bit code need `.w` (`cmp.w #29`); asar sizes immediates by value.
- Tests: page order both ways (Hall -> Log -> Big Man, back, Hall -> items -> Hall), START -> title; screenshots of floors 0-4, 13-17, 25-29, 46-50 at X = 0 and 16 with a test log.
- Not done yet: looping floors, the alternate floors 52-55, the OPTIONS item to clear the log.

## v91 - Thief's Log controls: one selected floor
- LEFT / RIGHT always turn the CODEX page (no more edge rule). UP / DOWN move a selection through the floors (the list scrolls to keep it on screen); L / R scroll only the selected floor's strip (8 tiles a step; UP/DOWN and L/R repeat when held). A newly selected strip starts at its left end.
- Selected floor: gold floor number and a bright frame (BG palette 4); other logged floors palette 6 (a little dimmer); floors not in the log palette 5.
- Floor 0 is no longer listed (no Thief there in normal play): the list is floors 1-50.
- Tests: L/R scroll only the selected strip; selection moves down/up with the list following (top floor 46 when floor 50 is selected); page order and START unchanged.

## v92 - Thief's Log: warp destinations
- Each hidden-door star is followed by the floor it leads to (record +$0E + 1), in white on the strip's lower inner row; the next icon moves right to clear it. Text drawing is now `LogCh` (one clipped character at !LgU, row !LgRow + !LgTo), used by LogText and `LogDestNum`.
- Checked: 1 -> 04, 7 -> 11, 14 -> 19, 17 -> 20.

## v93 - Thief's Log: spacing, title, hint, plain background
- Icon placement uses an occupancy map of the strip (`!LgOcc`, 64 bits): each icon takes 3 tiles (2 + a gap), a star with its destination number 5; an icon moves right to the first free run. The strip grows to hold icons pushed past its end (max 61). Fixes floor 39 (the Thief's head sat on the "42") and heads touching on floors 7 and 17.
- Title in the big letters at row 1 ("THIEF" + a small apostrophe + "S LOG", the big font has none); hint "L OR R TO SCROLL" on row 27 (footer blue). Boss names moved to the gap row above their strip.
- Selected floor number white, the others dim grey (BG3 text palette 4 replaced on this page).
- Plain black background: BG2 star field off ($212C = $15), backdrop black. BG3/BG1 map rows 28-31 are zeroed (VOFS 0 shows a line of row 28: that was the junk under the hint).
- Code layout: `$89:B600-$BFFF` (assert before $89:C000, the ally text) and `$89:AA00-$AFFF` (LogUpBg, LogClrRows, LogGfx, tables, strings).
- Checked: the six warp floors (1, 7, 14, 17, 34, 39) at every scroll step; page order and START.

## v94 - Thief's Log: round end orbs
- The end-cap orbs were 9 pixels wide in an 8-pixel tile column, so the right cap lost its left edge. Both caps now draw a 7-pixel orb centred in the column (scripts/mklog.py, asm/log_bg.bin).

## v95 - Thief's Log: clean exit to the title
- START faded out with the game's default BG1 settings already restored, so the Hall of Heroes' tower showed through during the fade. `LogRegs` ($2107 = $51, $210B = $31) now runs after the fade on the title path, and after the screen is blanked on the page-turn path.
- Checked: the fade from the log to the title (only the log fades), and the page order both ways.

## v96 - CODEX pages on L / R; attract loop leaves on START only
- CODEX: L / R turn the page on every page (Hall of Heroes `HiInput`, ally pages `CodexAllyPad`, items `CodexItemPad`, Thief's Log). The Hall's footer now reads "L OR R FOR MORE".
- Thief's Log: UP / DOWN select a floor, LEFT / RIGHT scroll the selected strip one tile at a time (a tile on the press, then one every 2 frames after 8 frames held). Hint: "LEFT OR RIGHT TO SCROLL". LogFrame only draws the columns on screen. A redraw still takes about 2 frames, so a held LEFT/RIGHT moves about 12 tiles a second.
- Attract loop: only START leaves it. Ally screens and the items screen (`CodexAllyPad` / `CodexItemPad` original paths: `$1246 & $10`), the Hall of Heroes (HiMode 1: `!HiPad & $1000`), and the gameplay demo (`$00:893C`: was `LDA $4218 / ORA $4219`, now `LDA $4219 / AND #$10`). (`$00:C014` is the title menu's cursor, not an exit: left alone.)
- Tests: in the attract loop A/B/X/Y keep the ally screen, items screen, demo and Hall of Heroes running and START leaves each one; CODEX page order with L/R both ways; RIGHT on the Hall does nothing.
- v96b fix: the title screen was garbled in v96. The Hall of Heroes changes made the `$89:C400` block 8 bytes longer, so its last table (`TitleRows`, the title's CODEX item and copyright rows) ran past `$89:F000`, where `LoadOptions` is assembled afterwards and overwrote its tail. `TitleRows` now has its own spot at `$89:F100` (free `$89:F06C-$F2C0`), and an `assert pc() <= $89F000` guards the block's end. Title screen pixel-identical to v95; CODEX paging and the attract-loop tests rerun.

## v97 - Thief's Log layout: centred numbers and "???"
- Strips are 3 tile rows (24 px; new tile set: 1-3 middle, 4-6 left cap, 7-9 right cap, orb centred on the middle row) on rows 4, 9, 14, 19, 24, so the floor number and the warp destination sit on the strip's middle text row. Icons are drawn 4 px into the strip. Boss names stay in the gap row above.
- Floors not in the log: 13-tile strip (`!LgQLen`) with "???" exactly in the middle (was 12, off by half a tile).
- The scroll hint is gone (LEFT / RIGHT are obvious now that pages use L / R).

## v98 - Thief's Log: loop arrows on looping floors
- Floors 9 and 33 loop (walking off one end brings you back in at the other; found in play). Their strips use green circular-arrow end caps instead of the red orbs, at both ends. Floors not in the log ("???") keep the plain orbs so nothing is given away.
- Code: `LgLoopFl` (`db 9, 33, $FF`, in the table area at `$89:AA00+`), `LogLoop` sets `!LgLp` (`$7FF829`) to 6 for a looping floor in the log; LogFrame's caps use tile 4/7 + `!LgLp`. New BG tiles 10-12 (left loop cap) and 13-15 (right loop cap) in log_bg.bin; colours 7-9 of BG palettes 4 and 6 (scripts/mklog.py, `LOOPV=B`). Options A (green orb) and C (two arrows) were mocked up; B was picked.
- Checked: floors 9 and 33 at both ends; floor 33 unlogged shows "???" with orbs; other strips identical to v97.
- To add a looping floor later: add it to `LgLoopFl`.

## v99 - Thief's Log in the pause screen; door icon without the dot
- While paused, SELECT opens the Thief's Log: the list starts at the floor being played (selected), and a gold box (37 x 32 px, OAM slots 0-5, built from a 16x16 corner and edge with flips) sits over its strip where the screen is: left edge = `$132C` / 7 + 8 strip pixels, width 256 / 7. The strip starts scrolled so the box is in view. No box when the floor isn't in the log ("???"), or on floors 0 and 51+ (the list then opens at 1 / 50). SELECT goes back to the pause screen, START unpauses. UP/DOWN/LEFT/RIGHT as on the CODEX page; L/R do nothing here.
- Hook `$00:8A31` (pause check, both main-loop paths) -> `PauseHook` (`$89:FA00`), view code `LogPauseL` there too. The view reuses the CODEX page code with `!LgPz` = 1: BG1 strips go to the game's own BG1 map `$5000` and tiles 0-15 at `$1000`, BG3 text to `$5C00`; the game's BG3 font already has the menu letters, digits and big title letters at the same tiles (checked), so no font upload. NMI stays on; the view waits on `$1242` like the game.
- Backups in `$7E:2600-$5A57` (the area no floor touches): WRAM `$7F:E000-$F82F`, `$00-$0F`, `$0776-$0787`, `$04A7-$04A8`, `$1302-$1303`, `$0ED2`; all CGRAM; VRAM `$5C00-$5FFF`, `$5000-$53FF`, `$1000-$10FF`, `$6000-$63FF`. Registers on the way out: `$212C` = `$17`, BG1/BG2 VOFS and BG3 scroll 0, brightness = `$1252` - 1 (the game's fade-in leaves the screen at `$0E`, not `$0F`), OAM re-sent with the game's own channel-2 setup copied to channel 7; BG1/BG2 HOFS and `$420C` come back from the NMI.
- VRAM reads need one dummy word after setting the address (a read reloads the buffer from the address before it steps: hardware, Snes9x and bsnes alike); without it every block came back shifted by one word.
- Checked (scripts/pv8.py, pvsec.py): floors 1-54 reached through the floor-7 door, 5 points each while walking/fighting (227 pausable points, incl. the Gold Dragon, Skull Chimera, Twin Worms, Dragon, Hydra and Queen Chimera fights) plus 13 points through the Drokmar fight from the floor-50 save: pause -> view -> back is identical to a plain pause in screen, VRAM, CGRAM, OAM, PPU/DMA registers and all WRAM outside the backup area (only the stack below SP and the frame counter `$0460`, which doesn't run while the view is open). START from the view vs a plain unpause, compared frame by frame for 256 frames on 12 points: identical, except 2 points that drift later from the frame counter (random numbers). CODEX log page pixel-identical to v98.
- Door icon on the maps: the keyhole dot is gone (scripts/mklog.py).

## v100 - a floor is in the Thief's Log as soon as the Thief is on it
- Was: marked when the floor was finished with the Thief. Now: marked the first frame the Thief is the active ally on it, however he got there (carried over, start-floor ally, resume, name, freed from a cell door, hidden door). Saved to SRAM at once, so the CODEX and the pause map show it right away, even if he dies or you reset before the exit. The end-of-floor marking stays.
- `ThiefSeenL` at `$86:D7C0` (thieflog.asm), called with `JSL $86D7C0` at the top of `PauseHook` (every main-loop pass, paused or not). Skips: attract demo (`$0402` = 4), not in play (`$0430` <> 0, the pause button's own test), not the Thief (`$0424` <> `$15`), dying (`$042E`), floors 56+, floors already in the log (SRAM written only once per floor), and the frames after a hidden door has written its destination - 1 into `$0403` (record +9; the first build marked floor 10 on the way through the floor-7 door to 11).
- Checked: Thief on floor 7 marked within 5 frames; warp 7 -> 11 gives {7, 11}; Knight for 300 frames: nothing, then switching `$0424` to the Thief marks it at once; dying: nothing; 12,000 frames of attract loop and every CODEX page: SRAM untouched; pause-view state check on floors 1, 7, 9, 17, 24, 33, 39, 50 still identical. Not run: freeing a Thief from a real cell door (the harness can't open doors), only the switch itself.

## v101 - CODEX order: Magic Items right after the Thief's Log
- Pages: 0 Hall of Heroes, 1 Thief's Log, 2 Magic Items, 3-10 the allies (Big Man ... Thief). `CodexEnter` maps page 2 to scene $0C and pages 3-10 to ally page - 3; `CodexNav` and `CodexFromHall` keep their numbers (L from the Hall still goes to page 10, now the last ally).
- Checked: R through all 11 pages and back to the Hall, L from the Hall (Thief, Lizardman, Wizard), L from the items page to the log and then the Hall, START to the title.

## v102 - Thief's Log: a B where the boss appears, the boss name centred over it
- Boss floors show a gold B on the strip's middle row at the boss's own record, and the name sits in the gap row above, centred on the B (was: lined up with the strip's right end). The selected strip scrolls far enough to show the whole name when it runs past the strip's end (Gold Dragon, Skull Chimera).
- Boss objects (`LgBossCl`, found in play by listing the live objects' class `+$A6` and position `+$A0` while each boss was on screen): floor 4 `$00F9` (pos 186), 12 `$010B` (198), 24 `$014A` (161), 29 `$00BA` (92), 36 `$0123` (147), 49 `$0174` (32), 50 `$0186` (256). Floor 0's Chimera isn't listed (the log starts at floor 1).
- `LogBossRec` (from LogIcons) reserves 2 strip tiles through `LogPut` with icon code `$FF` (no sprite) and writes the B with `LogCh`; `!LgBU` hands the B's tile to `LogBoss`. LogPut and LogOcc moved to a new block at `$89:F400` (free `$89:F3D2-$F7FF`); the `$89:FA00` block was full.
- Checked: all seven boss floors in the CODEX at both ends; non-boss strips identical to v101; pause-view state check on floors 4, 12, 24, 29, 36, 49, 50, 7 still identical.

## v103 - boss names centred on the whole strip
- The boss name is centred on the strip ((strip length - name length) / 2), not over the B; the B stays where the boss appears. The v102 extra scroll for names past the strip's end is gone (not needed).
- Checked: the seven boss floors in the CODEX; pause-view state check on floors 4, 24, 49, 50 still identical.

## v104 - floor 19 loops
- Floor 19 added to `LgLoopFl` (now 9, 19, 33; found in play). Its strip gets the green loop arrows at both ends. The table grew by one byte, so the boss tables and strings after it moved up one byte (ROM diff 173 bytes, all in that area plus the checksum).

## v105 - boss names revised
- Thief's Log boss names: 4 GOLD DRAGON, 12 SKULL CHIMERA, 24 CELESTIAL SERPENTS (was TWIN WORMS), 29 EMERALD DRAGON (was DRAGON), 36 HYDRA, 49 QUEEN CHIMERA, 50 LORD DROKMAR (was DROKMAR). Checked on all seven strips (centred, the 18-letter name fits the floor-24 strip).

## v106 - boss warning on floor 28 (before the Emerald Dragon)
- Floor 28's message was 5 lines, too long for the warning. Now: THERE ARE / RUMORS OF / SECRET / DOORS. / (blank) / BOSS AFTER / THIS FLOOR! (7 lines). New text `Warn28` in bosswarn.asm ($86:D400 block), floor-table entry `$00:CACC` repointed; message 24 was used by floor 28 only.
- Checked: all 52 floor messages rendered; only floor 28 differs from v105. No warning before Lord Drokmar (decided: not needed).

## v107 - fix: black screen entering the CODEX after playing and resetting
- Playtest report with save states: after playing, reset, then CODEX -> black screen forever. The CPU was stuck in the song loader's upload handshake (`$08:8218`) loading song id `$98`.
- Cause: the CODEX MUSIC value lives in WRAM `$7F:E7A8`, which the game overwrites in play (all of `$7F:E700-E7FF` is game data there; floor 7 leaves `$23`), and it was only set from SRAM by the power-on hook. A soft reset finds the game's "CAPC" stack signature and takes the warm-boot path (`$00:8105`), which skips the power-on defaults (`$80:DFC3` -> our PowerOnHook). So the CODEX looked up Music Test number 34 past the end of the song table.
- Fix (options.asm, slot.asm): `MusTitle` ($86:E700, from Dispatch at every title start) and `MusLoad` ($86:E710, at the CODEX entry) read the value back from SRAM (`$70:0018`, checked with `$70:0019`), else the default 6. `WarmHook` (`$00:8105` -> $86:E740) also sets them on the warm-boot path, together with the intro-skip flags `$7F:E7D6/E7D7`: after a reset from play the intro skipped itself (`$E7D7` was `$FF`).
- Checked: the author's title state now enters the CODEX at every wait tried (it hung every time in v106); reset from a floor-7 state with saved CODEX MUSIC NONE, 00, 12 and 25 plays the saved choice; OPTION MODE change -> save -> CODEX plays it; intro after a reset plays normally and START still skips it; CODEX pages pixel-identical to v106; pause-view state check on floors 7, 17, 50.
- Other `$7F:E7xx` variables were checked for the same pattern: the slot screen, Hall of Heroes, CODEX, log page and pause view set theirs on entry; Dispatch's `!LastSc` is written at every scene change, after play has ended.

## v108 - START in the attract demo goes straight to the title
- Was: START during the gameplay demo still showed the Hall of Heroes, because Dispatch shows it whenever the title follows the demo (scene $10). The demo's START exit (`$00:895F`, `$1253` = 2) now sets a flag (`$C5` at `$7E:6FF0`, in the area the game never touches; our `$7F:E7xx` variables don't survive the demo, which is play); `DemoQuit` ($86:E760, JSL from Dispatch `.attr`) clears it and skips the table. The demo running out of time still shows the table.
- Checked: START in the demo -> title (v107: table); demo timing out -> table; START in one demo, then the next demo timing out -> table again (the flag doesn't carry over).

## v109 - CODEX ally pages in the order the allies first appear
- Pages 3-10: Big Man, Amazon (floor 0), Ninja, Thief (floor 1), Cleric, Wizard (floor 2), Knight (floor 9), Lizardman (floor 17). First appearances from the floor records (cell doors, class $21), with the floor 1/2 door swap of v87.
- `AllyOrder` ($86:E780, JSL from CodexEnter) maps the page to the game's ally-screen number `$0462` (attract order 0 Big Man, 1 Knight, 2 Ninja, 3 Cleric, 4 Amazon, 5 Wizard, 6 Lizardman, 7 Thief) through a table. The attract loop keeps its own order.
- Checked: R through all 11 pages (right ally and description on each), L from the Hall (Lizardman, Knight, Wizard), START to the title.

## v110 - floor 22 loops
- Floor 22 added to `LgLoopFl` (now 9, 19, 22, 33; found in play). Checked: loop arrows at both ends of its strip.

## v111 - fix: the good ending put the Knight's head in the Hall of Heroes
- Playtest report (state before choosing the good ending, Thief run): the table showed the Knight. The good ending's scenes ($1A-$24) reuse `$0424` to show the allies one at a time (the Thief run went Thief -> Wizard -> Ninja -> Thief -> Knight), and the entry was recorded by `RunEnd` at the title afterwards, reading `$0424` = Knight. The bad ending ($18) doesn't touch it.
- Fix: `EndRec` ($86:E7C0, reached from `MusTitle` at every scene start) calls RecordBest (new fixed entry `JSL $82FB00` in slot.asm) when scene $16 (good ending) or $18 (bad ending) starts, while `$0424` is still the run's ally. `RunEnd` (hiscore.asm) skips its own RecordBest after an ending (`!HiClr` set).
- Checked from the author's state: good ending -> THIEF, 2,068,820, star 50, Thief L8 (v110: Knight); bad ending -> Thief in both; game over on floor 50 with the Knight save -> Knight in both.

## v112 - text pass: Thief description, Magic Items page, floors 15 and 21; boss names left-aligned
- Thief (CODEX and attract loop, text.asm): HIS BOMB HAS A SHORT / RANGE. HE SPOTS TRAPS, / SECRETS, AND ALLIES. A / SCOUT, HE KEEPS A / DETAILED LOG OF EVERY / FLOOR HE REACHES.
- Magic Items page (new items.asm + scripts/mkitems.py): Golden Pot HEALS / YOUR ALLY.; Crystal Ball FINDS TREASURE / CHESTS.; Magic Potion MAGIC BAR FILLS / TWICE AS FAST. (checked in code: item `$06` in the item box makes the bar step every 4 frames instead of 8, `$00:ADE6`, the only check for it); Diamond Ring BRIBES THE / LIZARDMAN.; Scroll ENEMIES DROP / MORE TREASURE. (SCROLL_DROPS.md). The page's two draw lists (`$07:BA07` $12C bytes, `$07:BB2F` $270 bytes; entries = VRAM address, tile, attribute, drawn by `$00:C3F8`) are rebuilt as one list at `$8B:E000`; `$00:D935/D93B/D941` repointed, `$00:D94A` = RTS (the second list).
- Floor 15: THE THIEF / SPOTS TRAPS / AND MAPS / EVERY FLOOR / HE REACHES. Floor 21: ...YOUR MAGIC / BAR. (was METER; "magic bar" everywhere now). hintdata.py -> genhints.py -> hints.asm.
- Thief's Log: boss names start at the strip's left end (v103-v111 centred).
- Checked: all 52 floor messages, only 15 and 21 differ from v111; items page, Thief page and the boss strips (4, 12) on screen; pause-view state check on floors 4 and 15.

## v113 - boss names start over the strip's box
- The name starts at strip column 1 (column 0 is the end orb, and the box's frame starts half-way through it), so it no longer sticks out past the box's left edge. Checked floors 4 and 12.

## v114 - Thief's Log clear of the CRT overscan
- Floor numbers move from screen columns 0-1 to 1-2 (8 px in), strips from column 3 to 4, so 28 strip columns show at a time (was 29). `LogCol` (+4, 28 wide), LogFrame's right-edge test, the LEFT/RIGHT scroll limit and the pause view's start clamp use 28; the pause view's screen box is offset 32 px (was 24) and hides left of 32.
- Checked: CODEX page (warp floors, a strip scrolled to its end with the right cap on column 31, boss names), pause view open/back/START on floor 7 (back to the pause screen pixel-identical), pause-view state check on floors 1, 17, 39.

## v115 - OPTION MODE: RESET CODEX (was RESET SCORES)
- Item 7 is now RESET CODEX. LEFT/RIGHT choose CHOOSE -> HALL OF HEROES -> THIEF'S LOG -> EVERYTHING (wrapping); it is CHOOSE every time OPTION MODE opens (`!RstSel` = `$7F:E7A9`, set in OptInitLast before the row is drawn). With a choice made, A+B+X+Y held + START arms it and the reset happens when START is released (as before); the row then says DONE, and the next press goes back to CHOOSE (LEFT/RIGHT move on from CHOOSE at once). With CHOOSE the combo does nothing.
- Rows: label 23 (RESET CODEX, green when highlighted), value 24 (the choice / DONE, centred), hint 25 (PRESS A B X Y START, only on the highlighted row with a choice made). The value and hint rows are built at WRAM `$0300` (read through the bank-07 low-WRAM mirror; `$7E:0300-$03FF` is untouched by the game); label lists at `$07:E500`; code `RstDraw`/`RstLeft`/`RstRight`/`RstDo` at `$86:E800`. Thief's Log reset = a valid empty record (marker `$7A`, no floors, check `$A5`, no pending warp).
- asar again: `ldx #100` in 16-bit X assembled as an 8-bit immediate (garbage on the hint row in the first build); `ldx.w`.
- Checked: CHOOSE + combo does nothing; the choice cycle both ways; THIEF'S LOG clears only the log, HALL OF HEROES only the table, EVERYTHING both; DONE, then RIGHT -> HALL OF HEROES; leaving and re-entering OPTION MODE shows CHOOSE; CODEX MUSIC change/save still works.

## v116 - Cleric food bonus tops out at +75% (was +100%)
- `PriestHeal` (priest.asm, `$81:FE00`): bonus = amount * `HealTbl[level]` / 32, `HealTbl` = 4, 7, 10, 13, 15, 18, 21, 24 (L1 +12.5%, L2 +22%, L3 +31%, L4 +41%, L5 +47%, L6 +56%, L7 +66%, L8 +75%). Was amount * (level+1) / 8 (+12.5% ... +100%). L1 unchanged. Food $20 (32): 36, 39, 42, 45, 47, 50, 53, 56 (was up to 64); food $28 (40): 45, 48, 52, 56, 58, 62, 66, 70 (was up to 80). X is saved around the table lookup. The life trickle is unchanged.
- Checked: the assembled routine run in a small 65816 interpreter for both food amounts at every level (values above, return to `$82:D653`, stack balanced); other allies and a dying Cleric get the plain amount; 900 frames from the Cleric, Wizard, Ninja and Thief states give WRAM identical to v115. No live food pickup run (as in v14).

## v117 - Wizard description
- TxtWIZARD (text.asm): HIS POWERFUL MISSILES / CAN BE AIMED ANYWHERE, / BUT HE HEALS SLOWLY. HE / SHARES HIS POWER, SO YOUR / MAGIC BAR FILLS FASTER. (was ...BUT HE IS SLOW AND FRAIL. HE RECHARGES YOUR MAGIC BAR FASTER.; "slow" came from the original's translation, the real weakness is his slow healing: 1080 frames per block at L1). Same in the attract loop. The text block still ends before `$89:C400` (last change `$89:C38D`).
- Checked: CODEX Wizard page rendered (5 lines, nothing over the sprite); Knight page unchanged.

## v118 - floors 51-55 (the ending scenes) are no longer logged
- Floors 51-55 are the ending: 51 the epilogue (VANQUISHED..... FOR NOW., sunrise, credits start), 52 the credits walk (staff names roll over outdoor scenery), 53-55 short staged scenes (53 uses the silence song). The game reuses the floor engine for them.
- thieflog.asm: `LogMark` and `ThiefSeenL` stop at floor 51 (`cmp.b #51`, was 56). Two bytes changed (`$86:D745`, `$86:D7E4`) plus the header checksum. Bits for 51-55 already in an SRAM record stay (harmless: the log shows floors 1-50 only).
- Checked (scripts/t118.py, Thief forced, empty log, 1,200 frames on each floor): floors 7 -> 11, 49 and 50 are still logged; 52, 53, 54 were logged by v117 and are not now; 51 and 55 were never logged (not in play there). The record stays valid in every case.

## v119 - floor 45 message gets its THE back
- hintdata.py message 47 (floors 45 and 51): WE MUST / RESTORE / LIGHT TO THE / SUFFERING / PEOPLE OF / THE WORLD. ("LIGHT TO THE" is exactly 12 characters; 6 lines.) v58-v118 had dropped THE. Regenerated hints.asm (genhints.py): 42 bytes of the block still free.
- Checked: all 52 floor messages rendered against v118, only floors 45 and 51 differ (same message); floor 45 fits the box.

## v120 - the pause map shows this run's door shuffle on the floor being played
- Finding (playtest report, floors 0 and 3): the original game shuffles some cell doors and chests every time a floor loads in play. `$00:B4F0` -> `$00:B597` (only when `$0402` = 2, `$0602` = 0, `$0401` <> `$10`): records whose position word has bit 14/15 set are collected, put in random order (RNG `$83:87BB`, 1-4 passes), and their bytes 6-21 (class, key type, contents...) are written back in the original record order, doors only among doors (class `$21`) and everything else among itself; positions (bytes 0-5) stay. Shuffled doors: floor 0 Amazon/Big Man; 2 Amazon/trap/Wizard; 3 Ninja/Amazon; 15 Big Man/Wizard/Cleric; 17 Ninja/Lizardman/trap/Amazon; 18 fairy/trap; 27 trap/Knight; 35 Wizard/Lizardman; 39 Thief/Ninja; 42 all 10; 45 Knight/trap; 48 Wizard/trap/trap/Knight. Chests are shuffled on ~30 floors, but hidden chests only ever among hidden chests (checked every floor), so the hidden-chest marks never move. A resume reloads the floor, so it reshuffles.
- On that path the live list at `$7E:FA00` gets no `$FFFF` end mark (the copy loop `$00:B54B` stops at it without storing it).
- Decision: the maps keep the ROM layout (good enough for planning); the floor being played is drawn from the live list in the pause view.
- logpage.asm: `LiveList` (in the `$89:F400` block, called from LogPauseL before the first draw) copies the floor being played from `$7E:FA00` to `!LvBuf` = `$7E:6000`, as many records as the ROM list has, plus an end mark, and sets `!LvMk` (`$7E:5FF0` = floor, `$5FF1` = `$A5`). Every record's bytes 0-5 (word 0 without the flags) must match the ROM list or nothing is marked valid (then the ROM list is used, as before). `LogPtr` uses `!LvBuf` when `!LgPz` = 1 and the strip is that floor; the old body is `LogRomPtr`. Both areas are in `$7E:2600-$6FFF`, which the game never touches. The CODEX page is unchanged.
- Checked: the author's floor-3 state (map now Amazon then Ninja, as in the live doors; v119 Ninja then Amazon); the live list keeps every record's position and the same set of contents at 6 points on every floor 1-50 (scripts/wl1.py); the pause view on every floor 1-50 vs v119: identical on 46 floors, door heads moved on 2, 17, 42, 48 (shuffled; the other shuffled floors happened to come out in ROM order); pause-view state check (pv120.py) on floors 1, 2, 3, 7, 15, 17, 18, 24, 27, 35, 39, 42, 45, 48, 50: 57 points identical to a plain pause outside `$7E:2600-$6FEF`.
- Tool: scripts/dis65.py, a small 65816 disassembler (`python3 dis65.py rom BB:AAAA count [m x]`).

## v121 - fix: game over skipped the Hall of Heroes (and kept the save)
- Playtest report with a save state (floor 12, continue timer running): the run ended with a placing score, but the title came up with no Hall of Heroes, and the slot kept the run.
- Cause: `!LastSc` (the last scene, which Dispatch reads at the title to tell that a run just ended) lived at `$7F:E781`. It is written when play starts, and a floor load writes over `$7F:E700-$E7FF` (floor 12 left `$DF` there), so the title saw neither 0, 4 nor 6 and treated it as a normal title start. The v107 check of the `$7F:E7xx` variables missed it: it assumed `!LastSc` was only needed after play.
- Fix: `!LastSc` = `$7E:6FF8` (slot.asm; `$7E:2600-$6FFF` is never touched by the game). Five long addresses changed, nothing else.
- Checked: the user's state (with `$7E:6FF8` set as v121 would have it at the start of play): 8th place entry and the slot cleared (v120: no table, slot kept); from power-on, new game in slot 1, `$7F:E781` overwritten with `$DF` during play, game over: Hall of Heroes name entry and the slot cleared (v120: neither); attract loop (demo time-out -> table) identical to v120.
- Audit of `$7F:E700-$E7FF` during play: with a non-Thief ally, filling it with junk every frame changes nothing (WRAM outside it and the screen) over 2,400 frames on floors 1, 17 and 20; CPU read/write logs show no game access during play. The only bytes touched are the door icons' own working values (`$7F:E7C0-$E7E6`), which only matter within a floor (the floor-load overwrite comes before them). The other `$7F:E7xx` variables that outlive play are already reloaded (CODEX MUSIC, v107) or reset on entry (RESET CODEX choice, intro flags on warm boot).

## v122 - Thief's Log: objects where the game puts them; right-to-left floors
- Playtest report (save state on floor 19, then floor 20): the floor 20 map didn't match the floor, and the allies looked reversed.
- Cause: the maps placed every object at its record's position (word 0), which is the point where the object is *made*, not where it *is*. The game makes an object when the screen's right edge (`$1328` = scroll / 8 + 32) reaches that position, at screen x = record +2 (signed px). On most floors that is about +250 (just inside the right edge), so the two agree within a tile. On the floors that run right to left (10 and 20) it is about -40: objects come in from the left, about 37 tiles (5 map tiles) left of their position. Records within reach of the first screen are made at once at the floor's start scroll (floors 2, 10, 18, 20, 29 and 49 don't start at 0), so their position says little. On floor 20 the box (from the real scroll) and the door heads were 5 map tiles apart, and the start arrow at the right end pointed right, so the map read as left to right.
- Measured: the live door, chest and exit objects on floors 1, 18 and 20 (`scripts/wx.py`); each floor's start scroll (`scripts/st0.py`): 2 = 256, 10 = 1248, 18 = 368, 20 = 1160, 29 = 256, 49 = 1024, the rest 0.
- logpage.asm: `LogX` gives a record's real tile for cell doors, chests and the exit: max(position - 32, start tile) + (record +2) / 8 (min on a right-to-left floor), at least 0 (start tiles: table `LgStartT`). Hidden warp doors (zone at word 0 x 8) and the bosses' B keep the record position. `LogScan` finds the direction first and takes the strip length from the real tiles and the start screen's right edge. `LogFlip`: the start arrow points left on a right-to-left floor. Scratch `$0782/$0784` (backed up by the pause view).
- Checked: floor 20 from the playtest state: at the start the box is right of the heads with a left arrow; mid-floor with the Wizard and Thief doors on screen the box covers them (v121: 5 map tiles away); the formula agrees with the measured objects within a tile on floors 1, 18 and 20; pause view on every floor vs v121: maps differ by one tile here and there on normal floors, by about 5 on floors 10 and 20; B marks unchanged; pause-view state check on floors 1, 2, 4, 10, 18, 20, 24, 29 and 49: identical to a plain pause.

## v123 - Thief's Log: overlapping icons keep their order on right-to-left floors
- Playtest report (v122, save state with the floor 20 map open): the map showed the Thief left of the Wizard, the doors are the other way round.
- Cause: `LogPut` moves an icon right until it finds free strip tiles. On a right-to-left floor the records come right to left, so the Thief (tile 73) was placed first and the Wizard (tile 57, a 3-tile icon running into the Thief's) was pushed right past him. v121 and earlier had the same swap (also on floor 20).
- Fix (logpage.asm): on a right-to-left floor (`!LgRev`) LogPut looks left first (`$0784` = direction, `$0786` = the tile the icon belongs at); if it reaches the end cap (tile 0) it looks right from the original tile as before. Other floors unchanged.
- Checked: floor 20 at scroll 482 (Thief door on screen, Wizard door just left of it): v122 exit, chest, Thief, Wizard; v123 exit, chest, Wizard, Thief, Thief inside the box (OAM read back); pause view on every floor vs v122: only the screens showing floor 20 differ; pause-view state check on floors 6, 10 and 20: identical to a plain pause.

## v124 - Slot screen: empty the sound-effect queue first (found by cross-emulator testing)
- Found with bsnes (accuracy core, random power-on RAM) and Mesen-S (random RAM by default): RESUME from the slot screen froze the game about 3 times in 4 on bsnes. The game's song upload (`$88:81F6`) waited forever for the sound chip's ready signal (`$BBAA` on `$2140`). Snes9x fills RAM with `$55` and never showed it; a real console powers on with random RAM too.
- Cause: the sound-effect queue (`$0B20-$0BFF`) holds random bytes at power-on, and the slot screen's loop calls `SndTick` (`$80:F3EE`), which sends one queued command to the sound chip per frame. Random commands left the sound driver in a state that never answered the next song upload. The original game never ticks that queue before the game itself has emptied it. Found by delta-debugging the random junk down to the single chunk `$0B00-$0BFF` (bsnes hook: `MS_WRAM_JUNK`, `MS_SEED`).
- Fix (slot.asm): `SlotScene` calls `$80:F40C` (the game's queue-empty routine) first, as the CODEX entry already did (v82).
- Checked: bsnes, resume flow, 15 random power-on patterns (seeds 10-24): v123 froze on 11, v124 on 0. Snes9x: slot screen and resumed floor pictures identical to v123, WRAM differs only in stack residue (`$01D9-$01F7`).
- Not yet confirmed on Mesen-S: its title screen often ignored the scripted START presses (same for v123 and v124), so only one v123 freeze (the same upload wait) and one clean v124 resume were seen there.

## v125 - fix: START during the gameplay demo froze the game (since v109)
- Playtest report: pressing START to leave the attract loop right after the character screens (during the gameplay demo) locks the game for good.
- Cause: a one-byte block collision. The demo's START exit (`DemoStart`, v108) ends with `JML $808964` at `$86:E77D-E780`; the CODEX ally-order code added in v109 (`AllyOrder`) started at `$86:E780` and overwrote that jump's last byte (the bank, `$80`) with its first opcode (`PHX`, `$DA`), so START jumped to `$DA:8964`. asar does not warn when one `org` block runs into the previous one, and the build's own overlap check doesn't see blocks that touch by a byte.
- Found by pressing START through the attract loop on Snes9x (frame counter stopped on every press during the demo) and bisecting the saved builds: v108 fine, v109 through v124 locked. START on the ally screens, the items screen, the Hall of Heroes and the title was always fine.
- Fix: `AllyOrder` moved to `$86:E7A0` (options.asm; the JSL in `CodexEnter`, slot.asm, follows). ROM difference to v124: the moved block (about 60 bytes) and the header checksum.
- New tool: `tools/overlap_check.py` assembles the build with every `org` block's end printed and lists blocks whose address ranges overlap. It finds this bug in v124 and reports 123 blocks, 0 overlaps now.
- Checked: START in the demo at 10 different times on Snes9x (title in every case, the frame counter runs), and at 3 times each on bsnes (random power-on RAM) and Mesen-S: back at the title; START on the ally screens, items screen, Hall of Heroes and demo 2: unchanged; the CODEX pages come up in the same order with identical screens (12 pages compared with v124).
