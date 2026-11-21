# Magic Sword: Ally Synergy

This is a ROM hack for Magic Sword (SNES) that doubles down on the ally system, giving the allies *impactful* abilities that make every switch a real strategic choice, and a lot of fun. It weaves in a bunch of new RPG-lite features that I've always thought the game was missing, like saved games and an automap system so you can plan where in your run you'll take advantage of each ally. It also brings back the arcade's missing high score table, so your best runs live forever.

**Contents:** [Concept](#concept) · [New Ally Abilities](#new-ally-abilities) · [Features](#features) · [Ally Details](#ally-details) · [Text Changes](#text-changes) · [Patching](#patching) · [Credits](#credits)

## Concept

This hack starts with Magic Sword's biggest hook: the ally system. The tower is continuously throwing cell doors, keys and a whole cast of allies at you—it *seems* like it's going to be a blast. But once you've started leveling up your favorite ally, it's hard to find a reason to switch. Their abilities are different, but maybe not quite different enough to give up those hard-earned levels. And that's the rub! In order for the game's hook to pay off, their abilities need to be so *compelling* that you just can't pass them up.

So for starters, two characters now have unique abilities that help you grow your life bar/count—the perfect switch after you've barely survived a boss fight or when you're building up for the final two bosses. "But what about that level tax?" you ask? Enter the Amazon and her **Shared Valor** ability: she joins at your previous ally's level and then *passes that level on* to the next ally. Taxes deferred! And speaking of bosses, try picking the best ally for each boss: The Wizard now recharges your magic bar faster, so he can shoot more frequently. Combined with his aimed shots, he's the perfect weapon against Celestial Serpents. Fancy some close-quarters melee for Gold Dragon or Hydra? The Ninja now imparts his martial arts skills, giving you evasion and critical hit chances. Both give an on-screen pop-up whenever they happen; it feels really fun!

And finally, you need a way to see when and where all the allies and secrets appear on each floor so that you can plan out your run. Even if you're not a planner, just being able to see what's coming up on the next few floors can be a ***game changer***. And that's where the Thief comes in. Every floor he reaches as your ally goes into his **Thief's Log**—a book of maps showing each floor's allies, bosses, hidden chests, and even secret warp doors. Pause and press SELECT at any time, with any ally, to see every floor you've mapped so far, with a box showing where you are right now. Take him along for a run or two, and from then on you'll know which floor holds the Cleric you need, where the next Amazon is, and when to switch to the Ninja before a boss.

## New Ally Abilities

| Ally | Ability | Drawback |
|---|---|---|
| **Cleric** | *Healer:* Food restores more life, and your life slowly trickles back. Keeps his original bonus damage against undead. | Very weak against enemies that aren't undead. |
| **Thief** | *Scout:* Maps every floor he reaches, viewable any time from the pause screen or from the title screen's CODEX. He also shows what's behind each cell door (which ally, a fairy, or a trap), marks hidden warp doors, and still reveals hidden and trapped treasure chests. | His bomb has a short range. |
| **Big Man** | *Protector:* Takes every other hit for you. His own healing speeds up as he levels. | His life regenerates slowly at low levels, and he can die if he takes too many hits. |
| **Amazon** | *Shared Valor:* She joins at your previous ally's level and passes it on to the next ally you free. If that ally is already as strong, they get +1 level instead. *Second Wind:* once per floor, a hit that would kill you leaves you alive. | Her crossbow is fast but not very powerful. |
| **Wizard** | *Powerful Magic:* Recharges your magic bar much faster. This means you get your magic attack more often and the Wizard fires more often. | He heals slowly. His missiles fire in whatever direction you're pressing (not just left/right), so they're not ideal for all situations and they take a bit more practice to use well. |
| **Ninja** | *Martial Resonance:* Bestows ninja abilities that make your melee far more effective: evade chance, critical hit chance and longer invincibility after a hit. These scale up with his level. | His rebounding stars are fast but weak. |
| **Knight** | *A powerful tank.* Unchanged from the original game. | No special abilities. |
| **Lizardman** | *A powerful tank.* Unchanged from the original game. | No special abilities. |

## Features

- **Saved runs**
  - Saves are for runs in progress—you can have up to 3 at a time.
  - The Resume screen shows the details of each run: player name, floor, difficulty, lives, credits, score, and your ally and their level.
  - Each save is written whenever you finish a floor.
  - When a run ends (game over, or beating the game), its save is erased and its score goes into the high score table, which lives on.
- **High scores**
  - Recreates the arcade's high score table.
  - The floor column marks a 1CC (beating the game without continuing) or a win after continuing (a star).
  - Saved to SRAM; can be reset in the OPTION menu.
- **Updated game text**
  - The between-level messages warn you when the next floor ends with a boss, so you can make a last-minute ally switch.
  - Every ally description now includes the new abilities (all the text changes are listed in [Text Changes](#text-changes)).
  - Clearer magic item descriptions that say what each item really does (for example, the Scroll makes enemies drop treasure far more often).
  - Between-level translation fixes: spelling (Quimera became Chimera) and mistranslations, such as the line about the Black Wizard being unable to hurt the undead.
- **CODEX** (on the title menu)
  - Everything in one place: the Hall of Heroes (high scores), the Thief's Log, and details about the magic items and the allies' abilities and weaknesses. Turn pages with L and R.
  - A handy reference for planning your run, or for checking mid-run, since your game is saved every floor.
  - Choose which song plays while you're in the CODEX (OPTION > CODEX MUSIC > Song # or NONE). I defaulted this to song 05 because it's *awesome*, but it only plays on floor 14. I thought that was a shame, so now you can enjoy it here too.
  - OPTION > RESET CODEX clears the high scores, the Thief's Log, or both: choose with LEFT/RIGHT, then hold A, B, X and Y and press START.
- **Quality of life**
  - Optionally disable the Y+B combo for the special action, so only the dedicated button works and you can't trigger it by accident (OPTION > CONTROL PAD > SPECIAL: pick a button marked ONLY).
  - Press START to skip the copyright and logo screens. In the attract loop, only START leaves the demo (in the original, any button did).
  - All OPTION menu settings are saved to SRAM.
  - Includes kandowontu's FastROM patch that removes most of the game's slowdown, and a fix for a FastROM timing bug that made the music occasionally fail to play on a floor.
  - There's a hidden easter egg. If you want to find it, see `SECRETS.txt` (spoilers).

## Ally Details

Levels run from L1 to L8. An ally's level goes up as you play, and the abilities below scale with it.

### Cleric

The healer. He keeps his original strength against undead (which he kills very quickly) and is weak against everything else.

- **Better food.** Healing items restore more life while the Cleric is your ally.
- **Life trickle.** The game slowly drains your life over time, and the Cleric slowly gives it back, faster as he levels up. At level 6 the two roughly cancel out, and at level 7 and up you slowly gain life.

| Level | Food bonus | Trickle: seconds per life point |
|:---:|:---:|:---:|
| L1 | +12.5% | 8.0 |
| L2 | +22% | 7.0 |
| L3 | +31% | 6.0 |
| L4 | +41% | 5.0 |
| L5 | +47% | 4.0 |
| L6 | +56% | 3.2 |
| L7 | +66% | 2.5 |
| L8 | +75% | 2.0 |

### Thief

The scout. He logs a map of each floor, and his insights overlay the screen during play.

- **Chest insight.** As in the original game, he reveals hidden chests, and trapped chests show a blinking skull.
- **Door insights.** A small icon appears over each cell door while he's your ally: the head of the ally inside, a fairy, or a skull for a trap. The icons blink (like the trapped chests).
- **Hidden doors.** A twinkling star marks the spot that opens each hidden warp door. Jump and strike it.
- **Thief's Log.** Every floor you reach with the Thief is mapped, from the moment he's with you on it. Each map shows where the floor starts and ends, the allies in the cell doors, hidden treasure chests, hidden warp doors (with the floor they lead to), the boss, and whether the floor loops around. Floors you haven't reached with him show ???. The log is kept across all your saves.
  - **In play:** pause and press SELECT, with any ally. You see every floor your Thief has mapped so far, starting at the floor you're on. If the Thief has been with you on this floor, its map is there too, with a box showing where you are. UP/DOWN pick a floor, LEFT/RIGHT scroll its map, SELECT goes back to the pause screen and START resumes playing.
  - **In the CODEX:** the same maps, along with the Hall of Heroes (high scores), ally details, and item details.
  - **Shuffled doors:** as in the original game, some floors shuffle which ally (or trap) is behind which cell door each time the floor loads (including after resuming a save). The map of the floor you're on (opened from the pause screen) always matches its real doors. The other maps show each floor's usual layout, which is good enough for planning.
  - A Thief now waits on floor 1 (the Cleric there moved to floor 2), so you can start mapping right away.

### Big Man

The protector. In practice, Big Man is really helpful when you're trying to build up your life bar/count. He's not quite as good at it as the Cleric, but his firepower is much better.

- **Takes every other hit for you.** The hits he takes come out of his own life, so he can die.
- **Heals slowly at first.** His healing speeds up as he levels.

| Level | Seconds per block of his life |
|:---:|:---:|
| L1 | 11.0 |
| L2 | 10.0 |
| L3 | 9.0 |
| L4 | 8.0 |
| L5 | 7.0 |
| L6 | 6.0 |
| L7 | 5.0 |
| L8 | 4.0 |

Original game: about 3.3 seconds at L1 and 2.2 at L8.

### Amazon

A natural leader. She's the best way to get a rare ally up to strength.

- **Shared Valor.** She carries levels from one ally to the next.
  - *When she joins:* she takes your previous ally's level, if it's higher than hers.
  - *When you switch from her:* the new ally joins at her level. If they're already that strong, they get +1 level instead.
  - Nothing is passed on from an ally that has died. Freeing the same type of ally you already have still gives its usual +2 levels.
  - *Example: your L5 Knight meets the Amazon, who would otherwise join at L2. She joins at L5. A few floors later you free a Lizardman who would normally join at L3. He joins at L5.*
- **Second Wind.** Once per floor, a hit that would kill you leaves you alive with part of your life. A REVIVED! message appears.

| Level | Life left after Second Wind |
|:---:|:---:|
| L1 | 19% |
| L2 | 25% |
| L3 | 31% |
| L4 | 38% |
| L5 | 44% |
| L6 | 50% |
| L7 | 56% |
| L8 | 62% |

### Wizard

The magic battery. *Powerful Magic:* he heals slowly, but you'll use your magic attack far more often.

- **Faster magic bar.** The time your magic bar needs to refill after a magic attack drops with his level. With any other ally it takes about 0.9 seconds. His missiles also fire more often, and they fly in whatever direction you're pressing.

| Level | Seconds to refill the magic bar |
|:---:|:---:|
| L1 | 0.70 |
| L2 | 0.67 |
| L3 | 0.55 |
| L4 | 0.55 |
| L5 | 0.42 |
| L6 | 0.37 |
| L7 | 0.37 |
| L8 | 0.37 |

### Ninja

His stars are good at clearing weaker enemies, and his *Martial Resonance* bestows ninja abilities that make your melee far more dangerous.

- **Evade.** A chance to dodge a hit completely. An EVADED! message pops up and you take no damage.
- **Critical hit.** A chance for your sword and magic attacks to do double damage. A CRITICAL! message pops up. His own stars can't crit.
- **Longer invincibility.** After you take a hit, you stay invincible longer than the usual 2.0 seconds.

| Level | Evade chance | Critical chance | Invincibility after a hit |
|:---:|:---:|:---:|:---:|
| L1 | 5% | 5% | 2.5 s |
| L2 | 8% | 7% | 2.7 s |
| L3 | 11% | 9% | 2.9 s |
| L4 | 13% | 11% | 3.1 s |
| L5 | 16% | 13% | 3.4 s |
| L6 | 19% | 15% | 3.6 s |
| L7 | 21% | 17% | 3.8 s |
| L8 | 24% | 19% | 4.0 s |

### Knight

A powerful tank with no special abilities, unchanged from the original game. He often joins weak, which makes him a great target for the Amazon's Shared Valor.

### Lizardman

A powerful tank with no special abilities, unchanged from the original game. As in the original, he only joins you when bribed with a diamond ring. He's another good target for the Amazon's Shared Valor.

## Text Changes

The in-game text, original vs. this hack.

### Ally descriptions (CODEX and attract loop)

| Ally | Original | Now |
|---|---|---|
| Big Man | IS STRONG AND HAS GREAT ENDURANCE. HIS BOOMERANG AXE IS POWERFUL BUT SLOW. | HIS BOOMERANG AXE IS POWERFUL BUT SLOW. A PROTECTOR, HE TAKES EVERY OTHER HIT FOR YOU. HE HEALS SLOWLY AT FIRST, FASTER AS HE LEVELS UP. |
| Amazon | FIRES HER CROSSBOW CONTINUOUSLY. HER ATTACK IS SWIFT BUT LACKING IN POWER. | FIRES A SWIFT BUT WEAK CROSSBOW. A GREAT LEADER, SHE CARRIES YOUR PREVIOUS ALLY'S LEVEL TO THE NEXT. ONCE A FLOOR, SHE GIVES A SECOND WIND IF YOU FALL. |
| Ninja | THROWS 2 TO 5 STARS WHICH REBOUND FROM WALLS AND CEILING. FAST BUT NOT SO POWERFUL. | THROWS REBOUNDING STARS THAT ARE FAST BUT WEAK. HE GIVES YOU A CHANCE TO EVADE ATTACKS OR LAND CRITICAL HITS, AND LONGER INVINCIBILITY WHEN HIT. |
| Thief | IS ABLE TO LOCATE HIDDEN TREASURE CHESTS AND TRAPS. HIS BOMB PACKS QUITE A WALLOP, TOO. | HIS BOMB HAS A SHORT RANGE. HE SPOTS TRAPS, SECRETS, AND ALLIES. A SCOUT, HE KEEPS A DETAILED LOG OF EVERY FLOOR HE REACHES. |
| Cleric | IS LACKING IN PHYSICAL STRENGTH AND SPEED BUT HIS MAGICAL BULLETS CAN DO GRAVE DAMAGE TO UNDEAD MONSTERS. | HIS WEAK MAGIC BULLETS DO GRAVE DAMAGE TO UNDEAD. A HEALER, HE ENHANCES FOOD AND SLOWLY RESTORES YOUR LIFE. |
| Wizard | SHOOTS MAGIC MISSILES. HE HAS THE MOST POWERFUL ATTACK BUT IS SLOW AND NOT MUCH TO SPEAK OF PHYSICALLY. | HIS POWERFUL MISSILES CAN BE AIMED ANYWHERE, BUT HE HEALS SLOWLY. HE SHARES HIS POWER, SO YOUR MAGIC BAR FILLS FASTER. |
| Knight | IS INCREDIBLY ADEPT WITH HIS SPEAR AND IS YOUR STRONGEST ALLY. HE IS HELD IN THE UPPER LEVEL OF THE TOWER. | Unchanged. |
| Lizardman | BECOMES AN ALLY ONLY WHEN BRIBED WITH A DIAMOND RING. HE IS A BRUTE WITH GREAT PHYSICAL STRENGTH SPEED AND ATTACKING POWER. | BECOMES AN ALLY ONLY WHEN BRIBED WITH A DIAMOND RING. HE IS A BRUTE WITH GREAT PHYSICAL STRENGTH, SPEED AND ATTACKING POWER. (added a comma) |

### Magic items (CODEX and attract loop)

| Item | Original | Now |
|---|---|---|
| Golden Pot | HEALING MAGIC FOR PARTNER. | HEALS YOUR ALLY. |
| Crystal Ball | DETECTS TREASURE BOXES. | FINDS TREASURE CHESTS. |
| Magic Potion | INCREASES MAGIC SKILL. | MAGIC BAR FILLS TWICE AS FAST. |
| Diamond Ring | THE LIZARDMAN TO JOIN YOU. | BRIBES THE LIZARDMAN. |
| Scroll | BRINGS GOOD LUCK. | ENEMIES DROP MORE TREASURE. |

The King's Crown, Gauntlet and Pendant are unchanged.

### Between-level messages

Shown on the NEXT FLOOR screen as you arrive on a floor. A hyphen inside a word in the Original column (LIZARD-MAN) is where the original broke the word across two lines.

| Floor | Original | Now |
|---|---|---|
| 3 | THE POISONOUS MUSHROOM WILL NUMB YOU. | THE POISONOUS MUSHROOM NUMBS YOU. BOSS AFTER THIS FLOOR! |
| 7 | THE WHITE WIZARD CAN DEFEAT EVEN UNDEAD CREATURES. | THE CLERIC CAN DEFEAT UNDEAD CREATURES. |
| 8 | IF YOU HAVE A DIAMOND RING, THE LIZARD-MAN MAY JOIN YOU. | IF YOU HAVE A DIAMOND RING, THE LIZARDMAN MAY JOIN YOU. |
| 11 | I HEAR WATER. LET'S HURRY. | I HEAR WATER. LET'S HURRY. BOSS AFTER THIS FLOOR! |
| 13, 14 | WE FINALLY DESTROYED QUIMYRA. LET'S MOVE ON. | WE FINALLY DESTROYED THE CHIMERA. LET'S MOVE ON. |
| 15 | THIEVES CAN DETECT THE TREASURE CHEST'S TRAPS. | THE THIEF SPOTS TRAPS AND MAPS EVERY FLOOR HE REACHES. |
| 18 | THE GOLDEN BOOK CHAN-GES FAKE GOLD COINS INTO REAL ONES. | THE GOLDEN BOOK TURNS FAKE GOLD COINS INTO REAL ONES. |
| 20 | THIS BLAZE FEELS LIKE IT'S STRA-IGHT FROM THE DEMON PITS. | THIS BLAZE FEELS LIKE IT'S STRAIGHT FROM THE DEMON PITS. |
| 21 | THE BLACK WIZARDS MAGIC HAS NO EFFECT ON UNDEAD CREATURES. | THE WIZARD REPLENISHES YOUR MAGIC BAR. |
| 23 | THE GAUNTLET ENHANCES SWORDPLAY. | THE GAUNTLET ENHANCES SWORDPLAY. BOSS AFTER THIS FLOOR! |
| 28 | THERE'S SAID TO BE A SECRET DOOR IN THE TOWER. | THERE ARE RUMORS OF SECRET DOORS. BOSS AFTER THIS FLOOR! |
| 35 | THE SWORD'S THUNDER WILL REND DARKNESS FROM THE SKY. | THE SWORD'S LIGHTNING RENDS THE DARKNESS. BOSS AFTER THIS FLOOR! |
| 43 | THE BLACK-ORB IS THE ROOT OF DROKMAR'S POWER. | THE BLACKORB IS THE ROOT OF DROKMAR'S POWER. |
| 45 | WE MUST RE-STORE LIGHT TO THE SUFFERING PEOPLE OF THE WORLD. | WE MUST RESTORE LIGHT TO THE SUFFERING PEOPLE OF THE WORLD. |
| 48 | OPEN DROK-MAR'S DOOR WITH THE KEY. | OPEN DROKMAR'S DOOR WITH THE KEY. BOSS AFTER THIS FLOOR! |

## Patching

You need a clean *Magic Sword (USA)* ROM: 1 MB, no header, CRC32 `27325E4D` (SHA-1 `0d64ef4149b71d13d287122f58eca9c580fa7d0f`). Apply `MagicSword_AllySynergy.ips` to it with any IPS patcher, such as [Floating IPS](https://www.romhacking.net/utilities/1040/) or [MultiPatch](https://www.romhacking.net/utilities/746/).

- **Don't apply the FastROM patch first.** It's already included.
- **Saved runs, high scores and OPTION settings use SRAM.** The patch sets the ROM header to 2 KB of battery RAM. Flash carts need SRAM enabled.
- **Tested in RetroArch (Snes9x core).**

## Credits

- **Magic Sword** by Capcom. This repository contains no ROM, only the patch, its source code and tools.
- **[Magic Sword - Fastrom](https://www.romhacking.net/hacks/7627)** by kandowontu, included.
- **AI assistance:** I built this with Claude, Anthropic's AI assistant. The design, play-testing and every gameplay decision are mine; Claude wrote and debugged the code, build tools and test scripts.
- **Tools:** [asar](https://github.com/RPGHacker/asar) by RPGHacker builds the code.

This is an unofficial fan project. It is not affiliated with or endorsed by the original developers or publishers.