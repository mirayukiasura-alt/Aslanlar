local cloneref = (cloneref or clonereference or function(instance: any) return instance end)
local CoreGui: CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService: UserInputService = cloneref(game:GetService("UserInputService"))
local TextService: TextService = cloneref(game:GetService("TextService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))

local gethui = gethui or function() return CoreGui end

local Library = {
    ActiveTab = nil,
    Tabs = {},
    Notifications = {},
    ToggleKeybind = Enum.KeyCode.RightShift,
    Open = true,

    -- Gönderdiğin Tasarımın CSS Değişkenleri (:root)
    BG0 = Color3.fromRGB(15, 13, 20),      -- --bg0
    BG1 = Color3.fromRGB(26, 22, 37),      -- --bg1
    BG2 = Color3.fromRGB(34, 30, 48),      -- --bg2
    BG3 = Color3.fromRGB(45, 40, 64),      -- --bg3
    Pur1 = Color3.fromRGB(108, 92, 231),   -- --pur1 (Neon Mor/Pembe Geçişi)
    Pur2 = Color3.fromRGB(139, 124, 248),  -- --pur2
    Pur3 = Color3.fromRGB(168, 155, 249),  -- --pur3
    Gry1 = Color3.fromRGB(61, 56, 80),     -- --gry1
    Txt1 = Color3.fromRGB(232, 228, 244),  -- --txt1
    Txt2 = Color3.fromRGB(176, 168, 204),  -- --txt2
    Txt3 = Color3.fromRGB(122, 116, 144),  -- --txt3

    Font = Enum.Font.SegoeUI
}

function Library:GetTextBounds(Text, Font, Size)
    return TextService:GetTextSize(Text, Size, Font, Vector2.new(1920, 1080))
end

function Library:Notify(Title, Text)
    -- Basit Bildirim Sistemi
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(0, 220, 0, 50)
    NotificationFrame.Position = UDim2.new(1, -240, 0, 20 + (#Library.Notifications * 55))
    NotificationFrame.BackgroundColor3 = Library.BG2
    NotificationFrame.BorderColor3 = Library.Pur1
    NotificationFrame.BorderSizePixel = 1
    NotificationFrame.Parent = Library.ScreenGui

    local MainLine = Instance.new("Frame")
    MainLine.Size = UDim2.new(0, 3, 1, 0)
    MainLine.BackgroundColor3 = Library.Pur1
    MainLine.BorderSizePixel = 0
    MainLine.Parent = NotificationFrame

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, -15, 0, 18)
    tLabel.Position = UDim2.new(0, 10, 0, 4)
    tLabel.Font = Library.Font
    tLabel.Text = Title
    tLabel.TextSize = 12
    tLabel.TextColor3 = Library.Txt1
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.BackgroundTransparency = 1
    tLabel.Parent = NotificationFrame

    local xLabel = Instance.new("TextLabel")
    xLabel.Size = UDim2.new(1, -15, 1, -22)
    xLabel.Position = UDim2.new(0, 10, 0, 22)
    xLabel.Font = Library.Font
    xLabel.Text = Text
    xLabel.TextSize = 11
    xLabel.TextColor3 = Library.Txt2
    xLabel.TextXAlignment = Enum.TextXAlignment.Left
    xLabel.BackgroundTransparency = 1
    xLabel.Parent = NotificationFrame

    table.insert(Library.Notifications, NotificationFrame)
    task.delay(3, function()
        NotificationFrame:Destroy()
        table.remove(Library.Notifications, 1)
    end)
end

function Library:CreateWindow(Config)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Aslanlar_ModernUI"
    ScreenGui.Parent = gethui()
    ScreenGui.ResetOnSpawn = false
    Library.ScreenGui = ScreenGui

    -- .window class yapısı
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.Parent = ScreenGui
    MainWindow.BackgroundColor3 = Library.BG1
    MainWindow.BorderColor3 = Library.Gry1
    MainWindow.BorderSizePixel = 1
    MainWindow.Position = UDim2.new(0.5, -340, 0.5, -230)
    MainWindow.Size = UDim2.new(0, 680, 0, 460)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainWindow

    -- .titlebar class yapısı
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 38)
    TitleBar.BackgroundColor3 = Library.BG2
    TitleBar.BorderColor3 = Library.BG3
    TitleBar.BorderSizePixel = 1
    TitleBar.Parent = MainWindow

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(0, 200, 1, 0)
    TitleText.Position = UDim2.new(0, 14, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Font = Library.Font
    TitleText.Text = "Aslanlar<font color='rgb(139,124,248)'>HUB</font>"
    TitleText.RichText = true
    TitleText.TextSize = 14
    TitleText.TextColor3 = Library.Txt1
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Parent = TitleBar

    local FooterText = Instance.new("TextLabel")
    FooterText.Size = UDim2.new(0, 200, 1, 0)
    FooterText.Position = UDim2.new(1, -214, 0, 0)
    FooterText.BackgroundTransparency = 1
    FooterText.Font = Library.Font
    FooterText.Text = Config.Footer or "FREE MIRA · UNBAN MIRA YUKI"
    FooterText.TextSize = 10
    FooterText.TextColor3 = Library.Txt3
    FooterText.TextXAlignment = Enum.TextXAlignment.Right
    FooterText.Parent = TitleBar

    -- Drag (Sürükleme) Bağlantısı
    local Dragging, DragInput, DragStart, StartPosition
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainWindow.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart
            MainWindow.Position = UDim2.new(StartPosition.Width.Scale, StartPosition.Width.Offset + Delta.X, StartPosition.Height.Scale, StartPosition.Height.Offset + Delta.Y)
        end
    end)

    -- .tabs container class yapısı
    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(1, 0, 0, 36)
    TabBar.Position = UDim2.new(0, 0, 0, 38)
    TabBar.BackgroundColor3 = Library.BG0
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainWindow

    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarLayout.Padding = UDim.new(0, 4)
    TabBarLayout.Parent = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingTop = UDim.new(0, 4)
    TabPadding.Parent = TabBar

    -- .content ana pencereleri alanı
    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, 0, 1, -74)
    Container.Position = UDim2.new(0, 0, 0, 74)
    Container.BackgroundTransparency = 1
    Container.Parent = MainWindow

    -- Mouse ile alt köşeden manuel boyutlandırma (Resize İkonu)
    local ResizeCornerBtn = Instance.new("ImageButton")
    ResizeCornerBtn.Size = UDim2.new(0, 14, 0, 14)
    ResizeCornerBtn.Position = UDim2.new(1, -14, 1, -14)
    ResizeCornerBtn.BackgroundTransparency = 1
    ResizeCornerBtn.Image = "rbxassetid://4384412423"
    ResizeCornerBtn.ImageColor3 = Library.Pur1
    ResizeCornerBtn.ZIndex = 12
    ResizeCornerBtn.Parent = MainWindow

    local Resizing = false
    local ResizeStart, StartSize
    ResizeCornerBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
            ResizeStart = UserInputService:GetMouseLocation()
            StartSize = Vector2.new(MainWindow.AbsoluteSize.X, MainWindow.AbsoluteSize.Y)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if Resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local MousePos = UserInputService:GetMouseLocation()
            local Delta = MousePos - ResizeStart
            MainWindow.Size = UDim2.new(0, math.max(550, StartSize.X + Delta.X), 0, math.max(380, StartSize.Y + Delta.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = false end
    end)

    local Window = {}

    function Window:AddTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(0, 85, 1, -8)
        TabButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
        TabButton.BackgroundTransparency = 1
        TabButton.Font = Library.Font
        TabButton.Text = Name
        TabButton.TextColor3 = Library.Txt3
        TabButton.TextSize = 12
        TabButton.Parent = TabBar

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = TabButton

        -- İki sütunlu .content.active yapısı (Grid)
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Library.Gry1
        Page.Parent = Container

        local LeftSide = Instance.new("Frame")
        LeftSide.Size = UDim2.new(0.5, -16, 1, 0)
        LeftSide.Position = UDim2.new(0, 12, 0, 12)
        LeftSide.BackgroundTransparency = 1
        LeftSide.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftSide

        local RightSide = Instance.new("Frame")
        RightSide.Size = UDim2.new(0.5, -16, 1, 0)
        RightSide.Position = UDim2.new(0.5, 4, 0, 12)
        RightSide.BackgroundTransparency = 1
        RightSide.Parent = Page

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightSide

        local function SyncCanvas()
            local mx = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0, 0, 0, mx + 30)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncCanvas)

        local function Select()
            if Library.ActiveTab then
                Library.ActiveTab.Page.Visible = false
                Library.ActiveTab.Button.BackgroundTransparency = 1
                Library.ActiveTab.Button.TextColor3 = Library.Txt3
            end
            Page.Visible = true
            TabButton.BackgroundTransparency = 0
            TabButton.BackgroundColor3 = Library.Pur1
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            Library.ActiveTab = { Page = Page, Button = TabButton }
        end

        TabButton.MouseButton1Click:Connect(Select)
        if not Library.ActiveTab then Select() end

        local Tab = {}

        function Tab:CreateGroupbox(Title, SideStr)
            local ParentSide = (SideStr == "Right" and RightSide or LeftSide)

            -- .box class yapısı
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(1, 0, 0, 40)
            Box.BackgroundColor3 = Library.BG2
            Box.BorderColor3 = Library.BG3
            Box.BorderSizePixel = 1
            Box.Parent = ParentSide

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 8)
            BoxCorner.Parent = Box

            local BoxPadding = Instance.new("UIPadding")
            BoxPadding.PaddingLeft = UDim.new(0, 12)
            BoxPadding.PaddingRight = UDim.new(0, 12)
            BoxPadding.PaddingTop = UDim.new(0, 12)
            BoxPadding.Parent = Box

            -- .box-title yapısı
            local BoxTitle = Instance.new("TextLabel")
            BoxTitle.Size = UDim2.new(1, 0, 0, 16)
            BoxTitle.BackgroundTransparency = 1
            BoxTitle.Font = Library.Font
            BoxTitle.Text = "  " .. Title:upper()
            BoxTitle.TextSize = 11
            BoxTitle.TextColor3 = Library.Pur3
            BoxTitle.TextXAlignment = Enum.TextXAlignment.Left
            BoxTitle.Parent = Box

            -- Sol taraftaki ufak dikey mor çizgi (::before)
            local TitleIndicator = Instance.new("Frame")
            TitleIndicator.Size = UDim2.new(0, 2, 0, 12)
            TitleIndicator.Position = UDim2.new(0, 0, 0, 2)
            TitleIndicator.BackgroundColor3 = Library.Pur1
            TitleIndicator.BorderSizePixel = 0
            TitleIndicator.Parent = BoxTitle

            local ContainerLayout = Instance.new("UIListLayout")
            ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ContainerLayout.Padding = UDim.new(0, 8)
            ContainerLayout.Parent = Box

            ContainerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Box.Size = UDim2.new(1, 0, 0, ContainerLayout.AbsoluteContentSize.Y + 24)
            end)

            local BOX = {}

            -- ⚠ UNBAN MIRA YUKI ⚠ Tarzı Özel Uyarı Etiketleri (.warn-label)
            function BOX:AddLabel(Text, IsWarn)
                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, IsWarn and 22 or 16)
                Label.Font = Library.Font
                Label.Text = Text
                Label.TextSize = IsWarn and 11 or 12
                Label.TextColor3 = IsWarn and Library.Pur3 or Library.Txt2
                Label.TextXAlignment = IsWarn and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
                
                if IsWarn then
                    Label.BackgroundColor3 = Color3.fromRGB(30, 22, 48)
                    Label.BorderColor3 = Color3.fromRGB(61, 42, 110)
                    local lc = Instance.new("UICorner") lc.CornerRadius = UDim.new(0, 4) lc.Parent = Label
                else
                    Label.BackgroundTransparency = 1
                end
                
                Label.Parent = Box
                return { SetText = function(_, nt) Label.Text = nt end }
            end

            -- Modern Buton Tasarımı (.btn)
            function BOX:AddButton(Text, Callback)
                local Button = Instance.new("TextButton")
                Button.Size = UDim2.new(1, 0, 0, 26)
                Button.BackgroundColor3 = Library.BG3
                Button.BorderColor3 = Library.Gry1
                Button.BorderSizePixel = 1
                Button.Font = Library.Font
                Button.Text = Text
                Button.TextColor3 = Library.Txt2
                Button.TextSize = 12
                Button.Parent = Box

                local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 6) bc.Parent = Button
                Button.MouseButton1Click:Connect(Callback)
            end

            -- HTML Kodundaki (.toggle) Sisteminin Birebir Klonu
            function BOX:AddToggle(Idx, Config)
                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 24)
                Row.BackgroundTransparency = 1
                Row.Parent = Box

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0, 150, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Library.Font
                Label.Text = Config.Text or "Toggle"
                Label.TextColor3 = Library.Txt2
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(0, 34, 0, 18)
                ToggleFrame.Position = UDim2.new(1, -34, 0.5, -9)
                ToggleFrame.BackgroundColor3 = Library.Gry1
                ToggleFrame.Text = ""
                ToggleFrame.Parent = Row

                local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0, 9) tc.Parent = ToggleFrame

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 14, 0, 14)
                Circle.Position = UDim2.new(0, 2, 0, 2)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.BorderSizePixel = 0
                Circle.Parent = ToggleFrame

                local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(1, 0) cc.Parent = Circle

                local State = Config.Default or false
                local function Update()
                    TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = State and Library.Pur1 or Library.Gry1}):Play()
                    TweenService:Create(Circle, TweenInfo.new(0.15), {Position = State and UDim2.new(0, 18, 0, 2) or UDim2.new(0, 2, 0, 2)}):Play()
                    Config.Callback(State)
                end

                ToggleFrame.MouseButton1Click:Connect(function() State = not State; Update() end)
                Update()

                local TObject = { SetValue = function(_, v) State = v; Update() end }

                -- Klavye Kısayolları İçin Rozet Yapısı (.badge.key)
                function TObject:AddKeyPicker(KeyIdx, KeyConfig)
                    local Badge = Instance.new("TextButton")
                    Badge.Size = UDim2.new(0, 26, 0, 18)
                    Badge.Position = UDim2.new(1, -66, 0.5, -9)
                    Badge.BackgroundColor3 = Library.BG0
                    Badge.BorderColor3 = Library.Gry1
                    Badge.BorderSizePixel = 1
                    Badge.Font = Library.Font
                    Badge.Text = KeyConfig.Default or "None"
                    Badge.TextColor3 = Library.Pur3
                    Badge.TextSize = 10
                    Badge.Parent = Row

                    local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0, 4) bc.Parent = Badge

                    local CurrentKey = KeyConfig.Default or "None"
                    Badge.MouseButton1Click:Connect(function()
                        Badge.Text = "..."
                        local c; c = UserInputService.InputBegan:Connect(function(io)
                            if io.UserInputType == Enum.UserInputType.Keyboard then
                                CurrentKey = io.KeyCode.Name
                                Badge.Text = CurrentKey
                                c:Disconnect()
                            end
                        end)
                    end)

                    UserInputService.InputBegan:Connect(function(io)
                        if io.UserInputType == Enum.UserInputType.Keyboard and io.KeyCode.Name == CurrentKey then
                            if KeyConfig.SyncToggleState then State = not State; Update() end
                        end
                    end)
                end

                return TObject
            end

            -- İnce Çizgili Kaydırma Çubuğu Sistemi (.range-wrap)
            function BOX:AddSlider(Idx, Config)
                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 26)
                Row.BackgroundTransparency = 1
                Row.Parent = Box

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0, 120, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Library.Font
                Label.Text = Config.Text or "Slider"
                Label.TextColor3 = Library.Txt3
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local SliderBack = Instance.new("TextButton")
                SliderBack.Size = UDim2.new(0, 110, 0, 4)
                SliderBack.Position = UDim2.new(1, -145, 0.5, -2)
                SliderBack.BackgroundColor3 = Library.Gry1
                SliderBack.BorderSizePixel = 0
                SliderBack.Text = ""
                SliderBack.Parent = Row

                local SliderFill = Instance.new("Frame")
                SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
                SliderFill.BackgroundColor3 = Library.Pur2
                SliderFill.BorderSizePixel = 0
                SliderFill.Parent = SliderBack

                local Thumb = Instance.new("Frame")
                Thumb.Size = UDim2.new(0, 12, 0, 12)
                Thumb.Position = UDim2.new(0.5, -6, 0.5, -6)
                Thumb.BackgroundColor3 = Library.Pur2
                Thumb.BorderColor3 = Library.BG1
                Thumb.BorderSizePixel = 2
                Thumb.Parent = SliderBack
                local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1,0) tc.Parent = Thumb

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0, 30, 1, 0)
                ValLabel.Position = UDim2.new(1, -30, 0, 0)
                ValLabel.BackgroundTransparency = 1
                ValLabel.Font = Library.Font
                ValLabel.Text = tostring(Config.Default or Config.Min)
                ValLabel.TextColor3 = Library.Pur3
                ValLabel.TextSize = 11
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.Parent = Row

                local function Update(Perc)
                    Perc = math.clamp(Perc, 0, 1)
                    SliderFill.Size = UDim2.new(Perc, 0, 1, 0)
                    Thumb.Position = UDim2.new(Perc, -6, 0.5, -6)
                    local rawVal = Config.Min + (Config.Max - Config.Min) * Perc
                    if Config.Step then
                        rawVal = math.round(rawVal / Config.Step) * Config.Step
                    else
                        rawVal = math.floor(rawVal)
                    end
                    ValLabel.Text = tostring(rawVal)
                    Config.Callback(rawVal)
                end

                local Sliding = false
                SliderBack.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = true
                        Update((i.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end end)
                UserInputService.InputChanged:Connect(function(i)
                    if Sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                        Update((i.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X)
                    end
                end)

                Update(((Config.Default or Config.Min) - Config.Min) / (Config.Max - Config.Min))
                return { SetValue = function(_, v) Update((v - Config.Min) / (Config.Max - Config.Min)) end }
            end

            -- Modern Seçim Kutusu Sistemi (.select)
            function BOX:AddDropdown(Idx, Config)
                local Row = Instance.new("Frame")
                Row.Size = UDim2.new(1, 0, 0, 26)
                Row.BackgroundTransparency = 1
                Row.Parent = Box

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0, 120, 1, 0)
                Label.BackgroundTransparency = 1
                Label.Font = Library.Font
                Label.Text = Config.Text or "Dropdown"
                Label.TextColor3 = Library.Txt2
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = Row

                local DropdownBtn = Instance.new("TextButton")
                DropdownBtn.Size = UDim2.new(0, 160, 0, 22)
                DropdownBtn.Position = UDim2.new(1, -160, 0.5, -11)
                DropdownBtn.BackgroundColor3 = Library.BG3
                DropdownBtn.BorderColor3 = Library.Gry1
                DropdownBtn.Font = Library.Font
                DropdownBtn.Text = "Select option..."
                DropdownBtn.TextColor3 = Library.Txt1
                DropdownBtn.TextSize = 12
                DropdownBtn.Parent = Row
                local dc = Instance.new("UICorner") dc.CornerRadius = UDim.new(0, 4) dc.Parent = DropdownBtn

                local DropList = Instance.new("Frame")
                DropList.Size = UDim2.new(1, 0, 0, 0)
                DropList.Position = UDim2.new(0, 0, 1, 2)
                DropList.BackgroundColor3 = Library.BG3
                DropList.BorderColor3 = Library.Gry1
                DropList.Visible = false
                DropList.ZIndex = 8
                DropList.Parent = DropdownBtn

                local dl = Instance.new("UIListLayout") dl.SortOrder = Enum.SortOrder.LayoutOrder dl.Parent = DropList

                local Open = false
                local Values = Config.Values or {}
                local Selected = {}

                local function Rebuild()
                    for _, c in pairs(DropList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for _, val in pairs(Values) do
                        local Item = Instance.new("TextButton")
                        Item.Size = UDim2.new(1, 0, 0, 20)
                        Item.BackgroundColor3 = Library.BG3
                        Item.BorderSizePixel = 0
                        Item.Font = Library.Font
                        Item.Text = "  " .. tostring(val)
                        Item.TextColor3 = Selected[val] and Library.Pur2 or Library.Txt2
                        Item.TextSize = 11
                        Item.TextXAlignment = Enum.TextXAlignment.Left
                        Item.ZIndex = 9
                        Item.Parent = DropList

                        Item.MouseButton1Click:Connect(function()
                            if Config.Multi then
                                Selected[val] = not Selected[val]
                                Item.TextColor3 = Selected[val] and Library.Pur2 or Library.Txt2
                                local t = {} for k, v in pairs(Selected) do if v then table.insert(t, k) end end
                                DropdownBtn.Text = #t > 0 and table.concat(t, ", ") or "None"
                                Config.Callback(Selected)
                            else
                                Selected = {} Selected[val] = true
                                DropdownBtn.Text = tostring(val)
                                Open = false DropList.Visible = false
                                Config.Callback(val)
                            end
                        end)
                    end
                end

                DropdownBtn.MouseButton1Click:Connect(function()
                    Open = not Open
                    DropList.Visible = Open
                    DropList.Size = Open and UDim2.new(1, 0, 0, #Values * 20) or UDim2.new(1, 0, 0, 0)
                end)

                Rebuild()
                return { SetValues = function(_, nv) Values = nv Selected = {} DropdownBtn.Text = "None" Rebuild() end }
            end

            function BOX:AddDivider()
                local Div = Instance.new("Frame")
                Div.Size = UDim2.new(1, 0, 0, 1)
                Div.BackgroundColor3 = Library.BG3
                Div.BorderSizePixel = 0
                Div.Parent = Box
            end

            return BOX
        end

        function Tab:AddLeftGroupbox(Title) return Tab:CreateGroupbox(Title, "Left") end
        function Tab:AddRightGroupbox(Title) return Tab:CreateGroupbox(Title, "Right") end

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
