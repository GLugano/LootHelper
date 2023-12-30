--- Libs
local LDBIcon = LibStub("LibDBIcon-1.0")
local ADDON_NAME, ADDON = ...

ADDON.Utils = {}
ADDON.Utils.Prefix = ""

function ADDON.Utils:SetPrefix(text)
    ADDON.Utils.Prefix = text
end

function ADDON.Utils:CoerceBooleanProperty(value)
    return value == true
end

function ADDON.Utils:ApplyPrefix(text)
    return ADDON.Utils.Prefix .. text
end

function ADDON.Utils:CreateCheckbox(parent, label, description, onClick)
    local name = parent.name .. "-" .. label .. "-" .. "-checkbox"
    local checkboxRef = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")

    checkboxRef:SetScript("OnClick", function(self)
        local tick = self:GetChecked()
        onClick(self, tick and true or false)
        if tick then
            PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
        else
            PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
        end
    end)

    checkboxRef.text = checkboxRef:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkboxRef.text:SetPoint("LEFT", checkboxRef, "RIGHT", 0, 1)
    checkboxRef.text:SetText(label)
    checkboxRef.tooltipText = label
    checkboxRef.tooltipRequirement = description

    return checkboxRef
end

function ADDON.Utils:CreateMapIcon(addonStructure)
    LDBIcon:Register(
        ADDON.Utils:ApplyPrefix("MapIcon"),
        addonStructure.MinimapIcon,
        addonStructure.MinimapIconOptions
    )
end

function ADDON.Utils:CoercePlayerName(name)
    if (name == "You" or name == "you") then
        return UnitName("PLAYER")
    end

    return name
end

-- Logic
function ADDON.Utils:Ternary(condition, trueValue, falseValue)
    if (condition) then return trueValue else return falseValue end
end

-- String functions
function ADDON.Utils:StringSplt(str, sep)
    if (sep == nil) then
        sep = "%s"
    end

    local t = {}

    for str in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end

    return t
end

-- Table functions
function ADDON.Utils:PrintTableData(table)
    for key in pairs(table) do
        print(key, table[key])
    end
end

function ADDON.Utils:GetTableSize(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function genOrderedIndex(t)
    local orderedIndex = {}

    for key in pairs(t) do
        
        if (tonumber(key) ~= nil) then
            table.insert(orderedIndex, key)
        end
    end

    table.sort(orderedIndex)

    return orderedIndex
end

local function orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
end

function ADDON.Utils:OrderedPairs(table)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, table, nil
end

-- PlaySoundFile([[Interface\CustomSounds\MyCustomSound.ogg]])
