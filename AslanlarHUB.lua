getgenv().ASURA = true 
if game.GameId == 4652005960 and getgenv().ASURA == true then 

    -- Kütüphaneler tamamen senin kendi public depondan çekiliyor
    local repo = "https://raw.githubusercontent.com/mirayukiasura-alt/Aslanlar/main/"
    local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
    local ThemeManager = loadstring(game:HttpGet(repo .. "ThemeManager.lua"))()
    local SaveManager = loadstring(game:HttpGet(repo .. "SaveManager.lua"))()

    local Options = Library.Options
    local Toggles = Library.Toggles

    local Window = Library:CreateWindow({
        Title = "Aslanlar HUB",
        Footer = "Gofret Macro System",
        NotifySide = "Right",
        ShowCustomCursor = false,
    })

    local Tabs = {
        Main = Window:AddTab("Main", "Main", "Player"),
        ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
    }
    local FarmBox = Tabs.Main:AddLeftGroupbox("MAIN CONTROL")

getgenv().tool_table = {}
getgenv().SelectedWeapon = nil
getgenv().SelectedMode = nil
getgenv().Equip = false
getgenv().AutoMode = false
getgenv().ModeCooldown = 5

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getChar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function fetchTools()
    getgenv().tool_table = {}
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(getgenv().tool_table, tool.Name)
        end
    end
end

fetchTools()

local uiElemsToolToEquip = FarmBox:AddDropdown("SelectTool", {
    Values  = getgenv().tool_table,
    Default = getgenv().tool_table[1] or "",
    Text    = "Select Tool",
    Callback = function(value)
        getgenv().SelectedWeapon = value
    end
})

local uiElemsModeToUse = FarmBox:AddDropdown("SelectMode", {
    Values  = getgenv().tool_table,
    Default = getgenv().tool_table[1] or "",
    Text    = "Select Mode To Use",
    Callback = function(value)
        getgenv().SelectedMode = value
    end
})

FarmBox:AddToggle("AutoEquipTool", {
    Text = "Auto Equip Tool",
    Default = false,
    Callback = function(state)
        getgenv().Equip = state
        
        if state then
            task.spawn(function()
                while getgenv().Equip do
                    pcall(function()
                        if getgenv().SelectedWeapon then
                            local char = getChar()
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            
                            if not humanoid then return end
                            
                            local equippedTool = char:FindFirstChildOfClass("Tool")
                            local isEquipped = equippedTool and equippedTool.Name == getgenv().SelectedWeapon
                            
                            if not isEquipped then
                                local tool = LocalPlayer.Backpack:FindFirstChild(getgenv().SelectedWeapon)
                                if tool then
                                    humanoid:EquipTool(tool)
                                end
                            end
                        end
                    end)
                    
                    task.wait(5)
                end
            end)
        end
    end
})

FarmBox:AddToggle("AutoActivateMode", {
    Text = "Auto Activate Mode",
    Default = false,
    Callback = function(state)
        getgenv().AutoMode = state
        
        if state then
            task.spawn(function()
                while getgenv().AutoMode do
                    pcall(function()
                        if getgenv().SelectedMode then
                            local char = getChar()
                            local humanoid = char:FindFirstChildOfClass("Humanoid")
                            
                            if not humanoid then return end
                            
                            local equippedTool = char:FindFirstChildOfClass("Tool")
                            local isModeEquipped = equippedTool and equippedTool.Name == getgenv().SelectedMode
                            
                            if not isModeEquipped then
                                local modeTool = LocalPlayer.Backpack:FindFirstChild(getgenv().SelectedMode)
                                if modeTool then
                                    humanoid:EquipTool(modeTool)
                                    task.wait(0.3)
                                end
                            end
                            
                            equippedTool = char:FindFirstChildOfClass("Tool")
                            if equippedTool and equippedTool.Name == getgenv().SelectedMode then
                                equippedTool:Activate()
                            end
                        end
                    end)
                    
                    task.wait(getgenv().ModeCooldown)
                end
            end)
        end
    end
})

FarmBox:AddSlider("ModeCooldown", {
    Text = "Amount Of Seconds Before Mode Reactivate",
    Min = 0.1,
    Max = 100,
    Default = 5,
    Rounding = 1,
    Callback = function(value)
        getgenv().ModeCooldown = value
    end
})

FarmBox:AddButton({
    Text = "Refresh Tools",
    Tooltip = "Click to refresh the tools in the tool selector dropdown",
    Func = function()
        fetchTools()
        uiElemsToolToEquip:SetValues(getgenv().tool_table)
        uiElemsModeToUse:SetValues(getgenv().tool_table)
    end
})

FarmBox:AddSlider("HEIGHTOFFSET", {
	Text = "HEIGHT OFFSET",
	Min = -20,
	Max = 20,
	Default = -6.5,
	Rounding = 0,
	Callback = function(v)
		DISTANCEHEIGHT = v
	end
})

FarmBox:AddToggle("AttachToBack", {
	Text = "Attach To Back",
	Default = false,
	Callback = function(v)
		getgenv().AttachToBack = v

		local Players = game:GetService("Players")
		local RunService = game:GetService("RunService")

		local lp = Players.LocalPlayer
		local char = lp.Character or lp.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")

		if getgenv().AttachConn then
			getgenv().AttachConn:Disconnect()
			getgenv().AttachConn = nil
		end

		if getgenv().CharConn then
			getgenv().CharConn:Disconnect()
			getgenv().CharConn = nil
		end

		if not v then return end

		getgenv().CharConn = lp.CharacterAdded:Connect(function(newChar)
			char = newChar
			hrp = newChar:WaitForChild("HumanoidRootPart")
		end)

		local function getClosestMob()
			local closest, dist = nil, math.huge

			for _, mob in ipairs(workspace.Mobs:GetChildren()) do
				if mob:IsA("Model") then
					local mobHRP = mob:FindFirstChild("HumanoidRootPart")
					local hum = mob:FindFirstChildWhichIsA("Humanoid")

					if mobHRP and hum and hum.Health > 0 then
						local d = (hrp.Position - mobHRP.Position).Magnitude
						if d < dist then
							dist = d
							closest = mobHRP
						end
					end
				end
			end

			return closest
		end

		getgenv().AttachConn = RunService.Heartbeat:Connect(function()
			if not getgenv().AttachToBack then return end
			if not hrp or not hrp.Parent then return end

			local targetHRP = getClosestMob()
			if not targetHRP then return end

			local behindOffset = targetHRP.CFrame.LookVector * -3
			local downOffset = Vector3.new(0, DISTANCEHEIGHT or -3, 0)

			local finalPos = targetHRP.Position + behindOffset + downOffset

			hrp.CFrame = CFrame.new(finalPos, targetHRP.Position)
		end)
	end
})

local RunService = game:GetService("RunService")
local AutoProceedConnection
local Players = game:GetService("Players") 
local VirtualInputManager = game:GetService("VirtualInputManager") 
local lp = Players.LocalPlayer 
local AutoProceedEnabled = false 

local function click_button1(button) 
    if not button then return end 
    for _, yOffset in ipairs({100, 90, 50}) do 
        local x = button.AbsolutePosition.X + button.AbsoluteSize.X / 2 
        local y = button.AbsolutePosition.Y + yOffset 
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, button, 1) 
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, button, 1) 
    end 
end

local function AutoProceedLoop()
	if AutoProceedConnection then
		AutoProceedConnection:Disconnect()
	end

	AutoProceedConnection = RunService.Heartbeat:Connect(function()
		if not AutoProceedEnabled then return end
        local lp = game.Players.LocalPlayer 
		local gui = lp:FindFirstChild("PlayerGui")
		if not gui then return end

		local trialResult = gui:FindFirstChild("TrialResult")
		if trialResult and trialResult:FindFirstChild("Frame") and trialResult.Frame.Visible then
			local backButton = trialResult.Frame.Container.Back.Back.Button
			click_button1(backButton)
		end

		local trialUI = gui:FindFirstChild("TrialUI")
		if trialUI and trialUI:FindFirstChild("Frame") then
			local startButton = trialUI.Frame.Container.Container.Right.Start.Button
			if startButton and startButton.Visible then
				click_button1(startButton)
			end
		end
	end)
end

FarmBox:AddToggle("AutoProceedStage", {
	Text = "Auto Proceed To Next Stage",
	Default = false,
	Callback = function(v)
		AutoProceedEnabled = v

		if v then
			AutoProceedLoop()
		else
			if AutoProceedConnection then
				AutoProceedConnection:Disconnect()
				AutoProceedConnection = nil
			end
		end
	end
})

local AutoHitEnabled = false
local WaitSeconds = 2 

local function ClickMouse()
	VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
	task.wait(0.05)
	VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,0)
end

local function AutoHitLoop()
	while AutoHitEnabled do
		pcall(function()
			ClickMouse()
			wait(.5)
			ClickMouse()
			wait(.5)
			ClickMouse()
			wait(.5)
			ClickMouse()
			wait(.5)
			ClickMouse()
		end)
		task.wait(WaitSeconds)
	end
end

FarmBox:AddToggle("AutoHit", {
	Text = "Auto Hit",
	Default = false,
	Callback = function(v)
		AutoHitEnabled = v
		if v then
			task.spawn(AutoHitLoop)
		end
	end
})

FarmBox:AddSlider("AutoHitWait", {
	Text = "Wait Seconds",
	Min = 0.1,
	Max = 15,
	Default = 2,
	Rounding = 1,
	Callback = function(v)
		WaitSeconds = v
	end
})

    local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

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

    MenuGroup:AddButton("Unload", function()
        Library:Unload()
    end)

    Library.ToggleKeybind = Enum.KeyCode["RightShift"]

	ThemeManager:SetLibrary(Library)
	SaveManager:SetLibrary(Library)

	SaveManager:IgnoreThemeSettings()
	SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

	ThemeManager:SetFolder("GofretSystem/AslanlarHub")
	SaveManager:SetFolder("GofretSystem/AslanlarHub/"..game.Name)
	SaveManager:SetSubFolder(game.Name) 

	SaveManager:BuildConfigSection(Tabs["UI Settings"])
	ThemeManager:ApplyToTab(Tabs["UI Settings"])
	ThemeManager:ApplyTheme("Default")

	SaveManager:LoadAutoloadConfig()
    Library:Toggle(false);
end
