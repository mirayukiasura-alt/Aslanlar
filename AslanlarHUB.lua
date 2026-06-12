getgenv().SHAMPO = true
if game.GameId ~= 4652005960 then return end

-- GitHub Repondan Dosyaları Çekme
local repo = "https://raw.githubusercontent.com/mirayukiasura-alt/Aslanlar/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "AslanlarHUB",
    Footer = "FREE MIRA | UNBAN MIRA YUKI",
    NotifySide = "Right",
    ShowCustomCursor = false
})

-- Kütüphanenin orijinal yapısına uygun İkon Tanımlamaları (Lucide)
local Tabs = {
    Main = Window:AddTab("Main", "home"),         -- Ana sekme için ev ikonu
    Skills = Window:AddTab("Skills", "bolt"),     -- Skills sekmesi için şimşek ikonu
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"), -- Ayarlar sekmesi
}

local FarmBox = Tabs.Main:AddLeftGroupbox("Combat Tools")
local NPCBox = Tabs.Main:AddRightGroupbox("NPC Filter")
local AutoBox = Tabs.Main:AddRightGroupbox("Automation")

FarmBox:AddLabel("⚠️ UNBAN MIRA YUKI ⚠️", true)
FarmBox:AddLabel("📢 FREE MIRA 📢", true)
FarmBox:AddDivider()

--------------------------------------------------
-- COMBAT TOOLS (SOL SÜTUN)
--------------------------------------------------
getgenv().SelectedWeapon = nil
getgenv().CombatWeapon = nil

local function fetchTools()
    local t = {}
    if LP:FindFirstChild("Backpack") then
        for _, v in pairs(LP.Backpack:GetChildren()) do
            if v:IsA("Tool") then table.insert(t, v.Name) end
        end
    end
    return t
end

local toolDrop = FarmBox:AddDropdown("RoundToolDropdown", {
    Values = fetchTools(),
    Default = 1,
    Multi = false,
    Text = "Round Tool",
    Callback = function(v) getgenv().SelectedWeapon = v end
})

local combatDrop = FarmBox:AddDropdown("CombatToolDropdown", {
    Values = fetchTools(),
    Default = 1,
    Multi = false,
    Text = "Combat Tool",
    Callback = function(v) getgenv().CombatWeapon = v end
})

FarmBox:AddButton({
    Text = "Refresh Tools",
    Func = function()
        local tools = fetchTools()
        toolDrop:SetValues(tools)
        combatDrop:SetValues(tools)
    end
})

FarmBox:AddDivider()

local AutoHit = false
local StopAt = 50

task.spawn(function()
    while true do
        task.wait(0.01)
        if AutoHit and not Library.Open then
            local gui = LP.PlayerGui:FindFirstChild("Main")
            if gui then
                local staminaBar = gui.HUD.Stamina.Clipping
                local staminaBg = gui.HUD.Stamina
                if staminaBar and staminaBg then
                     local percent = staminaBar.AbsoluteSize.X / staminaBg.AbsoluteSize.X * 100
                     if percent > StopAt then
                        VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                     end
                end
            end
        end
    end
end)

FarmBox:AddToggle("SmartAutoHit", {
    Text = "Smart Auto Hit",
    Default = false,
    Callback = function(v) AutoHit = v end
}):AddKeyPicker("AutoHitBind", { Default = "G", NoUI = false, Text = "Smart Auto Hit", SyncToggleState = true })

FarmBox:AddSlider("StopPercentSlider", {
    Text = "Stop at %",
    Min = 0,
    Max = 100,
    Default = 50,
    Rounding = 0,
    Compact = false,
    Callback = function(v) StopAt = v end
})

FarmBox:AddDivider()

getgenv().Height = -7
getgenv().Attach = false

FarmBox:AddToggle("AttachBackToggle", {
    Text = "Attach (Back)",
    Default = false,
    Callback = function(v)
        getgenv().Attach = v
        if getgenv().AttachConn then getgenv().AttachConn:Disconnect() end
        if not v then return end
        
        getgenv().AttachConn = RunService.Heartbeat:Connect(function()
            local char = LP.Character
            if not char or not getgenv().Attach then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local closest = getClosestAllowedMobHrp()
            if closest then
                local pos = closest.Position + closest.CFrame.LookVector * -2.5 + Vector3.new(0, getgenv().Height, 0)
                hrp.CFrame = CFrame.new(pos, closest.Position)
            end
        end)
    end
}):AddKeyPicker("AttachBind", { Default = "H", NoUI = false, Text = "Attach (Back)", SyncToggleState = true })

FarmBox:AddSlider("HeightOffsetSlider", {
    Text = "Height Offset",
    Min = -10,
    Max = 10,
    Default = -7,
    Rounding = 1,
    Compact = false,
    Callback = function(v) getgenv().Height = v end
})

--------------------------------------------------
-- NPC FILTER (SAĞ SÜTUN)
--------------------------------------------------
getgenv().NPCRange = 500
getgenv().SelectedNPCs = {}

NPCBox:AddSlider("ScanRangeSlider", {
    Text = "Scan Range",
    Min = 50,
    Max = 5000,
    Default = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(v) getgenv().NPCRange = v end
})

local npcDropdown = NPCBox:AddDropdown("TargetNPCDropdown", {
    Values = {"(Refresh first)"},
    Default = 1,
    Multi = true,
    Text = "Target NPCs",
    Callback = function(v) getgenv().SelectedNPCs = v end
})

function getClosestAllowedMobHrp()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mobs = workspace:FindFirstChild("Mobs")
    if not hrp or not mobs then return nil end

    local closest, dist = nil, math.huge
    for _, m in pairs(mobs:GetChildren()) do
        local mHrp = m:FindFirstChild("HumanoidRootPart")
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if mHrp and hum and hum.Health > 0 then
            local hasSelection = false
            for _ in pairs(getgenv().SelectedNPCs) do hasSelection = true break end
            
            if not hasSelection or getgenv().SelectedNPCs[m.Name] then
                local d = (hrp.Position - mHrp.Position).Magnitude
                if d <= getgenv().NPCRange and d < dist then
                    dist = d
                    closest = mHrp
                end
            end
        end
    end
    return closest
end

function getClosestAllowedMobFull()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mobs = workspace:FindFirstChild("Mobs")
    if not hrp or not mobs then return nil end

    local closest, dist = nil, math.huge
    for _, m in pairs(mobs:GetChildren()) do
        local mHrp = m:FindFirstChild("HumanoidRootPart")
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if mHrp and hum and hum.Health > 0 then
            local hasSelection = false
            for _ in pairs(getgenv().SelectedNPCs) do hasSelection = true break end
            
            if not hasSelection or getgenv().SelectedNPCs[m.Name] then
                local d = (hrp.Position - mHrp.Position).Magnitude
                if d <= getgenv().NPCRange and d < dist then
                    dist = d
                    closest = m
                end
            end
        end
    end
    return closest
end

NPCBox:AddButton({
    Text = "🔄 Refresh NPC List",
    Func = function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local mobs = workspace:FindFirstChild("Mobs")
        if not hrp or not mobs then return end

        local found = {}
        local nameSet = {}
        for _, m in pairs(mobs:GetChildren()) do
            local mHrp = m:FindFirstChild("HumanoidRootPart")
            if mHrp then
                local dist = (hrp.Position - mHrp.Position).Magnitude
                if dist <= getgenv().NPCRange and not nameSet[m.Name] then
                    nameSet[m.Name] = true
                    table.insert(found, m.Name)
                end
            end
        end

        if #found == 0 then Library:Notify("No NPCs found in range") return end
        table.sort(found)
        npcDropdown:SetValues(found)
        getgenv().SelectedNPCs = {}
    end
})

NPCBox:AddButton({
    Text = "Clear Selection",
    Func = function()
        getgenv().SelectedNPCs = {}
        npcDropdown:SetValues({"(Refresh first)"})
    end
})

--------------------------------------------------
-- AUTOMATION (SAĞ SÜTUN - ALT)
--------------------------------------------------
local UseEachRound = false
local UsedThisRound = false
local AutoProceed = false

local function click_ui(btn)
    if not btn or not btn.Visible then return end
    local x = btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2
    local y = btn.AbsolutePosition.Y + 105 
    VIM:SendMouseButtonEvent(x, y, 0, true, btn, 1)
    VIM:SendMouseButtonEvent(x, y, 0, false, btn, 1)
end

local function useRoundTool()
    if not getgenv().SelectedWeapon then return end
    local char = LP.Character
    local tool = LP.Backpack:FindFirstChild(getgenv().SelectedWeapon)
    if char and tool then char.Humanoid:EquipTool(tool) end
    task.wait(0.4)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    task.wait(0.5)
    if getgenv().CombatWeapon then 
        local cTool = LP.Backpack:FindFirstChild(getgenv().CombatWeapon)
        if char and cTool then char.Humanoid:EquipTool(cTool) end
    end
end

RunService.Heartbeat:Connect(function()
    if AutoProceed then
        local gui = LP:FindFirstChild("PlayerGui")
        if gui then
            pcall(function()
                local tr = gui:FindFirstChild("TrialResult")
                if tr and tr.Frame.Visible then click_ui(tr.Frame.Container.Back.Back.Button) end
                local tu = gui:FindFirstChild("TrialUI")
                if tu and tu.Frame.Visible then click_ui(tu.Frame.Container.Container.Right.Start.Button) end
            end)
        end
    end

    if UseEachRound then
        local mobs = workspace:FindFirstChild("Mobs")
        local alive = false
        if mobs then
            for _, m in pairs(mobs:GetChildren()) do
                if m:FindFirstChildWhichIsA("Humanoid") and m.Humanoid.Health > 0 then
                    alive = true
                    break
                end
            end
        end
        
        if alive and not UsedThisRound then
            UsedThisRound = true
            task.delay(5, function()
                if UseEachRound and UsedThisRound then useRoundTool() end
            end)
        elseif not alive then
             UsedThisRound = false
        end
    end
end)

AutoBox:AddToggle("UseToolEachRoundToggle", {
    Text = "Use Tool Each Round",
    Default = false,
    Callback = function(v) UseEachRound = v; UsedThisRound = false end
})

AutoBox:AddToggle("AutoProceedStageToggle", {
    Text = "Auto Proceed Stage",
    Default = false,
    Callback = function(v) AutoProceed = v end
}):AddKeyPicker("ProceedBind", { Default = "Z", NoUI = false, Text = "Auto Proceed Stage", SyncToggleState = true })

AutoBox:AddDivider()

--------------------------------------------------
-- SKILLS TAB (ROTASYON SİSTEMİ)
--------------------------------------------------
local MasterSkillList = {
    {Name = "Jinrai Kicks",      CD = 33,   Type = "Normal",   Style = "Karate"},
    {Name = "Controlled punch",  CD = 28,   Type = "Normal",   Style = "Karate"},
    {Name = "Roundhouse Kick",   CD = 28,   Type = "Normal",   Style = "Karate"},
    {Name = "Devil Strike",      CD = 50,   Type = "Ultimate", Style = "Karate"},
    {Name = "Tri-Jab",           CD = 13,   Type = "Normal",   Style = "Boxing"},
    {Name = "Gazelle Punch",     CD = 18,   Type = "Normal",   Style = "Boxing"},
    {Name = "Liver Blow",        CD = 23,   Type = "Normal",   Style = "Boxing"},
    {Name = "Gatling Knockout",  CD = 50,   Type = "Ultimate", Style = "Boxing"},
    {Name = "King's Horse",      CD = 33,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "540 Kick",          CD = 33,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "Jumping Roundhouse",CD = 28,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "Axe Rampage",       CD = 50,   Type = "Ultimate", Style = "Taekwondo"},
    {Name = "Cartwheel Kick",    CD = 23,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Flying Knee",       CD = 23,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Spinning Elbow",    CD = 27.9, Type = "Normal",   Style = "Muay Thai"},
    {Name = "Raging Flame",      CD = 60,   Type = "Ultimate", Style = "Muay Thai"},
    {Name = "Beast Launch",      CD = 20,   Type = "Normal",   Style = "Beast"},
    {Name = "Tiger Slam",        CD = 28,   Type = "Normal",   Style = "Beast"},
    {Name = "Ground Quake",      CD = 33,   Type = "Normal",   Style = "Beast"},
    {Name = "Pure Power",        CD = 60,   Type = "Ultimate", Style = "Beast"},
    {Name = "Blink",             CD = 15,   Type = "Normal",   Style = "Koei"},
    {Name = "Twin Rakashasa's",  CD = 25,   Type = "Normal",   Style = "Koei"},
    {Name = "Rakashasa's Sole",  CD = 22,   Type = "Normal",   Style = "Koei"},
    {Name = "Beautiful Beast",   CD = 60,   Type = "Ultimate", Style = "Koei"},
}

local SkillConfigBox = Tabs.Skills:AddLeftGroupbox("Skill Settings")
local StyleBoxes = {
    Karate = Tabs.Skills:AddLeftGroupbox("Karate"),
    Boxing = Tabs.Skills:AddRightGroupbox("Boxing"),
    Taekwondo = Tabs.Skills:AddLeftGroupbox("Taekwondo"),
    Muay Thai = Tabs.Skills:AddRightGroupbox("Muay Thai"),
    Beast = Tabs.Skills:AddLeftGroupbox("Beast"),
    Koei = Tabs.Skills:AddRightGroupbox("Koei"),
}

getgenv().SkillDelay = 6
getgenv().SkillInterval = 3
getgenv().AutoSkillActive = false

SkillConfigBox:AddSlider("SkillDelaySlider", {Text = "Start Delay", Min = 0, Max = 15, Default = 6, Rounding = 0, Callback = function(v) getgenv().SkillDelay = v end})
SkillConfigBox:AddSlider("SkillIntervalSlider", {Text = "Skill Interval", Min = 1, Max = 10, Default = 3, Rounding = 0, Callback = function(v) getgenv().SkillInterval = v end})

local DetectedSkills = {}
local SkillTimers = {}
local NormalCastCount = 0
local TotalNormalSkills = 0
local LastTarget = nil

local function ResetCooldowns()
    SkillTimers = {}
    NormalCastCount = 0
end

local function DetectOwnedSkills()
    DetectedSkills = {}
    TotalNormalSkills = 0
    Library:Notify("Scanning tools...")

    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return end

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            for _, skillData in pairs(MasterSkillList) do
                if tool.Name == skillData.Name then
                    table.insert(DetectedSkills, skillData)
                    if skillData.Type == "Normal" then
                        TotalNormalSkills = TotalNormalSkills + 1
                    end
                end
            end
        end
    end

    Library:Notify("Found " .. #DetectedSkills .. " skills!")

    for styleName, box in pairs(StyleBoxes) do
        box:AddLabel("--- Detected ---")
        for _, skill in pairs(DetectedSkills) do
            if skill.Style == styleName then
                local tag = skill.Type == "Ultimate" and " [ULT]" or " [N]"
                box:AddLabel("• " .. skill.Name .. " (" .. skill.CD .. "s)" .. tag)
            end
        end
    end
end

SkillConfigBox:AddButton({Text = "1. Detect Owned Skills", Func = DetectOwnedSkills})

local function CanUseSkill(skillData)
    local lastUsed = SkillTimers[skillData.Name] or 0
    return tick() - lastUsed >= skillData.CD
end

local function CastSkill(skillData)
    local char = LP.Character
    if not char then return false end
    local backpack = LP.Backpack
    local tool = backpack:FindFirstChild(skillData.Name)
    if not tool then return false end

    char.Humanoid:EquipTool(tool)
    task.wait(0.15)
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    task.wait(0.05)
    if getgenv().CombatWeapon then
        local cTool = backpack:FindFirstChild(getgenv().CombatWeapon)
        if cTool then char.Humanoid:EquipTool(cTool) end
    end

    SkillTimers[skillData.Name] = tick()
    return true
end

AutoBox:AddToggle("AutoSkillMasterToggle", {
    Text = "Start Smart Rotation",
    Default = false,
    Callback = function(v)
        getgenv().AutoSkillActive = v
        if not v then return end
        
        task.spawn(function()
            task.wait(getgenv().SkillDelay)
            while getgenv().AutoSkillActive do
                local currentTarget = getClosestAllowedMobFull()
                if not currentTarget then
                    task.wait(1)
                else
                    if LastTarget ~= currentTarget then
                        ResetCooldowns()
                        LastTarget = currentTarget
                    end
                    
                    local skillToUse = nil
                    local foundReadySkill = false
                    
                    for _, skill in pairs(DetectedSkills) do
                        if skill.Type == "Normal" then
                            if CanUseSkill(skill) then
                                skillToUse = skill
                                foundReadySkill = true
                                break
                            end
                        end
                    end
                    
                    if not foundReadySkill and TotalNormalSkills > 0 then
                        if NormalCastCount >= TotalNormalSkills then
                            for _, skill in pairs(DetectedSkills) do
                                if skill.Type == "Ultimate" then
                                    if CanUseSkill(skill) then
                                        skillToUse = skill
                                        NormalCastCount = 0 
                                        break
                                    end
                                end
                            end
                        end
                    end
                    
                    if skillToUse then
                        if CastSkill(skillToUse) then
                            if skillToUse.Type == "Normal" then
                                NormalCastCount = NormalCastCount + 1
                            end
                            task.wait(getgenv().SkillInterval)
                        else
                            task.wait(0.5)
                        end
                    else
                        task.wait(1)
                    end
                end
            end
        end)
    end
}):AddKeyPicker("SkillBind", { Default = "T", NoUI = false, Text = "Start Smart Rotation", SyncToggleState = true })

--------------------------------------------------
-- UI SETTINGS & MANAGERS
--------------------------------------------------
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu Settings")

MenuGroup:AddDropdown("DPIDropdown", {
    Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
    Default = "100%",
    Text = "DPI Scale",
    Callback = function(Value)
        Value = Value:gsub("%%", "")
        local DPI = tonumber(Value)
        Library:SetDPIScale(DPI)
    end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind", ChangedCallback = function(New) Library.ToggleKeybind = New end})

MenuGroup:AddButton("Unload Script", function() Library:Unload() end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("GofretSystem/AslanlarHub")
SaveManager:SetFolder("GofretSystem/AslanlarHub/" .. game.Name)
SaveManager:SetSubFolder(game.Name)

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

Library.ToggleKeybind = Enum.KeyCode.RightShift
