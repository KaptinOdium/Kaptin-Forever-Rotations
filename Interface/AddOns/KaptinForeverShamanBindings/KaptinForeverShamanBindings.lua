-- Native Simia targeting metadata. No automatic key assignment or casting.
local _, _, _, interface = GetBuildInfo()
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 then return end
local _, class = UnitClass("player")
if class ~= "SHAMAN" then return end

local A, M
local status = {version = "1.0.0", added = 0, skipped = 0}
_G.KaptinForeverShamanBindings = status

-- Forever families, not retail spell IDs. The localized
-- spellbook scan below supplies matching learned ranks and host base IDs.
-- cycle=members/tanks uses focus transport; it does not need party1-4 rows.
local families = {
    {331, "Healing Wave", "friendly"},
    {8004, "Lesser Healing Wave", "friendly"},
    {1064, "Chain Heal", "friendly"},
    {408521, "Riptide", "friendly"},
    {1239242, "Riptide", "friendly"},
    {1239243, "Riptide", "friendly"},
    {526, "Cure Poison", "friendly"},
    {2870, "Cure Disease", "friendly"},
    {370, "Purge", "hostile"},
    {8042, "Earth Shock", "hostile"},
    {8056, "Frost Shock", "hostile"},
}

local function mergeMissing(id, suffix, friendly)
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
    -- One explicit unit clause prevents fallback to the selected target if
    -- focus/mouseover changes between the condition check and the keypress.
    local condition = suffix == "player" and "@player" or
        ("@%s,%s,nodead"):format(suffix, friendly and "help" or "harm")
    entry[suffix] = ("/cast [%s] {%d}"):format(condition, id)
    status.added = status.added + 1
end

local function add(id, kind)
    if kind == "friendly" then
        mergeMissing(id, "player", true)
        mergeMissing(id, "focus", true)
    else
        mergeMissing(id, "mouseover", false)
        mergeMissing(id, "focus", false)
    end
end

local function spellInfo(key)
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        return C_Spell.GetSpellInfo(key)
    end
end

local function register()
    local names = {}
    for _, row in ipairs(families) do
        local id, english, kind = row[1], row[2], row[3]
        add(id, kind)
        local data = spellInfo(id)
        if data and data.name then names[data.name] = kind end
        local named = spellInfo(english)
        if named and type(named.spellID) == "number" then
            add(named.spellID, kind)
            if named.name then names[named.name] = kind end
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
                    local kind = info and names[info.name]
                    if kind then
                        add(spell.spellID, kind)
                        local base = A.ClassicRankBase and A.ClassicRankBase[spell.spellID]
                        if type(base) == "number" then add(base, kind) end
                    end
                end
            end
        end
    end
end

-- The inspected host's potion fallback IDs are retail. Its public rebuild
-- updates only generated potion buttons on their existing assigned keys;
-- native custom PotionConfig lists and user custom macros keep precedence.
local consumables = {
    HEALTH_POTION_ITEMS = {{13446,45},{3928,35},{1710,21},{929,12},{858,3},{118,1}},
    MANA_POTION_ITEMS = {{13444,49},{13443,41},{6149,31},{3827,22},{3385,14},{2455,5}},
}
local originalLists, consumablesPending, pendingLevel = {}, true, nil
local function refreshConsumables()
    if not A or not consumablesPending then return end
    if type(InCombatLockdown) ~= "function" or InCombatLockdown() then return end
    -- Do not change telemetry without the matching native macro rebuild.
    if not (A.Autobind and type(A.Autobind.RebuildConsumableMacros) == "function") then
        status.potions = "native rebuild unavailable; configure potions in Simia"
        return
    end
    local level = pendingLevel or (type(UnitLevel) == "function" and UnitLevel("player") or 0)
    if type(level) ~= "number" or level <= 0 then return end
    for name in pairs(consumables) do
        if type(_G[name]) ~= "table" then return end
    end
    for name, rows in pairs(consumables) do
        local list = _G[name]
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
                if type(actualRequired) == "number" and actualRequired >= 0 then required = actualRequired end
            end
            if level >= required and not added[id] then
                result[#result+1] = id; added[id] = true
            end
        end
        for _, id in ipairs(originalLists[name]) do
            if not known[id] and not added[id] then result[#result+1] = id; added[id] = true end
        end
        for index = #list, 1, -1 do list[index] = nil end
        for index, id in ipairs(result) do list[index] = id end
    end
    A.Autobind.RebuildConsumableMacros()
    consumablesPending, pendingLevel = false, nil
    status.potions = "Classic potion fallback refreshed"
end

local function connect()
    if A then return true end
    local name = type(_G.Z_AddonName) == "string" and _G.Z_AddonName or "SimulationcraftExtra"
    local host = _G[name]
    if not (type(host) == "table" and host.IsClassic and type(host.SpellMacros) == "table") then return false end
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

SLASH_KAPTINFOREVERSHAMANBINDINGS1 = "/kaptinshamanbindings"
SLASH_KAPTINFOREVERSHAMANBINDINGS2 = "/khanshamanbindings"
SlashCmdList.KAPTINFOREVERSHAMANBINDINGS = function()
    if not A then update() end
    if not A then
        print("Kaptin Forever Shaman Bindings " .. status.version .. ": waiting for an enabled compatible Simia addon.")
        return
    end
    print(("Kaptin Forever Shaman Bindings %s: %s; %d added variants; %s."):format(
        status.version, status.host, status.added, status.potions or "potion refresh pending"))
    print("Bind learned self/focus heal and utility variants in Simia; enable native group focus routing for member healing.")
    print("Bind Earth Shock, Frost Shock and Purge @mouseover/@focus if enabled. Existing keys and custom macros are preserved.")
end
