# Install or update

1. Download and extract the ZIP. Keep a backup of any matching profiles/addons you already use.
2. In `forever/custom`, copy the YAML files for your class into your actual **Simia Forever loader's `forever/custom` folder**. If your loader uses a different custom-profile location, use that location. YAML files do not go into the game's AddOns folder.
3. Copy your class's complete companion folder from `Interface/AddOns` into the **Forever game's `Interface/AddOns` folder**. Keep the TOC and Lua files directly inside that companion folder; avoid nesting the folder twice.

| Class | Companion folder |
|---|---|
| Paladin and Druid | `KhanForeverBindings` |
| Hunter | `KaptinForeverHunterBindings` |
| Shaman | `KaptinForeverShamanBindings` |
| Warlock | `KhanForeverWarlockBindings` |
| Warrior | `KaptinForeverWarriorBindings` |

4. Enable the companion alongside your existing Simia addon. Reload WoW; restart the game if a newly added addon is not listed. Refresh/reload the rotation list in Simia and select the desired **Forever** profile. Check its version against the README.
5. Run the actual **AUTOBIND** action at the top of Simia's AutoBind menu and confirm, or assign keys yourself. Selecting US/Czech/etc. under keyboard layout does not run AutoBind. Keep movement keys available.
6. Bind learned ordinary spells plus the exact `@player`, `@mouseover`, `@focus` and utility variants used by enabled options. Check those keys after learning new spells or changing talents. Read your [class guide](docs/classes.md) for special actions.
7. Start with the profile defaults and test your selected spells and intended healing targets. Saved settings can override new defaults after an update.

## Group healing

On the inspected host, shared focus healing requires **Keybinds > AutoBind > Focus binds** set to **Party** for dungeons or **Raid** for raids, followed by actual AutoBind/assignment. Bind the shared focus-assignment actions, one `@focus` key per enabled heal, and the separate `@player` self-heals. Adding a focus macro alone does not enable the loader's routing. See [Shaman binding instructions](docs/shaman-bindings.md) for the inspected host behavior.

## If something does not cast

- `NO BIND` means the requested action/variant has no usable exported binding.
- An activity-log entry records a request; it does not prove a successful cast. Pause the loader and check the exact logged key manually in the same game situation.
- Check that the intended profile is loaded, the ability is learned and the option is enabled. Include profile/version and a relevant snapshot when reporting a failure; remove account identifiers and credentials before posting logs publicly.

Normal installation runs no scripts and changes no saved settings. The older optional Warlock pet bridge has separate version checks and explicit installation instructions. It is not required for ordinary damage or player-engaged mouseover DoTs.
