local ADDON_NAME, ADDON = ...

ADDON.Utils = {}
ADDON.Utils.Prefix = ""
ADDON.Utils.TextTest = "123"

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

-- PlaySoundFile([[Interface\CustomSounds\MyCustomSound.ogg]])