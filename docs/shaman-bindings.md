# Shaman binding companion 1.0.1

Enable `KaptinForeverShamanBindings` alongside Simia on a Forever Shaman. The ZIP places the folder under `Interface/AddOns`. The binding fixtures were rechecked against SimulationcraftExtra 12.176, Forever interface 16001, on 15 November 2026. Existing native focus macros are preserved. Type `/kaptinshamanbindings` to inspect registration; `/khanshamanbindings` is an alias.

**Registration does not assign keys.** Run Simia's AutoBind command and confirm, or assign unused keys individually. Choosing a keyboard layout alone does not perform AutoBind. This package includes no personal key layout and does not reset existing keys or custom macros.

## Required actions

Bind learned ordinary damage, shield, cooldown and selected-totem spells used by the chosen profile. Bind the native **Attack Target**, **Health Potion**, and optional **Mana Potion** actions as needed. Ordinary Earth Shock interrupts the selected hostile target and shares the cooldown of the other shocks.

The companion supplies these targeting variants:

| Spell family | Added variants | Purpose |
|---|---|---|
| Healing Wave, Lesser Healing Wave | `@player`, `@focus` | Self-heals and native group healing |
| Chain Heal, Riptide | `@player`, `@focus` | Learned healing options |
| Cure Poison, Cure Disease | `@player`, `@focus` | Self and group cures |
| Earth Shock | `@mouseover`, `@focus` | Optional mouseover interrupt and manual focus use |
| Frost Shock, Purge | `@mouseover`, `@focus` | Manual utility variants |

Existing native mouseover healing entries remain intact. Bind only learned actions and variants you intend to use. No Earth Shield, Wind Shear, Lava Burst, Lava Lash or guessed weapon-hand targeting is added. Ordinary spell and racial actions use the host's existing bindings.

## Setting up group healing

In SimulationcraftExtra 12.176, **Focus binds controls the route**: Off exports direct-party routing, while Party/Raid exports focus routing. Forever defaults to Off for each talent group. Selecting the Restoration profile or adding a focus macro does not change that setting. Member cycling alone does not guarantee focus transport.

1. Open **Keybinds > AutoBind > Focus binds > Party (player + party1-4)** for a dungeon, or **Raid** for raids. Raid scope includes the party assignment keys for dungeons.
2. Click the top **AUTOBIND** entry and confirm, or assign the needed keys manually. Changing the scope does not itself run AutoBind.
3. Check the shared **Focus Player / Focus Party 1-4** assignment keys (plus raid assignment keys for Raid scope), each enabled heal/cure's **@focus** key, and self-heals' **@player** keys. The shared assignment keys are reused by all focus heals; each spell needs only one focus casting key.

Simia assigns focus during a group heal. You can keep an enemy selected. Run `/kaptinshamanbindings` on the current talent group to see the active route and check the shared focus assignment keys. Each enabled heal/cure also needs its own cast key.

**Direct dungeon keys with Focus binds Off.** In current Simia, right-click a learned heal's main row in Keybinds, open **Autobind > Additional Macros**, and select **@party1** through **@party4**. Repeat for each group heal or cure you enable and verify the assigned keys. Keep **@player** for self-heals. The native menu adds only the variants you select. Use Raid focus routing to cover raid members.

Before relying on party healing, confirm that a group heal reaches the intended injured member while an enemy is selected. Self-heals use the separate `@player` variants. If the focus route or a required key is missing, disable group healing until configured; the Restoration profile may correctly withhold damage while allies need recovery. Recheck learned rank bindings after training or changing talents.

Recheck after `/reload`: the inspected host still clears saved numeric focus keys during its Classic cleanup and may allocate new free keys during restore. This package does not patch that host behavior. A screenshot reporting `Healing Wave @partyN - NO BIND` establishes missing direct-party keys, not that the focus macro itself is missing. If Focus binds already shows Party/Raid, check binding exports and matching loader/addon versions before concluding why the route is wrong.

The hostile `@mouseover` and `@focus` macros use only that explicit living hostile unit, without fallback to the selected enemy. The automatic mouseover interrupt must be enabled separately in profile settings. The profile does not automatically Purge mouseover/focus units because their removable enemy-buff telemetry was not established. Those alternate Purge macros remain available for manual use.

## Movement and manual actions

WASD movement stays manual. The profiles react to movement; neither the companion nor the profiles walk, chase, turn or reposition the player. Instant Maelstrom Lightning Bolt and eligible Nature's Swiftness healing still require usable bindings.

For automatic main-hand imbues, bind the ordinary spell and select **Buffs > Main-hand weapon imbue**. Enhancement defaults to Automatic leveling. Restoration 1.0.6 has its own preference, initially Manual, and a separate **Totems > Air slot** preference, initially None. Select a choice in Restoration if you want a personal weapon imbue or an air totem. Existing temporary enchants keep their remaining duration. Off-hand application is manual.

Optional Fire Nova requires its ordinary key and the chosen Searing/Magma Totem key; see the Shaman section in [the class guide](classes.md) and the profile settings for tracked-totem and pack conditions. Totemic Call, Totemic Recall, Earthbind, Tremor, resistance and cleansing totems remain manual. Keep useful keys for them in your own layout. Totemic Call moves totems to your feet; Fire Nova is centered on an active fire totem. Chain Heal bounce geometry remains unavailable. No cursor/controller targeting helper or host patch is supplied.

## Potions

The companion adds level-appropriate Classic health and mana potion fallback tiers, strongest eligible tier first. Explicit native PotionConfig lists and custom macros retain precedence. The public native rebuild updates generated potion buttons on their existing assigned keys and defers during combat. If that rebuild is unavailable, the companion leaves potion detection and macros unchanged and reports the limitation.

Bind the native potion action and carry usable items. A ready flag does not establish successful key delivery. The addon does not purchase items, consume them from a timer, or allocate saved keys.

## Verification limits

The workspace contains offline tests of the companion against the inspected host's macro resolver and potion rebuild. They check localized ranks, preserved entries/custom macros, class/interface restrictions, existing keys and deferred refreshes. They cannot establish actual in-game casting or native focus transport. Package hash checks certify the included files, not game behavior. No DPS simulation was run for this release.
