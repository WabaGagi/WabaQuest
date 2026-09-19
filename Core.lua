-- Core.lua: addon state and logic. No WoW API calls here so it can be
-- loaded and unit-tested outside the game client.

WabaQuest = WabaQuest or {}
local WabaQuest = WabaQuest

WabaQuest.stats = { accepted = 0, completed = 0 }
WabaQuest.settings = { autoAccept = true, autoTurnIn = true }

function WabaQuest:OnQuestAccepted(questID)
    self.stats.accepted = self.stats.accepted + 1
end

function WabaQuest:OnQuestTurnedIn(questID)
    self.stats.completed = self.stats.completed + 1
end

function WabaQuest:SetAutoAccept(enabled)
    self.settings.autoAccept = enabled
end

function WabaQuest:SetAutoTurnIn(enabled)
    self.settings.autoTurnIn = enabled
end

function WabaQuest:Summary()
    return string.format(
        "Accepted: %d, Completed: %d (auto-accept: %s, auto-turn-in: %s)",
        self.stats.accepted,
        self.stats.completed,
        self.settings.autoAccept and "on" or "off",
        self.settings.autoTurnIn and "on" or "off"
    )
end

function WabaQuest:Reset()
    self.stats.accepted = 0
    self.stats.completed = 0
end

return WabaQuest
