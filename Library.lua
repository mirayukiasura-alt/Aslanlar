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

    ToggleKeybind = Enum.KeyCode.RightShift, -- Menü varsayılan olarak RightShift yapıldı
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
    
    -- ASLANLARHUB PREMIUM MOR TASARIM RENKLERİ ENJEKTE EDİLDİ
    Scheme = {
        BackgroundColor = Color3.fromRGB(15, 13, 20), -- --bg0 (Arka Plan)
        MainColor = Color3.fromRGB(26, 22, 37),       -- --bg1 (Pencereler)
        AccentColor = Color3.fromRGB(108, 92, 231),   -- --pur1 (Neon Mor Vurgu)
        OutlineColor = Color3.fromRGB(61, 56, 80),    -- --gry1 (Kenarlıklar)
        FontColor = Color3.fromRGB(232, 228, 244),   -- --txt1 (Yazı Rengi)
        Font = Font.fromEnum(Enum.Font.Code),

        Red = Color3.fromRGB(255, 50, 50),
        Dark = Color3.new(0, 0, 0),
        White = Color3.new(1, 1, 1),
    },

    Registry = {},
    DPIRegistry = {},
}

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

local Lucide = {
    ["bolt"] = "rbxassetid://10723344302",
    ["settings"] = "rbxassetid://10723346438",
    ["home"] = "rbxassetid://10723346914",
}

function Library:CreateWindow(Config)
    Config = Config or {}
    local Window = {
        Title = Config.Title or "UI Library",
        Footer = Config.Footer or "Footer",
        Tabs = {},
    }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AslanlarHubUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    Library.ScreenGui = ScreenGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
    MainFrame.BackgroundColor3 = Library.Scheme.BackgroundColor
    MainFrame.BorderColor3 = Library.Scheme.OutlineColor
    MainFrame.BorderSizePixel = 1
    MainFrame.Parent = ScreenGui

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Library.Scheme.MainColor
    TopBar.BorderColor3 = Library.Scheme.OutlineColor
    TopBar.BorderSizePixel = 1
    TopBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Text = Window.Title
    TitleLabel.TextColor3 = Library.Scheme.FontColor
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 16
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = TopBar

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -35)
    TabContainer.Position = UDim2.new(0, 0, 0, 35)
    TabContainer.BackgroundColor3 = Library.Scheme.MainColor
    TabContainer.BorderColor3 = Library.Scheme.OutlineColor
    TabContainer.BorderSizePixel = 1
    TabContainer.Parent = MainFrame

    local TabUIList = Instance.new("UIListLayout")
    TabUIList.SortOrder = Enum.SortOrder.LayoutOrder
    TabUIList.Padding = UDim.new(0, 2)
    TabUIList.Parent = TabContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -120, 1, -35)
    ContentContainer.Position = UDim2.new(0, 120, 0, 35)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    function Window:AddTab(Name, IconName)
        local Tab = { Name = Name, Elements = {} }
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name .. "Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundColor3 = Library.Scheme.MainColor
        TabButton.Text = "  " .. Name
        TabButton.TextColor3 = Library.Scheme.FontColor
        TabButton.Font = Enum.Font.Code
        TabButton.TextSize = 14
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabContainer

        if IconName and Lucide[IconName] then
            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(1, -22, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Image = Lucide[IconName]
            Icon.ImageColor3 = Library.Scheme.AccentColor
            Icon.Parent = TabButton
        end

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = Name .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 4
        TabPage.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent = TabPage

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(ContentContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in pairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") then btn.BackgroundColor3 = Library.Scheme.MainColor end
            end
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Library.Scheme.BackgroundColor
        end)

        if #TabContainer:GetChildren() == 2 then
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Library.Scheme.BackgroundColor
        end

        function Tab:AddLeftGroupbox(Title)
            local Box = Instance.new("Frame")
            Box.Name = Title .. "Box"
            Box.Size = UDim2.new(1, -10, 0, 0)
            Box.BackgroundColor3 = Library.Scheme.MainColor
            Box.BorderColor3 = Library.Scheme.OutlineColor
            Box.BorderSizePixel = 1
            Box.Parent = TabPage

            local BoxPadding = Instance.new("UIPadding")
            BoxPadding.PaddingLeft = UDim.new(0, 8)
            BoxPadding.PaddingRight = UDim.new(0, 8)
            BoxPadding.PaddingTop = UDim.new(0, 8)
            BoxPadding.PaddingBottom = UDim.new(0, 8)
            BoxPadding.Parent = Box

            local BoxLayout = Instance.new("UIListLayout")
            BoxLayout.SortOrder = Enum.SortOrder.LayoutOrder
            BoxLayout.Padding = UDim.new(0, 6)
            BoxLayout.Parent = Box

            local BoxTitle = Instance.new("TextLabel")
            BoxTitle.Text = Title:upper()
            BoxTitle.Font = Enum.Font.Code
            BoxTitle.TextSize = 12
            BoxTitle.TextColor3 = Library.Scheme.AccentColor
            BoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            BoxTitle.Size = UDim2.new(1, 0, 0, 15)
            BoxTitle.BackgroundTransparency = 1
            BoxTitle.Parent = Box

            BoxLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Box.Size = UDim2.new(1, -10, 0, BoxLayout.AbsoluteContentSize.Y + 16)
            end)

            local Group = {}
            
            function Group:AddLabel(Text, Center)
                local Label = Instance.new("TextLabel")
                Label.Text = Text
                Label.Font = Enum.Font.Code
                Label.TextSize = 13
                Label.TextColor3 = Library.Scheme.FontColor
                Label.TextXAlignment = Center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.BackgroundTransparency = 1
                Label.Parent = Box
                return Label
            end

            function Group:AddDivider()
                local Div = Instance.new("Frame")
                Div.Size = UDim2.new(1, 0, 0, 1)
                Div.BackgroundColor3 = Library.Scheme.OutlineColor
                Div.BorderSizePixel = 0
                Div.Parent = Box
            end

            function Group:AddToggle(Name, Config)
                local Toggle = { Value = Config.Default or false }
                
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 20)
                Btn.BackgroundTransparency = 1
                Btn.Text = ""
                Btn.Parent = Box

                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 12, 0, 12)
                Indicator.Position = UDim2.new(0, 0, 0.5, -6)
                Indicator.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor
                Indicator.BorderColor3 = Library.Scheme.OutlineColor
                Indicator.Parent = Btn

                local Txt = Instance.new("TextLabel")
                Txt.Text = Config.Text or Name
                Txt.Font = Enum.Font.Code
                Txt.TextSize = 13
                Txt.TextColor3 = Library.Scheme.FontColor
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.Position = UDim2.new(0, 20, 0, 0)
                Txt.Size = UDim2.new(1, -20, 1, 0)
                Txt.BackgroundTransparency = 1
                Txt.Parent = Btn

                local function Update()
                    Indicator.BackgroundColor3 = Toggle.Value and Library.Scheme.AccentColor or Library.Scheme.BackgroundColor
                    Library:SafeCallback(Config.Callback, Toggle.Value)
                end

                Btn.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    Update()
                end)

                function Toggle:SetState(State)
                    Toggle.Value = State
                    Update()
                end

                function Toggle:AddKeyPicker(BindName, PickerConfig)
                    local Key = PickerConfig.Default or "None"
                    local KeyLabel = Instance.new("TextLabel")
                    KeyLabel.Text = "[" .. Key .. "]"
                    KeyLabel.Font = Enum.Font.Code
                    KeyLabel.TextSize = 12
                    KeyLabel.TextColor3 = Library.Scheme.AccentColor
                    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
                    KeyLabel.Size = UDim2.new(1, 0, 1, 0)
                    KeyLabel.BackgroundTransparency = 1
                    KeyLabel.Parent = Btn

                    Library:GiveSignal(UserInputService.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.KeyCode.Name == Key then
                            if PickerConfig.SyncToggleState then
                                Toggle.Value = not Toggle.Value
                                Update()
                            else
                                Library:SafeCallback(PickerConfig.Callback)
                            end
                        end
                    end))
                end

                return Toggle
            end

            function Group:AddSlider(Name, Config)
                local Slider = { Value = Config.Default or Config.Min }
                
                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, 30)
                Container.BackgroundTransparency = 1
                Container.Parent = Box

                local Txt = Instance.new("TextLabel")
                Txt.Text = Config.Text or Name
                Txt.Font = Enum.Font.Code
                Txt.TextSize = 13
                Txt.TextColor3 = Library.Scheme.FontColor
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.Size = UDim2.new(1, 0, 0, 15)
                Txt.BackgroundTransparency = 1
                Txt.Parent = Container

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Text = tostring(Slider.Value)
                ValLabel.Font = Enum.Font.Code
                ValLabel.TextSize = 12
                ValLabel.TextColor3 = Library.Scheme.AccentColor
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Size = UDim2.new(1, 0, 0, 15)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Parent = Container

                local SlideBar = Instance.new("TextButton")
                SlideBar.Size = UDim2.new(1, 0, 0, 6)
                SlideBar.Position = UDim2.new(0, 0, 0, 18)
                SlideBar.BackgroundColor3 = Library.Scheme.BackgroundColor
                SlideBar.BorderColor3 = Library.Scheme.OutlineColor
                SlideBar.Text = ""
                SlideBar.Parent = Container

                local Fill = Instance.new("Frame")
                Fill.BackgroundColor3 = Library.Scheme.AccentColor
                Fill.BorderSizePixel = 0
                Fill.Size = UDim2.new((Slider.Value - Config.Min) / (Config.Max - Config.Min), 0, 1, 0)
                Fill.Parent = SlideBar

                local function Move(input)
                    local pos = math.clamp((input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
                    local val = Config.Min + ((Config.Max - Config.Min) * pos)
                    if Config.Rounding and Config.Rounding == 0 then val = math.floor(val + 0.5) end
                    Slider.Value = val
                    Fill.Size = UDim2.new(pos, 0, 1, 0)
                    ValLabel.Text = tostring(val)
                    Library:SafeCallback(Config.Callback, val)
                end

                local Sliding = false
                SlideBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true Move(input) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if Sliding and input.UserInputType == Enum.UserInputType.MouseMovement then Move(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
                end)

                return Slider
            end

            function Group:AddDropdown(Name, Config)
                local Dropdown = { Value = Config.Values[Config.Default or 1], Values = Config.Values }
                
                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, 35)
                Container.BackgroundTransparency = 1
                Container.Parent = Box

                local Txt = Instance.new("TextLabel")
                Txt.Text = Config.Text or Name
                Txt.Font = Enum.Font.Code
                Txt.TextSize = 12
                Txt.TextColor3 = Library.Scheme.FontColor
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.Size = UDim2.new(1, 0, 0, 14)
                Txt.BackgroundTransparency = 1
                Txt.Parent = Container

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, 0, 0, 18)
                DropBtn.Position = UDim2.new(0, 0, 0, 16)
                DropBtn.BackgroundColor3 = Library.Scheme.BackgroundColor
                DropBtn.BorderColor3 = Library.Scheme.OutlineColor
                DropBtn.Text = "  " .. tostring(Dropdown.Value)
                DropBtn.TextColor3 = Library.Scheme.FontColor
                DropBtn.Font = Enum.Font.Code
                DropBtn.TextSize = 12
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.Parent = Container

                function Dropdown:SetValues(NewValues)
                    Dropdown.Values = NewValues
                    Dropdown.Value = NewValues[1] or ""
                    DropBtn.Text = "  " .. tostring(Dropdown.Value)
                end

                function Dropdown:SetValue(Val)
                    Dropdown.Value = Val
                    DropBtn.Text = "  " .. tostring(Val)
                    Library:SafeCallback(Config.Callback, Val)
                end

                DropBtn.MouseButton1Click:Connect(function()
                    if Config.Multi then
                        local selected = {}
                        for _, v in pairs(Dropdown.Values) do selected[v] = true end
                        Library:SafeCallback(Config.Callback, selected)
                    else
                        local nextIdx = 1
                        for i, v in pairs(Dropdown.Values) do
                            if v == Dropdown.Value then nextIdx = i + 1 break end
                        end
                        if nextIdx > #Dropdown.Values then nextIdx = 1 end
                        local nextVal = Dropdown.Values[nextIdx] or Dropdown.Values[1]
                        Dropdown:SetValue(nextVal)
                    end
                end)

                return Dropdown
            end

            function Group:AddButton(Config)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 22)
                Btn.BackgroundColor3 = Library.Scheme.BackgroundColor
                Btn.BorderColor3 = Library.Scheme.OutlineColor
                Btn.Text = Config.Text or "Button"
                Btn.TextColor3 = Library.Scheme.FontColor
                Btn.Font = Enum.Font.Code
                Btn.TextSize = 13
                Btn.Parent = Box

                Btn.MouseButton1Click:Connect(function()
                    Library:SafeCallback(Config.Func)
                end)
            end

            return Group
        end

        Tab.AddRightGroupbox = Tab.AddLeftGroupbox
        return Tab
    end

    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input, gpe)
        if gpe then return end
        if Input.KeyCode == Library.ToggleKeybind then
            MainFrame.Visible = not MainFrame.Visible
        end
    end))

    return Window
end

function Library:Notify(Text)
    print("[AslanlarHub Notif]: " .. tostring(Text))
end

getgenv().Library = Library
return Library
