getgenv().SHAMPO = true
if game.GameId ~= 4652005960 then return end

local repo = "https://raw.githubusercontent.com/mirayukiasura-alt/Aslanlar/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer

local Window = Library:CreateWindow({
    Title = "AslanlarHUB ◆ Premium Edition",
    Footer = "FREE MIRA | UNBAN MIRA YUKI",
})

local Tabs = {
    Main = Window:AddTab("Main", "Main"),
    Skills = Window:AddTab("Skills", "bolt"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local FarmBox = Tabs.Main:AddLeftGroupbox("Combat Tools")
local AutoBox = Tabs.Main:AddRightGroupbox("Automation")
local NPCBox = Tabs.Main:AddLeftGroupbox("Target Filter")

FarmBox:AddLabel("⚠️ UNBAN MIRA YUKI ⚠️", true)
FarmBox:AddLabel("📢 FREE MIRA 📢", true)
FarmBox:AddDivider()

--------------------------------------------------
-- NPC FILTER SYSTEM
--------------------------------------------------
getgenv().NPCRange = 500
getgenv().SelectedNPCs = {}

NPCBox:AddSlider("NPCRangeSlider", {
    Text = "Scan Range",
    Min = 50,
    Max = 5000,
    Default = 500,
    Callback = function(v) getgenv().NPCRange = v end
})

local npcDropdown = NPCBox:AddDropdown("NPCSelector", {
    Values = {"Refresh list first"},
    Text = "Select Targets",
    Multi = true,
    Callback = function(v) getgenv().SelectedNPCs = v end
})

NPCBox:AddButton("Refresh NPC List", function()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mobs = workspace:FindFirstChild("Mobs")
    if not hrp or not mobs then return end

    local found = {}
    local nameSet = {}
    for _, m in pairs(mobs:GetChildren()) do
        local mHrp = m:FindFirstChild("HumanoidRootPart")
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if mHrp and hum and hum.Health > 0 then
            local dist = (hrp.Position - mHrp.Position).Magnitude
            if dist <= getgenv().NPCRange and not nameSet[m.Name] then
                nameSet[m.Name] = true
                table.insert(found, m.Name)
            end
        end
    end

    if #found == 0 then Library:Notify("System", "No NPCs found in range") return end
    table.sort(found)
    npcDropdown:SetValues(found)
    getgenv().SelectedNPCs = {}
    Library:Notify("System", "NPC list updated")
end)

NPCBox:AddButton("Clear Selection", function()
    getgenv().SelectedNPCs = {}
    npcDropdown:SetValues({"Refresh list first"})
    Library:Notify("System", "Selection cleared")
end)

local function isNPCAllowed(mob)
    local hasSelection = false
    for _ in pairs(getgenv().SelectedNPCs) do hasSelection = true break end
    if not hasSelection then return true end
    return getgenv().SelectedNPCs[mob.Name] == true
end

local function getClosestAllowedMobHrp()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mobs = workspace:FindFirstChild("Mobs")
    if not hrp or not mobs then return nil end

    local closest, dist = nil, math.huge
    for _, m in pairs(mobs:GetChildren()) do
        local mHrp = m:FindFirstChild("HumanoidRootPart")
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if mHrp and hum and hum.Health > 0 and isNPCAllowed(m) then
            local d = (hrp.Position - mHrp.Position).Magnitude
            if d <= getgenv().NPCRange and d < dist then
                dist = d
                closest = mHrp
            end
        end
    end
    return closest
end

local function getClosestAllowedMobFull()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local mobs = workspace:FindFirstChild("Mobs")
    if not hrp or not mobs then return nil end

    local closest, dist = nil, math.huge
    for _, m in pairs(mobs:GetChildren()) do
        local mHrp = m:FindFirstChild("HumanoidRootPart")
        local hum = m:FindFirstChildWhichIsA("Humanoid")
        if mHrp and hum and hum.Health > 0 and isNPCAllowed(m) then
            local d = (hrp.Position - mHrp.Position).Magnitude
            if d <= getgenv().NPCRange and d < dist then
                dist = d
                closest = m
            end
        end
    end
    return closest
end

--------------------------------------------------
-- TOOL SYSTEM
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

local toolDrop = FarmBox:AddDropdown("RoundTool", {
    Values = fetchTools(),
    Text = "Mode Tool",
    Callback = function(v) getgenv().SelectedWeapon = v end
})

local combatDrop = FarmBox:AddDropdown("CombatTool", {
    Values = fetchTools(),
    Text = "Main Combat Tool",
    Callback = function(v) getgenv().CombatWeapon = v end
})

FarmBox:AddButton("Refresh Tools", function()
    local tools = fetchTools()
    toolDrop:SetValues(tools)
    combatDrop:SetValues(tools)
end)

--------------------------------------------------
-- SMART AUTO HIT
--------------------------------------------------
local AutoHit = false
local StopAt = 50
getgenv().Height = -6.5
getgenv().Attach = false

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

FarmBox:AddToggle("AutoHit", {Text = "Auto Clicker", Default = false, Callback = function(v) AutoHit = v end}):AddKeyPicker("AutoHitBind", {Default = "G", NoUI = false, Text = "Auto Hit", SyncToggleState = true})

FarmBox:AddSlider("StopPercent", {
    Text = "Stop When Stamina below %", 
    Min = 0, 
    Max = 100, 
    Default = 50, 
    Callback = function(v) StopAt = v end
})

--------------------------------------------------
-- TELEPORT ATTACH
--------------------------------------------------
local AttachToggle = FarmBox:AddToggle("Attach", {
    Text = "Teleport Behind NPC",
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
})
AttachToggle:AddKeyPicker("AttachBind", {Default = "H", NoUI = false, Text = "Teleport Attach", SyncToggleState = true})
FarmBox:AddSlider("HeightVal", {Text = "Height Offset", Min = -10, Max = 10, Default = -6.5, Callback = function(v) getgenv().Height = v end})

--------------------------------------------------
-- AUTOMATION MANTIKLARI
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

AutoBox:AddToggle("RoundToggle", {Text = "Auto Buff Every Round", Default = false, Callback = function(v) UseEachRound = v; UsedThisRound = false end})

local ProceedToggle = AutoBox:AddToggle("AutoProceed", {Text = "Auto Next Stage", Default = false, Callback = function(v) AutoProceed = v end})
ProceedToggle:AddKeyPicker("ProceedBind", {Default = "Z", NoUI = false, Text = "Auto Next Stage", SyncToggleState = true})

--------------------------------------------------
-- SKILL DATABASE
--------------------------------------------------
local MasterSkillList = {
    {Name = "Jinrai Kicks",      CD = 33,   Type = "Normal",   Style = "Karate"},
    {Name = "Controlled punch",  CD = 28,   Type = "Normal",   Style = "Karate"},
    {Name = "Roundhouse Kick",   CD = 28,   Type = "Normal",   Style = "Karate"},
    {Name = "Side kick",         CD = 23,   Type = "Normal",   Style = "Karate"},
    {Name = "High kick",         CD = 22.9, Type = "Normal",   Style = "Karate"},
    {Name = "Devil Strike",      CD = 50,   Type = "Ultimate", Style = "Karate"},
    {Name = "Tri-Jab",           CD = 13,   Type = "Normal",   Style = "Boxing"},
    {Name = "Gazelle Punch",     CD = 18,   Type = "Normal",   Style = "Boxing"},
    {Name = "Liver Blow",        CD = 23,   Type = "Normal",   Style = "Boxing"},
    {Name = "White Fang",        CD = 23,   Type = "Normal",   Style = "Boxing"},
    {Name = "Corkscrew",         CD = 17.9, Type = "Normal",   Style = "Boxing"},
    {Name = "Gatling Knockout",  CD = 50,   Type = "Ultimate", Style = "Boxing"},
    {Name = "King's Horse",      CD = 33,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "540 Kick",          CD = 33,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "Slam Dunk",         CD = 43,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "Jumping Roundhouse",CD = 28,   Type = "Normal",   Style = "Taekwondo"},
    {Name = "Temple Hook Kick",  CD = 27.8, Type = "Normal",   Style = "Taekwondo"},
    {Name = "Axe Rampage",       CD = 50,   Type = "Ultimate", Style = "Taekwondo"},
    {Name = "Roundabout",        CD = 22,   Type = "Normal",   Style = "Capoeira"},
    {Name = "Drill Kick",        CD = 28,   Type = "Normal",   Style = "Capoeira"},
    {Name = "Rolling Axe",       CD = 16,   Type = "Normal",   Style = "Capoeira"},
    {Name = "Crouching Roundhouse", CD = 21, Type = "Normal",  Style = "Capoeira"},
    {Name = "Sweeping Round Hook", CD = 28, Type = "Normal",   Style = "Capoeira"},
    {Name = "Tinta Tempo",       CD = 50,   Type = "Ultimate", Style = "Capoeira"},
    {Name = "Lariat Counter",    CD = 26,   Type = "Normal",   Style = "Judo"},
    {Name = "Sweep Takedown",    CD = 18,   Type = "Normal",   Style = "Judo"},
    {Name = "Lotus Crash",       CD = 17.2, Type = "Normal",   Style = "Judo"},
    {Name = "Shoulder Throw",    CD = 27.2, Type = "Normal",   Style = "Judo"},
    {Name = "Demon Grip",        CD = 50,   Type = "Ultimate", Style = "Judo"},
    {Name = "Dragon Kick",       CD = 27.9, Type = "Normal",   Style = "Kung Fu"},
    {Name = "Tiger Hunt",        CD = 28,   Type = "Normal",   Style = "Kung Fu"},
    {Name = "Fajin",             CD = 28,   Type = "Normal",   Style = "Kung Fu"},
    {Name = "Shadowless Kick",   CD = 22.9, Type = "Normal",   Style = "Kung Fu"},
    {Name = "Palm Strike",       CD = 25,   Type = "Normal",   Style = "Kung Fu"},
    {Name = "1000 Deaths",       CD = 60,   Type = "Ultimate", Style = "Kung Fu"},
    {Name = "Cartwheel Kick",    CD = 23,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Hammer of Burma",   CD = 28,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Flying Knee",       CD = 23,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Spinning Elbow",    CD = 27.9, Type = "Normal",   Style = "Muay Thai"},
    {Name = "Falling Elbow",     CD = 23,   Type = "Normal",   Style = "Muay Thai"},
    {Name = "Raging Flame",      CD = 60,   Type = "Ultimate", Style = "Muay Thai"},
    {Name = "Dropkick",          CD = 18,   Type = "Normal",   Style = "Wrestling"},
    {Name = "Flash Suplex",      CD = 22,   Type = "Normal",   Style = "Wrestling"},
    {Name = "Back Breaker",      CD = 28,   Type = "Normal",   Style = "Wrestling"},
    {Name = "Head Smasher",      CD = 15,   Type = "Normal",   Style = "Wrestling"},
    {Name = "Spinning Lariat",   CD = 25,   Type = "Normal",   Style = "Wrestling"},
    {Name = "Unstoppable Force", CD = 60,   Type = "Ultimate", Style = "Wrestling"},
    {Name = "Hundred Palms",     CD = 16,   Type = "Normal",   Style = "Sumo"},
    {Name = "Yaguranage",        CD = 28,   Type = "Normal",   Style = "Sumo"},
    {Name = "Sumo Rush",         CD = 20,   Type = "Normal",   Style = "Sumo"},
    {Name = "Body Slam",         CD = 23,   Type = "Normal",   Style = "Sumo"},
    {Name = "Bear Hug",          CD = 30,   Type = "Normal",   Style = "Sumo"},
    {Name = "Haymaker",          CD = 60,   Type = "Ultimate", Style = "Sumo"},
    {Name = "Beast Launch",      CD = 20,   Type = "Normal",   Style = "Beast"},
    {Name = "Tiger Slam",        CD = 28,   Type = "Normal",   Style = "Beast"},
    {Name = "Ground Quake",      CD = 33,   Type = "Normal",   Style = "Beast"},
    {Name = "Beast Claw",        CD = 18,   Type = "Normal",   Style = "Beast"},
    {Name = "Pure Power",        CD = 60,   Type = "Ultimate", Style = "Beast"},
    {Name = "Blink",             CD = 15,   Type = "Normal",   Style = "Koei"},
    {Name = "Twin Rakashasa's",  CD = 25,   Type = "Normal",   Style = "Koei"},
    {Name = "Rakashasa's Sole",  CD = 22,   Type = "Normal",   Style = "Koei"},
    {Name = "Beautiful Beast",   CD = 60,   Type = "Ultimate", Style = "Koei"},
}

local StyleNames = {"Karate", "Boxing", "Taekwondo", "Capoeira", "Judo", "Kung Fu", "Muay Thai", "Wrestling", "Sumo", "Beast", "Koei"}
local SkillSettings = Tabs.Skills:AddLeftGroupbox("Skill Config")

local StyleBoxes = {}
for i, styleName in ipairs(StyleNames) do
    if i <= 6 then
        StyleBoxes[styleName] = Tabs.Skills:AddRightGroupbox(styleName)
    else
        StyleBoxes[styleName] = Tabs.Skills:AddLeftGroupbox(styleName)
    end
    StyleBoxes[styleName]:AddLabel("Waiting detection...", true)
end

getgenv().SkillDelay = 6
getgenv().SkillInterval = 3
getgenv().AutoSkillActive = false

SkillSettings:AddSlider("SkillDelaySlider", {Text = "Initial Delay (s)", Min = 0, Max = 15, Default = 6, Callback = function(v) getgenv().SkillDelay = v end})
SkillSettings:AddSlider("SkillIntervalSlider", {Text = "Cast Interval (s)", Min = 1, Max = 10, Default = 3, Callback = function(v) getgenv().SkillInterval = v end})

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
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return end
    
    DetectedSkills = {}
    TotalNormalSkills = 0
    Library:Notify("System", "Scanning tools")

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

    Library:Notify("System", "Found " .. #DetectedSkills .. " skills")

    for styleName, box in pairs(StyleBoxes) do
        box:AddLabel("--- Found ---", true)
        for _, skill in pairs(DetectedSkills) do
            if skill.Style == styleName then
                local tag = skill.Type == "Ultimate" and " [ULT]" or ""
                box:AddLabel(skill.Name .. " (" .. skill.CD .. "s)" .. tag, false)
            end
        end
    end
end

SkillSettings:AddButton("Detect Skills", DetectOwnedSkills)

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

local SkillToggle = AutoBox:AddToggle("AutoSkillMaster", {
    Text = "Skill Rotation",
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
})
SkillToggle:AddKeyPicker("SkillBind", {Default = "T", NoUI = false, Text = "Skill Rotation", SyncToggleState = true})

--------------------------------------------------
-- UI SETTINGS
--------------------------------------------------
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu Settings")
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind", ChangedCallback = function(New) Library.ToggleKeybind = New end})
MenuGroup:AddButton("Unload Script", function() Library:Unload() end)

Library.ToggleKeybind = Enum.KeyCode.RightShift
Library:Toggle()
