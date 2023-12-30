--- Libs
local LDBIcon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1")
local ADDON_NAME, ADDON = ...
local ADDON_PREFIX = "LootHelper"

ADDON.Utils:SetPrefix(ADDON_PREFIX)

-------------------------------------------------------------------------
--- Enums
local ChatMsgType = {
    ROLL_START = "roll_start",
    ROLL_ENDED = "roll_ended",
    PLAYER_ROLL = "player_roll",
    ROLL_ALL_PASS = "roll_all_pass"
}

local RollType = {
    NEED = "need",
    GREED = "greed",
    PASS = "pass"
}

--- Normal variables
local LootHelper = {}

LootHelper.Frames = {}
LootHelper.MainFrameRef = nil
LootHelper.HeaderTextRef = nil
LootHelper.MinimapIconOptions = LootHelper.MinimapIconOptions or { hide = false };
LootHelper.MinimapIcon = LDB:NewDataObject(
    ADDON.Utils:ApplyPrefix("MinimapIcon"),
    {
        type = "launcher",
        text = ADDON_NAME,
        icon = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\Icons\\loot.blp",
        label = ADDON_NAME,
        suffix = "",
        tocname = ADDON_NAME,
        OnClick = function(self, button)
            if (button == "LeftButton") then
                LootHelper:ShowMainFrame()
                -- elseif (button == "RightButton") then
                --     LootHelper:OpenOptions()
            end
        end,
        OnTooltipShow = function(self)
            self:AddLine(ADDON_NAME)
            self:AddLine("Left click |cffddff00to open the window|r")
            -- self:AddLine("Right click |cffddff00to open the options|r")
        end,
        iconR = 1,
        iconG = 1,
        iconB = 1
    }
)

function LootHelper:ShowMainFrame()
    if (LootHelper.MainFrameRef) then
        LootHelper.MainFrameRef:Show()
    end
end

function LootHelper:HideMainFrame()
    if (LootHelper.MainFrameRef) then
        LootHelper.MainFrameRef:Hide()
    end
end

function LootHelper:ShowChatNotification(text)
    print("|cffddff00[LH]|r " .. text)
end

function LootHelper:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
end

function LootHelper:CreateConfigFrame()
    LootHelper.ConfigFrame = CreateFrame("FRAME", ADDON.Utils:ApplyPrefix("ConfigFrame"))
    LootHelper.ConfigFrame.name = ADDON_NAME

    ---@type CheckButton
    local autoLoggingCheckbox = ADDON.Utils:CreateCheckbox(
        LootHelper.ConfigFrame,
        "Auto logging",
        "Start the log when entering raids (will be updated each phase)",
        ---@param self CheckButton
        function(self)
            CONFIG_AUTO_START_LOG = self:GetChecked()
        end
    )

    autoLoggingCheckbox:SetChecked(CONFIG_AUTO_START_LOG);
    autoLoggingCheckbox:SetPoint("TOPLEFT", LootHelper.ConfigFrame, "TOPLEFT", 0, -16)
    autoLoggingCheckbox:Show()

    -- ---@type CheckButton
    -- local testCheckbox = ADDON.Utils:CreateCheckbox(
    --     LootHelper.ConfigFrame,
    --     "Test",
    --     "Test"
    -- )

    -- testCheckbox:SetPoint("TOPLEFT", LootHelper.ConfigFrame, "TOPLEFT", 0, -48)
    -- testCheckbox:Show()

    -- InterfaceOptions_AddCategory(LootHelper.ConfigFrame)
end

-- Only works if this runs when ADDON_LOADED is running or already executed
function LootHelper:VerifySavedVariables()
    if (ModalVisible == nil) then
        ModalVisible = true
    end

    if (LootBag == nil) then
        LootBag = {}
    end
end

function LootHelper:SetupSlashCommands()
    SLASH_LootHelper1 = "/clh"
    SlashCmdList.LootHelper = function(strParam)
        if (not strParam or strParam:trim() == "") then
            print("Type /clh help for commands")
        elseif (strParam == "help") then
            print("Use the following parameters with /clh")
            print("- open: Open the window")
            print("- close: Close the window")
            -- print("- options: Open the options tab")
        elseif (strParam == "open") then
            LootHelper:ShowMainFrame()
        elseif (strParam == "close") then
            LootHelper:HideMainFrame()
            -- elseif (strParam == "options") then
            --     LootHelper:OpenOptions()
        end
    end
end

function LootHelper:UpdateList()
    local size = ADDON.Utils:GetTableSize(LootBag)
    local pos = 0

    if (size == 0) then
        return
    end

    for key in ADDON.Utils:OrderedPairs(LootBag) do
        local row = LootBag[key]
        local framesRow = LootHelper.Frames[key]
        pos = pos + 1

        if (not framesRow) then
            LootHelper.Frames[key] = {}
            framesRow = LootHelper.Frames[key]
        end

        if (not framesRow.frame) then
            framesRow.frame = CreateFrame("Frame", nil, LootHelper.ScrollChildFrame)
            framesRow.frame:SetWidth(150)
            framesRow.frame:SetHeight(45)
            framesRow.frame:Show()

            framesRow.frameIcon = framesRow.frame:CreateTexture(nil, "ARTWORK")
            framesRow.frameIcon:SetTexture(row.itemIcon)
            framesRow.frameIcon:SetPoint("TOPLEFT", framesRow.frame, "TOPLEFT", 10, 0)
            -- framesRow.frameIcon:SetAllPoints(framesRow.frame)
            framesRow.frameIcon:SetSize(30, 30)

            framesRow.frameHeader = framesRow.frame:CreateFontString(nil, "OVERLAY")
            framesRow.frameHeader:SetFontObject("GameFontHighlight")
            framesRow.frameHeader:SetPoint("TOPLEFT", framesRow.frame, "TOPLEFT", 50, -2)
            framesRow.frameHeader:SetText(row.itemLink)

            -- Winner row
        end

        if (not framesRow.frameWinner) then
            framesRow.frameWinner = framesRow.frame:CreateFontString(nil, "OVERLAY")
            framesRow.frameWinner:SetFontObject("GameFontHighlight")
            framesRow.frameWinner:SetPoint("TOPLEFT", framesRow.frame, "TOPLEFT", 50, -17)
            framesRow.frameWinner:SetText("-")
        end

        if (row.isDone) then
            if (row.winner) then
                local r, g, b, hex = GetClassColor(row.winner.class)
                print(row.winner.class, hex)
                framesRow.frameWinner:SetText("Winner: " .. "|c" .. hex .. row.winner.name .. "|r")
            else
                framesRow.frameWinner:SetText("All pass")
            end
        end

        framesRow.frame:SetPoint("TOPLEFT", LootHelper.ScrollChildFrame, "TOPLEFT", 5, -(((pos - 1) * 45) + 10))
    end
end

function LootHelper:CreateMainFrame()
    LootHelper.MainFrameRef = CreateFrame(
        "Frame",
        ADDON.Utils:ApplyPrefix("MainFrame"),
        UIParent,
        "BasicFrameTemplateWithInset"
    )
    -- LootHelper.MainFrameRef:SetBackdrop(DEFAULT_BACKGROUND)
    -- LootHelper.MainFrameRef:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
    LootHelper.MainFrameRef:SetMovable(true)
    LootHelper.MainFrameRef:SetPoint("CENTER", UIParent, "CENTER")
    LootHelper.MainFrameRef:SetClampedToScreen(true)
    LootHelper.MainFrameRef:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    LootHelper.MainFrameRef:SetSize(225, 450)

    if (ModalVisible) then
        LootHelper.MainFrameRef:Show()
    else
        LootHelper.MainFrameRef:Hide()
    end

    -- Moviment Config
    LootHelper.MainFrameRef.isMoving = false
    LootHelper.MainFrameRef:SetScript(
        "OnMouseDown",
        function(self, button)
            if (button == "MiddleButton" and not LootHelper.MainFrameRef.isMoving) then
                LootHelper.MainFrameRef:StartMoving();
                LootHelper.MainFrameRef.isMoving = true;
            end
        end
    )

    LootHelper.MainFrameRef:SetScript(
        "OnMouseUp",
        function(self, button)
            if (button == "MiddleButton" and LootHelper.MainFrameRef.isMoving) then
                LootHelper.MainFrameRef:StopMovingOrSizing();
                LootHelper.MainFrameRef.isMoving = false;
            end
        end
    )

    -- Hide Event
    LootHelper.MainFrameRef:SetScript("OnHide", function() ModalVisible = false end)
    LootHelper.MainFrameRef:SetScript("OnShow", function() ModalVisible = true end)

    --- Header
    LootHelper.HeaderTextRef = LootHelper.MainFrameRef:CreateFontString(nil, "OVERLAY")
    LootHelper.HeaderTextRef:SetFontObject("GameFontHighlight")
    LootHelper.HeaderTextRef:SetPoint("CENTER", LootHelper.MainFrameRef.TitleBg, "CENTER", 11, 0)
    LootHelper.HeaderTextRef:SetText(ADDON.Utils:ApplyPrefix(""))

    local scrollFrame = CreateFrame("ScrollFrame", nil, LootHelper.MainFrameRef, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 0, -25)
    scrollFrame:SetPoint("BOTTOMRIGHT", -27, 4)
    -- scrollFrame:SetVerticalScroll

    LootHelper.ScrollChildFrame = CreateFrame("Frame")
    LootHelper.ScrollChildFrame:SetWidth(LootHelper.MainFrameRef:GetWidth() - 18)
    LootHelper.ScrollChildFrame:SetHeight(1)

    scrollFrame:SetScrollChild(LootHelper.ScrollChildFrame)
end

function LootHelper:InitEvents()
    if (not LootHelper.MainFrameRef) then
        return
    end

    LootHelper.MainFrameRef:RegisterEvent("ADDON_LOADED")
    -- LootHelper.MainFrameRef:RegisterEvent("LOOT_HISTORY_FULL_UPDATE")
    -- LootHelper.MainFrameRef:RegisterEvent("LOOT_HISTORY_ROLL_COMPLETE")
    LootHelper.MainFrameRef:RegisterEvent("CHAT_MSG_LOOT")
    LootHelper.MainFrameRef:SetScript(
        "OnEvent",
        function(self, event, arg1, arg2, arg3)
            if (event == "ADDON_LOADED") then
                if (arg1 == ADDON_NAME) then
                    LootHelper:ShowChatNotification("LootHelper loaded")
                    LootHelper:SetupSlashCommands()
                    LootHelper:VerifySavedVariables()
                    LootHelper:CreateConfigFrame()
                    LootHelper:UpdateList()

                    if (ModalVisible) then
                        LootHelper:ShowMainFrame()
                    end
                end
            elseif (event == "CHAT_MSG_LOOT") then
                LootHelper:ChatMsgLootEvent(arg1)
            end
        end
    )
end

function LootHelper:ChatMsgLootEvent(msg)
    local eventData = LootHelper:GetChatMessageEventData(msg)

    if (eventData == nil) then
        return
    end

    local pos, item = LootHelper:GetLootStillRolling(eventData.itemId)

    if (not item) then
        item = {
            itemId = eventData.itemId,
            itemLink = eventData.itemLink,
            itemIcon = GetItemIcon(eventData.itemId),
            players = {},
            isDone = false,
            winner = nil
        }
    end

    if (eventData.type == ChatMsgType.PLAYER_ROLL) then
        if (eventData.player) then
            local playerFoundInList = false

            for _, player in ipairs(item.players) do
                if (player.name == eventData.player.name) then
                    playerFoundInList = true
                    break
                end
            end

            if (not playerFoundInList) then
                local playerRoll = {
                    name = eventData.player.name,
                    class = eventData.player.class,
                    roll = eventData.rollValue,
                    type = eventData.rollType
                }

                table.insert(item.players, playerRoll)
            end
        end
    elseif (eventData.type == ChatMsgType.ROLL_ENDED) then
        local playerRollFound = nil

        for _, player in ipairs(item.players) do
            if (player.name == eventData.player.name) then
                playerRollFound = player
            end
        end

        item.isDone = true

        if (playerRollFound) then
            item.winner = playerRollFound
        else
            item.winner = {
                name = eventData.player.name,
                class = eventData.player.class,
                roll = nil,
                type = nil,
            }
        end
    end

    if (not pos) then
        table.insert(LootBag, item)
    end

    LootHelper:UpdateList()
end

function LootHelper:GetChatMessageEventData(msg)
    local itemLink = LootHelper:GetItemLinkFromChatMessage(msg)

    if (not itemLink) then
        return
    end

    local itemId = GetItemInfoFromHyperlink(itemLink)
    local msgTokens = ADDON.Utils:StringSplt(msg, " ")
    local playerName = nil
    local startPos = string.find(msgTokens[1], "|HlootHistory")

    if (startPos ~= nil) then
        playerName = ADDON.Utils:CoercePlayerName(msgTokens[2])

        if (msgTokens[3] == "passed") then
            if (msgTokens[2] == "Everyone") then
                return {
                    type = ChatMsgType.ROLL_ALL_PASS,
                    itemLink = itemLink,
                    itemId = itemId
                }
            else
                return {
                    type = ChatMsgType.PLAYER_ROLL,
                    itemLink = itemLink,
                    itemId = itemId,
                    rollType = RollType.Pass,
                    player = {
                        name = playerName,
                        class = string.upper(UnitClass(playerName))
                    }
                }
            end
        elseif (msgTokens[2] == "Greed" or msgTokens[2] == "Need") then
            local rollType = ADDON.Utils:Ternary(msgTokens[2] == "Need", RollType.NEED, RollType.GREED)

            return {
                type = ChatMsgType.PLAYER_ROLL,
                itemLink = itemLink,
                itemId = itemId,
                rollType = rollType,
                rollValue = tonumber(msgTokens[5]),
                player = {
                    name = playerName,
                    class = string.upper(UnitClass(playerName))
                }
            }
        else
            if (msgTokens[3] == "won:") then
                playerName = ADDON.Utils:CoercePlayerName(msgTokens[2])

                return {
                    type = ChatMsgType.ROLL_ENDED,
                    itemLink = itemLink,
                    itemId = itemId,
                    player = {
                        name = playerName,
                        class = string.upper(UnitClass(playerName))
                    }
                }
            else
                if (string.find(msgTokens[2], "|H")) then
                    return {
                        type = ChatMsgType.ROLL_START,
                        itemLink = itemLink,
                        itemId = itemId,
                    }
                end
            end
        end
    end

    return nil
end

function LootHelper:GetItemLinkFromChatMessage(msg)
    local s, _ = string.find(msg, "%|c")

    if (s == nil) then
        return nil
    end

    local _, e = string.find(msg, "%|h|r")
    local itemLink = string.sub(msg, s, e)

    return itemLink
end

function LootHelper:GetLootStillRolling(itemId)
    for pos, value in ipairs(LootBag) do
        if (value.itemId == itemId and not value.isDone) then
            return pos, value
        end
    end

    return nil, nil
end

--- Start of the addon
LootHelper:CreateMainFrame()
ADDON.Utils:CreateMapIcon(LootHelper)
LootHelper:InitEvents()
