-- Additive Simia targeting metadata. No key allocation, movement or direct casts.
local _, _, _, interface = GetBuildInfo()
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 then return end
local _, class = UnitClass("player")
if class ~= "WARRIOR" then return end

local A, M
local status = {version = "1.0.0", added = 0, skipped = 0}
_G.KaptinForeverWarriorBindings = status

-- Forever active cast families. Learned localized ranks and native rank-base
-- entries are also registered; database presence does not imply learnability.
local families = {
    {355, "Taunt"},
    {6552, "Pummel"},
    {72, "Shield Bash"},
    {20252, "Intercept"},
    {676, "Disarm"},
}

local function mergeMissing(id, suffix, macro)
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
    -- No fallback clause: a lost or invalid alternate unit must not redirect
    -- an interrupt, taunt or control action onto the selected enemy.
    entry[suffix] = macro or ("/cast [@%s,harm,nodead] {%d}"):format(suffix, id)
    status.added = status.added + 1
end

local function add(id)
    mergeMissing(id, "mouseover")
    mergeMissing(id, "focus")
end

local function spellInfo(key)
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        return C_Spell.GetSpellInfo(key)
    end
end

local function register()
    -- Native suffix routing uses a learned spell as the binding owner. This
    -- variant only stops autoattack; it neither casts nor changes stance,
    -- cancels a cast/channel, or claims to clear Heroic Strike/Cleave queues.
    mergeMissing(2457, "stop_attack", "/stopattack")
    local names = {}
    for _, row in ipairs(families) do
        local id, english = row[1], row[2]
        add(id)
        local data = spellInfo(id)
        if data and data.name then names[data.name] = true end
        local named = spellInfo(english)
        if named and type(named.spellID) == "number" then
            add(named.spellID)
            if named.name then names[named.name] = true end
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
                    if info and names[info.name] then
                        add(spell.spellID)
                        local base = A.ClassicRankBase and A.ClassicRankBase[spell.spellID]
                        if type(base) == "number" then add(base) end
                    end
                end
            end
        end
    end
end

-- The host fallback table contains retail health potions. Reuse its PUBLIC
-- consumable rebuild, which respects custom lists/macros and assigned keys.
-- Do not alter mana/combat-potion or Healthstone detection for a Warrior.
local healthTiers = {{13446,45},{3928,35},{1710,21},{929,12},{858,3},{118,1}}
local originalHealth, consumablesPending, pendingLevel = nil, true, nil
local function refreshConsumables()
    if not A or not consumablesPending then return end
    if type(InCombatLockdown) ~= "function" or InCombatLockdown() then return end
    if not (A.Autobind and type(A.Autobind.RebuildConsumableMacros) == "function") then
        status.potions = "native rebuild unavailable; configure health potions in Simia"
        return
    end
    local level = pendingLevel or (type(UnitLevel) == "function" and UnitLevel("player") or 0)
    if type(level) ~= "number" or level <= 0 or type(HEALTH_POTION_ITEMS) ~= "table" then return end
    if not originalHealth then
        originalHealth = {}
        for _, id in ipairs(HEALTH_POTION_ITEMS) do originalHealth[#originalHealth+1] = id end
    end
    local added, known, result = {}, {}, {}
    for _, row in ipairs(healthTiers) do
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
    for _, id in ipairs(originalHealth) do
        if not known[id] and not added[id] then result[#result+1] = id; added[id] = true end
    end
    for index = #HEALTH_POTION_ITEMS, 1, -1 do HEALTH_POTION_ITEMS[index] = nil end
    for index, id in ipairs(result) do HEALTH_POTION_ITEMS[index] = id end
    A.Autobind.RebuildConsumableMacros()
    consumablesPending, pendingLevel = false, nil
    status.potions = "Classic health potion fallback refreshed"
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

SLASH_KAPTINFOREVERWARRIORBINDINGS1 = "/kaptinwarriorbindings"
SLASH_KAPTINFOREVERWARRIORBINDINGS2 = "/khanwarriorbindings"
SlashCmdList.KAPTINFOREVERWARRIORBINDINGS = function()
    if not A then update() end
    if not A then
        print("Kaptin Forever Warrior Bindings " .. status.version .. ": waiting for an enabled compatible Simia addon.")
        return
    end
    print(("Kaptin Forever Warrior Bindings %s: %s; %d added variants; %s."):format(
        status.version, status.host, status.added, status.potions or "health potion refresh pending"))
    print("Bind learned Taunt, Pummel, Shield Bash, Intercept and Disarm @mouseover/@focus as needed.")
    print("Bind Battle Stance @stop_attack for the protected-target autoattack stop action.")
    print("Registration does not assign keys. Existing keys and custom macros are preserved.")
end
