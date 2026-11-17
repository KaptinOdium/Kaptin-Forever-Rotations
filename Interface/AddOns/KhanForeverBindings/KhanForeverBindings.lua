-- Additional Simia bindings. A Find Herbs keypress enables native minimap
-- tracking; the host refreshes the previous generated macro on its existing key.
local _, _, _, interface = GetBuildInfo()
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 then return end
local _, class = UnitClass("player")
if class ~= "PALADIN" and class ~= "DRUID" then return end
local A, B, M
local status = { version = "1.1.6", added = 0, skipped = 0 }
_G.KhanForeverBindings = status

-- The host normally scans the General tab for racials only. Its extra spell
-- list still requires a learned, active spell before exposing a keybind.
local findHerbs = 2383
local herbsCommand = "/khanfindherbs"
local herbsMacro = herbsCommand .. " quiet"
local warStomp, shadowmeld, elunesLight = 20549, 20580, 1259799
local walkOnAir, readLeyline, skysight = 1259416, 1259705, 1259686
local generalSpells = class == "PALADIN" and {1259718, 20594, 7744} or {
    findHerbs, warStomp, shadowmeld, elunesLight, walkOnAir, readLeyline, skysight,
}
local function flagGeneralSpells()
    local flagged = A.SpellData.FlaggedForKeybind
    if type(flagged) ~= "table" then return end
    for _, id in ipairs(generalSpells) do
        local found = false
        for _, existing in ipairs(flagged) do if existing == id then found = true; break end end
        if not found then flagged[#flagged + 1] = id end
    end
end

-- Use the same rank-one families as the installed Classic macro definitions.
-- Explicit Forever ranks also cover caches before their rank-family scan runs.
local friendly = class == "PALADIN" and {
    {635, "Holy Light"}, {19750, "Flash of Light"}, {633, "Lay on Hands"},
    {1022, "Blessing of Protection"}, {1044, "Blessing of Freedom"},
    {1152, "Purify"}, {4987, "Cleanse"}, {20473, "Holy Shock"},
    {6940, "Blessing of Sacrifice"}, {19740, "Blessing of Might"},
    {19742, "Blessing of Wisdom"}, {20217, "Blessing of Kings"},
    {19977, "Blessing of Light"}, {1038, "Blessing of Salvation"},
    {20911, "Blessing of Sanctuary"}, {7328, "Redemption"},
    {1328548, "Oath of Light"}, {1310911, "Light's Vigil"},
    {1311590, "Light's Vigil"}, {1311595, "Light's Vigil"},
} or {
    {5185, "Healing Touch"}, {8936, "Regrowth"}, {774, "Rejuvenation"},
    {18562, "Swiftmend"}, {29166, "Innervate"}, {1126, "Mark of the Wild"},
    {467, "Thorns"}, {2782, "Remove Curse"}, {8946, "Cure Poison"},
    {2893, "Abolish Poison"}, {20484, "Rebirth"},
    {408120, "Wild Growth"}, {1238214, "Wild Growth"}, {1238215, "Wild Growth"},
}
local hostile = class == "PALADIN" and {
    {853, "Hammer of Justice"}, {20271, "Judgement"}, {1310994, "Swift Judgement"},
} or {
    {5211, "Bash"}, {6795, "Growl"}, {339, "Entangling Roots"},
    {2637, "Hibernate"}, {2908, "Soothe Animal"},
}

local function mergeMissing(id, additions)
    if type(id) ~= "number" or id <= 0 then return end
    local entry = M[id]
    if entry == nil then
        entry = {}; M[id] = entry
    elseif type(entry) == "string" then
        -- Preserve the pre-existing base macro while exposing new variants.
        entry = { macro = entry }; M[id] = entry
    elseif type(entry) ~= "table" then
        status.skipped = status.skipped + 1
        return
    end
    for suffix, macro in pairs(additions) do
        if suffix ~= "specs" and entry[suffix] == nil then
            entry[suffix] = macro
            status.added = status.added + 1
        end
    end
end

local function add(id, targeting)
    if targeting == "cursor" then
        mergeMissing(id, {cursor = ("/cast [@cursor] {%d}"):format(id)})
    elseif targeting == "hostile_mouseover" then
        -- The cursor may leave the nameplate between the check and the keypress.
        -- With one explicit unit clause, losing that unit cannot hit the target.
        mergeMissing(id, {mouseover = ("/cast [@mouseover,harm,nodead] {%d}"):format(id)})
    elseif targeting == "friendly" then
        mergeMissing(id, B.SelfCast(id))
        mergeMissing(id, B.FocusMouseover(id))
        mergeMissing(id, B.PartyTargets(id))
    else
        mergeMissing(id, B.FocusMouseover(id))
    end
end

local function info(key)
    if not (C_Spell and C_Spell.GetSpellInfo) then return nil end
    return C_Spell.GetSpellInfo(key)
end

local function trackingApi(name)
    if C_Minimap and type(C_Minimap[name]) == "function" then
        return C_Minimap[name], "C_Minimap." .. name
    elseif type(_G[name]) == "function" then
        return _G[name], name
    end
end

local function herbsTracker()
    local count, countName = trackingApi("GetNumTrackingTypes")
    local get, getName = trackingApi("GetTrackingInfo")
    if not count or not get then return nil, nil, "tracking read API unavailable" end
    local ok, total = pcall(count)
    if not ok then return nil, nil, countName .. " failed: " .. tostring(total) end
    if type(total) ~= "number" or total < 0 then return nil, nil, countName .. " returned no valid count" end
    local spell = info(findHerbs)
    for i = 1, total do
        local read, entry, texture, active, category, nested, id = pcall(get, i)
        if not read then return nil, nil, getName .. " failed: " .. tostring(entry) end
        local name = entry
        if type(entry) == "table" then
            name, active, id = entry.name, entry.active, entry.spellID
        end
        -- spellID is optional even on the structured API. Match the localized
        -- spell name only when the tracker does not supply a usable ID.
        if id == findHerbs or id == 8387 or
                ((id == nil or id == 0) and spell and spell.name and name == spell.name) then
            return i, active == true or active == 1, nil, getName
        end
    end
    return nil, nil, "Find Herbs is not listed in minimap tracking; check Herbalism and the tracking menu"
end

local function herbsBlocked()
    local checks = {
        {"InCombatLockdown", "combat lockdown"},
        {"UnitAffectingCombat", "in combat", "player"},
        {"UnitIsDeadOrGhost", "dead or ghost", "player"},
        {"IsMounted", "mounted"}, {"IsStealthed", "stealthed"},
        {"UnitCastingInfo", "casting", "player"},
        {"UnitChannelInfo", "channeling", "player"},
    }
    for _, check in ipairs(checks) do
        local fn = _G[check[1]]
        if type(fn) ~= "function" then return "player-state API unavailable: " .. check[1] end
        local ok, value
        if check[3] then ok, value = pcall(fn, check[3]) else ok, value = pcall(fn) end
        if not ok then return check[1] .. " failed: " .. tostring(value) end
        if value then return check[2] end
    end
end

local function herbsReport(message, quiet)
    status.herbsLast = message
    if not quiet then print("Khan Find Herbs " .. status.version .. ": " .. message .. ".") end
end

if class == "DRUID" then
    SLASH_KHANFINDHERBS1 = herbsCommand
    SlashCmdList.KHANFINDHERBS = function(argument)
        local mode = type(argument) == "string" and argument:lower():match("^%s*(.-)%s*$") or ""
        local quiet = mode == "quiet"
        local index, active, reason, api = herbsTracker()
        if mode == "status" then
            local current = index and ((active and "on" or "off") .. "; index " .. index .. "; " .. api) or reason
            print("Khan Find Herbs " .. status.version .. ": " .. current .. ".")
            print("Activation: " .. (herbsBlocked() or "allowed") ..
                "; last attempt: " .. (status.herbsLast or "none") .. ".")
            return
        end
        if mode ~= "" and not quiet then
            print("Use /khanfindherbs to enable tracking, or /khanfindherbs status to inspect it.")
            return
        end
        local blocked = herbsBlocked()
        if blocked then herbsReport("not enabled: " .. blocked, quiet); return end
        if not index then herbsReport(reason, quiet); return end
        if active then herbsReport("already on; index " .. index, quiet); return end
        local set, setName = trackingApi("SetTracking")
        if not set then herbsReport("SetTracking API unavailable", quiet); return end
        local ok, err = pcall(set, index, true)
        if not ok then herbsReport(setName .. " failed: " .. tostring(err), quiet); return end
        local after, enabled, afterReason = herbsTracker()
        if after and enabled then herbsReport("enabled; minimap confirms on at index " .. after, quiet)
        else herbsReport("enable requested, but minimap has not confirmed it: " .. (afterReason or "still off"), quiet) end
    end
end

-- Simia restores the exact macro text saved with a key. Changing SpellMacros
-- alone leaves existing users on /cast Find Herbs (host default) or the old
-- /cast !Find Herbs until their next Autobind. Only upgrade these generated
-- payloads on their existing key; preserve all custom macros and other keys.
local function herbsBinding()
    if not A or not A.Player or A.Player.SpecID ~= 11 or not A.KeyMapping then return end
    local global = A.db and A.db.Global
    local bindings = global and global.WowBindings and global.WowBindings[11]
    local settings = global and global.Spells and global.Spells[11] and global.Spells[11][findHerbs]
    if not (settings and settings.Keybind) then return end
    local toKey = A.KeyMapping.KeyCodeToKey
    if type(toKey) ~= "function" then return end
    local key = toKey(settings.Keybind)
    if not key then return end
    if settings.Modifier and tonumber(settings.Modifier) ~= 0 then
        local modifier = toKey(settings.Modifier)
        if not modifier then return end
        key = modifier .. "-" .. key
    end
    return key, settings, bindings and bindings[key]
end

local function refreshHerbsKey()
    if class ~= "DRUID" or not (A.Autobind and A.Autobind.ApplyBinding and A.Spells)
            or InCombatLockdown() then return end
    local key, settings, binding = herbsBinding()
    if not key or (settings.Macro and settings.Macro ~= "") then return end
    local spell = info(findHerbs)
    if spell and binding and binding.spellKey == findHerbs and binding.type == "macrotext"
            and (binding.macrotext == "/cast !" .. spell.name or binding.macrotext == "/cast " .. spell.name
                or binding.macrotext == herbsCommand)
            and A.SpellData.GetSpellMacro(findHerbs, 11) == herbsMacro then
        A.Autobind.ApplyBinding(findHerbs, key)
    end
end

local function register()
    local names = {}
    local function visit(list, targeting)
        for _, row in ipairs(list) do
            local id, english = row[1], row[2]
            add(id, targeting)
            local data = info(id)
            if data and data.name then names[data.name] = targeting end
            -- Name lookup supports replacement IDs exposed by a newer client;
            -- stable numeric families above work on non-English clients too.
            local named = info(english)
            if named and type(named.spellID) == "number" then
                add(named.spellID, targeting)
                if named.name then names[named.name] = targeting end
            end
        end
    end
    visit(friendly, "friendly")
    visit(hostile, "hostile")
    if class == "DRUID" then
        mergeMissing(findHerbs, {macro = herbsMacro})
        visit({{8921, "Moonfire"}}, "hostile_mouseover")
        visit({{770, "Faerie Fire"}}, "hostile_mouseover")
        visit({{16914, "Hurricane"}, {17401, "Hurricane"}, {17402, "Hurricane"}}, "cursor")
    end
    -- Register learned ranks directly as well as at their stable family base.
    -- This only adds metadata; existing bindings/settings remain untouched.
    if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and
            C_SpellBook.GetSpellBookSkillLineInfo and C_SpellBook.GetSpellBookItemInfo and
            Enum and Enum.SpellBookSpellBank and Enum.SpellBookItemType) then return end
    local bank = Enum.SpellBookSpellBank.Player
    for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skill = C_SpellBook.GetSpellBookSkillLineInfo(line)
        if skill and not skill.offSpecID then
            local offset = skill.itemIndexOffset or 0
            for slot = offset + 1, offset + (skill.numSpellBookItems or 0) do
                local spell = C_SpellBook.GetSpellBookItemInfo(slot, bank)
                if spell and spell.spellID and not spell.isPassive and not spell.isOffSpec and
                        spell.itemType == Enum.SpellBookItemType.Spell then
                    local data = info(spell.spellID)
                    local targeting = data and names[data.name]
                    if targeting then
                        add(spell.spellID, targeting)
                        local base = A.ClassicRankBase and A.ClassicRankBase[spell.spellID]
                        if type(base) == "number" then add(base, targeting) end
                    end
                end
            end
        end
    end
end

-- Simia distributions publish the active host under the name in Z_AddonName.
-- A renamed host can load after this companion, even when the UI is reloaded.
local function connect()
    if A then return true end
    local name = type(_G.Z_AddonName) == "string" and _G.Z_AddonName or "SimulationcraftExtra"
    local host = _G[name]
    local builders = type(host) == "table" and host.SpellData and host.SpellData.Builders
    if not (builders and host.IsClassic and type(host.SpellMacros) == "table"
            and type(builders.SelfCast) == "function" and type(builders.FocusMouseover) == "function"
            and type(builders.PartyTargets) == "function") then return false end
    A, B, M = host, builders, host.SpellMacros
    status.host = name
    flagGeneralSpells()
    return true
end
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("SPELLS_CHANGED")
if class == "DRUID" then
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:RegisterEvent("PLAYER_REGEN_ENABLED")
end
local function update(_, event)
    if event == "ADDON_LOADED" and A then return end
    local firstConnection = not A
    if connect() then
        if firstConnection or (event ~= "PLAYER_REGEN_ENABLED" and event ~= "PLAYER_ENTERING_WORLD") then register() end
        if event ~= "ADDON_LOADED" then refreshHerbsKey() end
    end
end
events:SetScript("OnEvent", update)
update()

SLASH_KHANFOREVERBINDINGS1 = "/khanbindings"
SlashCmdList.KHANFOREVERBINDINGS = function()
    if not A then update() end
    if not A then
        print("Khan Forever Bindings " .. status.version .. ": waiting for a compatible, enabled Simia addon.")
        return
    end
    local id = class == "DRUID" and 8921 or 853
    local hasVariant = type(M[id]) == "table" and M[id].mouseover ~= nil
    print(("Khan Forever Bindings %s: %s; %s @mouseover %s."):format(
        status.version, status.host, class == "DRUID" and "Moonfire" or "Hammer of Justice",
        hasVariant and "registered" or "unavailable"))
    if class == "DRUID" then
        local index, active, reason = herbsTracker()
        print("Find Herbs minimap tracking: " .. (index and ((active and "on" or "off") .. "; index " .. index) or reason))
        local key, settings, binding = herbsBinding()
        local known = KnownSpells and KnownSpells[findHerbs]
        local payload = binding and binding.spellKey == findHerbs and binding.type == "macrotext" and binding.macrotext
        local keyStatus = not key and "unassigned; assign Find Herbs a key in Simia" or
            ((settings.Macro and settings.Macro ~= "") and "custom macro preserved" or
            (payload == herbsMacro and "ready" or "reassign Find Herbs to this key in Simia"))
        print("Find Herbs host action: " .. (known and "available" or "missing; check Herbalism and reload") ..
            "; key: " .. (key and (key .. "; ") or "") .. keyStatus .. ".")
    end
end
