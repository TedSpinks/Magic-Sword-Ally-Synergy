# Cell door contents: census of every floor

Status tags: **[V]** verified by running, **[C]** read from ROM data only.

> The per-floor list below is the original game. This hack swaps two doors: floor 1's second door holds the Thief (was the Cleric) and floor 2's first door holds the Cleric (was the Thief), so a Thief is available from floor 1.

## Where door contents come from [V]
- Each floor has a list of 22-byte object records. Floor pointer table: `$00:B98A`, 3 bytes per floor, indexed by `$0403` (floor) x 3 (code at `$00:B440`). Lists are in ROM bank `$1E` (floors 0-44, 52-55) and `$17` (floors 45-50); each list ends with a `$FFFF` record. At floor start the list is copied to WRAM `$7E:FA00` and read through the pointer at `$0A8C` (`$00:B78C`), one record per scroll trigger (record word 0 vs `$1328`).
- A record's 22 bytes are staged at `$13E0` (`$00:B7BA`) and copied into the new object's `+A0..+B5` (`$00:B928`). So for a cell door: record byte 6 = `$21` (door), byte 8 = key type, byte `$0B` = contents id.

## Door shuffle [V]
When a floor loads in play (`$0402` = 2, `$0602` = 0, `$0401` <> `$10`), `$00:B4F0` -> `$00:B597` collects the records whose position word (word 0) has bit 14 or 15 set, puts them in random order (RNG `$83:87BB`, 1-4 passes), and writes their bytes 6-21 (class, key type, contents, ...) back in the original record order. Cell doors (class `$21`) only trade with doors, everything else only with non-doors; positions (bytes 0-5) never move. On this path the WRAM copy at `$7E:FA00` gets no `$FFFF` end mark.

Shuffled doors per floor: 0 Amazon/Big Man; 2 Amazon/trap/Wizard; 3 Ninja/Amazon; 15 Big Man/Wizard/Cleric; 17 Ninja/Lizardman/trap/Amazon; 18 fairy/trap; 27 trap/Knight; 35 Wizard/Lizardman; 39 Thief/Ninja; 42 all 10; 45 Knight/trap; 48 Wizard/trap/trap/Knight. Treasure chests are shuffled on about 30 floors, but hidden chests only ever trade with hidden chests. A resumed save reloads the floor, so it reshuffles.

The Thief's Log draws every map from the ROM lists (the usual layout); the pause view draws the floor being played from the live list (see `DEV_HISTORY.md`, v120).

## What each contents id does [V]
Tested by forcing each id into the floor-0 Amazon door and opening it.

| id | Doors in game | What comes out | Thief hint |
|---|---|---|---|
| `$03`-`$18` | 59 | the ally `3*(type+1)` | ally head |
| `$AB` | 7 | skeleton warriors (trap; extra damage) | skull |
| `$B1` | 6 | swarm of purple winged creatures (trap; extra damage) | skull |
| `$D2` | 8 | bouncing boulders (trap; extra damage) | skull |
| `$F0` | 2 (floors 10, 18) | three fairies that hover over the player | fairy icon |
| `$00` | 8 | the door never opens and no key is used | nothing |

**The `$00` doors are a different kind of door:** all eight have key type 0 (record byte 8), while every other door uses key type 1-3. The door code (`$02:C243`) sends any door with contents 0 straight to state 8, skipping the key and UP check. The hidden warp doors are separate objects (class `$0156`, see `HIDDEN_DOORS.md`).

Ally totals across all doors (original game): Ninja 11, Wizard 10, Big Man 8, Cleric 8, Knight 8, Amazon 6, Thief 5, Lizardman 3.

## Per-floor list (original game, ROM order) [C]
```
floor  0: Amazon BigMan              floor 23: Cleric Ninja Wizard $00
floor  1: Ninja Cleric               floor 27: $D2 Knight
floor  2: Thief Amazon $AB Wizard    floor 28: Cleric BigMan Lizard
floor  3: Ninja Amazon               floor 30: Cleric $00 Wizard Ninja
floor  6: BigMan Cleric $B1          floor 31: $B1 Ninja
floor  7: $AB Wizard $00 Thief Ninja floor 33: Amazon $D2 Knight Ninja
floor  8: Ninja BigMan               floor 35: Wizard Lizard
floor  9: Knight                     floor 39: Thief Ninja
floor 10: $AB $F0                    floor 42: $B1 $D2 $00 Cleric $B1 Thief Wizard BigMan $B1 $D2
floor 11: Wizard                     floor 44: $D2
floor 15: BigMan Wizard $00 Cleric   floor 45: Knight $D2
floor 17: Ninja $AB Lizard $AB $00 Amazon   floor 46: BigMan
floor 18: $00 $F0 $AB BigMan Cleric $00     floor 48: Wizard $D2 $B1 Knight
floor 20: $AB Thief Wizard           floor 52: Knight
floor 21: Knight                     floor 55: Ninja Knight $D2 Amazon
(all other floors: no cell doors)
```
Floors 51-55 are the ending scenes (the epilogue, the credits walk and short staged scenes), not playable floors.
