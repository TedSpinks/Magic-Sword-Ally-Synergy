# Tools

| Script | Purpose |
|---|---|
| `dis65.py` | A small 65816 disassembler: `python3 dis65.py rom.sfc BB:AAAA count [m x]` (m / x = 1 for 8-bit A / index) |
| `sim65.py` | A small 65816 interpreter, used to run assembled routines over every input combination |
| `genhints.py`, `hintdata.py` | Generate `src/hints.asm` (the between-level messages) from the text in `hintdata.py` |
| `mkitems.py` | Generates `src/items.bin` (the magic items page) |
| `mklog.py` | Generates the Thief's Log graphics: `src/log_bg.bin`, `src/log_obj.bin`, `src/log_pal.bin` |
| `mkicons.py`, `boxgfx.py` | Door icons and the Resume screen box graphics |
| `mkstar.py`, `mkstarbg.py` | The hidden-door star and the Hall of Heroes star field |

The generators were run from a working folder (`MS_WORK`, see `tests/README.md`) and some read graphics captured from
the running game, so check the paths at the top of each script before running it. Their output is committed in `src/`,
so building the patch doesn't need them.

asar is not included: get it from https://github.com/RPGHacker/asar (1.91 was used) and put it here or on `PATH`.
