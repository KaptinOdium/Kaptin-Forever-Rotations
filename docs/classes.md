# Class guides

All profiles use learned abilities and movement checks. They do not navigate, spend talents, train spells or guarantee optimal DPS. Choose the profile that matches your intended role; review talent-dependent switches yourself.

## Paladin

Protection has threat-rescue checks, defensive priorities and configurable Fury-versus-damage Judgements. Retribution includes selectable Echo seal handling and optional utility Judgement setup. Holy prioritizes group recovery with solo damage options. Shared features include assigned blessings, rank-aware buff checks, caster-only mouseover stun eligibility and optional solo bubble/healing recovery with Lay on Hands fallback. Solo recovery is separated from group tanking.

Use `KhanForeverBindings`. Bind the ordinary seals/Judgement and enabled self, group and mouseover variants. For Ret, match the Unsealed Wrath/Echo setting to the actual build. Protection's reported Judgement failure after target switching remains unresolved; this collection does not contain a confirmed fix for that report.

## Druid

Bear, Cat, Balance and Restoration have separate profiles. **Manual Feral** follows the form you choose and does not automatically switch forms. Early leveling melee finishing, resource management, healing and optional mouseover utility have their own settings. Current mouseover Bash requires a caster; selected-target stun behavior is separate.

In **Restoration**, Swiftmend defaults to 55% effective health and needs your Rejuvenation or Regrowth on the recipient. Nature's Swiftness has its own 30% threshold and pairs with Healing Touch. In combat, party Wild Growth defaults to three members at or below 80% effective health within 30 yards. Under **Clearcasting**, choose Healing Touch (default) or Regrowth and set the free direct-heal threshold (80% by default). Wild Growth has a separate 90% threshold during Clearcasting when Simia reports a zero mana cost.

Restoration 2.3.17 can prepare Swiftmend while you have an enemy selected or no target. When Swiftmend is ready and a party or raid teammate within 40 yards is at or below its threshold and lacks both of your HoTs, the profile can cast Rejuvenation using that same Swiftmend threshold. It needs mana for both spells. Emergency direct healing takes priority. On the next healing decision, Swiftmend checks the teammate's current effective health and your active HoT again.

For party healing with **Focus binds** off, bind the direct `@party1` through `@party4` variants. With **Party** or **Raid** selected, run AutoBind and check the shared focus assignment keys and each heal's `@focus` key.

In a battleground raid, select **Raid** scope for group healing. If Rejuvenation heals an unselected raider and Swiftmend stalls on the same ally, use **KhanForeverBindings 1.1.7** from this collection and run `/khanbindings swiftmend` to compare their spell bindings. To test delivery, pause Simia and keep an enemy selected. Hover the injured ally’s raid frame and type `/focus [@mouseover,help,nodead]`, then move the mouse away. With your Rejuvenation or Regrowth active on the ally and Swiftmend ready, press the **Swiftmend @focus** key. Check the recipient in the combat log.

You can stay on **Cat** when you switch to Bear or Dire Bear. Switch back to Cat to resume Cat attacks. For full manual control, turn off automatic form entry under **Feral**. Mark of the Wild, Thorns and caster heals wait until you leave Travel or Aquatic Form. In Bear, bind the ordinary **Lacerate**, **Primal Bite**, **Maul** and **Swipe** spells as you learn them. Lacerate builds to five stacks on the selected enemy and refreshes near expiry. Primal Bite or Maul fills single-target gaps, and Swipe fills gaps on an eligible engaged pack with AoE enabled.

In standalone **Cat**, **Stealth and opener → Pull with Faerie Fire out of combat** defaults off. With **Auto Prowl** on, approach in Cat Form and the profile waits for Prowl and your chosen opener. For a ranged Faerie Fire pull, turn Auto Prowl off and enable both the Faerie Fire pull and **Targeting → Allow attacks on an idle selected enemy**. In combat the usual debuff refresh applies.

Turn on **Combat self-healing → Heal in combat after I manually leave animal form** if you want to control shifts during a fight. Leave Cat or Bear to heal yourself, then switch back when ready. Bind the `@player` variants of the heals you know. The health sliders use effective health, including incoming heals. Healing Touch and Regrowth require standing still.

For corpse looting, enable the loader’s **Loot Nearby** option and bind **Interact Target**. Cat can use that key after combat when the dead enemy drops out of your target frame and WoW reports a lootable corpse nearby. A lootable mouseover still uses **Interact Mouseover**.

Cat and Manual Feral include **Stealth and opener** settings: enable Auto Prowl and choose a **5-40 yard** approach distance (default 25, center to center). It only runs outside combat while already in Cat Form with a selected hostile enemy and known distance. Auto Prowl is OFF by default and does not grant permission to pull idle enemies. **Exclusive stealth opener** selects Ravage (default) or Pounce. Both require rear positioning in the inspected Forever data; while prowling, the profile waits for the selected learned/bound spell instead of falling through to another attack or racial. If you want it to open an idle selected enemy automatically, separately enable **Targeting > Allow attacks on an idle selected enemy**. Manually queued actions are still honored.

War Stomp interrupts now work in the Cat profile and Cat/Bear modes of Manual Feral: an engaged selected or mouseover enemy must be casting, within the 8-yard center radius, non-boss and have a cast marked interruptible or stunnable. It requires standing still, more than 0.6 seconds remaining and the configured nearby-pull safeguards. Native learned/usable/binding checks remain; no form-cancel macro is added. Bind ordinary **War Stomp**, **Prowl**, and your chosen **Pounce/Ravage**. These are offline-validated decisions; actual client delivery still needs testing.

Use `KhanForeverBindings`. Bind the learned abilities/forms and the exact self/group/mouseover variants you enable. Leave form yourself for recovery in manual-form play. Optional Find Herbs needs the learned ordinary binding. Party/raid healing requires working native focus or direct-member routing.

## Hunter

All three specializations include pet management, movement/range checks, Hawk timing, optional dungeon entry, combat retargeting and low-mana priorities. Hawk timing uses exported guardian age and an assumed lifespan, not exact per-slot expiry.

Under **Buffs > Preferred combat aspect**, choose Hawk, Monkey or Beast. With Hawk or Beast selected, Monkey serves as an early-level fallback until you learn the preferred aspect. Any active rank of the preferred aspect satisfies the setting. You can keep Cheetah or Pack active between fights and the profile resumes your combat aspect when it recognizes an engagement.

In **Alterac Valley** or another battleground, select a living, attackable enemy player. Once both of you are in combat, the profile can use eligible single-target shots. Pet Attack waits four seconds between requests and Auto Shot waits two seconds between startup requests. This gives other shots time to fire while the pet is travelling or an attack confirmation is missing.

Use `KaptinForeverHunterBindings` 1.0.3. Bind **Pet Attack**, ordinary **Auto Shot**, **Auto Shot @stop_attack** and learned spells. Optional combat retargeting also needs **Target Enemy** and **Auto Shot @retarget_stop**.

To recall the pet with Follow when your selected enemy is under breakable crowd control (CC), bind **Auto Shot @retarget_stop** and enable **Targeting > Keep pet stance on breakable CC (Follow)**. Keep CC protection enabled. Combat retargeting can stay off. The binding runs `/stopattack` and `/petfollow`, preserving your pet's current stance. A pet in Assist or Defensive may re-engage on its own. If your pet is already Passive, select your preferred stance once.

With Follow off (the default), CC recalls set Passive. Disabling Damage or encountering an immunity covered by the immunity setting takes priority and recalls the pet in Passive using **Auto Shot @stop_attack**.

To join the tank's fight, enable **Targeting > Join selected fighting enemy in dungeons**, keep Force Combat and idle-target pulling off, select a fighting enemy and stand in shooting range. This dungeon mode needs no bridge installer. The old strict group bridge is not included here; disable it with `/kaptinhuntergroup off` if previously installed for that different mode.

Optional retargeting preserves living targets but native Target Enemy can select an idle enemy. Leave idle pulling off. Review mana/Mend reserves if expensive attacks are withheld. Traps, Feign Death and ground targeting remain manual.

**Cooldowns > Use remaining pull time for Bestial Wrath and Rapid Fire** is on by default. Both abilities check whether the pull has at least the configured time left (default 18 seconds). If the estimate is unknown or you turn the option off, they check the selected target's remaining life. A selected boss always passes the time check. Both abilities require Burst. Rapid Fire also needs its own option (off by default) and usable range. Bestial Wrath needs your pet attacking the selected target in melee.

## Mage

Arcane, Fire and Frost each have a level 1–60 profile. Use ordinary Simia spell bindings. The [Mage leveling guide](mage-leveling.md) covers setup, spec priorities and leveling simulations.

## Shaman

Under **Enhancement**, enable **Spend Clearcasting on Chain Lightning in packs (Deac)** to prioritize an Elemental Focus proc over Fire Nova and damage shocks. Enable AoE and **Damage > Chain Lightning for engaged packs**, bind ordinary Chain Lightning, and stand still for a hardcast. The pack threshold defaults to three enemies. Emergency healing, interrupts and a ready five-stack instant Maelstrom Bolt take priority.

Elemental, Enhancement and Restoration include movement-aware damage/healing, shield maintenance and configurable totems. Enhancement now prioritizes eligible Windfury Totem before Strength of Earth, while reactive Grounding stays first. Select **Totems > Air slot > Windfury** and bind its ordinary key. Both Earth/Air slots can stay active; existing mana, fight-length, movement and healing-reserve checks still apply. Optional Fire Nova requires the configured pack/totem conditions; it is not an unconditional single-target filler. Enhancement can apply the strongest learned main-hand imbue between fights when no temporary enchant is present. Existing enchants are preserved and off-hand application stays manual.

For Enhancement, select **Totems > Fire slot > Searing** or **Magma on packs; Searing otherwise** and bind the ordinary **Searing Totem** spell. With AoE off, Searing can drop for one detected, engaged enemy within 20 yards. Routine totems still use your minimum mana and fight-length settings.

**Totems > Recast selected totems that have fallen out of range** is enabled by default for Enhancement. During an eligible fight, stand still and the profile can replace an individual tracked support totem beyond its 30-yard buff radius. Searing and Magma also check whether their old position still reaches the target or other enemies. If the loader cannot locate an active totem, you can move or replace it manually.

Restoration saves its own **Main-hand weapon imbue** and **Air slot** choices. After updating, reselect any imbue or air totem you want on the healer. The defaults are **Manual** and **None** respectively.

Use `KaptinForeverShamanBindings`. Bind learned spells, chosen totems/imbues, potions and enabled heal/cure variants. For dungeon healing, choose **Keybinds > AutoBind > Focus binds > Party**, run **AUTOBIND** and confirm. Simia assigns focus for each heal while you keep your enemy selected. The [binding guide](shaman-bindings.md) also covers direct party keys, raid setup and separate self-heals.

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
