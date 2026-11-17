-- Additive targeting metadata only. Casting and key assignment stay with Simia.
-- This is deliberately separate from the Paladin/Druid companion.
local _, _, _, interface = GetBuildInfo()
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 then return end
local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local A, M
local consumablesPending = true
local pendingLevel
local status = {version = "1.3.3", added = 0, skipped = 0}
_G.KhanForeverWarlockBindings = status

-- Expose only the variants actually referenced by the three delivered profiles.
-- Extra variants consume keys even with the current dynamic binding transport.
-- Localized name matching below adds learned ranks without hardcoding max rank.
local families = {
    {172, "Corruption", "mouseover"},
    -- Forever renamed Curse of Agony; both names identify the same rank family.
    {980, {"Bane of Agony", "Curse of Agony"}, "mouseover"},
    {348, "Immolate", "mouseover"},
    {5782, "Fear", "mouseover"},
    {6789, "Death Coil", "mouseover"},
    {710, "Banish", "mouseover"},
    {5740, "Rain of Fire", {"cursor", "controller"}},
}

-- The host's defaults are retail-only except Minor Healthstone. The Classic
-- lists are fallbacks: an explicit native PotionConfig list still wins.
-- Strongest first within each tier. The minimum levels prevent the host's
-- "first item in bags" scan choosing a potion saved for a later level.
local consumables = {
    HEALTHSTONE_ITEMS = {
        {19013,48},{19012,48},{9421,48}, {19011,36},{19010,36},{5510,36},
        {19009,24},{19008,24},{5509,24}, {19007,12},{19006,12},{5511,12},
        {19005,1},{19004,1},{5512,1},
    },
    HEALTH_POTION_ITEMS = {{13446,45},{3928,35},{1710,21},{929,12},{858,3},{118,1}},
    MANA_POTION_ITEMS = {{13444,49},{13443,41},{6149,31},{3827,22},{3385,14},{2455,5}},
}
local originalLists = {}
local function refreshConsumables()
    if not A or not consumablesPending then return end
    -- Keep telemetry and generated potion macros consistent during combat.
    if type(InCombatLockdown) ~= "function" or InCombatLockdown() then return end
    local level = pendingLevel or (type(UnitLevel) == "function" and UnitLevel("player") or 0)
    if type(level) ~= "number" or level <= 0 then return end
    for name, rows in pairs(consumables) do
        local list = _G[name]
        if type(list) == "table" then
            if not originalLists[name] then
                originalLists[name] = {}
                for _, id in ipairs(list) do originalLists[name][#originalLists[name]+1] = id end
            end
            local added, known, result = {}, {}, {}
            for _, row in ipairs(rows) do
                local id, required = row[1], row[2]
                known[id] = true
                if C_Item and type(C_Item.GetItemInfo) == "function" then
                    local _, _, _, _, actualRequired = C_Item.GetItemInfo(id)
                    if type(actualRequired) == "number" and actualRequired >= 0 then
                        required = actualRequired
                    end
                end
                if level >= required and not added[id] then
                    result[#result+1] = id; added[id] = true
                end
            end
            for _, id in ipairs(originalLists[name]) do
                if not known[id] and not added[id] then
                    result[#result+1] = id; added[id] = true
                end
            end
            for index = #list, 1, -1 do list[index] = nil end
            for index, id in ipairs(result) do list[index] = id end
        end
    end
    if A.Autobind and type(A.Autobind.RebuildConsumableMacros) == "function" then
        -- Public native rebuild honors custom macros and reuses assigned keys.
        -- It rebuilds potion defaults, not the private Healthstone macro.
        A.Autobind.RebuildConsumableMacros()
        consumablesPending = false
        pendingLevel = nil
        status.potions = "native fallback rebuilt"
    end
end

local function mergeMissing(id, suffix)
    if type(id) ~= "number" or id <= 0 then return end
    local entry = M[id]
    if entry == nil then
        entry = {}; M[id] = entry
    elseif type(entry) == "string" then
        entry = {macro = entry}; M[id] = entry
    elseif type(entry) ~= "table" then
        status.skipped = status.skipped + 1
        return
    end
    if entry[suffix] ~= nil then return end
    if suffix == "mouseover" then
        -- Never fall back to the selected target if the cursor leaves a unit.
        entry.mouseover = ("/cast [@mouseover,harm,nodead] {%d}"):format(id)
    elseif suffix == "cursor" then
        entry.cursor = ("/cast [@cursor] {%d}"):format(id)
    elseif suffix == "controller" then
        -- Fail closed until the optional native-controller adapter is armed.
        -- A normal /cast fallback would silently use the wrong placement mode.
        entry.controller = "/stopmacro"
    else
        return
    end
    status.added = status.added + 1
end

local function spellInfo(key)
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        return C_Spell.GetSpellInfo(key)
    end
end

local function register()
    -- Shoot is a General spell and may be missed by the host's class-tab scan.
    -- FlaggedForKeybind still requires that the player actually knows it.
    local flagged = A.SpellData and A.SpellData.FlaggedForKeybind
    if type(flagged) == "table" then
        local found = false
        for _, id in ipairs(flagged) do if id == 5019 then found = true; break end end
        if not found then flagged[#flagged+1] = 5019 end
    end
    if M[5019] == nil then
        M[5019] = {macro = "/cast !{5019}"}
    elseif type(M[5019]) == "table" and M[5019].macro == nil then
        M[5019].macro = "/cast !{5019}"
    end
    local names = {}
    for _, row in ipairs(families) do
        local id = row[1]
        local aliases = type(row[2]) == "table" and row[2] or {row[2]}
        local suffixes = type(row[3]) == "table" and row[3] or {row[3]}
        for _, suffix in ipairs(suffixes) do mergeMissing(id, suffix) end
        local data = spellInfo(id)
        if data and data.name then names[data.name] = suffixes end
        for _, alias in ipairs(aliases) do
            local named = spellInfo(alias)
            if named and type(named.spellID) == "number" then
                for _, suffix in ipairs(suffixes) do mergeMissing(named.spellID, suffix) end
                if named.name then names[named.name] = suffixes end
            end
        end
    end
    if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines
            and C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo
            and Enum and Enum.SpellBookSpellBank and Enum.SpellBookItemType) then return end
    local bank = Enum.SpellBookSpellBank.Player
    for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skill = C_SpellBook.GetSpellBookSkillLineInfo(line)
        if skill and not skill.offSpecID then
            local offset = skill.itemIndexOffset or 0
            for slot = offset + 1, offset + (skill.numSpellBookItems or 0) do
                local spell = C_SpellBook.GetSpellBookItemInfo(slot, bank)
                if spell and spell.spellID and not spell.isPassive and not spell.isOffSpec
                        and spell.itemType == Enum.SpellBookItemType.Spell then
                    local info = spellInfo(spell.spellID)
                    local suffixes = info and names[info.name]
                    if suffixes then
                        local base = A.ClassicRankBase and A.ClassicRankBase[spell.spellID]
                        for _, suffix in ipairs(suffixes) do
                            mergeMissing(spell.spellID, suffix)
                            if type(base) == "number" then mergeMissing(base, suffix) end
                        end
                    end
                end
            end
        end
    end
end

local function connect()
    if A then return true end
    local name = type(_G.Z_AddonName) == "string" and _G.Z_AddonName or "SimulationcraftExtra"
    local host = _G[name]
    if not (type(host) == "table" and host.IsClassic and type(host.SpellMacros) == "table") then
        return false
    end
    A, M = host, host.SpellMacros
    status.host = name
    return true
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("SPELLS_CHANGED")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
local function update(_, event, newLevel)
    if event == "PLAYER_LEVEL_UP" or event == "PLAYER_LOGIN" then consumablesPending = true end
    if event == "PLAYER_LEVEL_UP" and type(newLevel) == "number" and newLevel > 0 then pendingLevel = newLevel end
    local connected = A ~= nil
    if connect() then
        if not connected or event == "SPELLS_CHANGED" or event == "PLAYER_LOGIN" then register() end
        refreshConsumables()
    end
end
events:SetScript("OnEvent", update)
update()

SLASH_KHANFOREVERWARLOCKBINDINGS1 = "/khanwarlockbindings"
SLASH_KHANFOREVERWARLOCKBINDINGS2 = "/kaptinwarlockbindings"
SlashCmdList.KHANFOREVERWARLOCKBINDINGS = function()
    if not A then update() end
    if not A then
        print("Kaptin Forever Warlock Bindings " .. status.version .. ": waiting for an enabled compatible Simia addon.")
        return
    end
    local function has(id, suffix)
        return type(M[id]) == "table" and M[id][suffix] ~= nil and "registered" or "unavailable"
    end
    print(("Kaptin Forever Warlock Bindings %s: %s; Corruption @mouseover %s; Bane of Agony @mouseover %s; Immolate @mouseover %s; Rain of Fire @cursor %s."):format(
        status.version, status.host, has(172, "mouseover"), has(980, "mouseover"), has(348, "mouseover"), has(5740, "cursor")))
    print("Assign each learned variant its own unused key in Simia. Existing keys and custom macros are preserved.")
    print("Rain of Fire automatic controller confirmation is EXPERIMENTAL. Requires Ground Export Bridge and /khanwarlockground on OPENKEY CONFIRMKEY. Normal cursor mode remains available.")
    print("Healthstone: higher ranks are detected; paste the supplied Healthstone macro into its Simia custom Macro setting before enabling automatic use.")
end
