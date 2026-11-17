# Collection 2026.11.17.6

This collection hardens Shaman air-slot detection so an unrecognized legacy totem name cannot prevent an otherwise eligible Windfury cast. It preserves detected active air occupants, priorities and existing settings. The missed-Windfury case was reproduced offline; the reported live cause remains unconfirmed. It also retains collection 2026.11.17.5's conservative Cat/Manual Feral Shred fallback and Paladin aura fix. Shred requires rear positioning and confirmed non-tanking threat; tanking or unknown threat uses Claw instead. Claw needs its ordinary enabled binding. This deliberately gives up some Shred opportunities behind a casting or stunned enemy that is still tanked by you. No live retest is claimed. Core payload: **20 YAML profiles, 5 companion addons**. Source dates and individual versions differ; a collection version does not replace class versions.

## Included updates

- Paladin 2.7.4 / 2.5.7 / 2.3.18: Ret/Prot recognize every trained preferred-aura rank and preserve an active preferred aura even if the named spell lookup fails. The earlier rank-aware self-blessing fix is retained. This does not diagnose native key delivery or change dispels.
- Cat 2.3.15 / manual Feral 2.3.12: conservative Shred eligibility with immediate Claw fallback while tanking or when threat is unknown. Ravage's opener positioning stays unchanged. Bear/Balance/Restoration remain 2.3.14; caster-only mouseover control is retained.
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

The collection builder parses all 20 YAML files with duplicate-key rejection and the existing structural/expression validator. It verifies declared versions, every TOC-listed file, an explicit source allowlist, source-byte equality and ZIP integrity. `manifest.json` records portable file hashes and profile versions. Run `python tools/verify_package.py` to check the extracted files; this checks package integrity, not live combat behavior.
