[CmdletBinding()]
param(
    [string]$AddOnsRoot = 'C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns',
    [switch]$ValidateOnly,
    [switch]$Remove
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Assert-RegularPath([string]$Path) {
    $entry = Get-Item -LiteralPath $Path -Force
    while ($null -ne $entry) {
        if (($entry.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw "Refusing reparse point in target path: $($entry.FullName)"
        }
        if ($entry -is [IO.FileInfo]) { $entry = $entry.Directory }
        elseif ($entry -is [IO.DirectoryInfo]) { $entry = $entry.Parent }
        else { throw 'Unsupported target path type.' }
    }
}

function Get-BytesHash([byte[]]$Bytes) {
    $sha = [Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant() }
    finally { $sha.Dispose() }
}

function Count-Exact([string]$Text, [string]$Needle) {
    return [regex]::Matches($Text, [regex]::Escape($Needle)).Count
}

$root = [IO.Path]::GetFullPath($AddOnsRoot)
$hostRoot = Join-Path $root 'SimulationcraftExtra'
$source = Join-Path $hostRoot 'MemData.lua'
$toc = Join-Path $hostRoot 'SimulationcraftExtra.toc'
Assert-RegularPath $source
Assert-RegularPath $toc
if (-not (Get-Item -LiteralPath $root).PSIsContainer) { throw 'AddOnsRoot must be an existing directory.' }

$originalBytes = [IO.File]::ReadAllBytes($source)
$originalHash = Get-BytesHash $originalBytes
$hasBom = $originalBytes.Length -ge 3 -and $originalBytes[0] -eq 239 -and $originalBytes[1] -eq 187 -and $originalBytes[2] -eq 191
$utf8 = New-Object Text.UTF8Encoding($false, $true)
$offset = 0
if ($hasBom) { $offset = 3 }
$originalText = $utf8.GetString($originalBytes, $offset, $originalBytes.Length - $offset)
$newline = "`n"
if ($originalText.Contains("`r`n")) { $newline = "`r`n" }
$text = $originalText.Replace("`r`n", "`n")
if ($text.Contains("`r")) { throw 'Unsupported line endings; nothing changed.' }

$anchor = "local MemData = {}`nMainAddon.MemData = MemData"
$protocol = @'
-- KAPTIN_PET_ENGAGEMENT_PROTOCOL_BEGIN v1
MainAddon.KaptinWarlockPetThreatBridgeVersion = 1
-- KAPTIN_PET_ENGAGEMENT_PROTOCOL_END v1
'@
$originalBlock = @'
    -- Threat: UnitThreatSituation returns 0-3, or nil if N/A (dynamic, changes in combat)
    local threat = API.UnitThreatSituation(STR.PLAYER, unit)
    unitData[26] = threat or -1
'@
$bridgeBlock = @'
    -- KAPTIN_PET_ENGAGEMENT_BEGIN v1
    -- Preserve real player threat. Public pet engagement supplies neutral 0 only
    -- for mouseover; this compatibility field must not be read as player aggro.
    local threat = API.UnitThreatSituation(STR.PLAYER, unit)
    if unit == STR.MOUSEOVER and type(issecretvalue) == "function"
            and not issecretvalue(threat) and threat == nil then
        local bridge = MainAddon.KaptinWarlockPetEngaged
        if type(bridge) == "function" then
            local ok, engaged = pcall(bridge, unit)
            if ok and not issecretvalue(engaged) and engaged == true then
                threat = 0
            end
        end
    end
    unitData[26] = threat or -1
    -- KAPTIN_PET_ENGAGEMENT_END v1
'@
# Here-strings use the script's line endings on Windows; normalize comparison text.
$protocol = $protocol.Replace("`r`n", "`n")
$originalBlock = $originalBlock.Replace("`r`n", "`n")
$bridgeBlock = $bridgeBlock.Replace("`r`n", "`n")
$protocolAnchor = "$anchor`n$protocol"
$markerCount = Count-Exact $text 'KAPTIN_PET_ENGAGEMENT_'
$installed = $markerCount -ne 0

if ((Count-Exact $text $anchor) -ne 1) { throw 'MemData anchor is missing or duplicated; nothing changed.' }
if ($installed) {
    if ($markerCount -ne 4 -or (Count-Exact $text $protocolAnchor) -ne 1 -or
            (Count-Exact $text $bridgeBlock) -ne 1 -or (Count-Exact $text $originalBlock) -ne 0) {
        throw 'Pet engagement markers are partial, changed, or duplicated; nothing changed.'
    }
} elseif ((Count-Exact $text $originalBlock) -ne 1) {
    throw 'Expected host threat block is missing or duplicated; nothing changed.'
}

if (-not $Remove) {
    $tocText = [IO.File]::ReadAllText($toc)
    if ([regex]::Matches($tocText, '(?m)^## Version:\s*12\.175\s*$').Count -ne 1) {
        throw 'This bridge is validated for SimulationcraftExtra 12.175 only; nothing changed.'
    }
}

if ($Remove) {
    if (-not $installed) { Write-Output 'Pet engagement bridge is already absent; no files changed.'; exit 0 }
    $candidate = $text.Replace($protocolAnchor, $anchor).Replace($bridgeBlock, $originalBlock)
    $operation = 'removed'
} else {
    if ($installed) { Write-Output 'Pet engagement bridge v1 already installed and validated; no files changed.'; exit 0 }
    $candidate = $text.Replace($anchor, $protocolAnchor).Replace($originalBlock, $bridgeBlock)
    $operation = 'installed'
}
if ($ValidateOnly) { Write-Output "Validated: pet engagement bridge can be $operation. No files changed."; exit 0 }

$candidate = $candidate.Replace("`n", $newline)
[byte[]]$candidateBytes = $utf8.GetBytes($candidate)
if ($hasBom) { $candidateBytes = [byte[]](239, 187, 191) + $candidateBytes }
$candidateHash = Get-BytesHash $candidateBytes
$token = [Guid]::NewGuid().ToString('N')
$temporary = Join-Path $hostRoot ('.kaptin-pet-' + $token + '.tmp')
$backup = Join-Path $hostRoot ('MemData.lua.kaptin-pet-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + $token + '.bak')
$published = $false
try {
    $stream = [IO.File]::Open($temporary, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
    try { $stream.Write($candidateBytes, 0, $candidateBytes.Length); $stream.Flush($true) }
    finally { $stream.Dispose() }
    if ((Get-BytesHash ([IO.File]::ReadAllBytes($temporary))) -ne $candidateHash) { throw 'Staged file hash mismatch.' }
    Assert-RegularPath $source
    if ((Get-BytesHash ([IO.File]::ReadAllBytes($source))) -ne $originalHash) { throw 'Host changed during preparation; nothing published.' }
    # Same-directory atomic replacement also saves the exact previous file.
    [IO.File]::Replace($temporary, $source, $backup)
    $published = $true
    if ((Get-BytesHash ([IO.File]::ReadAllBytes($backup))) -ne $originalHash) { throw 'Host changed at publication; restoring the atomic backup.' }
    if ((Get-BytesHash ([IO.File]::ReadAllBytes($source))) -ne $candidateHash) { throw 'Installed file hash mismatch.' }
} catch {
    if ($published -and [IO.File]::Exists($backup)) {
        # Restore only our own published bytes. Never overwrite a later external update.
        if ((Get-BytesHash ([IO.File]::ReadAllBytes($source))) -eq $candidateHash) {
            [IO.File]::Replace($backup, $source, $null)
        }
    }
    throw
} finally {
    if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
}
Write-Output "Pet engagement bridge $operation. SHA256: $candidateHash"
Write-Output "Exact previous file: $backup"
Write-Output 'Reload WoW to apply. Bindings and SavedVariables were not changed.'
