# Warlock binding companion 1.3.3

Copy `Interface/AddOns/KhanForeverWarlockBindings` into the Forever client's `Interface/AddOns` directory and enable it together with Simia on the Warlock. Restart WoW if the new addon is not listed. Then type `/khanwarlockbindings` to check which Simia host it found.

The ZIP puts this folder under `Interface/AddOns`. Keep the legacy folder name even though its display title says Kaptin. The optional pet engagement patch targets the inspected Simia addon 12.175. Selecting a keyboard layout alone does not bind anything: run AutoBind and confirm, or assign keys individually. Existing keys/custom macros are preserved; the addon does not import someone else's layout. `/kaptinwarlockbindings` is an alias for the original command.

In Simia's keybinding window, assign an unused key to each enabled learned variant:

- Ordinary spells used by the profile, including Shoot.
- The native **Pet Attack** action. This is already supplied by Simia; this addon does not create another pet attack action.
- **Corruption @mouseover**, **Bane of Agony @mouseover** (also known as Curse of Agony), and **Immolate @mouseover** for mouseover DoTs. Agony and Immolate are new in 1.3.2 and need their own keys after `/reload`.
- **Fear @mouseover**, **Banish @mouseover**, and **Death Coil @mouseover** when enabling those control options. Disable mouseover Fear/Banish when spreading DoTs: these controls take priority and controlled enemies are not dotted.
- **Rain of Fire @cursor** if enabling the optional ground spell. Position the cursor on the ground yourself; it does not calculate the pack's ground position.
- Leave experimental **Rain of Fire @controller** placement disabled in this collection; use cursor placement below.

Demon Skin, Demon Armor and Life Tap use their ordinary spell keys. They are naturally self-targeted and do not need separate self variants. Only the eight profile-required targeting variants are exposed, avoiding unnecessary key assignments. The new dynamic exporter still requires enough distinct keys in your chosen layout.

Mouseover macros act on the currently hovered living hostile unit with no selected-target fallback. Keep the cursor over the enemy through each cast/global. They do not remember or queue a whole set of DoTs. For pet-only enemies, read the optional [Warlock Pet Bridge instructions](../../Optional/Warlock-Pet-Bridge/README.txt) and install it only on its supported 12.175 host, reload WoW and the profile, then enable `/kaptinpetdots on`. It verifies your own pet's threat against that exact hovered enemy. No extra binding is required. `/kaptinpetdots status` checks availability; `/kaptinpetdots off` disables it. The helper defaults off per character.

The compatibility patch preserves real player threat and exports neutral mouseover threat 0 only when the player has none and your pet has a verified relationship. While enabled, this changes mouseover threat's meaning to include pet engagement; turn it off when using another Warlock profile that requires strictly player-only threat. Other units and classes are unchanged. Unavailable/secret data is rejected. The native loader handoff still needs a live combat test.

The addon preserves existing custom macros and assigned keys. It exposes matching learned ranks when the spellbook changes; Simia controls inheritance of existing rank bindings. It does not allocate saved keys, create spellbook abilities or change targets. The optional controller bridge temporarily routes the dedicated controller key to a native controller action; it does not issue casts from timers.

## Rain of Fire placement

**Normal cursor mode is the default.** Select Cursor in the profile's Rain of Fire placement setting, bind `Rain of Fire @cursor`, and enable Rain of Fire. With AoE enabled, enough mana and enough enemies, the profile casts at the cursor while you are stationary. No controller setup is needed.

**Automatic controller placement is not supplied by this collection.** Its separate ground-export installer and test instructions are excluded because successful live automatic placement has not been established. Keep Cursor selected and place your cursor manually. The companion retains its existing helper module for compatibility, but its presence is not a completed controller setup.

Shoot's default generated macro uses `/cast !Shoot` (localized through its spell ID) so repeat requests do not toggle wanding off. If Shoot was previously bound using a plain `/cast Shoot` macro, reassign **that same key** in Simia once to rebuild the button. A user-supplied custom Shoot macro is preserved.

## Consumables

The installed Simia build's default consumable tables contain retail potion IDs and only Minor Healthstone from Classic. On a Warlock, this helper adds the standard Classic healing and mana potion tiers and all five Healthstone tiers, including improved variants, strongest first. It filters the added entries by required level, using the client item level requirement when cached and the Classic requirement as fallback.

Simia's explicit PotionConfig lists still take precedence. If you configured those lists, include potions your character can use; the helper does not rewrite your choices. The public native potion-macro rebuild refreshes generated potion buttons on their existing keys and honors custom macros. Updates defer until combat ends.

**Healthstone requires one extra step.** The host stores its Healthstone macro privately and provides no public rebuild for it. Detection alone is not enough: open Simia's **Healthstone** action, paste the complete contents of `Healthstone-macro.txt` into its custom **Macro** setting, then assign or reassign the intended Healthstone key. The supplied macro is under 255 characters. Keep automatic Healthstone use disabled in the profile until this is done. It tries the strongest known tier first and does not create stones; create them yourself between pulls.

The helper does not touch the private Healthstone macro, fabricate a successful binding, or replace an existing Healthstone custom macro. Its recognition table includes pre-existing extra IDs, but the supplied macro covers only the documented Classic item tiers.

## Pet control limits

The installed Forever host scans the player spellbook, not the pet spell bank. Its retail Command Demon spell IDs are intentionally disabled for Classic. Consequently, adding a macro for the pet-side Spell Lock IDs cannot make the rotation recognize them as learned, ready and bound. **Spell Lock, Devour Magic, Sacrifice, Torment and other pet abilities remain native pet autocast/manual controls in this package.** Pet Attack is the supported native rotation action. No retail Spell Lock IDs or invented readiness checks are added.

Dark Pact was removed from Forever. No Demonic Empowerment or Shadowfury entry is invented for this package. Refer to the [official Rogue and Warlock deep dive](https://news.blizzard.com/en-gb/article/24310968/world-of-warcraft-forever-class-deep-dives-rogue-and-warlock).

## Verification

The original source workspace contains the companion integration suite. Those development fixtures are not part of this runtime collection. To verify these downloaded files, run `python tools/verify_package.py` from the collection root.

The tests execute the companion in Lua against the installed Simia macro resolver, native potion rebuild and binding application code. They cover localized ranks, delayed/renamed hosts, preservation of custom macros, non-toggle Shoot, item level boundaries, combat deferral and explicit potion lists. They do not certify actual in-game key delivery.
