# What the Scroll of Good Luck changes (drop tiers)

Decoded from the ROM (Magic Sword USA). Not yet watched in a live game. Each enemy type has a normal drop row and a scroll drop row. A random number 0-31 picks the drop, so every chance below is out of 32. All ids here are treasure worth points; the value is in brackets.

## Treasure ids and what they are worth

| id | points | id | points | id | points |
|---|---:|---|---:|---|---:|
| $02 | 20 | $04 | 30 | $06 | 40 |
| $08 | 50 | $0A | 60 | $0C | 70 |
| $0E | 90 | $10 | 100 | $12 | 150 |
| $14 | 200 | $16 | 300 | $18 | 400 |
| $1A | 500 | $1C | 600 | $1E | 700 |
| $20 | 800 | $22 | 900 | $24 | 1,000 |
| $26 | 1,030 | $28 | 1,200 | $2A | 1,500 |
| $2C | 1,600 | $2E | 2,000 | $30 | 2,060 |
| $32 | 2,500 | $34 | 3,000 | $36 | 3,500 |
| $38 | 4,000 | $3A | 5,000 | $3C | 6,000 |
| $3E | 7,000 | $40 | 8,000 | $42 | 9,000 |
| $44 | 10,000 | $46 | 12,000 | $48 | 15,000 |
| $4A | 20,000 | $4C | 30,000 | $4E | 40,000 |
| $50 | 50,000 | $52 | 60,000 | $54 | 80,000 |
| $56 | 100,000 | $58 | 200,000 | $5A | 500,000 |
| $5C | 1,000,000 | | | | |

Special cases: `$46` and `$48` are handled differently by the drop code (they set a different object state, probably the fake gold coins from the Golden Book hint), so the point values above may not apply to them. The Ring with a Hat (item `$08`) doubles every treasure pickup.

## Per enemy group: normal vs scroll

Rows are in enemy-type order (the enemy names are not mapped yet).

### Group A (`04:E12B`)

- **Type 0**
  - Normal: 2/32 $48 (15,000), 1/32 $18 (400); nothing 29/32. Drops 9%, average 950 points per kill.
  - Scroll: 16/32 $48 (15,000), 8/32 $18 (400); nothing 8/32. Drops 75%, average 7,600 points per kill.
- **Type 1**
  - Normal: 2/32 $0E (90); nothing 30/32. Drops 6%, average 6 points per kill.
  - Scroll: 16/32 $0E (90), 8/32 $12 (150); nothing 8/32. Drops 75%, average 82 points per kill.
- **Type 2**
  - Normal: 2/32 $22 (900); nothing 30/32. Drops 6%, average 56 points per kill.
  - Scroll: 16/32 $22 (900), 8/32 $20 (800); nothing 8/32. Drops 75%, average 650 points per kill.
- **Type 3**
  - Normal: 2/32 $06 (40); nothing 30/32. Drops 6%, average 2 points per kill.
  - Scroll: 16/32 $06 (40), 8/32 $04 (30); nothing 8/32. Drops 75%, average 28 points per kill.

### Group B (`05:E2AD`)

- **Type 0**
  - Normal: 4/32 $46 (12,000), 6/32 $28 (1,200); nothing 22/32. Drops 31%, average 1,725 points per kill.
  - Scroll: 6/32 $46 (12,000), 26/32 $28 (1,200); nothing 0/32. Drops 100%, average 3,225 points per kill.
- **Type 1**
  - Normal: 4/32 $46 (12,000), 4/32 $26 (1,030), 2/32 $30 (2,060); nothing 22/32. Drops 31%, average 1,758 points per kill.
  - Scroll: 6/32 $46 (12,000), 26/32 $26 (1,030); nothing 0/32. Drops 100%, average 3,087 points per kill.
- **Type 2**
  - Normal: 2/32 $48 (15,000), 4/32 $28 (1,200); nothing 26/32. Drops 19%, average 1,088 points per kill.
  - Scroll: 6/32 $48 (15,000), 26/32 $28 (1,200); nothing 0/32. Drops 100%, average 3,788 points per kill.
- **Type 3**
  - Normal: 1/32 $48 (15,000), 2/32 $3E (7,000); nothing 29/32. Drops 9%, average 906 points per kill.
  - Scroll: 8/32 $48 (15,000), 20/32 $3E (7,000); nothing 4/32. Drops 88%, average 8,125 points per kill.

### Group C (`06:BB30`)

- **Type 0**
  - Normal: 2/32 $2E (2,000), 1/32 $4A (20,000), 1/32 $24 (1,000); nothing 28/32. Drops 12%, average 781 points per kill.
  - Scroll: 12/32 $2E (2,000), 8/32 $4A (20,000), 8/32 $24 (1,000); nothing 4/32. Drops 88%, average 6,000 points per kill.
- **Type 1**
  - Normal: 2/32 $2E (2,000), 1/32 $4A (20,000), 1/32 $24 (1,000); nothing 28/32. Drops 12%, average 781 points per kill.
  - Scroll: 12/32 $2E (2,000), 8/32 $4A (20,000), 8/32 $24 (1,000); nothing 4/32. Drops 88%, average 6,000 points per kill.
- **Type 2**
  - Normal: 2/32 $4C (30,000), 1/32 $20 (800), 1/32 $30 (2,060); nothing 28/32. Drops 12%, average 1,964 points per kill.
  - Scroll: 12/32 $4C (30,000), 8/32 $20 (800), 8/32 $30 (2,060); nothing 4/32. Drops 88%, average 11,965 points per kill.
- **Type 3**
  - Normal: 2/32 $4C (30,000), 1/32 $20 (800), 1/32 $30 (2,060); nothing 28/32. Drops 12%, average 1,964 points per kill.
  - Scroll: 12/32 $4C (30,000), 8/32 $20 (800), 8/32 $30 (2,060); nothing 4/32. Drops 88%, average 11,965 points per kill.

### Group D (`05:F05C`)

- **Type 0**
  - Normal: 2/32 $26 (1,030), 2/32 $46 (12,000); nothing 28/32. Drops 12%, average 814 points per kill.
  - Scroll: 2/32 $26 (1,030), 30/32 $46 (12,000); nothing 0/32. Drops 100%, average 11,314 points per kill.
- **Type 1**
  - Normal: 4/32 $16 (300), 4/32 $12 (150); nothing 24/32. Drops 25%, average 56 points per kill.
  - Scroll: 4/32 $16 (300), 28/32 $12 (150); nothing 0/32. Drops 100%, average 169 points per kill.
- **Type 2**
  - Normal: 4/32 $12 (150), 2/32 $30 (2,060); nothing 26/32. Drops 19%, average 148 points per kill.
  - Scroll: 6/32 $12 (150), 10/32 $30 (2,060); nothing 16/32. Drops 50%, average 672 points per kill.
- **Type 3**
  - Normal: 2/32 $3A (5,000), 2/32 $46 (12,000); nothing 28/32. Drops 12%, average 1,062 points per kill.
  - Scroll: 8/32 $3A (5,000), 24/32 $46 (12,000); nothing 0/32. Drops 100%, average 10,250 points per kill.

### Group E (`06:C93D`)

- **Type 0**
  - Normal: 2/32 $5C (1,000,000), 1/32 $2E (2,000); nothing 29/32. Drops 9%, average 62,562 points per kill.
  - Scroll: 16/32 $5C (1,000,000), 12/32 $2E (2,000); nothing 4/32. Drops 88%, average 500,750 points per kill.
- **Type 1**
  - Normal: 1/32 $40 (8,000); nothing 31/32. Drops 3%, average 250 points per kill.
  - Scroll: 16/32 $40 (8,000), 12/32 $4E (40,000); nothing 4/32. Drops 88%, average 19,000 points per kill.
- **Type 2**
  - Normal: 4/32 $12 (150), 1/32 $42 (9,000); nothing 27/32. Drops 16%, average 300 points per kill.
  - Scroll: 16/32 $12 (150), 12/32 $42 (9,000); nothing 4/32. Drops 88%, average 3,450 points per kill.

### Group F (`04:F5DA`, one special enemy): 8 equally likely outcomes

- Normal: `$1A` (500) 5/8, `$4E` (40,000) 1/8, `$46` 1/8, `$24` (1,000) 1/8.
- Scroll: `$1A` 2/8, `$4E` 2/8, `$46` 2/8, `$24` 2/8.

## Other scroll effects

- `03:B185`: normally a coin flip removes the drop; with the scroll the drop is always kept.
- `05:CB70`: a bonus drop that happens 1 time in 8 normally happens 1 time in 2 with the scroll.
- `04:A13F` / `04:A71C`: adds `$40` to an enemy table index (a different set of per-enemy values); not decoded yet.
