# Class guides

All profiles use learned abilities and movement checks. They do not navigate, spend talents, train spells or guarantee optimal DPS. Choose the profile that matches your intended role; review talent-dependent switches yourself.

## Paladin

Protection has threat-rescue checks, defensive priorities and configurable Fury-versus-damage Judgements. Retribution includes selectable Echo seal handling and optional utility Judgement setup. Holy prioritizes group recovery with solo damage options. Shared features include assigned blessings, rank-aware buff checks, caster-only mouseover stun eligibility and optional solo bubble/healing recovery with Lay on Hands fallback. Solo recovery is separated from group tanking.

Use `KhanForeverBindings`. Bind the ordinary seals/Judgement and enabled self, group and mouseover variants. For Ret, match the Unsealed Wrath/Echo setting to the actual build. Protection's reported Judgement failure after target switching remains unresolved; this collection does not contain a confirmed fix for that report.

## Druid

Bear, Cat, Balance and Restoration have separate profiles. **Manual Feral** follows the form you choose and does not automatically switch forms. Early leveling melee finishing, resource management, healing and optional mouseover utility have their own settings. Current mouseover Bash requires a caster; selected-target stun behavior is separate.

In standalone **Cat**, **Stealth and opener → Pull with Faerie Fire out of combat** defaults off. With **Auto Prowl** on, approach in Cat Form and the profile waits for Prowl and your chosen opener. For a ranged Faerie Fire pull, turn Auto Prowl off and enable both the Faerie Fire pull and **Targeting → Allow attacks on an idle selected enemy**. In combat the usual debuff refresh applies.

Turn on **Combat self-healing → Heal in combat after I manually leave animal form** if you want to control shifts during a fight. Leave Cat or Bear to heal yourself, then switch back when ready. Bind the `@player` variants of the heals you know. The health sliders use effective health, including incoming heals. Healing Touch and Regrowth require standing still.

For corpse looting, enable the loader’s **Loot Nearby** option and bind **Interact Target**. Cat can use that key after combat when the dead enemy drops out of your target frame and WoW reports a lootable corpse nearby. A lootable mouseover still uses **Interact Mouseover**.

Cat and Manual Feral include **Stealth and opener** settings: enable Auto Prowl and choose a **5-40 yard** approach distance (default 25, center to center). It only runs outside combat while already in Cat Form with a selected hostile enemy and known distance. Auto Prowl is OFF by default and does not grant permission to pull idle enemies. **Exclusive stealth opener** selects Ravage (default) or Pounce. Both require rear positioning in the inspected Forever data; while prowling, the profile waits for the selected learned/bound spell instead of falling through to another attack or racial. If you want it to open an idle selected enemy automatically, separately enable **Targeting > Allow attacks on an idle selected enemy**. Manually queued actions are still honored.

War Stomp interrupts now work in the Cat profile and Cat/Bear modes of Manual Feral: an engaged selected or mouseover enemy must be casting, within the 8-yard center radius, non-boss and have a cast marked interruptible or stunnable. It requires standing still, more than 0.6 seconds remaining and the configured nearby-pull safeguards. Native learned/usable/binding checks remain; no form-cancel macro is added. Bind ordinary **War Stomp**, **Prowl**, and your chosen **Pounce/Ravage**. These are offline-validated decisions; actual client delivery still needs testing.

Use `KhanForeverBindings`. Bind the learned abilities/forms and the exact self/group/mouseover variants you enable. Leave form yourself for recovery in manual-form play. Optional Find Herbs needs the learned ordinary binding. Party/raid healing requires working native focus or direct-member routing.

## Hunter

All three specializations include pet management, movement/range checks, Hawk timing, optional dungeon entry, combat retargeting and low-mana priorities. Hawk timing uses exported guardian age and an assumed lifespan, not exact per-slot expiry.

Use `KaptinForeverHunterBindings`. Bind **Pet Attack**, ordinary **Auto Shot**, **Auto Shot @stop_attack**, and learned spells. Optional retargeting additionally needs **Target Enemy** and **Auto Shot @retarget_stop**. The new retarget stop uses `/stopattack` and `/petfollow` without changing pet stance. Protective stop for recognized CC/immunity or Damage disabled still deliberately sets Passive. Select the preferred stance yourself if your pet was already Passive.

To join the tank's fight, enable **Targeting > Join selected fighting enemy in dungeons**, keep Force Combat and idle-target pulling off, select a fighting enemy and stand in shooting range. This dungeon mode needs no bridge installer. The old strict group bridge is not included here; disable it with `/kaptinhuntergroup off` if previously installed for that different mode.

Optional retargeting preserves living targets but native Target Enemy can select an idle enemy. Leave idle pulling off. Rapid Fire needs its own option, Burst and lifetime/range checks. Bestial Wrath also checks pet melee range. Review mana/Mend reserves if expensive attacks are withheld. Traps, Feign Death and ground targeting remain manual.

## Mage

Arcane, Fire and Frost each have a level 1–60 profile. Use ordinary Simia spell bindings. The [Mage leveling guide](mage-leveling.md) covers setup, spec priorities and leveling simulations.

## Shaman

Elemental, Enhancement and Restoration include movement-aware damage/healing, shield maintenance and configurable totems. Enhancement now prioritizes eligible Windfury Totem before Strength of Earth, while reactive Grounding stays first. Select **Totems > Air slot > Windfury** and bind its ordinary key. Both Earth/Air slots can stay active; existing mana, fight-length, movement and healing-reserve checks still apply. Optional Fire Nova requires the configured pack/totem conditions; it is not an unconditional single-target filler. Enhancement can apply the strongest learned main-hand imbue between fights when no temporary enchant is present. Existing enchants are preserved and off-hand application stays manual.

For Enhancement, select **Totems > Fire slot > Searing** or **Magma on packs; Searing otherwise** and bind the ordinary **Searing Totem** spell. With AoE off, Searing can drop for one detected, engaged enemy within 20 yards. Routine totems still use your minimum mana and fight-length settings.

**Totems > Recast selected totems that have fallen out of range** is enabled by default for Enhancement. During an eligible fight, stand still and the profile can replace an individual tracked support totem beyond its 30-yard buff radius. Searing and Magma also check whether their old position still reaches the target or other enemies. If the loader cannot locate an active totem, you can move or replace it manually.

Use `KaptinForeverShamanBindings`. Bind learned spells, chosen totems/imbues, potions and enabled heal/cure variants. Configure native focus routing for group healing. [Detailed bindings](shaman-bindings.md) explain focus assignment, `@player` self-heals and optional mouseover Earth Shock. Choose utility totems and position them yourself.

## Warlock

Affliction, Demonology and Destruction include coordinated Life Tap/Drain Life recovery, low-mana wand use, pet support and optional mouseover Corruption, Agony and Immolate. Keep hovering an engaged enemy through each cast/global; this does not queue all DoTs or remember the enemy after the cursor moves. Disable mouseover Fear/Banish when you want DoT spreading without control.

Use `KhanForeverWarlockBindings`. Bind learned spells, Shoot, Pet Attack, Stop Casting and enabled mouseover/cursor variants. Match talent-dependent settings to the build. [Detailed bindings](warlock/BINDINGS.md) and [Healthstone macro setup](warlock/Healthstone-macro.txt) cover additional actions.

The optional own-pet engagement patch is in `Optional/Warlock-Pet-Bridge`; it supports only the documented **12.175** host. Its public threat checks may be unavailable. Do not force it into other versions. Ordinary damage and confirmed player-engaged mouseover DoTs work without it. Experimental controller Rain of Fire is not configured by this collection: keep normal manual/cursor placement. No verified automatic ground-cast package is included.

## Warrior

Arms, Fury and Protection include rage management, movement-aware priorities, optional interrupts/taunts and equipment/stance conditions. Set retained rage only to the amount your actual training/talents allow. Choose the initial stance and equipment yourself; no automatic stance-dance sequence is assumed.

Fury allows up to **15 extra rage loss** when maintaining its preferred Berserker stance; Arms/Protection default to 0. Adjust **Stances > Maximum rage to discard**; 0 restores strict retention. Above the limit, legal attacks spend down and Bloodrage waits, while emergency/interrupt/Shield Block priorities remain. Bind the ordinary preferred stance key. Pack size does not select a different stance; sustained rage gains may still delay a bounded switch.

Whirlwind uses its full **8-yard center radius**, including outside ordinary melee, with confirmed in-range combat enemies and existing AoE/CC checks. Blood Fury and Death Wish require an engaged enemy in actual melee reach. All three require readable player/target positions. Other melee attacks gain no extra range.

Blood Fury (20572) follows the Offensive cooldowns and Burst toggles, requires an engaged enemy in melee, a boss or the configured fight duration, and at least 80% player health by default (adjustable). Shatter Curse (1299026) is independently enabled and only responds to a detected curse on you; it also works out of combat without an enemy selected. Bind each ordinary racial spell if your character has it. Neither action bypasses native availability or binding checks.

Use `KaptinForeverWarriorBindings`. Bind **Attack Target**, **Health Potion**, learned abilities and **Battle Stance @stop_attack** (this variant only stops attacking). Optional mouseover/focus control needs its exact variants. Slam and charge behavior are opt-in. Retaliation and Shield Wall default off; optional Retaliation uses emergency solo conditions rather than pack size alone. Raid tank swaps remain manual.
