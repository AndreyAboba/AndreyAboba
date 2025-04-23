-- Модуль для управления меню (вкладки Main, Autofarm, Settings, TopBar)
print('1')
local function InitMenu(MainFrame, Core, CurrentTab, ChatSection, OutputSection, ChatLocation)
    local SectionFrames = {}
    local CurrentSection = "Main"

    -- Создаём BlurEffect и изначально отключаем его
    local Blur = Instance.new("BlurEffect")
    Blur.Size = 0 -- Изначально выключен
    Blur.Parent = game:GetService("Lighting")
    local BlurEnabled = false

    -- Верхняя полоска с логотипом, текстом и вкладками
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TopBar.BackgroundTransparency = 0
    TopBar.BorderSizePixel = 1
    TopBar.BorderColor3 = Color3.fromRGB(50, 50, 50)
    TopBar.Parent = MainFrame

    -- Логотип (круг с сегментами) в левом углу
    local LogoContainer = Instance.new("Frame")
    LogoContainer.Size = UDim2.new(0, 28, 0, 28)
    LogoContainer.Position = UDim2.new(0, 5, 0.5, -14)
    LogoContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    LogoContainer.BackgroundTransparency = 0
    LogoContainer.BorderSizePixel = 1
    LogoContainer.BorderColor3 = Color3.fromRGB(50, 50, 50)
    LogoContainer.Parent = TopBar

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 14)
    LogoCorner.Parent = LogoContainer

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(0, 20, 0, 20)
    LogoFrame.Position = UDim2.new(0.5, -10, 0.5, -10)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = LogoContainer

    local LogoConstraint = Instance.new("UISizeConstraint")
    LogoConstraint.MaxSize = Vector2.new(28, 28)
    LogoConstraint.MinSize = Vector2.new(28, 28)
    LogoConstraint.Parent = LogoContainer

    local LogoSegments = {}
    local segmentCount = 12
    for i = 1, segmentCount do
        local segment = Instance.new("ImageLabel")
        segment.Size = UDim2.new(1, 0, 1, 0)
        segment.BackgroundTransparency = 1
        segment.Image = "rbxassetid://7151778302"
        segment.ImageTransparency = 0.4
        segment.Rotation = (i - 1) * (360 / segmentCount)
        segment.Parent = LogoFrame
        Instance.new("UICorner", segment).CornerRadius = UDim.new(0.5, 0)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value)
        gradient.Rotation = (i - 1) * (360 / segmentCount)
        gradient.Parent = segment
        LogoSegments[i] = { Segment = segment, Gradient = gradient }
    end

    -- Фон для текста "Syllinse"
    local TitleFrame = Instance.new("Frame")
    TitleFrame.Size = UDim2.new(0, 100, 0, 24)
    TitleFrame.Position = UDim2.new(0, 38, 0.5, -12)
    TitleFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    TitleFrame.BackgroundTransparency = 0
    TitleFrame.BorderSizePixel = 1
    TitleFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    TitleFrame.Parent = TopBar

    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 5)
    TitleCorner.Parent = TitleFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Syllinse"
    TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TitleLabel.TextSize = 18
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = TitleFrame

    -- Разделитель (вертикальная линия) между Syllinse и Loader
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(0, 2, 0, 20)
    Divider.Position = UDim2.new(0, 150, 0.5, -10)
    Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Divider.BorderSizePixel = 0
    Divider.Parent = TopBar

    -- Кнопка "Loader" в стиле вкладки
    local LoaderTab = Instance.new("TextButton")
    LoaderTab.Size = UDim2.new(0, 80, 0, 24)
    LoaderTab.Position = UDim2.new(0, 160, 0.5, -12)
    LoaderTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    LoaderTab.BackgroundTransparency = CurrentTab.Value == "Loader" and 0 or 0.2
    LoaderTab.Text = "Loader"
    LoaderTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoaderTab.TextSize = 14
    LoaderTab.Font = Enum.Font.Gotham
    LoaderTab.BorderSizePixel = 1
    LoaderTab.BorderColor3 = Color3.fromRGB(50, 50, 50)
    LoaderTab.Parent = TopBar

    local LoaderTabCorner = Instance.new("UICorner")
    LoaderTabCorner.CornerRadius = UDim.new(0, 5)
    LoaderTabCorner.Parent = LoaderTab

    -- Разделитель (вертикальная линия) между Loader и Chat
    local LoaderChatDivider = Instance.new("Frame")
    LoaderChatDivider.Size = UDim2.new(0, 2, 0, 20)
    LoaderChatDivider.Position = UDim2.new(0, 250, 0.5, -10)
    LoaderChatDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    LoaderChatDivider.BorderSizePixel = 0
    LoaderChatDivider.Parent = TopBar

    -- Кнопка "Chat" в стиле вкладки
    local ChatTab = Instance.new("TextButton")
    ChatTab.Size = UDim2.new(0, 80, 0, 24)
    ChatTab.Position = UDim2.new(0, 260, 0.5, -12)
    ChatTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    ChatTab.BackgroundTransparency = CurrentTab.Value == "Chat" and 0 or 0.2
    ChatTab.Text = "Chat"
    ChatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChatTab.TextSize = 14
    ChatTab.Font = Enum.Font.Gotham
    ChatTab.BorderSizePixel = 1
    ChatTab.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ChatTab.Parent = TopBar

    local ChatTabCorner = Instance.new("UICorner")
    ChatTabCorner.CornerRadius = UDim.new(0, 5)
    ChatTabCorner.Parent = ChatTab

    -- Разделитель (вертикальная линия) между Chat и Output
    local ChatOutputDivider = Instance.new("Frame")
    ChatOutputDivider.Size = UDim2.new(0, 2, 0, 20)
    ChatOutputDivider.Position = UDim2.new(0, 350, 0.5, -10)
    ChatOutputDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ChatOutputDivider.BorderSizePixel = 0
    ChatOutputDivider.Parent = TopBar

    -- Кнопка "Output" в стиле вкладки
    local OutputTab = Instance.new("TextButton")
    OutputTab.Size = UDim2.new(0, 80, 0, 24)
    OutputTab.Position = UDim2.new(0, 360, 0.5, -12)
    OutputTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    OutputTab.BackgroundTransparency = CurrentTab.Value == "Output" and 0 or 0.2
    OutputTab.Text = "Output"
    OutputTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    OutputTab.TextSize = 14
    OutputTab.Font = Enum.Font.Gotham
    OutputTab.BorderSizePixel = 1
    OutputTab.BorderColor3 = Color3.fromRGB(50, 50, 50)
    OutputTab.Parent = TopBar

    local OutputTabCorner = Instance.new("UICorner")
    OutputTabCorner.CornerRadius = UDim.new(0, 5)
    OutputTabCorner.Parent = OutputTab

    -- Анимация градиента для логотипа
    local GradientTime = 0
    local LastGradientUpdate = 0
    local GradientSpeed = 0.5
    local GradientUpdateInterval = 0.02

    local function updateGradients(deltaTime)
        LastGradientUpdate = LastGradientUpdate + deltaTime
        if LastGradientUpdate < GradientUpdateInterval then return end

        GradientTime = GradientTime + LastGradientUpdate * GradientSpeed
        LastGradientUpdate = 0
        local t = (math.sin(GradientTime) + 1) / 2
        local color1, color2 = Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value

        for _, segmentData in ipairs(LogoSegments) do
            segmentData.Gradient.Color = ColorSequence.new(color1:Lerp(color2, t), color2:Lerp(color1, t))
        end
    end

    Core.Services.RunService.Heartbeat:Connect(updateGradients)

    -- Бокая панель
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Sidebar.BackgroundTransparency = 0
    Sidebar.BorderSizePixel = 1
    Sidebar.BorderColor3 = Color3.fromRGB(50, 50, 50)
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.Padding = UDim.new(0, 5)
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Parent = Sidebar

    -- Кнопки боковой панели с иконками
    local Sections = {
        { Name = "Main", Icon = "rbxassetid://18821914323" },
        { Name = "Autofarm", Icon = "rbxassetid://18821914323" },
        { Name = "Settings", Icon = "rbxassetid://18821914323" }
    }

    for i, section in ipairs(Sections) do
        local SectionButton = Instance.new("TextButton")
        SectionButton.Size = UDim2.new(1, -10, 0, 40)
        SectionButton.Position = UDim2.new(0, 5, 0, 0)
        SectionButton.BackgroundColor3 = CurrentSection == section.Name and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(15, 15, 15)
        SectionButton.BackgroundTransparency = 0
        SectionButton.BorderSizePixel = 1
        SectionButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
        SectionButton.Text = ""
        SectionButton.LayoutOrder = i
        SectionButton.Parent = Sidebar

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = SectionButton

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 20, 0, 20)
        Icon.Position = UDim2.new(0, 10, 0, 10)
        Icon.BackgroundTransparency = 1
        Icon.Image = section.Icon
        Icon.Parent = SectionButton

        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -40, 1, 0)
        Label.Position = UDim2.new(0, 40, 0, 0)
        Label.BackgroundTransparency = 1
        Label.Text = section.Name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 16
        Label.Font = Enum.Font.SourceSans -- Более минималистичный шрифт
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = SectionButton

        SectionButton.MouseButton1Click:Connect(function()
            if CurrentTab.Value == "Chat" or CurrentTab.Value == "Output" then return end
            CurrentSection = section.Name
            CurrentTab.Value = "Loader"
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.TextLabel.Text == section.Name and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(15, 15, 15)
                    btn.BackgroundTransparency = 0
                end
            end
            for secName, frame in pairs(SectionFrames) do
                frame.Visible = (secName == section.Name) and (CurrentTab.Value == "Loader")
            end
            LoaderTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            LoaderTab.BackgroundTransparency = 0
            ChatTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            ChatTab.BackgroundTransparency = 0.2
            OutputTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            OutputTab.BackgroundTransparency = 0.2
            ChatSection.Position = UDim2.new(0, 150, 0, 40)
            ChatSection.Size = UDim2.new(1, -150, 0, 350)
            OutputSection.Position = UDim2.new(0, 150, 1, -110)
            OutputSection.Size = UDim2.new(1, -150, 0, 110)
            ChatSection.Visible = ChatLocation == "InMenu" and CurrentTab.Value == "Chat"
            OutputSection.Visible = true
            Sidebar.Visible = true
        end)
    end

    -- Контейнер для секций (сверху)
    local SectionContainer = Instance.new("Frame")
    SectionContainer.Size = UDim2.new(1, -150, 0, 350)
    SectionContainer.Position = UDim2.new(0, 150, 0, 40)
    SectionContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    SectionContainer.BackgroundTransparency = 0
    SectionContainer.BorderSizePixel = 1
    SectionContainer.BorderColor3 = Color3.fromRGB(50, 50, 50)
    SectionContainer.Parent = MainFrame

    -- Секция Main (бывшая Load)
    local MainSection = Instance.new("Frame")
    MainSection.Size = UDim2.new(1, 0, 1, 0)
    MainSection.BackgroundTransparency = 1
    MainSection.Visible = true
    MainSection.Parent = SectionContainer
    SectionFrames["Main"] = MainSection

    local ModuleList = Instance.new("ScrollingFrame")
    ModuleList.Size = UDim2.new(1, -20, 1, -60)
    ModuleList.Position = UDim2.new(0, 10, 0, 40)
    ModuleList.BackgroundTransparency = 1
    ModuleList.BorderSizePixel = 0
    ModuleList.CanvasSize = UDim2.new(0, 0, 0, #Core.Modules * 50)
    ModuleList.ScrollBarThickness = 6
    ModuleList.Parent = MainSection

    local ModuleListLayout = Instance.new("UIListLayout")
    ModuleListLayout.Padding = UDim.new(0, 5)
    ModuleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ModuleListLayout.Parent = ModuleList

    local LoadButton = Instance.new("TextButton")
    LoadButton.Size = UDim2.new(1, -20, 0, 40)
    LoadButton.Position = UDim2.new(0, 10, 1, -50)
    LoadButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    LoadButton.BackgroundTransparency = 0
    LoadButton.Text = "Load Selected Modules"
    LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoadButton.TextSize = 16
    LoadButton.Font = Enum.Font.GothamBold
    LoadButton.BorderSizePixel = 1
    LoadButton.BorderColor3 = Color3.fromRGB(50, 50, 50)
    LoadButton.Parent = MainSection

    local LoadButtonCorner = Instance.new("UICorner")
    LoadButtonCorner.CornerRadius = UDim.new(0, 8)
    LoadButtonCorner.Parent = LoadButton

    -- Заголовок и линия для Main
    local MainLabel = Instance.new("TextLabel")
    MainLabel.Size = UDim2.new(1, -20, 0, 30)
    MainLabel.Position = UDim2.new(0, 10, 0, 10)
    MainLabel.BackgroundTransparency = 1
    MainLabel.Text = "Main"
    MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MainLabel.TextSize = 16
    MainLabel.Font = Enum.Font.GothamBold
    MainLabel.TextXAlignment = Enum.TextXAlignment.Left
    MainLabel.Parent = MainSection

    local MainDivider = Instance.new("Frame")
    MainDivider.Size = UDim2.new(1, -20, 0, 2)
    MainDivider.Position = UDim2.new(0, 10, 0, 40)
    MainDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MainDivider.BorderSizePixel = 0
    MainDivider.Parent = MainSection

    -- Секция Autofarm (пока пустая)
    local AutofarmSection = Instance.new("Frame")
    AutofarmSection.Size = UDim2.new(1, 0, 1, 0)
    AutofarmSection.BackgroundTransparency = 1
    AutofarmSection.Visible = false
    AutofarmSection.Parent = SectionContainer
    SectionFrames["Autofarm"] = AutofarmSection

    local AutofarmLabel = Instance.new("TextLabel")
    AutofarmLabel.Size = UDim2.new(1, -20, 0, 30)
    AutofarmLabel.Position = UDim2.new(0, 10, 0, 10)
    AutofarmLabel.BackgroundTransparency = 1
    AutofarmLabel.Text = "Autofarm"
    AutofarmLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutofarmLabel.TextSize = 16
    AutofarmLabel.Font = Enum.Font.GothamBold
    AutofarmLabel.TextXAlignment = Enum.TextXAlignment.Left
    AutofarmLabel.Parent = AutofarmSection

    local AutofarmDivider = Instance.new("Frame")
    AutofarmDivider.Size = UDim2.new(1, -20, 0, 2)
    AutofarmDivider.Position = UDim2.new(0, 10, 0, 40)
    AutofarmDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    AutofarmDivider.BorderSizePixel = 0
    AutofarmDivider.Parent = AutofarmSection

    -- Секция Settings
    local SettingsSection = Instance.new("Frame")
    SettingsSection.Size = UDim2.new(1, 0, 1, 0)
    SettingsSection.BackgroundTransparency = 1
    SettingsSection.Visible = false
    SettingsSection.Parent = SectionContainer
    SectionFrames["Settings"] = SettingsSection

    local SettingsLabel = Instance.new("TextLabel")
    SettingsLabel.Size = UDim2.new(1, -20, 0, 30)
    SettingsLabel.Position = UDim2.new(0, 10, 0, 10)
    SettingsLabel.BackgroundTransparency = 1
    SettingsLabel.Text = "Settings"
    SettingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsLabel.TextSize = 16
    SettingsLabel.Font = Enum.Font.GothamBold
    SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    SettingsLabel.Parent = SettingsSection

    local SettingsDivider = Instance.new("Frame")
    SettingsDivider.Size = UDim2.new(1, -20, 0, 2)
    SettingsDivider.Position = UDim2.new(0, 10, 0, 40)
    SettingsDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    SettingsDivider.BorderSizePixel = 0
    SettingsDivider.Parent = SettingsSection

    -- Контейнер для Chat Location
    local ChatLocationContainer = Instance.new("Frame")
    ChatLocationContainer.Size = UDim2.new(1, -20, 0, 60)
    ChatLocationContainer.Position = UDim2.new(0, 10, 0, 50)
    ChatLocationContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    ChatLocationContainer.BackgroundTransparency = 0
    ChatLocationContainer.BorderSizePixel = 1
    ChatLocationContainer.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ChatLocationContainer.Parent = SettingsSection

    local ChatLocationContainerCorner = Instance.new("UICorner")
    ChatLocationContainerCorner.CornerRadius = UDim.new(0, 4)
    ChatLocationContainerCorner.Parent = ChatLocationContainer

    local ChatLocationLabel = Instance.new("TextLabel")
    ChatLocationLabel.Size = UDim2.new(1, -10, 0, 20)
    ChatLocationLabel.Position = UDim2.new(0, 5, 0, 5)
    ChatLocationLabel.BackgroundTransparency = 1
    ChatLocationLabel.Text = "Chat Location"
    ChatLocationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChatLocationLabel.TextSize = 14
    ChatLocationLabel.Font = Enum.Font.Gotham
    ChatLocationLabel.TextXAlignment = Enum.TextXAlignment.Left
    ChatLocationLabel.Parent = ChatLocationContainer

    local ChatLocationFrame = Instance.new("Frame")
    ChatLocationFrame.Size = UDim2.new(0, 80, 0, 20)
    ChatLocationFrame.Position = UDim2.new(0, 5, 0, 30)
    ChatLocationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ChatLocationFrame.BackgroundTransparency = 0
    ChatLocationFrame.BorderSizePixel = 1
    ChatLocationFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    ChatLocationFrame.Parent = ChatLocationContainer

    local ChatLocationCorner = Instance.new("UICorner")
    ChatLocationCorner.CornerRadius = UDim.new(1, 0)
    ChatLocationCorner.Parent = ChatLocationFrame

    local ChatLocationIndicator = Instance.new("Frame")
    ChatLocationIndicator.Size = UDim2.new(0, 40, 0, 20)
    ChatLocationIndicator.Position = ChatLocation == "InMenu" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 40, 0, 0)
    ChatLocationIndicator.BackgroundColor3 = ChatLocation == "InMenu" and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(147, 112, 219) -- Исправлены цвета
    ChatLocationIndicator.Parent = ChatLocationFrame

    local ChatLocationIndicatorCorner = Instance.new("UICorner")
    ChatLocationIndicatorCorner.CornerRadius = UDim.new(1, 0)
    ChatLocationIndicatorCorner.Parent = ChatLocationIndicator

    local ChatLocationText = Instance.new("TextLabel")
    ChatLocationText.Size = UDim2.new(1, 0, 1, 0)
    ChatLocationText.BackgroundTransparency = 1
    ChatLocationText.Text = ChatLocation == "InMenu" and "In Menu" or "As Output"
    ChatLocationText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ChatLocationText.TextSize = 14
    ChatLocationText.Font = Enum.Font.Gotham
    ChatLocationText.TextXAlignment = Enum.TextXAlignment.Center
    ChatLocationText.Parent = ChatLocationFrame

    -- Контейнер для переключателя Blur Effect
    local BlurContainer = Instance.new("Frame")
    BlurContainer.Size = UDim2.new(1, -20, 0, 60)
    BlurContainer.Position = UDim2.new(0, 10, 0, 120)
    BlurContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    BlurContainer.BackgroundTransparency = 0
    BlurContainer.BorderSizePixel = 1
    BlurContainer.BorderColor3 = Color3.fromRGB(50, 50, 50)
    BlurContainer.Parent = SettingsSection

    local BlurContainerCorner = Instance.new("UICorner")
    BlurContainerCorner.CornerRadius = UDim.new(0, 4)
    BlurContainerCorner.Parent = BlurContainer

    local BlurLabel = Instance.new("TextLabel")
    BlurLabel.Size = UDim2.new(1, -10, 0, 20)
    BlurLabel.Position = UDim2.new(0, 5, 0, 5)
    BlurLabel.BackgroundTransparency = 1
    BlurLabel.Text = "Blur Effect"
    BlurLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    BlurLabel.TextSize = 14
    BlurLabel.Font = Enum.Font.Gotham
    BlurLabel.TextXAlignment = Enum.TextXAlignment.Left
    BlurLabel.Parent = BlurContainer

    local BlurToggleFrame = Instance.new("Frame")
    BlurToggleFrame.Size = UDim2.new(0, 40, 0, 20)
    BlurToggleFrame.Position = UDim2.new(0, 5, 0, 30)
    BlurToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    BlurToggleFrame.BackgroundTransparency = 0
    BlurToggleFrame.BorderSizePixel = 1
    BlurToggleFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
    BlurToggleFrame.Parent = BlurContainer

    local BlurToggleCorner = Instance.new("UICorner")
    BlurToggleCorner.CornerRadius = UDim.new(1, 0)
    BlurToggleCorner.Parent = BlurToggleFrame

    local BlurToggleIndicator = Instance.new("Frame")
    BlurToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    BlurToggleIndicator.Position = UDim2.new(0, 0, 0, 0)
    BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    BlurToggleIndicator.Parent = BlurToggleFrame

    local BlurIndicatorCorner = Instance.new("UICorner")
    BlurIndicatorCorner.CornerRadius = UDim.new(1, 0)
    BlurIndicatorCorner.Parent = BlurToggleIndicator

    BlurToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            BlurEnabled = not BlurEnabled
            Core.Services.TweenService:Create(
                BlurToggleIndicator,
                TweenInfo.new(0.2),
                {Position = BlurEnabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)}
            ):Play()
            BlurToggleIndicator.BackgroundColor3 = BlurEnabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(80, 80, 80)
            Blur.Size = BlurEnabled and 10 or 0
        end
    end)

    -- Создание UI для каждого модуля в секции Main
    for i, module in ipairs(Core.Modules) do
        local ModuleFrame = Instance.new("Frame")
        ModuleFrame.Size = UDim2.new(1, 0, 0, 40)
        ModuleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        ModuleFrame.BackgroundTransparency = 0
        ModuleFrame.BorderSizePixel = 1
        ModuleFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        ModuleFrame.LayoutOrder = i
        ModuleFrame.Parent = ModuleList

        local ModuleCorner = Instance.new("UICorner")
        ModuleCorner.CornerRadius = UDim.new(0, 4)
        ModuleCorner.Parent = ModuleFrame

        local ModuleLabel = Instance.new("TextLabel")
        ModuleLabel.Size = UDim2.new(0.7, 0, 1, 0)
        ModuleLabel.Position = UDim2.new(0, 10, 0, 0)
        ModuleLabel.BackgroundTransparency = 1
        ModuleLabel.Text = module.Name
        ModuleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        ModuleLabel.TextSize = 16
        ModuleLabel.Font = Enum.Font.Gotham
        ModuleLabel.TextXAlignment = Enum.TextXAlignment.Left
        ModuleLabel.Parent = ModuleFrame

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
        ToggleFrame.Position = UDim2.new(1, -50, 0, 10)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleFrame.BackgroundTransparency = 0
        ToggleFrame.BorderSizePixel = 1
        ToggleFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
        ToggleFrame.Parent = ModuleFrame

        local ToggleCorner = Instance.new("UICorner")
        ToggleCorner.CornerRadius = UDim.new(1, 0)
        ToggleCorner.Parent = ToggleFrame

        local ToggleIndicator = Instance.new("Frame")
        ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
        ToggleIndicator.Position = module.Enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
        ToggleIndicator.BackgroundColor3 = module.Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(200, 200, 200)
        ToggleIndicator.BackgroundTransparency = 0
        ToggleIndicator.Parent = ToggleFrame

        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = ToggleIndicator

        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                module.Enabled = not module.Enabled
                Core.Services.TweenService:Create(
                    ToggleIndicator,
                    TweenInfo.new(0.2),
                    {Position = module.Enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)}
                ):Play()
                ToggleIndicator.BackgroundColor3 = module.Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(200, 200, 200)
            end
        end)
    end

    -- Обработчик переключения вкладок
    LoaderTab.MouseButton1Click:Connect(function()
        CurrentTab.Value = "Loader"
        LoaderTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        LoaderTab.BackgroundTransparency = 0
        ChatTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        ChatTab.BackgroundTransparency = 0.2
        OutputTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        OutputTab.BackgroundTransparency = 0.2
        ChatSection.Position = UDim2.new(0, 150, 0, 40)
        ChatSection.Size = UDim2.new(1, -150, 0, 350)
        OutputSection.Position = UDim2.new(0, 150, 1, -110)
        OutputSection.Size = UDim2.new(1, -150, 0, 110)
        ChatSection.Visible = ChatLocation == "InMenu" and CurrentTab.Value == "Chat"
        OutputSection.Visible = true
        Sidebar.Visible = true
        for secName, frame in pairs(SectionFrames) do
            frame.Visible = (secName == CurrentSection) and (CurrentTab.Value == "Loader")
        end
    end)

    ChatTab.MouseButton1Click:Connect(function()
        if ChatLocation ~= "InMenu" then return end
        CurrentTab.Value = "Chat"
        LoaderTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        LoaderTab.BackgroundTransparency = 0.2
        ChatTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        ChatTab.BackgroundTransparency = 0
        OutputTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        OutputTab.BackgroundTransparency = 0.2
        for secName, frame in pairs(SectionFrames) do
            frame.Visible = false
        end
        ChatSection.Position = UDim2.new(0, 0, 0, 40)
        ChatSection.Size = UDim2.new(1, 0, 1, -150)
        ChatSection.Visible = true
        OutputSection.Position = UDim2.new(0, 0, 1, -110)
        OutputSection.Size = UDim2.new(1, 0, 0, 110)
        OutputSection.Visible = true
        Sidebar.Visible = false
    end)

    OutputTab.MouseButton1Click:Connect(function()
        CurrentTab.Value = "Output"
        LoaderTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        LoaderTab.BackgroundTransparency = 0.2
        ChatTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        ChatTab.BackgroundTransparency = 0.2
        OutputTab.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        OutputTab.BackgroundTransparency = 0
        for secName, frame in pairs(SectionFrames) do
            frame.Visible = false
        end
        ChatSection.Position = UDim2.new(0, 0, 0, 40)
        ChatSection.Size = UDim2.new(1, 0, 1, -150)
        ChatSection.Visible = false
        OutputSection.Position = UDim2.new(0, 0, 0, 40)
        OutputSection.Size = UDim2.new(1, 0, 1, -40)
        OutputSection.Visible = true
        Sidebar.Visible = false
    end)

    -- Отключаем Blur при загрузке модулей
    LoadButton.MouseButton1Click:Connect(function()
        Blur.Size = 0
        BlurEnabled = false
        if BlurToggleIndicator then
            BlurToggleIndicator.Position = UDim2.new(0, 0, 0, 0)
            BlurToggleIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)

    return {
        Sidebar = Sidebar,
        SectionFrames = SectionFrames,
        CurrentSection = CurrentSection,
        LoadButton = LoadButton,
        ChatLocationFrame = ChatLocationFrame,
        ChatLocationIndicator = ChatLocationIndicator,
        ChatLocationText = ChatLocationText,
        TopBar = TopBar,
        ChatTab = ChatTab,
        OutputTab = OutputTab
    }
end

return {
    InitMenu = InitMenu
}
