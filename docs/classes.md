# Class guides

All profiles use learned abilities and movement checks. They do not navigate, spend talents, train spells or guarantee optimal DPS. Choose the profile that matches your intended role; review talent-dependent switches yourself.

## Paladin

Protection has threat-rescue checks, defensive priorities and configurable Fury-versus-damage Judgements. Retribution includes selectable Echo seal handling and optional utility Judgement setup. Holy prioritizes group recovery with solo damage options. Shared features include assigned blessings, rank-aware buff checks, caster-only mouseover stun eligibility and optional solo bubble/healing recovery with Lay on Hands fallback. Solo recovery is separated from group tanking.

Use `KhanForeverBindings`. Bind the ordinary seals/Judgement and enabled self, group and mouseover variants. For Ret, match the Unsealed Wrath/Echo setting to the actual build. Protection's reported Judgement failure after target switching remains unresolved; this collection does not contain a confirmed fix for that report.

## Druid

Bear, Cat, Balance and Restoration have separate profiles. **Manual Feral** follows the form you choose and does not automatically switch forms. Early leveling melee finishing, resource management, healing and optional mouseover utility have their own settings. Current mouseover Bash requires a caster; selected-target stun behavior is separate.

Use `KhanForeverBindings`. Bind the learned abilities/forms and the exact self/group/mouseover variants you enable. Leave form yourself for recovery in manual-form play. Optional Find Herbs needs the learned ordinary binding. Party/raid healing requires working native focus or direct-member routing.

## Hunter

All three specializations include pet management, movement/range checks, Hawk timing, optional dungeon entry, combat retargeting and low-mana priorities. Hawk timing uses exported guardian age and an assumed lifespan, not exact per-slot expiry.

Use `KaptinForeverHunterBindings`. Bind **Pet Attack**, ordinary **Auto Shot**, **Auto Shot @stop_attack**, and learned spells. Optional retargeting additionally needs **Target Enemy** and **Auto Shot @retarget_stop**. The new retarget stop uses `/stopattack` and `/petfollow` without changing pet stance. Protective stop for recognized CC/immunity or Damage disabled still deliberately sets Passive. Select the preferred stance yourself if your pet was already Passive.

To join the tank's fight, enable **Targeting > Join selected fighting enemy in dungeons**, keep Force Combat and idle-target pulling off, select a fighting enemy and stand in shooting range. This dungeon mode needs no bridge installer. The old strict group bridge is not included here; disable it with `/kaptinhuntergroup off` if previously installed for that different mode.

Optional retargeting preserves living targets but native Target Enemy can select an idle enemy. Leave idle pulling off. Rapid Fire needs its own option, Burst and lifetime/range checks. Bestial Wrath also checks pet melee range. Review mana/Mend reserves if expensive attacks are withheld. Traps, Feign Death and ground targeting remain manual.

## Shaman

Elemental, Enhancement and Restoration include movement-aware damage/healing, shield maintenance and configurable totems. Enhancement now prioritizes eligible Windfury Totem before Strength of Earth, while reactive Grounding stays first. Select **Totems > Air slot > Windfury** and bind its ordinary key. Both Earth/Air slots can stay active; existing mana, fight-length, movement and healing-reserve checks still apply. Optional Fire Nova requires the configured pack/totem conditions; it is not an unconditional single-target filler. Enhancement can apply the strongest learned main-hand imbue between fights when no temporary enchant is present. Existing enchants are preserved and off-hand application stays manual.

Use `KaptinForeverShamanBindings`. Bind learned spells, chosen totems/imbues, potions and enabled heal/cure variants. Configure native focus routing for group healing. [Detailed bindings](shaman-bindings.md) explain focus assignment, `@player` self-heals and optional mouseover Earth Shock. Choose utility totems and position them yourself.

## Warlock

Affliction, Demonology and Destruction include coordinated Life Tap/Drain Life recovery, low-mana wand use, pet support and optional mouseover Corruption, Agony and Immolate. Keep hovering an engaged enemy through each cast/global; this does not queue all DoTs or remember the enemy after the cursor moves. Disable mouseover Fear/Banish when you want DoT spreading without control.

Use `KhanForeverWarlockBindings`. Bind learned spells, Shoot, Pet Attack, Stop Casting and enabled mouseover/cursor variants. Match talent-dependent settings to the build. [Detailed bindings](warlock/BINDINGS.md) and [Healthstone macro setup](warlock/Healthstone-macro.txt) cover additional actions.

The optional own-pet engagement patch is in `Optional/Warlock-Pet-Bridge`; it supports only the documented **12.175** host. Its public threat checks may be unavailable. Do not force it into other versions. Ordinary damage and confirmed player-engaged mouseover DoTs work without it. Experimental controller Rain of Fire is not configured by this collection: keep normal manual/cursor placement. No verified automatic ground-cast package is included.

## Warrior

Arms, Fury and Protection include rage management, movement-aware priorities, optional interrupts/taunts and equipment/stance conditions. Set retained rage only to the amount your actual training/talents allow. Choose the initial stance and equipment yourself; no automatic stance-dance sequence is assumed.

Use `KaptinForeverWarriorBindings`. Bind **Attack Target**, **Health Potion**, learned abilities and **Battle Stance @stop_attack** (this variant only stops attacking). Optional mouseover/focus control needs its exact variants. Slam and charge behavior are opt-in. Retaliation and Shield Wall default off; optional Retaliation uses emergency solo conditions rather than pack size alone. Raid tank swaps remain manual.
