-- Additive Simia targeting metadata. No key allocation, movement or direct casts.
local _, _, _, interface = GetBuildInfo()
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 then return end
local _, class = UnitClass("player")
if class ~= "HUNTER" then return end

local A, M
local status = {version = "1.0.3", added = 0, skipped = 0}
_G.KaptinForeverHunterBindings = status

-- Forever active cast families. Learned localized ranks and native rank-base
-- entries are also registered; database presence does not imply learnability.
local families = {
    {{19503}, "Scatter Shot", {
        mouseover = "/cast [@mouseover,harm,nodead] {%d}",
        focus = "/cast [@focus,harm,nodead] {%d}",
    }},
    {{5116}, "Concussive Shot", {
        mouseover = "/cast [@mouseover,harm,nodead] {%d}",
        focus = "/cast [@focus,harm,nodead] {%d}",
    }},
    {{1978}, "Serpent Sting", {
        mouseover = "/cast [@mouseover,harm,nodead] {%d}",
    }},
    {{1293241, 1293525, 1293526, 1293527}, "Summon Hawk", {
        -- A separate opt-in variant preserves the ordinary cast and manual
        -- stance. Both commands require a living hostile selected target.
        -- Assist persists after the cast; restoring Passive would undo it.
        assist = "/petassist [harm,nodead]\n/cast [harm,nodead] {%d}",
    }},
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
    entry[suffix] = macro
    status.added = status.added + 1
end

local function add(id, variants)
    for suffix, template in pairs(variants) do
        -- Explicit templates keep control variants strict and allow command
        -- variants without mistaking their suffix for a target unit.
        mergeMissing(id, suffix, template:format(id))
    end
end

local function spellInfo(key)
    if C_Spell and type(C_Spell.GetSpellInfo) == "function" then
        return C_Spell.GetSpellInfo(key)
    end
end

local function register()
    -- Auto Shot is a non-toggle start macro. Preserve an existing native or
    -- custom base macro; users run AutoBind to apply generated metadata.
    mergeMissing(75, "macro", "/cast !{75}")
    -- This intentionally leaves the pet Passive after recall. Native petattack
    -- still works in that mode; pet autocast abilities are not altered.
    -- Protective recall is independent of permanent-pet care configuration.
    -- No /stopcasting: a legitimate current cast/channel is not interrupted.
    mergeMissing(75, "stop_attack", "/stopattack\n/petpassive\n/petfollow")
    -- Retargeting is not a CC recall. Stop and follow without changing the
    -- user's pet stance; the profile still waits for inactive attack telemetry.
    -- Separate metadata preserves old/custom protective keys and macros.
    mergeMissing(75, "retarget_stop", "/stopattack\n/petfollow")
    local names = {}
    for _, row in ipairs(families) do
        local ids, english, variants = row[1], row[2], row[3]
        for _, id in ipairs(ids) do
            add(id, variants)
            local data = spellInfo(id)
            if data and data.name then names[data.name] = variants end
        end
        local named = spellInfo(english)
        if named and type(named.spellID) == "number" then
            add(named.spellID, variants)
            if named.name then names[named.name] = variants end
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
                    local variants = info and names[info.name]
                    if variants then
                        add(spell.spellID, variants)
                        local base = A.ClassicRankBase and A.ClassicRankBase[spell.spellID]
                        if type(base) == "number" then add(base, variants) end
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

SLASH_KAPTINFOREVERHUNTERBINDINGS1 = "/kaptinhunterbindings"
SlashCmdList.KAPTINFOREVERHUNTERBINDINGS = function()
    if not A then update() end
    if not A then
        print("Kaptin Forever Hunter Bindings " .. status.version .. ": waiting for an enabled compatible Simia addon.")
        return
    end
    print(("Kaptin Forever Hunter Bindings %s: %s; %d added variants; %s."):format(
        status.version, status.host, status.added, status.potions or "potion refresh pending"))
    print("Bind Scatter Shot / Concussive Shot @mouseover/@focus, and Serpent Sting @mouseover only if enabled.")
    print("Bind Auto Shot @stop_attack to stop autoattacks and recall your pet; recall leaves the pet Passive.")
    print("For combat retargeting, bind Auto Shot @retarget_stop: stop and follow without a pet stance command. Requires companion 1.0.3.")
    print("Protective recall remains active when permanent-pet care is OFF.")
    print("Bind Summon Hawk @assist for the opt-in Hawk Assist workaround. It leaves the pet in Assist until changed or recalled.")
    print("Assist changes manual pet stance and can engage other enemies; verify the Hawk workaround in game.")
    print("Registration does not assign keys. Existing keys and custom macros are preserved.")
end
