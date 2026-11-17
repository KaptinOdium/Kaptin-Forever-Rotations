# Collection 2026.11.17.1

This collection updates Shaman to 1.0.3: Enhancement prioritizes eligible Windfury Totem before Strength of Earth, after reactive Grounding. Existing conditions, saved choices and bindings are preserved. Elemental and Restoration have release metadata updates only; other classes and all companions are unchanged. Core payload: **20 YAML profiles, 5 companion addons**. Source dates and individual versions differ; a collection version does not replace class versions.

## Included updates

- Paladin 2.7.3 / 2.5.6 / 2.3.18: rank-aware self-blessing selection fixes the reproduced Wisdom/Might switching loop.
- Druid 2.3.14, manual Feral 2.3.11: stricter caster-only mouseover control. Older 2.3.13 archives predate this change.
- Hunter 1.0.8, companion 1.0.3: ordinary retargeting no longer shares the protective Passive macro; new `@retarget_stop` binding required for optional retargeting.
- Shaman 1.0.3, companion 1.0.0: Enhancement Windfury-first routine-totem priority; configurable main-hand imbues with existing-enchant protection, shield and Fire Nova logic retained. Reload the Enhancement YAML; no new binding or addon update is required.
- Warlock 1.3.3: engaged-mouseover DoTs and optional own-pet engagement support, retaining health/mana recovery.
- Warrior 1.0.0: separate Arms, Fury and Protection profiles with matching companion.
- Paladin/Druid shared companion is 1.1.6; Warlock companion is 1.3.3.

## Compatibility and known issues

These target WoW Forever interface **16001** and the inspected Simia host APIs. Hunter/Shaman/Warrior integration was checked against **12.176**. This is not a compatibility guarantee for every future loader update. The optional Warlock pet patch supports **12.175 only**. The older Hunter group installer and experimental Warlock ground installer are excluded from this normal collection.

The Protection report where Judgement requests appear but no cast follows a target switch is still under investigation. A manual key worked in the reported case; the cause and fix are not established.

Existing source test reports have known gaps: two Paladin scenarios (other-tank/mouseover-taunt handling and Echo/cooldown/spare-mana coverage) and three broader Druid settings-coverage checks were already failing before these latest fixes. Packaging does not resolve or conceal those results.

Offline profile/scenario and companion checks cover conditions and generated macros, not native input delivery, live threat/focus visibility, pet AI or measured DPS. Hunter dungeon entry was confirmed by a tester; new retarget pet behavior still needs live verification. Shaman Chain Heal bounce geometry is not modeled. Party/raid healing depends on correctly configured native bindings and routing. Restricted combat information can leave an action ineligible.

## Package verification

The collection builder parses all 20 YAML files with duplicate-key rejection and the existing structural/expression validator. It verifies declared versions, every TOC-listed file, an explicit source allowlist, source-byte equality and ZIP integrity. `manifest.json` records portable file hashes and profile versions. Run `python tools/verify_package.py` to check the extracted files; this checks package integrity, not live combat behavior.
