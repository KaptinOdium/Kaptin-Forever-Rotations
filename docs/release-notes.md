# Collection 2026.11.18.3

Added Arcane, Fire and Frost Mage leveling profiles. See the [Mage leveling guide](mage-leveling.md) for the simulated builds and results.

Standalone Cat 2.3.19 adds an optional out-of-combat Faerie Fire pull, off by default. Auto Prowl takes priority while you approach in Cat Form, including outside the configured Prowl distance and while waiting for the stealth aura.

Enhancement 1.0.5 can drop Searing with AoE off for a lone engaged enemy and replace an individual totem that has fallen out of range. Setup is under Shaman in [class features](classes.md). Totemic Recall stays under player control.

Standalone Cat can now heal you in combat after you manually leave animal form. Enable this option to keep control of combat form changes. With Loot Nearby enabled, Cat can also use Interact when WoW clears your target and reports a nearby lootable corpse. See the Druid setup in [class features](classes.md).

The Cat tester reports Shred is working again. The cause of the earlier positional rejection remains unknown.

## Included updates

- Paladin 2.7.4 / 2.5.7 / 2.3.18: Ret/Prot recognize every trained preferred-aura rank and preserve an active preferred aura even if the named spell lookup fails. The earlier rank-aware self-blessing fix is retained. This does not diagnose native key delivery or change dispels.
- Standalone Cat 2.3.18 adds combat self-healing in caster form and nearby corpse interaction. Cat and manual Feral 2.3.14 also support adjustable Auto Prowl, exclusive Pounce/Ravage openers and War Stomp interrupts.
- Hunter 1.0.8, companion 1.0.3: ordinary retargeting no longer shares the protective Passive macro; new `@retarget_stop` binding required for optional retargeting.
- Shaman 1.0.4, companion 1.0.0: air-slot checks use reported active occupants, avoiding an unavailable legacy name's false absence flag. Active utility totems remain protected. Enhancement Windfury-first priority, weapon imbues, shields, Fire Nova and healing reserves remain. Reload the YAML; no new binding or addon update is required. Existing Air slot choices still apply.
- Warlock 1.3.3: engaged-mouseover DoTs and optional own-pet engagement support, retaining health/mana recovery.
- Warrior 1.0.2: Fury stance recovery allows a configurable 15-rage loss by default; normal attacks spend higher rage down while Bloodrage waits. Whirlwind covers its full 8-yard radius, and both offensive self-buffs require an engaged melee enemy. Position/AoE safeguards remain. Blood Fury and curse-only Shatter Curse support is retained. Ordinary stance/racial keys are required; companion 1.0.0 is unchanged. 63 offline Warrior scenarios passed; the reported live stance cause and actual casting still need confirmation.
- Paladin/Druid shared companion is 1.1.6; Warlock companion is 1.3.3.

## Compatibility and known issues

These target WoW Forever interface **16001** and the inspected Simia host APIs. Hunter/Shaman/Warrior integration was checked against **12.176**. This is not a compatibility guarantee for every future loader update. The optional Warlock pet patch supports **12.175 only**. The older Hunter group installer and experimental Warlock ground installer are excluded from this normal collection.

The Protection report where Judgement requests appear but no cast follows a target switch is still under investigation. A manual key worked in the reported case; the cause and fix are not established.

Existing source test reports have known gaps: two Paladin scenarios (other-tank/mouseover-taunt handling and Echo/cooldown/spare-mana coverage) and three broader Druid settings-coverage checks were already failing before these latest fixes. Packaging does not resolve or conceal those results.

Offline profile/scenario and companion checks cover conditions and generated macros, not native input delivery, live threat/focus visibility, pet AI or measured DPS. Hunter dungeon entry was confirmed by a tester; new retarget pet behavior still needs live verification. Shaman Chain Heal bounce geometry is not modeled. Party/raid healing depends on correctly configured native bindings and routing. Restricted combat information can leave an action ineligible.

## Package verification

The collection builder parses all 23 YAML files, rejects duplicate keys and validates profile expressions. It verifies declared versions, TOC dependencies, source files and ZIP integrity. `manifest.json` records portable file hashes and profile versions. Run `python tools/verify_package.py` to check the extracted files.
