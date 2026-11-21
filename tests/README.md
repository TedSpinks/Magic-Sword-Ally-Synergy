# Tests

Emulator scripts used while developing the patch. They drive the Snes9x libretro core from Python, play the game with
scripted input, and compare screens and memory. They are here for reference and for anyone continuing the work; they
are not a turnkey test suite.

## What you need
- **A work folder**, given by the `MS_WORK` environment variable (default `work/`), with:
  - `rom/`: the clean ROM, `Magic Sword (USA).sfc`, and the patched builds the scripts name at the top (for example
    `rom/ms_v119.sfc` and `rom/ms120.sfc` for an old-vs-new comparison; copy `build.py`'s patched ROM there under those names);
  - `states/`: raw Snes9x save states the scripts start from. Most scripts start from `states/f7_trig.raw`, floor 7 in
    front of the hidden warp door, and set its destination to reach any floor. Save states contain game data, so they
    are not in this repository: make your own (`lr.py`'s `Core.save()` writes one);
  - `shots/`: screenshots and contact sheets are written here;
  - the libretro core, built from Snes9x's libretro port with `tw_core.patch` applied and named as the script expects
    (`s9x_tw3.so`). The patch adds a few calls for reading the PPU state and watching executed addresses.
- Python 3 with NumPy and Pillow.

## Scripts
| Script | Checks |
|---|---|
| `lr.py`, `common.py` | the libretro driver (`Core`: run, pad input, memory, save states, screenshots) and shared helpers |
| `pv8.py`, `pvsec.py` | pause view memory safety: on each floor given, pause -> Thief's Log -> back vs a plain pause, compared in screen, VRAM, CGRAM, OAM, registers and WRAM |
| `wl1.py` | the game's live floor list at `$7E:FA00` keeps every record's position during play |
| `lv2.py` | pause map on every floor, old build vs new build |
| `t118.py` | which floors the Thief's Log records (floors 51-55 must not be recorded) |
| `v65t.py` | renders every between-level message and compares two builds |
| `cx117.py` | CODEX ally pages |
| `rs115.py` | OPTION > RESET CODEX and saved options |
| `end2.py` | the good ending's high score entry |
| `textdump.py` | dumps the original and new texts |
| `loadst.py`, `unrzip.py` | loading raw and RetroArch (RZIP) save states |
