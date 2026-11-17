-- Optional selected-target group proof for the matching host bridge. No casts,
-- targeting, key changes, API replacement or telemetry polling.
local function public(value)
    if type(issecretvalue) ~= "function" then return false end
    local ok, secret = pcall(issecretvalue, value)
    return ok and type(secret) == "boolean" and not secret
end

if type(GetBuildInfo) ~= "function" or type(UnitClass) ~= "function" then return end
local buildOK, _, _, _, interface = pcall(GetBuildInfo)
if not buildOK or not public(interface) or type(interface) ~= "number"
        or interface < 16000 or interface >= 17000 then return end
local classOK, _, class = pcall(UnitClass, "player")
if not classOK or not public(class) or class ~= "HUNTER" then return end

local A, enabled, lastMember, lastRaid = nil, false, nil, nil
local status = {protocol = 1, version = "1.0.2", enabled = false, lastResult = false, reason = "disabled"}
_G.KaptinForeverHunterGroupEngagement = status
local function settings()
    local db = _G.KaptinForeverHunterGroupDB
    if type(db) ~= "table" then db = {}; _G.KaptinForeverHunterGroupDB = db end
    db.enabled = db.enabled == true
    return db
end
enabled = settings().enabled
status.enabled = enabled
status.reason = enabled and "enabled; awaiting check" or "disabled"
local party, raid = {}, {}
for i = 1, 4 do party[i] = "party" .. i end
for i = 1, 40 do raid[i] = "raid" .. i end

local function read(fn, ...)
    if type(fn) ~= "function" then return false end
    local ok, value = pcall(fn, ...)
    if not ok or not public(value) then return false end
    return true, value
end

local function boolean(fn, expected, ...)
    local ok, value = read(fn, ...)
    return ok and type(value) == "boolean" and value == expected
end

local failures, checkedMembers, eligibleMembers
local function reject(label)
    failures[label] = (failures[label] or 0) + 1
end

local function memberFlag(fn, expected, member, label)
    local ok, value = read(fn, member)
    if not ok or type(value) ~= "boolean" then
        reject(label .. " unreadable")
        return false
    end
    if value ~= expected then reject(label .. " rejected"); return false end
    return true
end

local function memberEngaged(member)
    checkedMembers = checkedMembers + 1
    if not memberFlag(UnitExists, true, member, "member presence")
            or not memberFlag(UnitIsConnected, true, member, "member connection")
            or not memberFlag(UnitIsDeadOrGhost, false, member, "member alive")
            or not memberFlag(UnitAffectingCombat, true, member, "member combat") then return false end
    eligibleMembers = eligibleMembers + 1
    local ok, threat = read(UnitThreatSituation, member, "target")
    if ok and type(threat) == "number"
            and (threat == 0 or threat == 1 or threat == 2 or threat == 3) then
        status.proof = "group threat confirmed"
        return true
    end
    if not ok then reject("threat unreadable")
    elseif threat == nil then reject("threat absent")
    else reject("threat invalid") end

    -- Independent positive identity proof, not an interpretation of missing
    -- threat. On restricted maps this compound-token comparison may itself
    -- be unavailable; only a public literal true is accepted.
    local sameOK, same = read(UnitIsUnit, "targettarget", member)
    if sameOK and type(same) == "boolean" and same then
        status.proof = "enemy targeting group member confirmed"
        return true
    end
    if not sameOK or type(same) ~= "boolean" then reject("enemy-target unreadable")
    else reject("enemy-target not matched") end
    return false
end

local function engaged(unit)
    status.lastResult = false
    status.details, status.proof = nil, nil
    if not enabled then status.reason = "disabled"; return false end
    if not public(unit) or type(unit) ~= "string" or unit ~= "target" then
        status.reason = "selected target only"; return false
    end
    if not A or A.KaptinHunterGroupThreatBridgeVersion ~= 1 then
        status.reason = "matching host bridge unavailable"; return false
    end
    if not boolean(UnitExists, true, "target")
            or not boolean(UnitIsDeadOrGhost, false, "target")
            or not boolean(UnitAffectingCombat, true, "target")
            or not boolean(UnitCanAttack, true, "player", "target") then
        lastMember = nil
        status.reason = "target not confirmed alive, hostile and in combat"; return false
    end
    local raidOK, inRaid = read(IsInRaid)
    if not raidOK or type(inRaid) ~= "boolean" or not boolean(IsInGroup, true) then
        lastMember = nil
        status.reason = "group unavailable"; return false
    end
    local countOK, count = read(inRaid and GetNumGroupMembers or GetNumSubgroupMembers)
    local limit = inRaid and 40 or 4
    if not countOK or type(count) ~= "number" or count < 1 or count > limit or count % 1 ~= 0 then
        lastMember = nil
        status.reason = "roster unavailable"; return false
    end
    local roster = inRaid and raid or party
    -- party1-4 exclude the player by definition. raidN does not: use the
    -- public roster index rather than another unit-comparison prerequisite.
    local selfIndex
    if inRaid then
        local selfOK, index = read(UnitInRaid, "player")
        if not selfOK or type(index) ~= "number" or index < 1 or index > count
                or index % 1 ~= 0 then
            lastMember = nil
            status.reason = "own raid slot unavailable"; return false
        end
        selfIndex = index
    end
    failures, checkedMembers, eligibleMembers = {}, 0, 0
    -- Cache only the roster index, never the result. Revalidate the current
    -- member and its threat against the current target on every invocation.
    local previous = lastRaid == inRaid and lastMember or nil
    lastMember, lastRaid = nil, inRaid
    if previous and previous <= count and previous ~= selfIndex and memberEngaged(roster[previous]) then
        lastMember = previous
    else
        for i = 1, count do
            if i ~= previous and i ~= selfIndex and memberEngaged(roster[i]) then lastMember = i; break end
        end
    end
    status.lastResult = lastMember ~= nil
    status.reason = status.lastResult and status.proof or "no public group relationship confirmed"
    if not status.lastResult then
        local labels = {}
        for label in pairs(failures) do labels[#labels + 1] = label end
        table.sort(labels)
        local details = {("eligible members %d/%d"):format(eligibleMembers, checkedMembers)}
        for _, label in ipairs(labels) do
            details[#details + 1] = label .. "=" .. failures[label]
        end
        status.details = table.concat(details, "; ")
    end
    return status.lastResult
end

local function connect()
    local name = type(_G.Z_AddonName) == "string" and _G.Z_AddonName or "SimulationcraftExtra"
    local host = _G[name]
    if type(host) ~= "table" or host.IsClassic ~= true then return false end
    if host.KaptinHunterGroupEngaged ~= nil and host.KaptinHunterGroupEngaged ~= engaged then
        status.conflict = true; return false
    end
    A = host
    A.KaptinHunterGroupEngaged = engaged
    status.conflict = false
    return true
end

local function report()
    local ready = connect() and A.KaptinHunterGroupThreatBridgeVersion == 1
    print("Kaptin Hunter group entry " .. status.version .. ": " .. (enabled and "ON" or "OFF")
        .. "; host bridge " .. (ready and "ready" or "unavailable")
        .. "; last check " .. (status.lastResult and "confirmed" or "not confirmed")
        .. "; " .. status.reason .. ".")
    if status.details then print("Kaptin Hunter last check: " .. status.details .. ".") end
    if status.conflict then print("Kaptin Hunter: existing group predicate left unchanged.") end
end

SLASH_KAPTINHUNTERGROUP1 = "/kaptinhuntergroup"
SlashCmdList.KAPTINHUNTERGROUP = function(message)
    local command = type(message) == "string" and message:lower():match("^%s*(.-)%s*$") or ""
    if command == "on" or command == "off" then
        enabled = command == "on"
        settings().enabled = enabled
        status.enabled, status.lastResult = enabled, false
        status.details, status.proof = nil, nil
        lastMember, lastRaid = nil, nil
        status.reason = enabled and "enabled; awaiting check" or "disabled"
    elseif command ~= "" and command ~= "status" then
        print("Kaptin Hunter: /kaptinhuntergroup on | off | status")
        return
    end
    report()
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", connect)
connect()
