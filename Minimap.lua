-- Minimap.lua: a small draggable minimap button, no external library
-- (LibDBIcon) - self-contained to match the rest of this addon. Position
-- is stored as an angle around the ring, persisted in WabaQuestSettingsDB.

local ICON = 134939 -- Interface\Icons\inv_scroll_03

local button = CreateFrame("Button", "WabaQuestMinimapButton", Minimap)
button:SetSize(31, 31)
button:SetFrameStrata("MEDIUM")
button:SetFrameLevel(8)
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")
button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local border = button:CreateTexture(nil, "OVERLAY")
border:SetSize(53, 53)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT")

local icon = button:CreateTexture(nil, "BACKGROUND")
icon:SetTexture(ICON)
icon:SetSize(20, 20)
icon:SetPoint("CENTER", 0, 1)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- crop the icon's edge so it doesn't peek past the round border

local RING_GAP = 10 -- how far outside the minimap's edge the button sits

local function GetRadius()
    return (Minimap:GetWidth() / 2) + RING_GAP
end

local function UpdatePosition()
    local angle = math.rad(WabaQuestSettingsDB.minimapAngle or 200)
    local radius = GetRadius()
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
        local mx, my = Minimap:GetCenter()
        local px, py = GetCursorPosition()
        local scale = Minimap:GetEffectiveScale()
        px, py = px / scale, py / scale
        WabaQuestSettingsDB.minimapAngle = math.deg(math.atan2(py - my, px - mx))
        UpdatePosition()
    end)
end)

button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
end)

button:SetScript("OnClick", function(self, mouseButton)
    if mouseButton == "RightButton" then
        Settings.OpenToCategory(WabaQuest.optionsCategoryID)
    else
        SlashCmdList["WABAQUEST"]("")
    end
end)

button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("WabaQuest")
    GameTooltip:AddLine(WabaQuest:Summary(), 1, 1, 1, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-click: show status", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("Right-click: options", 0.6, 0.6, 0.6)
    GameTooltip:AddLine("Drag: reposition", 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
button:SetScript("OnLeave", GameTooltip_Hide)

local minimapButtonFrame = CreateFrame("Frame")
minimapButtonFrame:RegisterEvent("ADDON_LOADED")
minimapButtonFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == "WabaQuest" then
        WabaQuestSettingsDB.minimapAngle = WabaQuestSettingsDB.minimapAngle or 200
        UpdatePosition()
    end
end)
