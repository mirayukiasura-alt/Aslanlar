local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local Players: Players = cloneref(game:GetService("Players"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local gethui = gethui or function() return CoreGui end
local LocalPlayer = Players.LocalPlayer

local Library = {
    ActiveTab = nil,
    Tabs = {},
    Notifications = {},
    ToggleKeybind = Enum.KeyCode.RightShift,
    TweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Open = true,
    Signals = {},

    -- Premium Mor / Pembe / Siyah / Gri Renk Paleti
    FontColor = Color3.fromRGB(245, 245, 245),
    MainColor = Color3.fromRGB(15, 15, 17),       -- Ultra Derin Siyah/Gri
    BackgroundColor = Color3.fromRGB(10, 10, 11), -- Arka Plan Siyahı
    AccentColor = Color3.fromRGB(185, 30, 230),   -- Neon Mor (Ana Detaylar)
    PinkColor = Color3.fromRGB(255, 60, 180),     -- Neon Pembe (İkincil Parlamalar)
    OutlineColor = Color3.fromRGB(35, 35, 40),    -- Modern Gri Çizgiler
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

local TogglesRegistry = {}

function Library:AddToRegistry(Instance, Properties)
    local Data = { Instance = Instance, Properties = Properties }
    table.insert(Library.Registry, Data)
    Library:UpdateProperties(Data)
end

function Library:UpdateProperties(Data)
    for Property, ColorIdx in pairs(Data.Properties) do
        Data.Instance[Property] = Library[ColorIdx]
    end
end

function Library:UpdateColors()
    for _, RegistryData in pairs(Library.Registry) do
        Library:UpdateProperties(RegistryData)
    end
end

function Library:ToggleColorBlender(Instance, Property, DefaultColor, IsToggled)
    table.insert(TogglesRegistry, { Instance = Instance, Property = Property, DefaultColor = DefaultColor, IsToggled = IsToggled })
end

function Library:UpdateToggleColors()
    for _, RegistryData in pairs(TogglesRegistry) do
        if RegistryData.IsToggled() then
            RegistryData.Instance[RegistryData.Property] = Library.PinkColor
        else
            RegistryData.Instance[RegistryData.Property] = RegistryData.DefaultColor
        end
    end
end

function Library:GetTextBounds(Text, Font, Size)
    return TextService:GetTextSize(Text, Size, Font, Vector2.new(1920, 1080))
end

function Library:Notify(Title, Text, Duration)
    local Duration = Duration or 4
    local NotificationFrame = Instance.new("Frame")
    local NotificationOutline = Instance.new("Frame")
    local NotificationTitle = Instance.new("TextLabel")
    local NotificationText = Instance.new("TextLabel")

    NotificationFrame.Name = "NotificationFrame"
    NotificationFrame.Parent = Library.ScreenGui
    NotificationFrame.BackgroundColor3 = Library.BackgroundColor
    NotificationFrame.BorderColor3 = Library.OutlineColor
    NotificationFrame.BorderSizePixel = 1
    NotificationFrame.Position = UDim2.new(1, -230, 0, 20 + (#Library.Notifications * 70))
    NotificationFrame.Size = UDim2.new(0, 210, 0, 60)

    NotificationOutline.BackgroundColor3 = Library.PinkColor
    NotificationOutline.BorderSizePixel = 0
    NotificationOutline.Size = UDim2.new(0, 3, 1, 0)
    NotificationOutline.Parent = NotificationFrame

    NotificationTitle.Parent = NotificationFrame
    NotificationTitle.BackgroundTransparency = 1
    NotificationTitle.Position = UDim2.new(0, 12, 0, 6)
    NotificationTitle.Size = UDim2.new(1, -20, 0, 18)
    NotificationTitle.Font = Library.Font
    NotificationTitle.Text = Title
    NotificationTitle.TextColor3 = Library.FontColor
    NotificationTitle.TextSize = 13
    NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left

    NotificationText.Parent = NotificationFrame
    NotificationText.BackgroundTransparency = 1
    NotificationText.Position = UDim2.new(0, 12, 0, 24)
    NotificationText.Size = UDim2.new(1, -20, 1, -30)
    NotificationText.Font = Library.Font
    NotificationText.Text = Text
    NotificationText.TextColor3 = Color3.fromRGB(180, 180, 180)
    NotificationText.TextSize = 11
    NotificationText.TextXAlignment = Enum.TextXAlignment.Left
    NotificationText.TextYAlignment = Enum.TextYAlignment.Top
    NotificationText.TextWrapped = true

    table.insert(Library.Notifications, NotificationFrame)

    task.delay(Duration, function()
        NotificationFrame:Destroy()
        table.remove(Library.Notifications, 1)
    end)
end

function Library:CreateWindow(Config)
    local Title = Config.Title or "AslanlarHUB"
    local Footer = Config.Footer or "Premium"

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AslanlarHub_Modern"
    ScreenGui.Parent = gethui()
    ScreenGui.ResetOnSpawn = false
    Library.ScreenGui = ScreenGui

    -- Büyük ve Geniş Başlangıç Boyutu (680 x 450)
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Parent = ScreenGui
    MainWindow.BackgroundColor3 = Library.MainColor
    MainWindow.BorderColor3 = Library.OutlineColor
    MainWindow.BorderSizePixel = 1
    MainWindow.Position = UDim2.new(0.5, -340, 0.5, -225)
    MainWindow.Size = UDim2.new(0, 680, 0, 450)
    MainWindow.ClipsDescendants = false

    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = Library.AccentColor
    TopLine.BorderSizePixel = 0
    TopLine.Parent = MainWindow

    local MainHeader = Instance.new("Frame")
    MainHeader.Name = "MainHeader"
    MainHeader.Parent = MainWindow
    MainHeader.BackgroundColor3 = Library.BackgroundColor
    MainHeader.BorderColor3 = Library.OutlineColor
    MainHeader.BorderSizePixel = 1
    MainHeader.Position = UDim2.new(0, 12, 0, 14)
    MainHeader.Size = UDim2.new(1, -24, 0, 30)

    local MainTitle = Instance.new("TextLabel")
    MainTitle.Parent = MainHeader
    MainTitle.BackgroundTransparency = 1
    MainTitle.Position = UDim2.new(0, 10, 0, 0)
    MainTitle.Size = UDim2.new(1, -20, 1, 0)
    MainTitle.Font = Library.Font
    MainTitle.Text = Title
    MainTitle.TextColor3 = Library.FontColor
    MainTitle.TextSize = 14
    MainTitle.TextXAlignment = Enum.TextXAlignment.Left

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = MainWindow
    TabContainer.BackgroundColor3 = Library.BackgroundColor
    TabContainer.BorderColor3 = Library.OutlineColor
    TabContainer.BorderSizePixel = 1
    TabContainer.Position = UDim2.new(0, 12, 0, 52)
    TabContainer.Size = UDim2.new(0, 140, 1, -90)

    local TabContainerLayout = Instance.new("UIListLayout")
    TabContainerLayout.Parent = TabContainer
    TabContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabContainerLayout.Padding = UDim.new(0, 2)

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainWindow
    ContentContainer.BackgroundColor3 = Library.BackgroundColor
    ContentContainer.BorderColor3 = Library.OutlineColor
    ContentContainer.BorderSizePixel = 1
    ContentContainer.Position = UDim2.new(0, 164, 0, 52)
    ContentContainer.Size = UDim2.new(1, -176, 1, -90)

    local MainFooter = Instance.new("Frame")
    MainFooter.Parent = MainWindow
    MainFooter.BackgroundColor3 = Library.BackgroundColor
    MainFooter.BorderColor3 = Library.OutlineColor
    MainFooter.BorderSizePixel = 1
    MainFooter.Position = UDim2.new(0, 12, 1, -30)
    MainFooter.Size = UDim2.new(1, -24, 0, 20)

    local FooterText = Instance.new("TextLabel")
    FooterText.Parent = MainFooter
    FooterText.BackgroundTransparency = 1
    FooterText.Position = UDim2.new(0, 8, 0, 0)
    FooterText.Size = UDim2.new(1, -16, 1, 0)
    FooterText.Font = Library.Font
    FooterText.Text = Footer
    FooterText.TextColor3 = Color3.fromRGB(130, 130, 140)
    FooterText.TextSize = 11
    FooterText.TextXAlignment = Enum.TextXAlignment.Left

    ------------------------------------------------------------------------
    -- MOUSE ILE TUTUP BOYUTLANDIRMA (RESIZE) SISTEMI (SAĞ ALT KÖŞE)
    ------------------------------------------------------------------------
    local ResizeButton = Instance.new("ImageButton")
    ResizeButton.Name = "ResizeButton"
    ResizeButton.Parent = MainWindow
    ResizeButton.BackgroundTransparency = 1
    ResizeButton.Position = UDim2.new(1, -15, 1, -15)
    ResizeButton.Size = UDim2.new(0, 15, 0, 15)
    ResizeButton.Image = "rbxassetid://4384412423" -- Modern Çizgili Resize İkonu
    ResizeButton.ImageColor3 = Library.AccentColor
    ResizeButton.ZIndex = 10

    local Resizing = false
    local ResizeStart = Vector2.new()
    local StartSize = Vector2.new()

    ResizeButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
            ResizeStart = UserInputService:GetMouseLocation()
            StartSize = Vector2.new(MainWindow.AbsoluteSize.X, MainWindow.AbsoluteSize.Y)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local MousePos = UserInputService:GetMouseLocation()
            local Delta = MousePos - ResizeStart
            
            -- Minimum Boyut Sınırı (550x380'den küçük olamaz, istenildiği kadar büyüyebilir)
            local NewX = math.max(550, StartSize.X + Delta.X)
            local NewY = math.max(380, StartSize.Y + Delta.Y)
            
            MainWindow.Size = UDim2.new(0, NewX, 0, NewY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = false
        end
    end)

    ------------------------------------------------------------------------
    -- DRAG (SÜRÜKLEME) SİSTEMİ
    ------------------------------------------------------------------------
    local Dragging, DragInput, DragStart, StartPosition
    MainHeader.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainWindow.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    MainHeader.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            MainWindow.Position = UDim2.new(StartPosition.Width.Scale, StartPosition.Width.Offset + Delta.X, StartPosition.Height.Scale, StartPosition.Height.Offset + Delta.Y)
        end
    end)

    Library:AddToRegistry(MainWindow, { BackgroundColor3 = "MainColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(TopLine, { BackgroundColor3 = "AccentColor" })
    Library:AddToRegistry(MainHeader, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(TabContainer, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })
    Library:AddToRegistry(ContentContainer, { BackgroundColor3 = "BackgroundColor", BorderColor3 = "OutlineColor" })

    local Window = {}

    function Window:AddTab(Name, Icon)
        local TabButton = Instance.new("TextButton")
        local TabTitle = Instance.new("TextLabel")
        local TabPage = Instance.new("ScrollingFrame")
        local LeftContainer = Instance.new("Frame")
        local RightContainer = Instance.new("Frame")
        local LeftLayout = Instance.new("UIListLayout")
        local RightLayout = Instance.new("UIListLayout")

        TabButton.Parent = TabContainer
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.Text = ""

        TabTitle.Parent = TabButton
        TabTitle.BackgroundTransparency = 1
        TabTitle.Position = UDim2.new(0, 14, 0, 0)
        TabTitle.Size = UDim2.new(1, -14, 1, 0)
        TabTitle.Font = Library.Font
        TabTitle.Text = Name
        TabTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
        TabTitle.TextSize = 13
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left

        TabPage.Parent = ContentContainer
        TabPage.BackgroundTransparency = 1
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Library.OutlineColor

        LeftContainer.Parent = TabPage
        LeftContainer.BackgroundTransparency = 1
        LeftContainer.Position = UDim2.new(0, 8, 0, 8)
        LeftContainer.Size = UDim2.new(0.5, -12, 1, -16)

        LeftLayout.Parent = LeftContainer
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)

        RightContainer.Parent = TabPage
        RightContainer.BackgroundTransparency = 1
        RightContainer.Position = UDim2.new(0.5, 4, 0, 8)
        RightContainer.Size = UDim2.new(0.5, -12, 1, -16)

        RightLayout.Parent = RightContainer
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)

        local function UpdatePageCanvas()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y) + 24)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePageCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdatePageCanvas)

        local function Select()
            if Library.ActiveTab then
                Library.ActiveTab.Page.Visible = false
                Library.ActiveTab.Button.TabTitle.TextColor3 = Color3.fromRGB(140, 140, 150)
            end
            TabPage.Visible = true
            TabTitle.TextColor3 = Library.PinkColor
            Library.ActiveTab = { Page = TabPage, Button = TabButton }
        end
        TabButton.MouseButton1Click:Connect(Select)
        if not Library.ActiveTab then Select() end

        local Tab = { Page = TabPage }

        function Tab:CreateGroupbox(Title, Container)
            local Groupbox = Instance.new("Frame")
            local GroupLine = Instance.new("Frame")
            local GroupTitle = Instance.new("TextLabel")
            local GroupContainer = Instance.new("Frame")
            local GroupLayout = Instance.new("UIListLayout")

            Groupbox.Parent = Container
            Groupbox.BackgroundColor3 = Library.MainColor
            Groupbox.BorderColor3 = Library.OutlineColor
            Groupbox.BorderSizePixel = 1
            Groupbox.Size = UDim2.new(1, 0, 0, 40)

            GroupLine.Size = UDim2.new(1, 0, 0, 1)
            GroupLine.BackgroundColor3 = Library.AccentColor
            GroupLine.BorderSizePixel = 0
            GroupLine.Parent = Groupbox

            GroupTitle.Parent = Groupbox
            GroupTitle.BackgroundColor3 = Library.MainColor
            GroupTitle.Position = UDim2.new(0, 12, 0, -6)
            GroupTitle.Size = UDim2.new(0, Library:GetTextBounds(Title, Library.Font, 12).X + 8, 0, 12)
            GroupTitle.Font = Library.Font
            GroupTitle.Text = Title
            GroupTitle.TextColor3 = Library.FontColor
            GroupTitle.TextSize = 12

            GroupContainer.Parent = Groupbox
            GroupContainer.BackgroundTransparency = 1
            GroupContainer.Position = UDim2.new(0, 10, 0, 12)
            GroupContainer.Size = UDim2.new(1, -20, 1, -18)

            GroupLayout.Parent = GroupContainer
            GroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupLayout.Padding = UDim.new(0, 5)

            GroupLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Groupbox.Size = UDim2.new(1, 0, 0, GroupLayout.AbsoluteContentSize.Y + 20)
            end)

            local BOX = {}

            function BOX:AddLabel(Text, IsSub)
                local Label = Instance.new("TextLabel")
                Label.Parent = GroupContainer
                Label.BackgroundTransparency = 1
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Font = Library.Font
                Label.Text = Text
                Label.TextColor3 = IsSub and Color3.fromRGB(140, 140, 150) or Library.FontColor
                Label.TextSize = 13
                Label.TextXAlignment = Enum.TextXAlignment.Left
                return { SetText = function(_, nt) Label.Text = nt end }
            end

            function BOX:AddButton(Text, Callback)
                local Button = Instance.new("TextButton")
                Button.Parent = GroupContainer
                Button.BackgroundColor3 = Library.BackgroundColor
                Button.BorderColor3 = Library.OutlineColor
                Button.BorderSizePixel = 1
                Button.Size = UDim2.new(1, 0, 0, 22)
                Button.Font = Library.Font
                Button.Text = Text
                Button.TextColor3 = Library.FontColor
                Button.TextSize = 13
                Button.MouseButton1Click:Connect(Callback)
            end

            function BOX:AddToggle(Idx, Config)
                local ToggleButton = Instance.new("TextButton")
                local ToggleFrame = Instance.new("Frame")
                local ToggleLabel = Instance.new("TextLabel")

                ToggleButton.Parent = GroupContainer
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Size = UDim2.new(1, 0, 0, 18)
                ToggleButton.Text = ""

                ToggleFrame.Parent = ToggleButton
                ToggleFrame.BackgroundColor3 = Library.BackgroundColor
                ToggleFrame.BorderColor3 = Library.OutlineColor
                ToggleFrame.BorderSizePixel = 1
                ToggleFrame.Position = UDim2.new(0, 0, 0.5, -5)
                ToggleFrame.Size = UDim2.new(0, 10, 0, 10)

                ToggleLabel.Parent = ToggleButton
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Position = UDim2.new(0, 18, 0, 0)
                ToggleLabel.Size = UDim2.new(1, -18, 1, 0)
                ToggleLabel.Font = Library.Font
                ToggleLabel.Text = Config.Text or "Toggle"
                ToggleLabel.TextColor3 = Library.FontColor
                ToggleLabel.TextSize = 13
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

                local State = Config.Default or false
                local function Update()
                    ToggleFrame.BackgroundColor3 = State and Library.PinkColor or Library.BackgroundColor
                    Config.Callback(State)
                end
                Library:ToggleColorBlender(ToggleFrame, "BackgroundColor3", Library.BackgroundColor, function() return State end)
                ToggleButton.MouseButton1Click:Connect(function() State = not State; Update() end)
                Update()

                local TObject = { SetValue = function(_, v) State = v; Update() end }

                function TObject:AddKeyPicker(KeyIdx, KeyConfig)
                    local KeyLabel = Instance.new("TextLabel")
                    KeyLabel.Parent = ToggleButton
                    KeyLabel.BackgroundTransparency = 1
                    KeyLabel.Position = UDim2.new(1, -45, 0, 0)
                    KeyLabel.Size = UDim2.new(0, 45, 1, 0)
                    KeyLabel.Font = Library.Font
                    KeyLabel.Text = "[" .. (KeyConfig.Default or "None") .. "]"
                    KeyLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
                    KeyLabel.TextSize = 12
                    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right

                    local CurrentKey = KeyConfig.Default or "None"
                    KeyLabel.InputBegan:Connect(function(io)
                        if io.UserInputType == Enum.UserInputType.MouseButton1 then
                            KeyLabel.Text = "[...]"
                            local c; c = UserInputService.InputBegan:Connect(function(i)
                                if i.UserInputType == Enum.UserInputType.Keyboard then
                                    CurrentKey = i.KeyCode.Name
                                    KeyLabel.Text = "[" .. CurrentKey .. "]"
                                    c:Disconnect()
                                end
                            end)
                        end
                    end)
                    UserInputService.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.Keyboard and i.KeyCode.Name == CurrentKey then
                            if KeyConfig.SyncToggleState then State = not State; Update() end
                        end
                    end)
                end
                return TObject
            end

            function BOX:AddSlider(Idx, Config)
                local SliderButton = Instance.new("TextButton")
                local SliderLabel = Instance.new("TextLabel")
                local SliderFrame = Instance.new("Frame")
                local SliderFill = Instance.new("Frame")
                local SliderValue = Instance.new("TextLabel")

                SliderButton.Parent = GroupContainer
                SliderButton.BackgroundTransparency = 1
                SliderButton.Size = UDim2.new(1, 0, 0, 28)
                SliderButton.Text = ""

                SliderLabel.Parent = SliderButton
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Size = UDim2.new(1, 0, 0, 14)
                SliderLabel.Font = Library.Font
                SliderLabel.Text = Config.Text or "Slider"
                SliderLabel.TextColor3 = Library.FontColor
                SliderLabel.TextSize = 13
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
                SliderValue.BackgroundTransparency = 1
                SliderValue.Position = UDim2.new(1, -40, 0, 0)
                SliderValue.Size = UDim2.new(0, 40, 0, 14)
                SliderValue.Font = Library.Font
                SliderValue.Text = tostring(Config.Default or Config.Min)
                SliderValue.TextColor3 = Color3.fromRGB(140, 140, 150)
                SliderValue.TextSize = 12
                SliderValue.TextXAlignment = Enum.TextXAlignment.Right

                local function Update(Percent)
                    local P = math.clamp(Percent, 0, 1)
                    SliderFill.Size = UDim2.new(P, 0, 1, 0)
                    local Val = math.floor(Config.Min + (Config.Max - Config.Min) * P)
                    SliderValue.Text = tostring(Val)
                    Config.Callback(Val)
                end

                local Sliding = false
                SliderFrame.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true Update((i.Position.X - SliderFrame.AbsolutePosition.X)/SliderFrame.AbsoluteSize.X) end
                end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
                UserInputService.InputChanged:Connect(function(i) if Sliding and i.UserInputType == Enum.UserInputType.MouseMovement then Update((i.Position.X - SliderFrame.AbsolutePosition.X)/SliderFrame.AbsoluteSize.X) end end)
                Update(((Config.Default or Config.Min) - Config.Min)/(Config.Max - Config.Min))

                return { SetValue = function(_, v) Update((v - Config.Min)/(Config.Max - Config.Min)) end }
            end

            function BOX:AddDropdown(Idx, Config)
                local DropdownButton = Instance.new("TextButton")
                local DropdownLabel = Instance.new("TextLabel")
                local DropdownFrame = Instance.new("Frame")
                local DropdownValue = Instance.new("TextLabel")
                local DropdownList = Instance.new("Frame")
                local DropdownListLayout = Instance.new("UIListLayout")

                DropdownButton.Parent = GroupContainer
                DropdownButton.BackgroundTransparency = 1
                DropdownButton.Size = UDim2.new(1, 0, 0, 36)
                DropdownButton.Text = ""

                DropdownLabel.Parent = DropdownButton
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Size = UDim2.new(1, 0, 0, 14)
                DropdownLabel.Font = Library.Font
                DropdownLabel.Text = Config.Text or "Dropdown"
                DropdownLabel.TextColor3 = Library.FontColor
                DropdownLabel.TextSize = 13
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

                DropdownFrame.Parent = DropdownButton
                DropdownFrame.BackgroundColor3 = Library.BackgroundColor
                DropdownFrame.BorderColor3 = Library.OutlineColor
                DropdownFrame.BorderSizePixel = 1
                DropdownFrame.Position = UDim2.new(0, 0, 0, 16)
                DropdownFrame.Size = UDim2.new(1, 0, 0, 20)

                DropdownValue.Parent = DropdownFrame
                DropdownValue.BackgroundTransparency = 1
                DropdownValue.Position = UDim2.new(0, 8, 0, 0)
                DropdownValue.Size = UDim2.new(1, -16, 1, 0)
                DropdownValue.Font = Library.Font
                DropdownValue.Text = "None"
                DropdownValue.TextColor3 = Color3.fromRGB(200, 200, 200)
                DropdownValue.TextSize = 12
                DropdownValue.TextXAlignment = Enum.TextXAlignment.Left

                DropdownList.Parent = DropdownButton
                DropdownList.BackgroundColor3 = Library.BackgroundColor
                DropdownList.BorderColor3 = Library.OutlineColor
                DropdownList.BorderSizePixel = 1
                DropdownList.Position = UDim2.new(0, 0, 0, 37)
                DropdownList.Size = UDim2.new(1, 0, 0, 0)
                DropdownList.Visible = false
                DropdownList.ZIndex = 5

                DropdownListLayout.Parent = DropdownList
                DropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                local Selected = {}
                local Open = false
                local Values = Config.Values or {}

                local function Rebuild()
                    for _, c in pairs(DropdownList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _, val in pairs(Values) do
                        local Item = Instance.new("TextButton")
                        Item.Parent = DropdownList
                        Item.BackgroundColor3 = Library.BackgroundColor
                        Item.BorderSizePixel = 0
                        Item.Size = UDim2.new(1, 0, 0, 18)
                        Item.Font = Library.Font
                        Item.Text = "  " .. tostring(val)
                        Item.TextColor3 = Selected[val] and Library.PinkColor or Library.FontColor
                        Item.TextSize = 12
                        Item.TextXAlignment = Enum.TextXAlignment.Left
                        Item.ZIndex = 6

                        Item.MouseButton1Click:Connect(function()
                            if Config.Multi then
                                Selected[val] = not Selected[val]
                                Item.TextColor3 = Selected[val] and Library.PinkColor or Library.FontColor
                                local t = {} for k, v in pairs(Selected) do if v then table.insert(t, k) end end
                                DropdownValue.Text = #t > 0 and table.concat(t, ", ") or "None"
                                Config.Callback(Selected)
                            else
                                Selected = {} Selected[val] = true
                                DropdownValue.Text = tostring(val)
                                Open = false DropdownList.Visible = false
                                DropdownButton.Size = UDim2.new(1, 0, 0, 36)
                                Config.Callback(val)
                            end
                        end)
                    end
                end

                DropdownButton.MouseButton1Click:Connect(function()
                    Open = not Open
                    DropdownList.Visible = Open
                    if Open then
                        DropdownList.Size = UDim2.new(1, 0, 0, #Values * 18)
                        DropdownButton.Size = UDim2.new(1, 0, 0, 38 + (#Values * 18))
                    else
                        DropdownButton.Size = UDim2.new(1, 0, 0, 36)
                    end
                end)
                Rebuild()

                return { SetValues = function(_, nv) Values = nv Selected = {} DropdownValue.Text = "None" Rebuild() end }
            end

            function BOX:AddDivider()
                local Div = Instance.new("Frame")
                Div.Parent = GroupContainer
                Div.BackgroundColor3 = Library.OutlineColor
                Div.BorderSizePixel = 0
                Div.Size = UDim2.new(1, 0, 0, 1)
            end

            return BOX
        end

        function Tab:AddLeftGroupbox(Title) return Tab:CreateGroupbox(Title, LeftContainer) end
        function Tab:AddRightGroupbox(Title) return Tab:CreateGroupbox(Title, RightContainer) end

        return Tab
    end

    return Window
end

function Library:Toggle()
    Library.Open = not Library.Open
    if Library.ScreenGui and Library.ScreenGui:FindFirstChild("MainWindow") then
        Library.ScreenGui.MainWindow.Visible = Library.Open
    end
end

function Library:Unload()
    if Library.ScreenGui then Library.ScreenGui:Destroy() end
    getgenv().Library = nil
end

getgenv().Library = Library
return Library
