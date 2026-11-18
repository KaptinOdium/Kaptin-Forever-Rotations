# Mage leveling for WoW Forever

Copy the three `8_*_leveling.yaml` files from `forever/custom` into your Simia Forever loader’s custom profile folder. Reload the rotations and select the Arcane, Fire or Frost Mage profile. Use Simia’s ordinary spell bindings. After training new spells, check that each spell you want the profile to cast has a working key.

You control movement and facing. Select an enemy and start combat. Pick a profile to match the talents you actually trained. The profiles use learned spells, so their opening levels can look similar before the trees gain their signature abilities.

If someone Polymorphs your target while your wand is firing, stop shooting or change targets immediately. The profile holds new attacks on recognized crowd control. A wand attack that already started can keep repeating in the game.

| Profile | What it does as you level |
| --- | --- |
| Frost | Casts Frostbolt while stationary and gives Ice Lance priority against a frozen target or with Fingers of Frost. Fire Blast shares Ice Lance’s cooldown. With area damage enabled, the profile checks facing and range for Cone of Cold. The five-stack Winter’s Chill option also allows a Cone below the normal pack minimum. |
| Fire | Uses Fire Blast to build Heating Up when talented and casts Pyroblast at three stacks once you stand still. Fireball is the default filler. If you train Improved Scorch, enable **I trained Improved Scorch** to maintain the vulnerability on bosses and longer pulls. |
| Arcane | Uses Arcane Missiles when Missile Barrage procs. Once trained, Arcane Blast builds to a configurable stack budget, then the profile uses Arcane Wrath when available. The defaults are three stacks and a 35% mana floor for building. Clearcasting can allow a free Blast below the floor. |

At level 1, all three can use Fireball. Train Frostbolt at 4, Fire Blast at 6 and Arcane Missiles at 8. Keep training new ranks and binding newly learned abilities as you level.

**Pulls and control.** Pull manually by default. Enable **Allow pulling an idle selected enemy** if you want to start a fight by selecting it. Hardcasts and channels wait while you move. You control Blink, Frost Nova, Polymorph and ground-targeted spells. Close-range pack damage defaults to three nearby engaged enemies and at least 45% mana. Position and face the pack yourself.

**Between pulls.** The profiles maintain Arcane Intellect and a learned armor. Enable WoW’s auto self-cast for the ordinary Intellect bind. They can use a bound wand at low mana and channel Evocation between fights. A Mage without a usable wand continues through the spell list. Burst mode and the remaining fight time control offensive cooldowns.

## Leveling simulation

MythicSim ran the three published spell priorities at levels 10, 20, 30, 40, 50 and 60. The study included 486 cases with 1,000 iterations each, covering 15- and 45-second fights, a single enemy and three-enemy packs. It used synthetic, level-scaled character sheets, spec-specific talent builds and trained spell ranks. The table shows mean DPS against one same-level enemy at 20 yards for 15 seconds with the default profiles.

| Level | Arcane | Fire | Frost |
| --- | ---: | ---: | ---: |
| 10 | 22.3 | 14.6 | 16.9 |
| 20 | 38.7 | 29.5 | 32.3 |
| 30 | 73.8 | 59.7 | 48.2 |
| 40 | 126.2 | 98.7 | 81.3 |
| 50 | 181.5 | 158.8 | 140.6 |
| 60 | 246.8 | 227.3 | 189.7 |

**Choosing a setting.** Building four Arcane Blast stacks instead of three gained about 4–6% DPS on the 15-second pulls at levels 30–60, cost another 230–406 net mana per pull, and lost about 3–5% DPS over 45 seconds. Three is the leveling default. At level 30, the Frost build used 549 net mana in the 15-second trial, Arcane used 824 and Fire used 1,073. For talented Fire Mages, maintaining Improved Scorch gained about 15–16% in the level 30, 45-second single-target trial. At levels 40–60 the normal Fireball and Frostbolt fillers beat Frostfire Bolt on these builds. You can select Frostfire Bolt to try different gear or talents.

The DPS model covers stationary spellcasting with synthetic gear and no wand damage. Drinking time, kiting, incoming damage and survival can change how quickly you level in game. Levels 1–9 were checked through spell-selection tests for each level and spec. Native Mage DPS simulation starts at 10. [MythicSim Forever engine](https://github.com/sage3648/mythicsim-forever-engine)
