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

    Open = true,
    Signals = {},

    FontColor = Color3.fromRGB(255, 255, 255),
    MainColor = Color3.fromRGB(18, 18, 18),
    BackgroundColor = Color3.fromRGB(14, 14, 14),
    AccentColor = Color3.fromRGB(255, 50, 160), -- Modern Neon Pembe / Mor
    OutlineColor = Color3.fromRGB(32, 32, 32),
    InvertedFontColor = Color3.fromRGB(0, 0, 0),

    Registry = {},
    RegistryMap = {},

    Font = Enum.Font.Code,

    Icons = {
        ["settings"] = "rbxassetid://11326613041",
        ["bolt"] = "rbxassetid://11383416737",
        ["Main"] = "rbxassetid://13847970597",
    }
}

local RenderRegistry = {}

function Library:AddToRegistry(Instance, Properties, IsToggled)
    local Id = game:GetService("HttpService"):GenerateGUID(false)

    local Data = {
        Instance = Instance,
        Properties = Properties,
        Id = Id,
        IsToggled = IsToggled
    }

    table.insert(Library.Registry, Data)
    Library.RegistryMap[Instance] = Data

    Library:UpdateProperties(Data)

    return Id
end

function Library:RemoveFromRegistry(Instance)
    local Data = Library.RegistryMap[Instance]

    if Data then
        for Id, RegistryData in pairs(Library.Registry) do
            if RegistryData == Data then
                table.remove(Library.Registry, Id)
                break
            end
        end

        Library.RegistryMap[Instance] = nil
    end
end

function Library:UpdateProperties(Data)
    for Property, ColorIdx in pairs(Data.Properties) do
        if typeof(ColorIdx) == "table" then
            Data.Instance[Property] = ColorIdx
        else
            Data.Instance[Property] = Library[ColorIdx]
        end
    end
end

function Library:UpdateColors()
    for _, RegistryData in pairs(Library.Registry) do
        Library:UpdateProperties(RegistryData)
    end
end

local TogglesCount = 0
local TogglesRegistry = {}

function Library:ToggleColorBlender(Instance, Property, DefaultColor, IsToggled)
    local Id = game:GetService("HttpService"):GenerateGUID(false)

    local Data = {
        Instance = Instance,
        Property = Property,
        DefaultColor = DefaultColor,
        Id = Id,
        IsToggled = IsToggled
    }

    table.insert(TogglesRegistry, Data)

    return Id
end

function Library:UpdateToggleColors()
    for _, RegistryData in pairs(TogglesRegistry) do
        if RegistryData.IsToggled() then
            RegistryData.Instance[RegistryData.Property] = Library.AccentColor
        else
            RegistryData.Instance[RegistryData.Property] = RegistryData.DefaultColor
        end
    end
end

function Library:GetTextBounds(Text, Font, Size, SizeAxis)
    return TextService:GetTextSize(Text, Size, Font, SizeAxis or Vector2.new(1920, 1080))
end

function Library:GetNextNotificationPosition()
    local Y = 20
    for _, Notification in pairs(Library.Notifications) do
        Y = Y + Notification.Frame.AbsoluteSize.Y + 10
    end
    return Y
end

function Library:Notify(Title, Text, Duration)
    local Duration = Duration or 5
    local Notification = {
        Title = Title,
        Text = Text,
        Duration = Duration,
    }

    local NotificationFrame = Instance.new("Frame")
    local NotificationOutline = Instance.new("Frame")
    local NotificationTitle = Instance.new("TextLabel")
    local NotificationText = Instance.new("TextLabel")

    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Parent = Library.ScreenGui
    NotificationFrame.BackgroundColor3 = Library.BackgroundColor
    NotificationFrame.BorderColor3 = Library.OutlineColor
    NotificationFrame.BorderSizePixel = 1
    
    if Library.NotifySide == "Left" then
        NotificationFrame.Position = CFrame.new(20, Library:GetNextNotificationPosition(), 0)
    else
        NotificationFrame.Position = CFrame.new(Library.ScreenGui.AbsoluteSize.X - 220, Library:GetNextNotificationPosition(), 0)
    end
    
    NotificationFrame.Size = UDim2.new(0, 200, 0, 60)

    NotificationOutline.Name = "NotificationOutline"
    NotificationOutline.Parent = NotificationFrame
    NotificationOutline.BackgroundColor3 = Library.AccentColor
    NotificationOutline.BorderSizePixel = 0
    NotificationOutline.Size = UDim2.new(0, 2, 1, 0)

    NotificationTitle.Name = "NotificationTitle"
    NotificationTitle.Parent = NotificationFrame
    NotificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotificationTitle.BackgroundTransparency = 1.000
    NotificationTitle.Position = UDim2.new(0, 10, 0, 5)
    NotificationTitle.Size = UDim2.new(1, -20, 0, 20)
    NotificationTitle.Font = Library.Font
    NotificationTitle.Text = Title
    NotificationTitle.TextColor3 = Library.FontColor
    NotificationTitle.TextSize = 14.000
    NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left

    NotificationText.Name = "NotificationText"
    NotificationText.Parent = NotificationFrame
    NotificationText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotificationText.BackgroundTransparency = 1.000
    NotificationText.Position = UDim2.new(0, 10, 0, 25)
    NotificationText.Size = UDim2.new(1, -20, 1, -30)
    NotificationText.Font = Library.Font
    NotificationText.Text = Text
    NotificationText.TextColor3 = Library.FontColor
    NotificationText.TextSize = 12.000
    NotificationText.TextXAlignment = Enum.TextXAlignment.Left
    NotificationText.TextYAlignment = Enum.TextYAlignment.Top
    NotificationText.TextWrapped = true

    Library:AddToRegistry(NotificationFrame, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(NotificationOutline, { BackgroundColor3 = "AccentColor" })
    Library:AddToRegistry(NotificationTitle, { TextColor3 = "FontColor" })
    Library:AddToRegistry(NotificationText, { TextColor3 = "FontColor" })

    table.insert(Library.Notifications, Notification)

    task.delay(Duration, function()
        for Id, Notif in pairs(Library.Notifications) do
            if Notif == Notification then
                table.remove(Library.Notifications, Id)
                break
            end
        end

        NotificationFrame:Destroy()

        for Id, Notif in pairs(Library.Notifications) do
            TweenService:Create(Notif.Frame, Library.TweenInfo, { Position = UDim2.new(0, Library.NotifySide == "Left" and 20 or Library.ScreenGui.AbsoluteSize.X - 220, 0, Library:GetNextNotificationPosition()) }):Play()
        end
    end)

    Notification.Frame = NotificationFrame
end

function Library:CreateWindow(Config)
    local Title = Config.Title or "Window"
    local Footer = Config.Footer or "Footer"
    local ShowCustomCursor = Config.ShowCustomCursor or false
    Library.NotifySide = Config.NotifySide or "Right"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AslanlarHub"
    ScreenGui.Parent = gethui()
    ScreenGui.ResetOnSpawn = false
    Library.ScreenGui = ScreenGui

    local MainWindow = Instance.new("Frame")
    local MainOutline = Instance.new("Frame")
    local MainHeader = Instance.new("Frame")
    local MainTitle = Instance.new("TextLabel")
    local TabContainer = Instance.new("Frame")
    local TabContainerLayout = Instance.new("UIListLayout")
    local ContentContainer = Instance.new("Frame")
    local MainFooter = Instance.new("Frame")
    local FooterText = Instance.new("TextLabel")

    MainWindow.Name = "MainWindow"
    MainWindow.Parent = ScreenGui
    MainWindow.BackgroundColor3 = Library.MainColor
    MainWindow.BorderColor3 = Library.OutlineColor
    MainWindow.BorderSizePixel = 1
    MainWindow.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainWindow.Size = UDim2.new(0, 550, 0, 380)

    MainOutline.Name = "MainOutline"
    MainOutline.Parent = MainWindow
    MainOutline.BackgroundColor3 = Library.AccentColor
    MainOutline.BorderSizePixel = 0
    MainOutline.Position = UDim2.new(0, 0, 0, 0)
    MainOutline.Size = UDim2.new(1, 0, 0, 2)

    MainHeader.Name = "MainHeader"
    MainHeader.Parent = MainWindow
    MainHeader.BackgroundColor3 = Library.BackgroundColor
    MainHeader.BorderColor3 = Library.OutlineColor
    MainHeader.BorderSizePixel = 1
    MainHeader.Position = UDim2.new(0, 10, 0, 12)
    MainHeader.Size = UDim2.new(1, -20, 0, 25)

    MainTitle.Name = "MainTitle"
    MainTitle.Parent = MainHeader
    MainTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainTitle.BackgroundTransparency = 1.000
    MainTitle.Position = UDim2.new(0, 6, 0, 0)
    MainTitle.Size = UDim2.new(1, -12, 1, 0)
    MainTitle.Font = Library.Font
    MainTitle.Text = Title
    MainTitle.TextColor3 = Library.FontColor
    MainTitle.TextSize = 14.000
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left

    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainWindow
    TabContainer.BackgroundColor3 = Library.BackgroundColor
    TabContainer.BorderColor3 = Library.OutlineColor
    TabContainer.BorderSizePixel = 1
    TabContainer.Position = UDim2.new(0, 10, 0, 44)
    TabContainer.Size = UDim2.new(0, 120, 1, -76)

    TabContainerLayout.Name = "TabContainerLayout"
    TabContainerLayout.Parent = TabContainer
    TabContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder

    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainWindow
    ContentContainer.BackgroundColor3 = Library.BackgroundColor
    ContentContainer.BorderColor3 = Library.OutlineColor
    ContentContainer.BorderSizePixel = 1
    ContentContainer.Position = UDim2.new(0, 136, 0, 44)
    ContentContainer.Size = UDim2.new(1, -146, 1, -76)

    MainFooter.Name = "MainFooter"
    MainFooter.Parent = MainWindow
    MainFooter.BackgroundColor3 = Library.BackgroundColor
    MainFooter.BorderColor3 = Library.OutlineColor
    MainFooter.BorderSizePixel = 1
    MainFooter.Position = UDim2.new(0, 10, 1, -24)
    MainFooter.Size = UDim2.new(1, -20, 0, 16)

    FooterText.Name = "FooterText"
    FooterText.Parent = MainFooter
    FooterText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FooterText.BackgroundTransparency = 1.000
    FooterText.Position = UDim2.new(0, 6, 0, 0)
    FooterText.Size = UDim2.new(1, -12, 1, 0)
    FooterText.Font = Library.Font
    FooterText.Text = Footer
    FooterText.TextColor3 = Library.FontColor
    FooterText.TextSize = 11.000
    FooterText.TextXAlignment = Enum.TextXAlignment.Left

    Library:AddToRegistry(MainWindow, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(MainOutline, { BackgroundColor3 = "AccentColor" })
    Library:AddToRegistry(MainHeader, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(MainTitle, { TextColor3 = "FontColor" })
    Library:AddToRegistry(TabContainer, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(ContentContainer, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(MainFooter, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(FooterText, { TextColor3 = "FontColor" })

    -- Sürükleme fonksiyonu
    local Dragging, DragInput, DragStart, StartPosition
    MainHeader.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainWindow.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    MainHeader.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            MainWindow.Position = UDim2.new(StartPosition.Width.Scale, StartPosition.Width.Offset + Delta.X, StartPosition.Height.Scale, StartPosition.Height.Offset + Delta.Y)
        end
    end)

    local Window = {}

    function Window:AddTab(Name, Icon)
        local TabButton = Instance.new("TextButton")
        local TabIcon = Instance.new("ImageLabel")
        local TabTitle = Instance.new("TextLabel")
        local TabPage = Instance.new("ScrollingFrame")
        local LeftLayout = Instance.new("UIListLayout")
        local RightLayout = Instance.new("UIListLayout")
        local LeftContainer = Instance.new("Frame")
        local RightContainer = Instance.new("Frame")

        TabButton.Name = "TabButton"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.BackgroundTransparency = 1.000
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Font = Library.Font
        TabButton.Text = ""

        if Icon and Library.Icons[Icon] then
            TabIcon.Name = "TabIcon"
            TabIcon.Parent = TabButton
            TabIcon.BackgroundTransparency = 1.000
            TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
            TabIcon.Size = UDim2.new(0, 16, 0, 16)
            TabIcon.Image = Library.Icons[Icon]
            TabIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

            TabTitle.Position = UDim2.new(0, 32, 0, 0)
            TabTitle.Size = UDim2.new(1, -32, 1, 0)
        else
            TabTitle.Position = UDim2.new(0, 10, 0, 0)
            TabTitle.Size = UDim2.new(1, -10, 1, 0)
        end

        TabTitle.Name = "TabTitle"
        TabTitle.Parent = TabButton
        TabTitle.BackgroundTransparency = 1.000
        TabTitle.Font = Library.Font
        TabTitle.Text = Name
        TabTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabTitle.TextSize = 13.000
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left

        TabPage.Name = "TabPage"
        TabPage.Parent = ContentContainer
        TabPage.BackgroundTransparency = 1.000
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = Library.OutlineColor

        LeftContainer.Name = "LeftContainer"
        LeftContainer.Parent = TabPage
        LeftContainer.BackgroundTransparency = 1.000
        LeftContainer.Position = UDim2.new(0, 6, 0, 6)
        LeftContainer.Size = UDim2.new(0.5, -9, 1, -12)

        LeftLayout.Name = "LeftLayout"
        LeftLayout.Parent = LeftContainer
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 6)

        RightContainer.Name = "RightContainer"
        RightContainer.Parent = TabPage
        RightContainer.BackgroundTransparency = 1.000
        RightContainer.Position = UDim2.new(0.5, 3, 0, 6)
        RightContainer.Size = UDim2.new(0.5, -9, 1, -12)

        RightLayout.Name = "RightLayout"
        RightLayout.Parent = RightContainer
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 6)

        Library:AddToRegistry(TabPage, { ScrollBarImageColor3 = "OutlineColor" })

        local function UpdatePageCanvas()
            local LeftSize = LeftLayout.AbsoluteContentSize.Y + 12
            local RightSize = RightLayout.AbsoluteContentSize.Y + 12
            TabPage.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftSize, RightSize))
        end

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePageCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePageCanvas)

        local Tab = { Page = TabPage }

        local function Select()
            if Library.ActiveTab then
                Library.ActiveTab.Page.Visible = false
                Library.ActiveTab.Button.TabTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
                if Library.ActiveTab.Button:FindFirstChild("TabIcon") then
                    Library.ActiveTab.Button.TabIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            TabPage.Visible = true
            TabTitle.TextColor3 = Library.AccentColor
            if Icon and Library.Icons[Icon] then
                TabIcon.ImageColor3 = Library.AccentColor
            end
            Library.ActiveTab = { Page = TabPage, Button = TabButton }
        end

        TabButton.MouseButton1Click:Connect(Select)

        if not Library.ActiveTab then
            Select()
        end

        function Tab:AddLeftGroupbox(Title)
            local Groupbox = Instance.new("Frame")
            local GroupboxOutline = Instance.new("Frame")
            local GroupboxTitle = Instance.new("TextLabel")
            local GroupboxContainer = Instance.new("Frame")
            local GroupboxLayout = Instance.new("UIListLayout")

            Groupbox.Name = "Groupbox"
            Groupbox.Parent = LeftContainer
            Groupbox.BackgroundColor3 = Library.MainColor
            Groupbox.BorderColor3 = Library.OutlineColor
            Groupbox.BorderSizePixel = 1
            Groupbox.Size = UDim2.new(1, 0, 0, 30)

            GroupboxOutline.Name = "GroupboxOutline"
            GroupboxOutline.Parent = Groupbox
            GroupboxOutline.BackgroundColor3 = Library.AccentColor
            GroupboxOutline.BorderSizePixel = 0
            GroupboxOutline.Size = UDim2.new(1, 0, 0, 2)

            GroupboxTitle.Name = "GroupboxTitle"
            GroupboxTitle.Parent = Groupbox
            GroupboxTitle.BackgroundColor3 = Library.MainColor
            GroupboxTitle.Position = UDim2.new(0, 10, 0, -6)
            GroupboxTitle.Size = UDim2.new(0, Library:GetTextBounds(Title, Library.Font, 12).X + 6, 0, 12)
            GroupboxTitle.Font = Library.Font
            GroupboxTitle.Text = Title
            GroupboxTitle.TextColor3 = Library.FontColor
            GroupboxTitle.TextSize = 12.000

            GroupboxContainer.Name = "GroupboxContainer"
            GroupboxContainer.Parent = Groupbox
            GroupboxContainer.BackgroundTransparency = 1.000
            GroupboxContainer.Position = UDim2.new(0, 6, 0, 12)
            GroupboxContainer.Size = UDim2.new(1, -12, 1, -18)

            GroupboxLayout.Name = "GroupboxLayout"
            GroupboxLayout.Parent = GroupboxContainer
            GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupboxLayout.Padding = UDim.new(0, 4)

            Library:AddToRegistry(Groupbox, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor" })
            Library:AddToRegistry(GroupboxOutline, { BackgroundColor3 = "AccentColor" })
            Library:AddToRegistry(GroupboxTitle, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor" })

            GroupboxLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Groupbox.Size = UDim2.new(1, 0, 0, GroupboxLayout.AbsoluteContentSize.Y + 18)
            end)

            local GroupboxObject = {}

            function GroupboxObject:AddLabel(Text, IsSub)
                local Label = Instance.new("TextLabel")
                Label.Name = "Label"
                Label.Parent = GroupboxContainer
                Label.BackgroundTransparency = 1.000
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Font = Library.Font
                Label.Text = Text
                Label.TextColor3 = IsSub and Color3.fromRGB(150, 150, 150) or Library.FontColor
                Label.TextSize = 13.000
                Label.TextXAlignment = Enum.TextXAlignment.Left

                if not IsSub then
                    Library:AddToRegistry(Label, { TextColor3 = "FontColor" })
                end

                local LabelObject = {}
                function LabelObject:SetText(NewText)
                    Label.Text = NewText
                end
                return LabelObject
            end

            function GroupboxObject:AddButton(Text, Callback)
                local Button = Instance.new("TextButton")
                local ButtonOutline = Instance.new("Frame")

                Button.Name = "Button"
                Button.Parent = GroupboxContainer
                Button.BackgroundColor3 = Library.BackgroundColor
                Button.BorderColor3 = Library.OutlineColor
                Button.BorderSizePixel = 1
                Button.Size = UDim2.new(1, 0, 0, 20)
                Button.Font = Library.Font
                Button.Text = Text
                Button.TextColor3 = Library.FontColor
                Button.TextSize = 13.000

                ButtonOutline.Name = "ButtonOutline"
                ButtonOutline.Parent = Button
                ButtonOutline.BackgroundColor3 = Library.AccentColor
                ButtonOutline.BorderSizePixel = 0
                ButtonOutline.Position = UDim2.new(0, 0, 1, -1)
                ButtonOutline.Size = UDim2.new(1, 0, 0, 1)

                Library:AddToRegistry(Button, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor", TextColor3 = "FontColor" })
                Library:AddToRegistry(ButtonOutline, { BackgroundColor3 = "AccentColor" })

                Button.MouseButton1Click:Connect(Callback)
            end

            function GroupboxObject:AddToggle(Idx, Config)
                local Text = Config.Text or "Toggle"
                local Default = Config.Default or false
                local Callback = Config.Callback or function() end

                local ToggleButton = Instance.new("TextButton")
                local ToggleFrame = Instance.new("Frame")
                local ToggleLabel = Instance.new("TextLabel")

                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = GroupboxContainer
                ToggleButton.BackgroundTransparency = 1.000
                ToggleButton.Size = UDim2.new(1, 0, 0, 16)
                ToggleButton.Text = ""

                ToggleFrame.Name = "ToggleFrame"
                ToggleFrame.Parent = ToggleButton
                ToggleFrame.BackgroundColor3 = Library.BackgroundColor
                ToggleFrame.BorderColor3 = Library.OutlineColor
                ToggleFrame.BorderSizePixel = 1
                ToggleFrame.Position = UDim2.new(0, 0, 0.5, -5)
                ToggleFrame.Size = UDim2.new(0, 10, 0, 10)

                ToggleLabel.Name = "ToggleLabel"
                ToggleLabel.Parent = ToggleButton
                ToggleLabel.BackgroundTransparency = 1.000
                ToggleLabel.Position = UDim2.new(0, 16, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -16, 1, 0)
                ToggleLabel.Font = Library.Font
                ToggleLabel.Text = Text
                ToggleLabel.TextColor3 = Library.FontColor
                ToggleLabel.TextSize = 13.000
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                Library:AddToRegistry(ToggleFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(ToggleLabel, { TextColor3 = "FontColor" })

                local State = Default
                local function Update()
                    if State then
                        ToggleFrame.BackgroundColor3 = Library.AccentColor
                    else
                        ToggleFrame.BackgroundColor3 = Library.BackgroundColor
                    end
                    Callback(State)
                end

                Library:ToggleColorBlender(ToggleFrame, "BackgroundColor3", Library.BackgroundColor, function() return State end)

                ToggleButton.MouseButton1Click:Connect(function()
                    State = not State
                    Update()
                end)

                Update()

                local ToggleObject = {}
                function ToggleObject:SetValue(Val)
                    State = Val
                    Update()
                end
                function ToggleObject:AddKeyPicker(KeyIdx, KeyConfig)
                    local KeyDefault = KeyConfig.Default or "None"
                    local KeyText = KeyConfig.Text or Text
                    local KeyCallback = KeyConfig.Callback or function() end
                    local SyncToggle = KeyConfig.SyncToggleState or false

                    local KeyLabel = Instance.new("TextLabel")
                    KeyLabel.Name = "KeyLabel"
                    KeyLabel.Parent = ToggleButton
                    KeyLabel.BackgroundTransparency = 1.000
                    KeyLabel.Position = UDim2.new(1, -40, 0, 0)
                    KeyLabel.Size = UDim2.new(0, 40, 1, 0)
                    KeyLabel.Font = Library.Font
                    KeyLabel.Text = "[" .. KeyDefault .. "]"
                    KeyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                    KeyLabel.TextSize = 12.000
                    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right

                    local CurrentKey = KeyDefault

                    local function Listen()
                        KeyLabel.Text = "[...]"
                        local Connection
                        Connection = UserInputService.InputBegan:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.Keyboard then
                                CurrentKey = Input.KeyCode.Name
                                KeyLabel.Text = "[" .. CurrentKey .. "]"
                                Connection:Disconnect()
                                KeyCallback(Input.KeyCode)
                            end
                        end)
                    end

                    KeyLabel.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            Listen()
                        end
                    end)

                    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == CurrentKey then
                            if SyncToggle then
                                State = not State
                                Update()
                            else
                                KeyCallback(Input.KeyCode)
                            end
                        end
                    end))
                end

                return ToggleObject
            end

            function GroupboxObject:AddSlider(Idx, Config)
                local Text = Config.Text or "Slider"
                local Min = Config.Min or 0
                local Max = Config.Max or 100
                local Default = Config.Default or Min
                local Callback = Config.Callback or function() end

                local SliderButton = Instance.new("TextButton")
                local SliderLabel = Instance.new("TextLabel")
                local SliderFrame = Instance.new("Frame")
                local SliderFill = Instance.new("Frame")
                local SliderValue = Instance.new("TextLabel")

                SliderButton.Name = "SliderButton"
                SliderButton.Parent = GroupboxContainer
                SliderButton.BackgroundTransparency = 1.000
                SliderButton.Size = UDim2.new(1, 0, 0, 26)
                SliderButton.Text = ""

                SliderLabel.Name = "SliderLabel"
                SliderLabel.Parent = SliderButton
                SliderLabel.BackgroundTransparency = 1.000
                SliderLabel.Size = UDim2.new(1, 0, 0, 14)
                SliderLabel.Font = Library.Font
                SliderLabel.Text = Text
                SliderLabel.TextColor3 = Library.FontColor
                SliderLabel.TextSize = 13.000
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

                SliderFrame.Name = "SliderFrame"
                SliderFrame.Parent = SliderButton
                SliderFrame.BackgroundColor3 = Library.BackgroundColor
                SliderFrame.BorderColor3 = Library.OutlineColor
                SliderFrame.BorderSizePixel = 1
                SliderFrame.Position = UDim2.new(0, 0, 0, 16)
                SliderFrame.Size = UDim2.new(1, 0, 0, 8)

                SliderFill.Name = "SliderFill"
                SliderFill.Parent = SliderFrame
                SliderFill.BackgroundColor3 = Library.AccentColor
                SliderFill.BorderSizePixel = 0
                SliderFill.Size = UDim2.new(0, 0, 1, 0)

                SliderValue.Name = "SliderValue"
                SliderValue.Parent = SliderButton
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.Position = UDim2.new(1, -40, 0, 0)
                SliderValue.Size = UDim2.new(0, 40, 0, 14)
                SliderValue.Font = Library.Font
                SliderValue.Text = tostring(Default)
                SliderValue.TextColor3 = Color3.fromRGB(150, 150, 150)
                SliderValue.TextSize = 12.000
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right

                Library:AddToRegistry(SliderLabel, { TextColor3 = "FontColor" })
                Library:AddToRegistry(SliderFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(SliderFill, { BackgroundColor3 = "AccentColor" })

                local CurrentValue = Default
                local function Update(Percent)
                    local P = math.clamp(Percent, 0, 1)
                    SliderFill.Size = UDim2.new(P, 0, 1, 0)
                    CurrentValue = math.floor(Min + (Max - Min) * P)
                    SliderValue.Text = tostring(CurrentValue)
                    Callback(CurrentValue)
                end

                local Sliding = false
                local function Snap(Input)
                    local MousePos = Input.Position.X
                    local FramePos = SliderFrame.AbsolutePosition.X
                    local FrameSize = SliderFrame.AbsoluteSize.X
                    Update((MousePos - FramePos) / FrameSize)
                end

                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = true
                        Snap(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        Snap(Input)
                    end
                end)

                Update((Default - Min) / (Max - Min))

                local SliderObject = {}
                function SliderObject:SetValue(Val)
                    Update((Val - Min) / (Max - Min))
                end
                return SliderObject
            end

            function GroupboxObject:AddDropdown(Idx, Config)
                local Text = Config.Text or "Dropdown"
                local Values = Config.Values or {}
                local Multi = Config.Multi or false
                local Callback = Config.Callback or function() end

                local DropdownButton = Instance.new("TextButton")
                local DropdownLabel = Instance.new("TextLabel")
                local DropdownFrame = Instance.new("Frame")
                local DropdownValue = Instance.new("TextLabel")
                local DropdownIcon = Instance.new("ImageLabel")
                local DropdownList = Instance.new("Frame")
                local DropdownListLayout = Instance.new("UIListLayout")

                DropdownButton.Name = "DropdownButton"
                DropdownButton.Parent = GroupboxContainer
                DropdownButton.BackgroundTransparency = 1.000
                DropdownButton.Size = UDim2.new(1, 0, 0, 34)
                DropdownButton.Text = ""

                DropdownLabel.Name = "DropdownLabel"
                DropdownLabel.Parent = DropdownButton
                DropdownLabel.BackgroundTransparency = 1.000
                DropdownLabel.Size = UDim2.new(1, 0, 0, 14)
                DropdownLabel.Font = Library.Font
                DropdownLabel.Text = Text
                DropdownLabel.TextColor3 = Library.FontColor
                DropdownLabel.TextSize = 13.000
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

                DropdownFrame.Name = "DropdownFrame"
                DropdownFrame.Parent = DropdownButton
                DropdownFrame.BackgroundColor3 = Library.BackgroundColor
                DropdownFrame.BorderColor3 = Library.OutlineColor
                DropdownFrame.BorderSizePixel = 1
                DropdownFrame.Position = UDim2.new(0, 0, 0, 16)
                DropdownFrame.Size = UDim2.new(1, 0, 0, 18)

                DropdownValue.Name = "DropdownValue"
                DropdownValue.Parent = DropdownFrame
                DropdownValue.BackgroundTransparency = 1.000
                DropdownValue.Position = UDim2.new(0, 6, 0, 0)
                DropdownValue.Size = UDim2.new(1, -26, 1, 0)
                DropdownValue.Font = Library.Font
                DropdownValue.Text = "None"
                DropdownValue.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownValue.TextSize = 12.000
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Left

                DropdownIcon.Name = "DropdownIcon"
                DropdownIcon.Parent = DropdownFrame
                DropdownIcon.BackgroundTransparency = 1.000
                DropdownIcon.Position = UDim2.new(1, -16, 0.5, -4)
                DropdownIcon.Size = UDim2.new(0, 8, 0, 8)
                DropdownIcon.Image = "rbxassetid://11294002205"
                DropdownIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)

                DropdownList.Name = "DropdownList"
                DropdownList.Parent = DropdownButton
                DropdownList.BackgroundColor3 = Library.BackgroundColor
                DropdownList.BorderColor3 = Library.OutlineColor
                DropdownList.BorderSizePixel = 1
                DropdownList.Position = UDim2.new(0, 0, 0, 35)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Visible = false
                DropdownList.ZIndex = 5

                DropdownListLayout.Name = "DropdownListLayout"
                DropdownListLayout.Parent = DropdownList
                DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                Library:AddToRegistry(DropdownLabel, { TextColor3 = "FontColor" })
                Library:AddToRegistry(DropdownFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(DropdownList, { BorderColor3 = "OutlineColor" })

                local SelectedValues = {}
                local Open = false

                local function RebuildList()
                    for _, c in pairs(DropdownList:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end

                    for _, val in pairs(Values) do
                        local Item = Instance.new("TextButton")
                        Item.Name = "Item"
                        Item.Parent = DropdownList
                        Item.BackgroundColor3 = Library.BackgroundColor
                        Item.BorderSizePixel = 0
                        Item.Size = UDim2.new(1, 0, 0, 18)
                        Item.ZIndex = 6
                        Item.Font = Library.Font
                        Item.Text = "  " .. tostring(val)
                        Item.TextColor3 = SelectedValues[val] and Library.AccentColor or Library.FontColor
                        Item.TextSize = 12.000
                        Item.TextXAlignment = Enum.TextXAlignment.Left

                        Item.MouseButton1Click:Connect(function()
                            if Multi then
                                SelectedValues[val] = not SelectedValues[val]
                                Item.TextColor3 = SelectedValues[val] and Library.AccentColor or Library.FontColor
                                local t = {}
                                for k, v in pairs(SelectedValues) do if v then table.insert(t, k) end end
                                DropdownValue.Text = #t > 0 and table.concat(t, ", ") or "None"
                                Callback(SelectedValues)
                            else
                                SelectedValues = {}
                                SelectedValues[val] = true
                                DropdownValue.Text = tostring(val)
                                Open = false
                                DropdownList.Visible = false
                                DropdownButton.Size = UDim2.new(1, 0, 0, 34)
                                Callback(val)
                            end
                        end)
                    end
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    Open = not Open
                    DropdownList.Visible = Open
                    if Open then
                        DropdownList.Size = UDim2.new(1, 0, 0, #Values * 18)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 35 + (#Values * 18))
                    else
                        DropdownButton.Size = UDim2.new(1, 0, 0, 34)
                    end
                end)

                RebuildList()

                local DropdownObject = {}
                function DropdownObject:SetValues(NewValues)
                    Values = NewValues
                    SelectedValues = {}
                    DropdownValue.Text = "None"
                    RebuildList()
                end
                return DropdownObject
            end

            function GroupboxObject:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Name = "Divider"
                Divider.Parent = GroupboxContainer
                Divider.BackgroundColor3 = Library.OutlineColor
                Divider.BorderSizePixel = 0
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Library:AddToRegistry(Divider, { BackgroundColor3 = "OutlineColor" })
            end

            return GroupboxObject
        end

        function Tab:AddRightGroupbox(Title)
            -- Simetri için sağ tarafı sol tarafla tamamen eşliyoruz
            local Groupbox = Instance.new("Frame")
            local GroupboxOutline = Instance.new("Frame")
            local GroupboxTitle = Instance.new("TextLabel")
            local GroupboxContainer = Instance.new("Frame")
            local GroupboxLayout = Instance.new("UIListLayout")

            Groupbox.Name = "Groupbox"
            Groupbox.Parent = RightContainer
            Groupbox.BackgroundColor3 = Library.MainColor
            Groupbox.BorderColor3 = Library.OutlineColor
            Groupbox.BorderSizePixel = 1
            Groupbox.Size = UDim2.new(1, 0, 0, 30)

            GroupboxOutline.Name = "GroupboxOutline"
            GroupboxOutline.Parent = Groupbox
            GroupboxOutline.BackgroundColor3 = Library.AccentColor
            GroupboxOutline.BorderSizePixel = 0
            GroupboxOutline.Size = UDim2.new(1, 0, 0, 2)

            GroupboxTitle.Name = "GroupboxTitle"
            GroupboxTitle.Parent = Groupbox
            GroupboxTitle.BackgroundColor3 = Library.MainColor
            GroupboxTitle.Position = UDim2.new(0, 10, 0, -6)
            GroupboxTitle.Size = UDim2.new(0, Library:GetTextBounds(Title, Library.Font, 12).X + 6, 0, 12)
            GroupboxTitle.Font = Library.Font
            GroupboxTitle.Text = Title
            GroupboxTitle.TextColor3 = Library.FontColor
            GroupboxTitle.TextSize = 12.000

            GroupboxContainer.Name = "GroupboxContainer"
            GroupboxContainer.Parent = Groupbox
            GroupboxContainer.BackgroundTransparency = 1.000
            GroupboxContainer.Position = UDim2.new(0, 6, 0, 12)
            GroupboxContainer.Size = UDim2.new(1, -12, 1, -18)

            GroupboxLayout.Name = "GroupboxLayout"
            GroupboxLayout.Parent = GroupboxContainer
            GroupboxLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupboxLayout.Padding = UDim.new(0, 4)

            Library:AddToRegistry(Groupbox, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor" })
            Library:AddToRegistry(GroupboxOutline, { BackgroundColor3 = "AccentColor" })
            Library:AddToRegistry(GroupboxTitle, { BackgroundColor3 = "MainColor", TextColor3 = "FontColor" })

            GroupboxLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Groupbox.Size = UDim2.new(1, 0, 0, GroupboxLayout.AbsoluteContentSize.Y + 18)
            end)

            -- Sol taraftaki tüm metotları sağ tarafa kopyalıyoruz
            local GroupboxObject = {}
            GroupboxObject.AddLabel = function(_, t, s) return Tab:AddLeftGroupbox(Title).AddLabel(GroupboxObject, t, s) end
            GroupboxObject.AddButton = function(_, t, c) local lb = Tab:AddLeftGroupbox(Title) return lb.AddButton(GroupboxObject, t, c) end
            GroupboxObject.AddToggle = function(_, i, c) return Tab:AddLeftGroupbox(Title).AddToggle(GroupboxObject, i, c) end
            GroupboxObject.AddSlider = function(_, i, c) return Tab:AddLeftGroupbox(Title).AddSlider(GroupboxObject, i, c) end
            GroupboxObject.AddDropdown = function(_, i, c) return Tab:AddLeftGroupbox(Title).AddDropdown(GroupboxObject, i, c) end
            GroupboxObject.AddDivider = function() return Tab:AddLeftGroupbox(Title).AddDivider() end
            
            -- Doğrudan sağ kutuya bağlanmasını garantileyen ezici fonksiyonlar:
            function GroupboxObject:AddLabel(Text, IsSub)
                local Label = Instance.new("TextLabel")
                Label.Parent = GroupboxContainer
                Label.BackgroundTransparency = 1.000
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Font = Library.Font
                Label.Text = Text
                Label.TextColor3 = IsSub and Color3.fromRGB(150, 150, 150) or Library.FontColor
                Label.TextSize = 13.000
                Label.TextXAlignment = Enum.TextXAlignment.Left
                if not IsSub then Library:AddToRegistry(Label, { TextColor3 = "FontColor" }) end
                local LabelObject = {}
                function LabelObject:SetText(Nt) Label.Text = Nt end
                return LabelObject
            end

            function GroupboxObject:AddButton(Text, Callback)
                local Button = Instance.new("TextButton")
                local ButtonOutline = Instance.new("Frame")
                Button.Parent = GroupboxContainer
                Button.BackgroundColor3 = Library.BackgroundColor
                Button.BorderColor3 = Library.OutlineColor
                Button.BorderSizePixel = 1
                Button.Size = UDim2.new(1, 0, 0, 20)
                Button.Font = Library.Font
                Button.Text = Text
                Button.TextColor3 = Library.FontColor
                Button.TextSize = 13.000
                ButtonOutline.Parent = Button
                ButtonOutline.BackgroundColor3 = Library.AccentColor
                ButtonOutline.BorderSizePixel = 0
                ButtonOutline.Position = UDim2.new(0, 0, 1, -1)
                ButtonOutline.Size = UDim2.new(1, 0, 0, 1)
                Library:AddToRegistry(Button, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor", TextColor3 = "FontColor" })
                Library:AddToRegistry(ButtonOutline, { BackgroundColor3 = "AccentColor" })
                Button.MouseButton1Click:Connect(Callback)
            end

            function GroupboxObject:AddToggle(Idx, Config)
                local Text = Config.Text or "Toggle"
                local Default = Config.Default or false
                local Callback = Config.Callback or function() end
                local ToggleButton = Instance.new("TextButton")
                local ToggleFrame = Instance.new("Frame")
                local ToggleLabel = Instance.new("TextLabel")
                ToggleButton.Parent = GroupboxContainer
                ToggleButton.BackgroundTransparency = 1.000
                ToggleButton.Size = UDim2.new(1, 0, 0, 16)
                ToggleButton.Text = ""
                ToggleFrame.Parent = ToggleButton
                ToggleFrame.BackgroundColor3 = Library.BackgroundColor
                ToggleFrame.BorderColor3 = Library.OutlineColor
                ToggleFrame.BorderSizePixel = 1
                ToggleFrame.Position = UDim2.new(0, 0, 0.5, -5)
                ToggleFrame.Size = UDim2.new(0, 10, 0, 10)
                ToggleLabel.Parent = ToggleButton
                ToggleLabel.BackgroundTransparency = 1.000
                ToggleLabel.Position = UDim2.new(0, 16, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -16, 1, 0)
                ToggleLabel.Font = Library.Font
                ToggleLabel.Text = Text
                ToggleLabel.TextColor3 = Library.FontColor
                ToggleLabel.TextSize = 13.000
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                Library:AddToRegistry(ToggleFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(ToggleLabel, { TextColor3 = "FontColor" })
                local State = Default
                local function Update()
                    ToggleFrame.BackgroundColor3 = State and Library.AccentColor or Library.BackgroundColor
                    Callback(State)
                end
                Library:ToggleColorBlender(ToggleFrame, "BackgroundColor3", Library.BackgroundColor, function() return State end)
                ToggleButton.MouseButton1Click:Connect(function() State = not State; Update() end)
                Update()
                local ToggleObject = {}
                function ToggleObject:SetValue(Val) State = Val; Update() end
                function ToggleObject:AddKeyPicker(KeyIdx, KeyConfig)
                    local KeyDefault = KeyConfig.Default or "None"
                    local KeyCallback = KeyConfig.Callback or function() end
                    local SyncToggle = KeyConfig.SyncToggleState or false
                    local KeyLabel = Instance.new("TextLabel")
                    KeyLabel.Parent = ToggleButton
                    KeyLabel.BackgroundTransparency = 1.000
                    KeyLabel.Position = UDim2.new(1, -40, 0, 0)
                    KeyLabel.Size = UDim2.new(0, 40, 1, 0)
                    KeyLabel.Font = Library.Font
                    KeyLabel.Text = "[" .. KeyDefault .. "]"
                    KeyLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
                    KeyLabel.TextSize = 12.000
                    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
                    local CurrentKey = KeyDefault
                    KeyLabel.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            KeyLabel.Text = "[...]"
                            local Conn; Conn = UserInputService.InputBegan:Connect(function(Inp)
                                if Inp.UserInputType == Enum.UserInputType.Keyboard then
                                    CurrentKey = Inp.KeyCode.Name
                                    KeyLabel.Text = "[" .. CurrentKey .. "]"
                                    Conn:Disconnect()
                                    KeyCallback(Inp.KeyCode)
                                end
                            end)
                        end
                    end)
                    Library:GiveSignal(UserInputService.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == CurrentKey then
                            if SyncToggle then State = not State; Update() else KeyCallback(Input.KeyCode) end
                        end
                    end))
                end
                return ToggleObject
            end

            function GroupboxObject:AddSlider(Idx, Config)
                local Text = Config.Text or "Slider"
                local Min = Config.Min or 0
                local Max = Config.Max or 100
                local Default = Config.Default or Min
                local Callback = Config.Callback or function() end
                local SliderButton = Instance.new("TextButton")
                local SliderLabel = Instance.new("TextLabel")
                local SliderFrame = Instance.new("Frame")
                local SliderFill = Instance.new("Frame")
                local SliderValue = Instance.new("TextLabel")
                SliderButton.Parent = GroupboxContainer
                SliderButton.BackgroundTransparency = 1.000
                SliderButton.Size = UDim2.new(1, 0, 0, 26)
                SliderButton.Text = ""
                SliderLabel.Parent = SliderButton
                SliderLabel.BackgroundTransparency = 1.000
                SliderLabel.Size = UDim2.new(1, 0, 0, 14)
                SliderLabel.Font = Library.Font
                SliderLabel.Text = Text
                SliderLabel.TextColor3 = Library.FontColor
                SliderLabel.TextSize = 13.000
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderFrame.Parent = SliderButton
                SliderFrame.BackgroundColor3 = Library.BackgroundColor
                SliderFrame.BorderColor3 = Library.OutlineColor
                SliderFrame.BorderSizePixel = 1
                SliderFrame.Position = UDim2.new(0, 0, 0, 16)
                SliderFrame.Size = UDim2.new(1, 0, 0, 8)
                SliderFill.Parent = SliderFrame
                SliderFill.BackgroundColor3 = Library.AccentColor
                SliderFill.BorderSizePixel = 0
                SliderValue.Parent = SliderButton
                SliderValue.BackgroundTransparency = 1.000
                SliderValue.Position = UDim2.new(1, -40, 0, 0)
                SliderValue.Size = UDim2.new(0, 40, 0, 14)
                SliderValue.Font = Library.Font
                SliderValue.Text = tostring(Default)
                SliderValue.TextColor3 = Color3.fromRGB(150, 150, 150)
                SliderValue.TextSize = 12.000
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                Library:AddToRegistry(SliderLabel, { TextColor3 = "FontColor" })
                Library:AddToRegistry(SliderFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(SliderFill, { BackgroundColor3 = "AccentColor" })
                local CurrentValue = Default
                local function Update(Percent)
                    local P = math.clamp(Percent, 0, 1)
                    SliderFill.Size = UDim2.new(P, 0, 1, 0)
                    CurrentValue = math.floor(Min + (Max - Min) * P)
                    SliderValue.Text = tostring(CurrentValue)
                    Callback(CurrentValue)
                end
                local Sliding = false
                local function Snap(Input)
                    local MousePos = Input.Position.X
                    local FramePos = SliderFrame.AbsolutePosition.X
                    local FrameSize = SliderFrame.AbsoluteSize.X
                    Update((MousePos - FramePos) / FrameSize)
                end
                SliderFrame.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true; Snap(Input) end
                end)
                UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
                UserInputService.InputChanged:Connect(function(Input) if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then Snap(Input) end end)
                Update((Default - Min) / (Max - Min))
                local SliderObject = {}
                function SliderObject:SetValue(Val) Update((Val - Min) / (Max - Min)) end
                return SliderObject
            end

            function GroupboxObject:AddDropdown(Idx, Config)
                local Text = Config.Text or "Dropdown"
                local Values = Config.Values or {}
                local Multi = Config.Multi or false
                local Callback = Config.Callback or function() end
                local DropdownButton = Instance.new("TextButton")
                local DropdownLabel = Instance.new("TextLabel")
                local DropdownFrame = Instance.new("Frame")
                local DropdownValue = Instance.new("TextLabel")
                local DropdownIcon = Instance.new("ImageLabel")
                local DropdownList = Instance.new("Frame")
                DropdownButton.Parent = GroupboxContainer
                DropdownButton.BackgroundTransparency = 1.000
                DropdownButton.Size = UDim2.new(1, 0, 0, 34)
                DropdownButton.Text = ""
                DropdownLabel.Parent = DropdownButton
                DropdownLabel.BackgroundTransparency = 1.000
                DropdownLabel.Size = UDim2.new(1, 0, 0, 14)
                DropdownLabel.Font = Library.Font
                DropdownLabel.Text = Text
                DropdownLabel.TextColor3 = Library.FontColor
                DropdownLabel.TextSize = 13.000
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownFrame.Parent = DropdownButton
                DropdownFrame.BackgroundColor3 = Library.BackgroundColor
                DropdownFrame.BorderColor3 = Library.OutlineColor
                DropdownFrame.BorderSizePixel = 1
                DropdownFrame.Position = UDim2.new(0, 0, 0, 16)
                DropdownFrame.Size = UDim2.new(1, 0, 0, 18)
                DropdownValue.Parent = DropdownFrame
                DropdownValue.BackgroundTransparency = 1.000
                DropdownValue.Position = UDim2.new(0, 6, 0, 0)
                DropdownValue.Size = UDim2.new(1, -26, 1, 0)
                DropdownValue.Font = Library.Font
                DropdownValue.Text = "None"
                DropdownValue.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownValue.TextSize = 12.000
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Left
                DropdownIcon.Parent = DropdownFrame
                DropdownIcon.BackgroundTransparency = 1.000
                DropdownIcon.Position = UDim2.new(1, -16, 0.5, -4)
                DropdownIcon.Size = UDim2.new(0, 8, 0, 8)
                DropdownIcon.Image = "rbxassetid://11294002205"
                DropdownIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                DropdownList.Parent = DropdownButton
                DropdownList.BackgroundColor3 = Library.BackgroundColor
                DropdownList.BorderColor3 = Library.OutlineColor
                DropdownList.BorderSizePixel = 1
                DropdownList.Position = UDim2.new(0, 0, 0, 35)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Visible = false
                DropdownList.ZIndex = 5
                local DropdownListLayout = Instance.new("UIListLayout")
                DropdownListLayout.Parent = DropdownList
                Library:AddToRegistry(DropdownLabel, { TextColor3 = "FontColor" })
                Library:AddToRegistry(DropdownFrame, { BorderColor3 = "OutlineColor" })
                Library:AddToRegistry(DropdownList, { BorderColor3 = "OutlineColor" })
                local SelectedValues = {}
                local Open = false
                local function RebuildList()
                    for _, c in pairs(DropdownList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _, val in pairs(Values) do
                        local Item = Instance.new("TextButton")
                        Item.Parent = DropdownList
                        Item.BackgroundColor3 = Library.BackgroundColor
                        Item.Size = UDim2.new(1, 0, 0, 18)
                        Item.ZIndex = 6
                        Item.Font = Library.Font
                        Item.Text = "  " .. tostring(val)
                        Item.TextColor3 = SelectedValues[val] and Library.AccentColor or Library.FontColor
                        Item.TextXAlignment = Enum.TextXAlignment.Left
                        Item.MouseButton1Click:Connect(function()
                            if Multi then
                                SelectedValues[val] = not SelectedValues[val]
                                Item.TextColor3 = SelectedValues[val] and Library.AccentColor or Library.FontColor
                                local t = {} for k, v in pairs(SelectedValues) do if v then table.insert(t, k) end end
                                DropdownValue.Text = #t > 0 and table.concat(t, ", ") or "None"
                                Callback(SelectedValues)
                            else
                                SelectedValues = {} SelectedValues[val] = true
                                DropdownValue.Text = tostring(val) Open = false DropdownList.Visible = false
                                DropdownButton.Size = UDim2.new(1, 0, 0, 34) Callback(val)
                            end
                        end)
                    end
                end
                DropdownButton.MouseButton1Click:Connect(function()
                    Open = not Open DropdownList.Visible = Open
                    if Open then
                        DropdownList.Size = UDim2.new(1, 0, 0, #Values * 18)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 35 + (#Values * 18))
                    else DropdownButton.Size = UDim2.new(1, 0, 0, 34) end
                end)
                RebuildList()
                local DropdownObject = {}
                function DropdownObject:SetValues(Nv) Values = Nv; SelectedValues = {}; DropdownValue.Text = "None"; RebuildList() end
                return DropdownObject
            end

            function GroupboxObject:AddDivider()
                local Divider = Instance.new("Frame")
                Divider.Parent = GroupboxContainer
                Divider.BackgroundColor3 = Library.OutlineColor
                Divider.BorderSizePixel = 0
                Divider.Size = UDim2.new(1, 0, 0, 1)
                Library:AddToRegistry(Divider, { BackgroundColor3 = "OutlineColor" })
            end

            return GroupboxObject
        end

        return Tab
    end

    function Window:SetWatermark(Text)
        -- Gerekirse eklenebilir, şimdilik boş bırakıldı.
    end

    return Window
end

function Library:Toggle(State)
    Library.Open = (State ~= nil and State or not Library.Open)
    if Library.ScreenGui and Library.ScreenGui:FindFirstChild("MainWindow") then
        Library.ScreenGui.MainWindow.Visible = Library.Open
    end
end

function Library:Unload()
    for _, Signal in pairs(Library.Signals) do Signal:Disconnect() end
    if Library.ScreenGui then Library.ScreenGui:Destroy() end
    getgenv().Library = nil
end

function Library:GiveSignal(Signal)
    table.insert(Library.Signals, Signal)
end

function Library:SetDPIScale(Value)
    -- Basit DPI ölçekleme fonksiyonu
end

getgenv().Library = Library
return Library
