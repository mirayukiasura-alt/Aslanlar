local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local SoundService: SoundService = cloneref(game:GetService("SoundService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local Teams: Teams = cloneref(game:GetService("Teams"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local getgenv = getgenv or function()
    return shared
end
local setclipboard = setclipboard or nil
local protectgui = protectgui or (syn and syn.protect_gui) or function() end
local gethui = gethui or function() 
    return CoreGui 
end

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Labels = {}
local Buttons = {}
local Toggles = {}
local Options = {}

local Library = {
    LocalPlayer = LocalPlayer,
    DevicePlatform = nil,
    IsMobile = false,

    ScreenGui = nil,

    ActiveTab = nil,
    Tabs = {},

    KeybindFrame = nil,
    KeybindContainer = nil,
    KeybindToggles = {},

    Notifications = {},

    -- Varsayılan açma tuşu RightShift yapıldı
    ToggleKeybind = Enum.KeyCode.RightShift,
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    NotifyTweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

    Toggled = false,
    Unloaded = false,

    Labels = Labels,
    Buttons = Buttons,
    Toggles = Toggles,
    Options = Options,

    NotifySide = "Right",
    ShowCustomCursor = true,
    ForceCheckbox = false,
    ShowToggleFrameInKeybinds = true,
    NotifyOnError = false,

    CantDragForced = false,

    Signals = {},
    UnloadSignals = {},

    MinSize = Vector2.new(480, 360),
    DPIScale = 1,
    CornerRadius = 4,

    IsLightTheme = false,
    
    -- ASLANLARHUB PREMIUM RENK PALETİ
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 13, 20), -- --bg0
        MainColor = Color3.fromRGB(26, 22, 37),       -- --bg1
        AccentColor = Color3.fromRGB(108, 92, 231),   -- --pur1
        OutlineColor = Color3.fromRGB(61, 56, 80),    -- --gry1
        FontColor = Color3.fromRGB(232, 228, 244),   -- --txt1
        Font = Font.fromEnum(Enum.Font.Code),

        Red = Color3.fromRGB(255, 50, 50),
        Dark = Color3.new(0, 0, 0),
        White = Color3.new(1, 1, 1),
    },

    Registry = {},
    DPIRegistry = {},
}

-- Kütüphanenin geri kalan binlerce satırlık orijinal kod gövdesini (UI nesneleri, elementler, sliderlar vs.) 
-- buraya hiç dokunmadan ekleyebilirsin veya bu üst kısmı senin mevcut tam dosyandaki 'local Library = { ... }' ve 'Scheme' alanıyla değiştirebilirsin.
-- (Geri kalan tüm fonksiyonlar, pcall'lar ve deivid'in geliştirmeleri bu satırın altında aynen korunmalıdır.)
