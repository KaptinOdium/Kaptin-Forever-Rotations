-- Optional, read-only own-pet engagement predicate for the matching host patch.
-- It does not cast, target, assign keys, or replace global game APIs.
-- Protocol 1: true means the current hostile mouseover has a public threat
-- relationship with this character's living, fighting pet. False is fail-closed.
local function publicValue(value)
    if type(issecretvalue) ~= "function" then return false end
    local ok, secret = pcall(issecretvalue, value)
    if not ok or type(secret) ~= "boolean" then return false end
    return not secret
end

if type(GetBuildInfo) ~= "function" or type(UnitClass) ~= "function" then return end
local buildOK, _, _, _, interface = pcall(GetBuildInfo)
if not buildOK or not publicValue(interface) or type(interface) ~= "number"
        or interface < 16000 or interface >= 17000 then return end
local classOK, _, class = pcall(UnitClass, "player")
if not classOK or not publicValue(class) or class ~= "WARLOCK" then return end

local A
local status = {protocol = 1, lastOwnPetResult = false, reason = "not checked"}
_G.KhanForeverWarlockPetEngagement = status

local function settings()
    local db = _G.KhanForeverWarlockPetDB
    if type(db) ~= "table" then
        db = {enabled = false}
        _G.KhanForeverWarlockPetDB = db
    elseif db.enabled ~= true then
        db.enabled = false
    end
    return db
end
settings()

local function read(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, value = pcall(fn, ...)
    if not ok or not publicValue(value) then return false end
    return true, value
end

local function requireBoolean(fn, expected, rejection, unavailable, ...)
    local ok, value = read(fn, ...)
    if not ok or type(value) ~= "boolean" then
        status.reason = unavailable
        return false
    end
    if value ~= expected then
        status.reason = rejection
        return false
    end
    return true
end

local function engaged(unit)
    status.lastOwnPetResult = false
    if settings().enabled ~= true then status.reason = "disabled"; return false end
    if not publicValue(unit) then status.reason = "unit unavailable/secret"; return false end
    if unit ~= "mouseover" then status.reason = "not mouseover"; return false end
    -- Direct "pet" always means this player's pet. No party/raid pet tokens,
    -- stale GUID cache, target switching, or selected-target assumptions.
    if not requireBoolean(UnitExists, true, "pet missing", "pet state unavailable/secret", "pet")
            or not requireBoolean(UnitIsDeadOrGhost, false, "pet dead", "pet state unavailable/secret", "pet")
            or not requireBoolean(UnitAffectingCombat, true, "pet not in combat", "pet combat unavailable/secret", "pet")
            or not requireBoolean(UnitExists, true, "no mouseover", "hover state unavailable/secret", "mouseover")
            or not requireBoolean(UnitIsDeadOrGhost, false, "mouseover dead", "hover state unavailable/secret", "mouseover")
            or not requireBoolean(UnitAffectingCombat, true, "mouseover not in combat", "hover combat unavailable/secret", "mouseover")
            or not requireBoolean(UnitCanAttack, true, "mouseover not hostile", "hover hostility unavailable/secret", "player", "mouseover") then return false end
    local ok, threat = read(UnitThreatSituation, "pet", "mouseover")
    if not ok then status.reason = "pet threat unavailable/secret"; return false end
    if threat == nil then status.reason = "no own-pet threat relationship"; return false end
    if type(threat) ~= "number" then status.reason = "pet threat invalid"; return false end
    -- Exactly the documented public values, rejecting nil, false, NaN,
    -- fractions, sentinels and secret values before any value comparison.
    local result = threat == 0 or threat == 1 or threat == 2 or threat == 3
    status.lastOwnPetResult = result
    status.reason = result and "own-pet engagement confirmed" or "pet threat invalid"
    return result
end

local function connect()
    local name = type(_G.Z_AddonName) == "string" and _G.Z_AddonName or "SimulationcraftExtra"
    local host = _G[name]
    if type(host) ~= "table" or host.IsClassic ~= true then return false end
    -- Refuse an unrelated existing implementation rather than overwrite it.
    if host.KaptinWarlockPetEngaged ~= nil and host.KaptinWarlockPetEngaged ~= engaged then
        status.conflict = true
        return false
    end
    A = host
    A.KaptinWarlockPetEngaged = engaged
    A.KaptinWarlockPetEngagementVersion = 1
    status.conflict = false
    return true
end

local function report()
    local connected = connect()
    local bridge = connected and A.KaptinWarlockPetThreatBridgeVersion == 1
    print("Kaptin Warlock Pet DoTs: " .. (settings().enabled and "ON" or "OFF")
        .. "; host patch " .. (bridge and "ready" or "unavailable")
        .. "; last own-pet check " .. (status.lastOwnPetResult and "engaged" or "not confirmed")
        .. "; reason " .. status.reason .. ".")
    if status.conflict then print("Kaptin Warlock Pet DoTs: another predicate is already registered; left unchanged.") end
end

SLASH_KAPTINWARLOCKPETDOTS1 = "/kaptinpetdots"
SlashCmdList.KAPTINWARLOCKPETDOTS = function(message)
    local command = type(message) == "string" and message:lower():match("^%s*(.-)%s*$") or ""
    if command == "on" then
        settings().enabled = true
        status.lastOwnPetResult = false
        status.reason = "enabled; awaiting check"
    elseif command == "off" then
        settings().enabled = false
        status.lastOwnPetResult = false
        status.reason = "disabled"
    elseif command ~= "" and command ~= "status" then
        print("Kaptin Warlock Pet DoTs: /kaptinpetdots on | off | status")
        return
    end
    report()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
    settings()
    connect()
end)
connect()
