--- Libs
local LDBIcon = LibStub("LibDBIcon-1.0")
local LDB = LibStub("LibDataBroker-1.1")
local ADDON_NAME, ADDON = ...
local ADDON_PREFIX = "LootHelper"

ADDON.Utils:SetPrefix(ADDON_PREFIX)

-------------------------------------------------------------------------
--- Normal variables
local LOOT_HELPER = {}

LOOT_HELPER.MainFrameRef = nil
LOOT_HELPER.HeaderTextRef = nil
LOOT_HELPER.MinimapIconOptions = LOOT_HELPER.MinimapIconOptions or { hide = false };
LOOT_HELPER.MinimapIcon = LDB:NewDataObject(
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
                LOOT_HELPER:ShowMainFrame()
            -- elseif (button == "RightButton") then
            --     LOOT_HELPER:OpenOptions()
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

function LOOT_HELPER:ShowMainFrame()
    if (LOOT_HELPER.MainFrameRef) then
        LOOT_HELPER.MainFrameRef:Show()
    end
end

function LOOT_HELPER:HideMainFrame()
    if (LOOT_HELPER.MainFrameRef) then
        LOOT_HELPER.MainFrameRef:Hide()
    end
end

function LOOT_HELPER:ShowChatNotification(text)
    print("|cffddff00[CLH]|r " .. text)
end

function LOOT_HELPER:OpenOptions()
    InterfaceOptionsFrame_OpenToCategory(ADDON_NAME)
end

function LOOT_HELPER:CreateConfigFrame()
    LOOT_HELPER.ConfigFrame = CreateFrame("FRAME", ADDON.Utils:ApplyPrefix("ConfigFrame"))
    LOOT_HELPER.ConfigFrame.name = ADDON_NAME

    ---@type CheckButton
    local autoLoggingCheckbox = ADDON.Utils:CreateCheckbox(
        LOOT_HELPER.ConfigFrame,
        "Auto logging",
        "Start the log when entering raids (will be updated each phase)",
        ---@param self CheckButton
        function(self)
            CONFIG_AUTO_START_LOG = self:GetChecked()
        end
    )

    autoLoggingCheckbox:SetChecked(CONFIG_AUTO_START_LOG);
    autoLoggingCheckbox:SetPoint("TOPLEFT", LOOT_HELPER.ConfigFrame, "TOPLEFT", 0, -16)
    autoLoggingCheckbox:Show()

    -- ---@type CheckButton
    -- local testCheckbox = ADDON.Utils:CreateCheckbox(
    --     LOOT_HELPER.ConfigFrame,
    --     "Test",
    --     "Test"
    -- )

    -- testCheckbox:SetPoint("TOPLEFT", LOOT_HELPER.ConfigFrame, "TOPLEFT", 0, -48)
    -- testCheckbox:Show()

    -- InterfaceOptions_AddCategory(LOOT_HELPER.ConfigFrame)
end

-- Only works if this runs when ADDON_LOADED is running or already executed
function LOOT_HELPER:VerifySavedVariables()
    if (MODAL_VISIBLE == nil) then
        MODAL_VISIBLE = true
    end
end

function LOOT_HELPER:SetupSlashCommands()
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
            LOOT_HELPER:ShowMainFrame()
        elseif (strParam == "close") then
            LOOT_HELPER:HideMainFrame()
            -- elseif (strParam == "options") then
            --     LOOT_HELPER:OpenOptions()
        end
    end
end

---------------------------------------------------------------------------------
--- Local Functions
local function createMainFrame()
    LOOT_HELPER.MainFrameRef = CreateFrame(
        "Frame",
        ADDON.Utils:ApplyPrefix("MainFrame"),
        UIParent,
        "BasicFrameTemplateWithInset"
    )
    -- LOOT_HELPER.MainFrameRef:SetBackdrop(DEFAULT_BACKGROUND)
    -- LOOT_HELPER.MainFrameRef:SetBackdropColor(0.1, 0.1, 0.1, 0.7)
    LOOT_HELPER.MainFrameRef:SetMovable(true)
    LOOT_HELPER.MainFrameRef:SetPoint("CENTER", UIParent, "CENTER")
    LOOT_HELPER.MainFrameRef:SetClampedToScreen(true)
    LOOT_HELPER.MainFrameRef:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    LOOT_HELPER.MainFrameRef:SetSize(200, 75)

    if (MODAL_VISIBLE) then
        LOOT_HELPER.MainFrameRef:Show()
    else
        LOOT_HELPER.MainFrameRef:Hide()
    end

    -- Moviment Config
    LOOT_HELPER.MainFrameRef.isMoving = false
    LOOT_HELPER.MainFrameRef:SetScript(
        "OnMouseDown",
        function(self, button)
            if (button == "MiddleButton" and not LOOT_HELPER.MainFrameRef.isMoving) then
                LOOT_HELPER.MainFrameRef:StartMoving();
                LOOT_HELPER.MainFrameRef.isMoving = true;
            end
        end
    )

    LOOT_HELPER.MainFrameRef:SetScript(
        "OnMouseUp",
        function(self, button)
            if (button == "MiddleButton" and LOOT_HELPER.MainFrameRef.isMoving) then
                LOOT_HELPER.MainFrameRef:StopMovingOrSizing();
                LOOT_HELPER.MainFrameRef.isMoving = false;
            end
        end
    )

    -- Hide Event
    LOOT_HELPER.MainFrameRef:SetScript("OnHide", function() MODAL_VISIBLE = false end)
    LOOT_HELPER.MainFrameRef:SetScript("OnShow", function() MODAL_VISIBLE = true end)

    --- Header
    LOOT_HELPER.HeaderTextRef = LOOT_HELPER.MainFrameRef:CreateFontString(nil, "OVERLAY")
    LOOT_HELPER.HeaderTextRef:SetFontObject("GameFontHighlight")
    LOOT_HELPER.HeaderTextRef:SetPoint("CENTER", LOOT_HELPER.MainFrameRef.TitleBg, "CENTER", 11, 0)
    LOOT_HELPER.HeaderTextRef:SetText(ADDON.Utils:ApplyPrefix(""))
end

local function initEvents()
    if (not LOOT_HELPER.MainFrameRef) then
        return
    end

    LOOT_HELPER.MainFrameRef:RegisterEvent("ADDON_LOADED")
    LOOT_HELPER.MainFrameRef:RegisterEvent("LOOT_ITEM_AVAILABLE")
    LOOT_HELPER.MainFrameRef:RegisterEvent("LOOT_READY")
    LOOT_HELPER.MainFrameRef:RegisterEvent("LOOT_HISTORY_FULL_UPDATE")
    -- LOOT_HELPER.MainFrameRef:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    LOOT_HELPER.MainFrameRef:SetScript(
        "OnEvent",
        function(self, event, addOnName)
            if (event == "ADDON_LOADED") then
                if (addOnName == ADDON_NAME) then
                    LOOT_HELPER:ShowChatNotification("LootHelper loaded")
                    LOOT_HELPER:SetupSlashCommands()
                    LOOT_HELPER:VerifySavedVariables()
                    LOOT_HELPER:CreateConfigFrame()
                end
            elseif (addOnName == nil) then
               SHOW_LOOT_HISTORY()
            end
        end
    )
end

function SHOW_LOOT_HISTORY()
    local numItems = C_LootHistory.GetNumItems();
	for i=1, numItems do

		local rollID, itemLink, numPlayers, isDone, winnerIdx = C_LootHistory.GetItem(i);
        print(itemLink)
    end
end

local function createMapIcon()
    LDBIcon:Register(
        ADDON.Utils:ApplyPrefix("MapIcon"),
        LOOT_HELPER.MinimapIcon,
        LOOT_HELPER.MinimapIconOptions
    )
end

--- Start of the addon
createMainFrame()
createMapIcon()
initEvents()
