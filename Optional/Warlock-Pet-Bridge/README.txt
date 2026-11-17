Kaptin Warlock pet engagement compatibility bridge, protocol v1

This optional bridge is for SimulationcraftExtra 12.175 on WoW Forever.
It works with the companion's KaptinWarlockPetEngaged callback. The host
patch alone does not enable pet detection; without the callback it preserves
the native behavior.

Install from PowerShell, substituting your actual Forever AddOns directory:
  .\Install-PetEngagement.ps1 -AddOnsRoot 'D:\YourGame\Interface\AddOns'
Validate without changes:
  .\Install-PetEngagement.ps1 -AddOnsRoot 'D:\YourGame\Interface\AddOns' -ValidateOnly
Remove only the exact bridge blocks while preserving other host changes:
  .\Install-PetEngagement.ps1 -AddOnsRoot 'D:\YourGame\Interface\AddOns' -Remove

Reload WoW after installing or removing. The installer saves an exact backup
beside MemData.lua, validates hashes, and publishes by atomic replacement.
It refuses unfamiliar versions, altered or partial markers, duplicate source
blocks and reparse paths. It does not change bindings or SavedVariables.
Host updates may remove the bridge; never force it into an unrecognized build.

How it works:
The native mouseover threat field normally describes the player's threat.
When that value is public nil, and the companion confirms public engagement
with your own living pet, the bridge exports neutral 0 for the mouseover only.
Actual player threat is preserved. Target, focus, pet and nameplate snapshots
are unchanged. No global API is replaced and no casts or targets are issued.

The field is now player-or-pet engagement for compatible Warlock profiles.
It must not be interpreted as actual player threat when the pet fallback is
active. The supplied three profiles test >=0 for engagement, and neutral 0
allows pet-only entry before the player's combat flag catches up. This also
allows enabled mouseover control spells to recognize pet-engaged enemies.
Unknown, secret, failed or absent callback results never authorize engagement.

Offline tests validate the bridge and installer. A successful install is not
proof of live combat behavior; public pet threat availability depends on the
client. If the client hides that information, the bridge deliberately skips it.
