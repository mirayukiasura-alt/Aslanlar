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

    ToggleKeybind = Enum.KeyCode.RightShift,
    TweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Registry = {},
    Signals = {}
}

-- ASLANLARHUB PREMIUM RENK PALETİ ENJEKSİYONU
Library.MainColor = Color3.fromRGB(26, 22, 37)       -- --bg1 (Ana Pencereler)
Library.BackgroundColor = Color3.fromRGB(15, 13, 20) -- --bg0 (Arka Plan / Tab bar)
Library.AccentColor = Color3.fromRGB(108, 92, 231)   -- --pur1 (Neon Mor Accent)
Library.OutlineColor = Color3.fromRGB(61, 56, 80)    -- --gry1 (Kutuların ve çerçevenin border rengi)
Library.FontColor = Color3.fromRGB(232, 228, 244)   -- --txt1 (Ana Yazı Rengi)

function Library:SafeCallback(f, ...)
    if (not f) then return end
    local success, err = pcall(f, ...)
    if (not success) then
        warn(string.format("[Kütüphane Hatası]: Geri çağırma yürütülemedi: %s", tostring(err)))
    end
end

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:Unload()
    for _, Signal in next, Library.Signals do
        Signal:Disconnect()
    end
    if Library.ScreenGui then
        Library.ScreenGui:Destroy()
    end
    getgenv().Library = nil
end

-- Orijinal LinoriaLib UI yapısının devamı buraya eklenmiştir (Eksiksiz yüklenmesi için yönlendirildi)
local BaseLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
for k, v in pairs(BaseLibrary) do
    if Library[k] == nil then
        Library[k] = v
    end
end

-- Renkleri kütüphane ayarlarına sabitleme
BaseLibrary.MainColor = Library.MainColor
BaseLibrary.BackgroundColor = Library.BackgroundColor
BaseLibrary.AccentColor = Library.AccentColor
BaseLibrary.OutlineColor = Library.OutlineColor
BaseLibrary.FontColor = Library.FontColor

getgenv().Library = Library
return Library
