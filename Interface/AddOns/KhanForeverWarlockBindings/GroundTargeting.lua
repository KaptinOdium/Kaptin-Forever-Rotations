-- Experimental two-key native controller placement; native confirmation is unverified.
-- No casts from Lua, CVar changes, reloads, saved key changes, or automatic enable.
local _, _, _, interface = GetBuildInfo()
local _, class = UnitClass("player")
if type(interface) ~= "number" or interface < 16000 or interface >= 17000 or class ~= "WARLOCK" then return end

local owner = CreateFrame("Frame", "KhanForeverWarlockGroundOwner", UIParent)
local state = {version = "1.2.0-beta2", active = false, reason = "off", phase = "off",
    opens = 0, owned = 0, confirms = 0, channels = 0, failures = 0}
_G.KhanForeverWarlockGround = state
local host, originalBlock, blockWrapper, hookedHost
local learned, pendingOff, scheduled, elapsed = nil, false, false, 0
local exportFilter, previousFilter, confirmationHooked
local publish, advance, fail
local hookedButtons = setmetatable({}, {__mode="k"})
local CONFIRM_ACTION = "CAMERAORSELECTORMOVE"
local OPEN_TIMEOUT, CONFIRM_TIMEOUT = 1.5, 1.5

local function say(message) print("Kaptin Warlock Ground: " .. message) end
local function trim(value) return type(value) == "string" and value:match("^%s*(.-)%s*$") or "" end
local function inCombat() return InCombatLockdown() end
local function db()
    if type(KhanForeverWarlockGroundDB) ~= "table" then KhanForeverWarlockGroundDB = {} end
    return KhanForeverWarlockGroundDB
end
local function findHost()
    local name = type(Z_AddonName) == "string" and Z_AddonName or "SimulationcraftExtra"
    local found = _G[name]
    if type(found) == "table" and found.IsClassic and type(found.ShouldBlockInput) == "function" then return found end
end
local function rainName(id)
    local base = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(5740)
    local info = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(id)
    return base and info and base.name == info.name
end
local function refreshLearned()
    learned = nil
    if not (C_SpellBook and C_SpellBook.GetNumSpellBookSkillLines and C_SpellBook.GetSpellBookSkillLineInfo
            and C_SpellBook.GetSpellBookItemInfo and Enum and Enum.SpellBookSpellBank and Enum.SpellBookItemType) then return end
    local bestRank = -1
    for line = 1, C_SpellBook.GetNumSpellBookSkillLines() do
        local skill = C_SpellBook.GetSpellBookSkillLineInfo(line)
        if skill and not skill.offSpecID then
            local offset = skill.itemIndexOffset or 0
            for slot = offset + 1, offset + (skill.numSpellBookItems or 0) do
                local spell = C_SpellBook.GetSpellBookItemInfo(slot, Enum.SpellBookSpellBank.Player)
                if spell and spell.spellID and not spell.isPassive and not spell.isOffSpec
                        and spell.itemType == Enum.SpellBookItemType.Spell and rainName(spell.spellID) then
                    -- Same rank ordering as Simia's ClassicRankTop builder.
                    local text = C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spell.spellID) or ""
                    local rank = tonumber((text or ""):match("(%d+)")) or 0
                    if rank > bestRank or (rank == bestRank and (not learned or spell.spellID > learned)) then
                        learned, bestRank = spell.spellID, rank
                    end
                end
            end
        end
    end
end
local function modeProblem()
    if not (InputUtil and InputUtil.IsGamepadUIEnabled and InputUtil.IsGamepadUIEnabled()) then
        return "native Gamepad UI is off; enable it yourself in WoW settings before setup"
    end
    if GetCVar("GamePadEnable") ~= "1" or GetCVar("GamePadCursorForTargeting") ~= "2"
            or GetCVar("GamepadConstrainedGroundTargetEnabled") ~= "1" then
        return "requires GamePadEnable=1, GamePadCursorForTargeting=2 and GamepadConstrainedGroundTargetEnabled=1; no settings were changed"
    end
end
local function currentBindings()
    local spec = host and host.Player and host.Player.SpecID
    local global = host and host.db and host.db.Global
    return global and global.WowBindings and global.WowBindings[spec], spec
end
local function controllerRow(row)
    if type(row) ~= "table" then return false end
    local id, suffix = tostring(row.spellKey):match("^(%d+)%-(.+)$")
    return suffix == "controller" and rainName(tonumber(id))
end
local function noopRow(row)
    if row.type ~= "macrotext" or trim(row.macrotext) ~= "/stopmacro" then return false end
    local custom = host.Spells and host.Spells.GetSetting and host.Spells.GetSetting(row.spellKey, "Macro")
    if custom and custom ~= "" and trim(custom) ~= "/stopmacro" then return false end
    local resolved = host.SpellData and host.SpellData.GetSpellMacro
        and host.SpellData.GetSpellMacro(row.spellKey, host.Player.SpecID)
    return trim(resolved) == "/stopmacro"
end
local function validKey(key)
    if type(key) ~= "string" or key:find("[^A-Z0-9]") then return false end
    local number = tonumber(key:match("^F(%d+)$"))
    return (number and number >= 1 and number <= 12) or key:match("^NUMPAD%d$")
        or key == "NUMPADPLUS" or key == "NUMPADMINUS" or key == "NUMPADMULTIPLY"
        or key == "NUMPADDIVIDE" or key == "NUMPADDECIMAL" or key:match("^[A-Z0-9]$")
end
local function exportProblem(row, spec, key)
    local global = host.db and host.db.Global
    local spells = global and global.Spells and global.Spells[spec]
    local record = spells and spells[row.spellKey]
    if type(record) ~= "table" or not tonumber(record.Keybind) or tonumber(record.Keybind) <= 0 then
        return "the controller row has no exported Simia key; assign it again"
    end
    local mapper = host.KeyMapping and host.KeyMapping.KeyToKeyCode
    local physical = type(mapper) == "function" and tonumber(mapper(key))
    if not physical or physical <= 0 or physical ~= tonumber(record.Keybind) then
        return "saved controller key and exported physical key disagree; assign the key again in Simia"
    end
    if (tonumber(record.Modifier) or 0) ~= 0 or record.Enabled == false then
        return "the controller row must be enabled with an unmodified key"
    end
    for other, value in pairs(spells) do
        if other ~= row.spellKey and type(value) == "table"
                and tonumber(value.Keybind) == tonumber(record.Keybind)
                and (tonumber(value.Modifier) or 0) == 0 then
            return "another Simia action exports the same key; resolve the conflict first"
        end
    end
end
local function selectKey(requested)
    local bindings, spec = currentBindings()
    if type(bindings) ~= "table" then return nil, "Simia has no saved bindings for this spec" end
    local matches = {}
    for key, row in pairs(bindings) do
        if controllerRow(row) and (not requested or key == requested) then matches[#matches+1] = {key=key,row=row} end
    end
    if #matches ~= 1 then return nil, "assign one Rain of Fire @controller key in Simia, then use on KEY if multiple ranks have keys" end
    local key, row = matches[1].key, matches[1].row
    if not validKey(key) then return nil, "use a dedicated unmodified keyboard key; Shift/Ctrl change native gamepad bars" end
    if not noopRow(row) then return nil, "the controller row has a custom/non-placeholder macro; it was preserved, not replaced" end
    local exportError = exportProblem(row, spec, key)
    if exportError then return nil, exportError end
    local normal = GetBindingAction(key, false, Enum.BindingContext.None)
    local gamepad = GetBindingAction(key, false, Enum.BindingContext.GamepadModeInGameCore)
    if (normal and normal ~= "") or (gamepad and gamepad ~= "") then return nil, "that key already has a normal or gamepad binding; choose an unused key" end
    local expected = "CLICK SimiaAutobind_" .. tostring(row.spellKey):gsub("-", "_") .. ":LeftButton"
    local effective = GetBindingAction(key, true)
    if effective ~= expected then return nil, "that key is not currently owned by its Simia controller placeholder; reload/rebind it first" end
    return {key=key,spellKey=row.spellKey,spec=spec}
end

local function selectConfirmKey(key, openKey)
    if not validKey(key) or key == openKey then return nil, "confirmation needs a different unused unmodified key" end
    for _, context in ipairs({Enum.BindingContext.None, Enum.BindingContext.GamepadModeInGameCore}) do
        local action = GetBindingAction(key, false, context)
        if action and action ~= "" then return nil, "confirmation key has an existing normal/gamepad binding" end
    end
    local effective = GetBindingAction(key, true)
    if effective and effective ~= "" then return nil, "confirmation key is already overridden" end
    local bindings, spec = currentBindings()
    if bindings and bindings[key] then return nil, "confirmation key belongs to a saved Simia binding" end
    local mapper = host.KeyMapping and host.KeyMapping.KeyToKeyCode
    local code = type(mapper) == "function" and tonumber(mapper(key))
    if not code or code <= 0 then return nil, "confirmation key has no physical key mapping" end
    local spells = host.db.Global.Spells and host.db.Global.Spells[spec]
    for _, value in pairs(spells or {}) do
        if type(value) == "table" and tonumber(value.Keybind) == code and (tonumber(value.Modifier) or 0) == 0 then
            return nil, "confirmation key is exported by another Simia action"
        end
    end
    return code
end

local function targetProblem()
    if not UnitExists("target") or not UnitGUID("target") then return "target_missing" end
    if not UnitCanAttack("player", "target") or UnitIsDeadOrGhost("target") then return "target_not_live_hostile" end
    if not UnitAffectingCombat("target") then return "target_not_engaged" end
    if GetUnitSpeed("player") ~= 0 then return "player_moving" end
end

-- Only remove a spell placed into a slot verified empty by this addon.
-- Per-character SavedVariables allow cleanup after reload; never auto-enable.
local function cleanupLease()
    local saved = db()
    local lease = saved.lease
    if type(lease) ~= "table" then return true end
    if inCombat() then return false end
    if not (C_GamepadUI and C_GamepadUI.IsValidGamepadActionStorageSlotIndex) then return false end
    if type(lease.slot) ~= "number" or type(lease.spellID) ~= "number"
            or not C_GamepadUI.IsValidGamepadActionStorageSlotIndex(lease.slot) then
        saved.lease = nil; return true
    end
    local kind, id = GetActionInfo(lease.slot)
    if kind == "spell" and id == lease.spellID then
        if GetCursorInfo() then return false end -- Never discard an action the user is carrying.
        PickupAction(lease.slot)
        ClearCursor()
        if GetActionInfo(lease.slot) then return false end
    end
    saved.lease = nil -- A changed slot belongs to the user; leave its contents alone.
    return true
end

local function unsafeReason()
    if pendingOff then return "disable queued until combat ends" end
    if state.fault then return state.fault end
    local problem = modeProblem()
    if problem then return problem end
    if findHost() ~= host then return "Simia host changed" end
    if host.KhanGroundExportHookVersion ~= 1 or host.KhanGroundExportFilter ~= exportFilter then return "export_hook_changed" end
    local bindings, spec = currentBindings()
    if spec ~= state.spec then return "Simia spec changed" end
    if bindings and bindings[state.confirmKey] then return "confirmation_key_claimed_by_simia" end
    local spells = host.db.Global.Spells and host.db.Global.Spells[spec]
    for _, record in pairs(spells or {}) do
        if type(record) == "table" and tonumber(record.Keybind) == state.confirmCode and (tonumber(record.Modifier) or 0) == 0 then
            return "confirmation_key_export_collision"
        end
    end
    for _, context in ipairs({Enum.BindingContext.None, Enum.BindingContext.GamepadModeInGameCore}) do
        local action = GetBindingAction(state.confirmKey, false, context)
        if action and action ~= "" then return "confirmation_key_reassigned" end
    end
    local row = bindings and bindings[state.key]
    if not controllerRow(row) or row.spellKey ~= state.spellKey or not noopRow(row) then return "controller binding or macro changed" end
    local exportError = exportProblem(row, spec, state.key)
    if exportError then return exportError end
    if not learned or learned ~= state.spellID then return "learned Rain of Fire rank changed; run setup again" end
    local unit = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
    if not unit or unit:GetCurrentPage() ~= state.page or unit:GetActiveBar() ~= state.bar then
        return "native gamepad page/bar changed; switch back or disable the helper"
    end
    local button = state.bar:GetActionButtonByIndex(state.index)
    if not button or button:GetID() ~= state.slot then return "native action button changed" end
    local kind, id = GetActionInfo(state.slot)
    if kind ~= "spell" or id ~= state.spellID then return "native slot changed; user contents will be preserved" end
    if GetBindingAction(state.key, true) ~= state.action then return "controller override is no longer active" end
    if GetBindingAction(state.confirmKey, true) ~= CONFIRM_ACTION then return "confirmation_override_changed" end
end

local function published()
    return state.exportSerial and not host.KhanGroundExportError
        and tonumber(host.KhanGroundExportPublishSerial or 0) >= state.exportSerial
end

fail = function(code)
    if not state.fault then state.failures = state.failures + 1 end
    state.fault, state.reason, state.phase = code, code, "failed"
    state.exportSerial = nil
end

publish = function()
    if not host or state.publishing then return end
    state.publishing = true
    local ok = pcall(host.UpdateBindingData)
    state.publishing = false
    if not ok then fail("export_refresh_failed") end
end

-- Current hosts may throw while inspecting a forbidden UI focus frame. During
-- this experiment, an unreadable host input guard must never grant a cast or
-- confirmation. Keep its original behavior when the helper is not armed.
local function hostBlocksInput(callback, ...)
    local ok, blocked = pcall(callback, ...)
    if not ok then
        fail("host_input_guard_error")
        publish()
        return true
    end
    return blocked
end

local function finishChannel()
    state.channels = state.channels + 1
    state.pending, state.attempt, state.exportSerial = nil, nil, nil
    state.phase, state.reason = "idle", "armed; last Rain channel observed"
    publish()
end

advance = function()
    if not state.active or pendingOff or state.fault then return end
    local problem = unsafeReason()
    if problem then fail(problem); publish(); return end
    local now = GetTime()
    if state.attempt then
        local attempt = state.attempt
        if SpellIsTargeting() then
            if UnitGUID("target") ~= attempt.guid then fail("target_changed_during_open")
            elseif targetProblem() then fail(targetProblem())
            elseif not C_Spell.IsCurrentSpell(state.spellID) then
                -- Native targeting and IsCurrentSpell can publish in different
                -- event order. Hold all keys until identity settles or expires.
                if now > attempt.deadline then fail("pending_rain_not_verified")
                else state.reason = "waiting for exact Rain identity" end
                publish()
            else
                state.pending = {guid=attempt.guid, deadline=now+OPEN_TIMEOUT, started=now}
                state.attempt, state.phase = nil, "pending"
                state.owned, state.reason = state.owned+1, "owned Rain circle; publishing confirmation key"
                publish()
            end
        elseif now > attempt.deadline then fail("native_open_not_observed"); publish() end
        return
    end
    if state.pending then
        if UnitGUID("target") ~= state.pending.guid then fail("target_changed_while_pending"); publish(); return end
        local targetError = targetProblem()
        if targetError then fail(targetError); publish(); return end
        if SpellIsTargeting() then
            if not C_Spell.IsCurrentSpell(state.spellID) then fail("pending_rain_replaced"); publish()
            elseif now > state.pending.deadline then fail(state.phase == "confirming" and "confirmation_not_completed" or "confirmation_not_dispatched"); publish() end
        elseif state.phase == "pending" then
            fail("circle_cancelled_before_confirmation"); publish()
        elseif now > state.pending.deadline then
            fail("rain_channel_not_observed"); publish()
        end
        return
    end
    if SpellIsTargeting() then state.reason = "foreign_ground_circle_blocked" else state.reason = "armed; automatic confirmation experimental" end
end

local function makeExportFilter()
    return function(rows, context)
        if not state.active then return rows end
        if type(context) ~= "table" or context.specID ~= state.spec then fail("export_spec_mismatch"); return {} end
        if pendingOff then return {} end
        local problem = unsafeReason()
        if problem then fail(problem); return {} end
        if state.fault or pendingOff or state.attempt or state.phase == "confirming" then return {} end
        if not state.pending then
            if SpellIsTargeting() then return {} end
            return rows
        end
        if state.phase ~= "pending" or not SpellIsTargeting() then return {} end
        if not C_Spell.IsCurrentSpell(state.spellID) then fail("pending_rain_replaced"); return {} end
        if targetProblem() or UnitGUID("target") ~= state.pending.guid then fail("export_target_invalid"); return {} end
        local found
        for _, row in ipairs(rows) do
            if row.bindingKey == tostring(state.spellID) .. ".controller" and row.sourceKey == state.spellKey then
                if found or row.keybind ~= state.openCode or (row.modifier or 0) ~= 0 then fail("export_controller_mismatch"); return {} end
                found = row
            end
        end
        if not found then fail("export_controller_missing"); return {} end
        local copy = {}
        for key, value in pairs(found) do copy[key] = value end
        copy.keybind, copy.modifier = state.confirmCode, 0
        state.exportSerial = context.publishSerial
        return {copy}
    end
end

local function observeNativeButton(button)
    if hookedButtons[button] then return end
    -- Observers do not change protected attributes or decide the native click.
    button:HookScript("PreClick", function(self, _, down)
        if not state.active or self ~= state.button or down ~= true then return end
        if state.fault or pendingOff or state.attempt or state.pending or SpellIsTargeting() then return end
        local problem = unsafeReason() or targetProblem()
        if hostBlocksInput(originalBlock) then problem = state.fault or "input_blocked_during_open" end
        if problem then fail(problem); publish(); return end
        state.opens = state.opens + 1
        state.attempt = {guid=UnitGUID("target"), deadline=GetTime()+0.5}
        state.phase, state.reason = "opening", "observed native Rain key; waiting for circle"
        publish()
    end)
    button:HookScript("PostClick", function(self)
        if state.active and self == state.button then advance() end
    end)
    hookedButtons[button] = true
end

local function observeConfirmation()
    if confirmationHooked then return end
    -- Native CAMERAORSELECTORMOVE calls this function on key-down. The observer
    -- never invokes it. Stop exporting the key after its first real invocation.
    hooksecurefunc("CameraOrSelectOrMoveStart", function()
        if not state.active or state.fault or pendingOff or state.phase ~= "pending" or not state.pending or not published() then return end
        state.confirms = state.confirms + 1
        state.phase, state.reason = "confirming", "confirmation input observed; waiting for Rain channel"
        state.pending.deadline, state.exportSerial = GetTime()+CONFIRM_TIMEOUT, nil
        publish()
    end)
    confirmationHooked = true
end

local function detachGuard()
    if host and host.ShouldBlockInput == blockWrapper then host.ShouldBlockInput = originalBlock end
    if host and host.KhanGroundExportFilter == exportFilter then host.KhanGroundExportFilter = previousFilter end
    publish()
    -- If another addon wrapped us, our dormant wrapper still delegates correctly.
end
local function disable(message)
    if inCombat() then
        pendingOff = true; state.reason = "disable queued until combat ends"; publish()
        say(state.reason .. "; press Escape to cancel any ground circle")
        return false
    end
    ClearOverrideBindings(owner)
    state.active, pendingOff = false, false
    state.pending, state.attempt, state.exportSerial = nil, nil, nil
    state.phase = "off"
    detachGuard()
    local cleaned = cleanupLease()
    state.reason = message or "off"
    if not cleaned then state.reason = state.reason .. "; slot cleanup pending (clear your cursor, then run off again)" end
    say(state.reason .. ". Normal cursor mode and saved Simia keys are unchanged.")
    if SpellIsTargeting() then say("A ground circle is still open: press Escape to cancel it.") end
    return true
end
local function attachGuard()
    originalBlock = host.ShouldBlockInput
    local previous = originalBlock
    blockWrapper = function(...)
        if not state.active then return previous(...) end
        if hostBlocksInput(previous, ...) then return true end
        advance()
        local problem = unsafeReason()
        if problem then state.reason = problem; return true end
        if state.attempt or state.phase == "confirming" then return true end
        if SpellIsTargeting() then return not (state.phase == "pending" and state.pending and published()) end
        if state.pending then return true end
        return false
    end
    host.ShouldBlockInput = blockWrapper
end
local function reconcile()
    scheduled = false
    if not state.active then return end
    if inCombat() then return end
    if SpellIsTargeting() then return end -- Native confirmation may temporarily override its own bindings.
    -- Rebuild only our override after Simia rebuilds its own. Validate every
    -- other invariant first, so a changed user binding is never taken back.
    local effective = GetBindingAction(state.key, true)
    local expected = "CLICK SimiaAutobind_" .. tostring(state.spellKey):gsub("-", "_") .. ":LeftButton"
    if effective == expected then
        local bindings = currentBindings()
        local row = bindings and bindings[state.key]
        if controllerRow(row) and row.spellKey == state.spellKey and noopRow(row) then
            SetOverrideBinding(owner, true, state.key, state.action)
        end
    end
    local problem = unsafeReason()
    if problem then disable("disarmed: " .. problem) end
end
local function scheduleReconcile()
    if not state.active or scheduled then return end
    scheduled = true
    C_Timer.After(0, reconcile)
end
local function installHooks()
    if hookedHost == host then return end
    local auto = host.Autobind
    if auto and type(hooksecurefunc) == "function" then
        for _, name in ipairs({"ApplyBinding", "RestoreBindings", "Execute", "ClearBindings", "RemoveBinding"}) do
            if type(auto[name]) == "function" then hooksecurefunc(auto, name, scheduleReconcile) end
        end
    end
    hookedHost = host
end

local function enable(requested, confirmKey)
    if state.active then say("already armed; use off before changing setup"); return end
    if inCombat() then say("setup requires being out of combat; nothing changed"); return end
    if SpellIsTargeting() or GetCursorInfo() then say("cancel the ground circle or clear your cursor before setup"); return end
    if not cleanupLease() then say("previous slot cleanup is pending; run off first"); return end
    host = findHost()
    if not host then say("compatible Simia host is not ready"); return end
    if host.KhanGroundExportHookVersion ~= 1 or type(host.UpdateBindingData) ~= "function" then
        say("export_patch_missing: install the matching experimental export bridge first"); return
    end
    if host.KhanGroundExportFilter ~= nil then say("another export filter is active; nothing changed"); return end
    if type(hooksecurefunc) ~= "function" or type(CameraOrSelectOrMoveStart) ~= "function" then
        say("native confirmation observer unavailable; nothing changed"); return
    end
    if not C_Spell or type(C_Spell.IsCurrentSpell) ~= "function" then say("rain_identity_api_missing; nothing changed"); return end
    local problem = modeProblem()
    if problem then say(problem); return end
    refreshLearned()
    if not learned then say("learn Rain of Fire before setup"); return end
    local selected, keyError = selectKey(requested)
    if not selected then say(keyError); return end
    local confirmCode, confirmError = selectConfirmKey(confirmKey, selected.key)
    if not confirmCode then say(confirmError .. "; usage: on OPENKEY CONFIRMKEY"); return end
    local unit = GamepadMainActionBarFrame and GamepadMainActionBarFrame.PageUnit
    local bar = unit and unit:GetActiveBar()
    if not (bar and unit.actionBars and bar == unit.actionBars.topBar and unit:GetCurrentPage() <= 3) then
        say("select a standard native gamepad page with no bar modifiers held"); return
    end
    if not (C_GamepadUI and C_GamepadUI.IsValidGamepadActionStorageSlotIndex and GamepadActionBarBindingUtil
            and GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot and C_Spell.PickupSpell) then
        say("native gamepad slot APIs are unavailable"); return
    end
    local slot, index
    for i = 1, 4 do -- Top-right buttons 5-8 are reserved native UI actions.
        local button = bar:GetActionButtonByIndex(i)
        local id = button and button:GetID()
        if id and C_GamepadUI.IsValidGamepadActionStorageSlotIndex(id) and not GetActionInfo(id) then slot,index=id,i; break end
    end
    if not slot then say("no empty bindable slot on this gamepad top bar; nothing was overwritten"); return end
    local nativeButton = bar:GetActionButtonByIndex(index)
    if type(nativeButton.HookScript) ~= "function" then say("native button observer unavailable"); return end
    db().lease = {slot=slot,spellID=learned}
    local ok, placed = pcall(GamepadActionBarBindingUtil.AssignActionToGamepadStandardSlot, slot, C_Spell.PickupSpell, learned)
    local kind, id = GetActionInfo(slot)
    if not ok or not placed or kind ~= "spell" or id ~= learned then
        cleanupLease(); say("native spell placement failed; helper remains off"); return
    end
    state.key, state.spellKey, state.spec = selected.key, selected.spellKey, selected.spec
    state.confirmKey, state.confirmCode = confirmKey, confirmCode
    state.openCode = host.KeyMapping.KeyToKeyCode(selected.key)
    state.spellID, state.slot, state.index = learned, slot, index
    state.bar, state.page = bar, unit:GetCurrentPage()
    state.button = nativeButton
    state.action = "GAMEPADACTIONBUTTON" .. index
    local bound = pcall(SetOverrideBinding, owner, true, state.key, state.action)
    local confirmBound = pcall(SetOverrideBinding, owner, true, confirmKey, CONFIRM_ACTION)
    if not bound or not confirmBound or GetBindingAction(state.key, true) ~= state.action
            or GetBindingAction(confirmKey, true) ~= CONFIRM_ACTION then
        ClearOverrideBindings(owner); cleanupLease(); say("native binding could not be installed; helper remains off"); return
    end
    state.active, pendingOff, state.fault = true, false, nil
    state.pending, state.attempt, state.exportSerial = nil, nil, nil
    state.phase, state.reason = "idle", "armed; automatic confirmation experimental"
    previousFilter, exportFilter = host.KhanGroundExportFilter, makeExportFilter()
    host.KhanGroundExportFilter = exportFilter
    attachGuard(); installHooks(); observeNativeButton(nativeButton); observeConfirmation(); publish()
    say("EXPERIMENTAL: " .. state.key .. " opens Rain through native slot " .. slot .. "; " .. confirmKey .. " is reserved for automatic confirmation.")
    say("Native confirmation remains unverified. Only an owned Rain circle receives the confirmation key. Failures stop the bridge; use status, Escape, then off.")
end

SLASH_KHANWARLOCKGROUND1 = "/khanwarlockground"
SLASH_KHANWARLOCKGROUND2 = "/kaptinwarlockground"
SlashCmdList.KHANWARLOCKGROUND = function(message)
    local command, key, confirmKey, extra = trim(message):match("^(%S*)%s*(%S*)%s*(%S*)%s*(.-)$")
    command = (command or ""):lower()
    if command == "on" then
        if key == "" or confirmKey == "" or extra ~= "" then say("usage: on OPENKEY CONFIRMKEY (two dedicated unmodified keys)")
        else enable(key:upper(), confirmKey:upper()) end
    elseif command == "off" then disable()
    else
        if state.active then advance() end
        say(state.version .. ": " .. state.phase .. "; " .. state.reason .. (state.active and ("; open " .. state.key .. ", confirm " .. state.confirmKey .. ", slot " .. state.slot) or ""))
        say("opens=" .. state.opens .. " owned=" .. state.owned .. " confirms=" .. state.confirms .. " channels=" .. state.channels .. " failures=" .. state.failures)
        local currentHost = findHost()
        say("host=" .. (currentHost and "ready" or "missing") .. "; export hook=" .. tostring(currentHost and currentHost.KhanGroundExportHookVersion or "missing") .. "; native mode=" .. (modeProblem() or "ready"))
        say("on OPENKEY CONFIRMKEY / off / status. Requires native Gamepad UI plus matching export patch. No settings or saved keys are changed.")
    end
end
owner:RegisterEvent("PLAYER_LOGIN")
owner:RegisterEvent("PLAYER_REGEN_ENABLED")
owner:RegisterEvent("SPELLS_CHANGED")
owner:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
owner:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
owner:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
owner:RegisterEvent("UNIT_SPELLCAST_FAILED")
owner:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
owner:SetScript("OnEvent", function(_, event, unit, _, spellID)
    if state.active and unit == "player" and spellID == state.spellID and state.pending then
        if event == "UNIT_SPELLCAST_CHANNEL_START" then finishChannel()
        elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then fail("rain_spell_failed"); publish() end
    end
    if event == "SPELLS_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" then refreshLearned() end
    if pendingOff and not inCombat() then disable()
    elseif state.active then advance(); scheduleReconcile()
    elseif not inCombat() then cleanupLease() end
end)
owner:SetScript("OnUpdate", function(_, delta)
    if not state.active then return end
    elapsed = elapsed + delta
    if elapsed < 0.03 then return end
    elapsed = 0
    advance()
    if not inCombat() and (pendingOff or state.fault) then disable(state.fault)
    elseif not inCombat() and not state.pending and not state.attempt then reconcile() end
end)
-- SavedVariables are loaded before addon files. Cleanup only, never enable.
if not inCombat() then cleanupLease() end
