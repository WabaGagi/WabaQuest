-- Init.lua: WoW API glue - event registration, auto-accept/auto-turn-in,
-- and the slash command. This is the file that only runs correctly
-- inside the game (or the stub).

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

-- Options panel: a vertical-list Settings category with one checkbox per
-- toggle, each bound directly to WabaQuestSettingsDB via RegisterAddOnSetting
-- (per Blizzard_Settings_Shared/Blizzard_ImplementationReadme.lua) and routed
-- through the same setters the slash command uses, so both stay in sync.
local function CreateOptionsPanel()
    local category = Settings.RegisterVerticalLayoutCategory("WabaQuest")

    local autoAcceptSetting = Settings.RegisterAddOnSetting(category, "WABAQUEST_AUTO_ACCEPT", "autoAccept",
        WabaQuestSettingsDB, Settings.VarType.Boolean, "Auto-accept quests", true)
    autoAcceptSetting:SetValueChangedCallback(function(_, value)
        WabaQuest:SetAutoAccept(value)
    end)
    Settings.CreateCheckbox(category, autoAcceptSetting, "Automatically accept quests offered by NPCs.")

    local autoTurnInSetting = Settings.RegisterAddOnSetting(category, "WABAQUEST_AUTO_TURN_IN", "autoTurnIn",
        WabaQuestSettingsDB, Settings.VarType.Boolean, "Auto-turn-in quests", true)
    autoTurnInSetting:SetValueChangedCallback(function(_, value)
        WabaQuest:SetAutoTurnIn(value)
    end)
    Settings.CreateCheckbox(category, autoTurnInSetting, "Automatically turn in quests that are ready to complete.")

    Settings.RegisterAddOnCategory(category)
    WabaQuest.optionsCategoryID = category:GetID()
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == "WabaQuest" then
            WabaQuestDB = WabaQuestDB or { accepted = 0, completed = 0 }
            WabaQuest.stats = WabaQuestDB
            WabaQuestSettingsDB = WabaQuestSettingsDB or { autoAccept = true, autoTurnIn = true }
            WabaQuest.settings = WabaQuestSettingsDB
            CreateOptionsPanel()
        end
    elseif event == "QUEST_ACCEPTED" then
        WabaQuest:OnQuestAccepted(...)
    elseif event == "QUEST_TURNED_IN" then
        WabaQuest:OnQuestTurnedIn(...)

    -- Multi-quest NPC gossip screen: accept every offer, turn in every
    -- quest that's already complete.
    elseif event == "QUEST_GREETING" then
        if WabaQuest.settings.autoAccept then
            for i = 1, GetNumAvailableQuests() do
                SelectAvailableQuest(i)
            end
        end
        if WabaQuest.settings.autoTurnIn then
            for i = 1, GetNumActiveQuests() do
                local _, isComplete = GetActiveTitle(i)
                if isComplete then
                    SelectActiveQuest(i)
                end
            end
        end

    -- Single-quest offer popup.
    elseif event == "QUEST_DETAIL" then
        if WabaQuest.settings.autoAccept then
            AcceptQuest()
        end

    -- Turn-in screen showing objectives/items still needed.
    elseif event == "QUEST_PROGRESS" then
        if WabaQuest.settings.autoTurnIn and IsQuestCompletable() then
            CompleteQuest()
        end

    -- Reward screen. Only auto-pick when there's nothing to choose
    -- between - a real choice is left for the player.
    elseif event == "QUEST_COMPLETE" then
        if WabaQuest.settings.autoTurnIn and GetNumQuestChoices() <= 1 then
            GetQuestReward(1)
        end
    end
end)

SLASH_WABAQUEST1 = "/wabaquest"
SlashCmdList["WABAQUEST"] = function(msg)
    local cmd, arg = (msg or ""):match("^(%S*)%s*(%S*)$")
    cmd = cmd:lower()
    arg = arg:lower()

    if cmd == "accept" then
        WabaQuest:SetAutoAccept(arg == "on")
        print("|cff33ff99WabaQuest|r: auto-accept " .. (WabaQuest.settings.autoAccept and "ON" or "OFF"))
    elseif cmd == "turnin" then
        WabaQuest:SetAutoTurnIn(arg == "on")
        print("|cff33ff99WabaQuest|r: auto-turn-in " .. (WabaQuest.settings.autoTurnIn and "ON" or "OFF"))
    elseif cmd == "options" then
        Settings.OpenToCategory(WabaQuest.optionsCategoryID)
    else
        print("|cff33ff99WabaQuest|r: " .. WabaQuest:Summary())
    end
end
