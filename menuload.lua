local function createMenu(Core)
    local Logs, ChatMessages, DisplayedMessageIds, FriendsList, Usernames = {}, {}, {}, {}, {}
    local UserId = LRM_LinkedDiscordID and tostring(LRM_LinkedDiscordID) ~= "" and tostring(LRM_LinkedDiscordID) or tostring(math.random(1000,9999))
    local FIREBASE_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/messages.json"
    local FRIENDS_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/friends.json"
    local USERNAMES_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/usernames.json"
    local PRIVATE_MESSAGES_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/private_messages.json"
    local ChatLocation, PlaceId, CurrentTab, CurrentSection = "InMenu", game.PlaceId, "Loader", "Main"
    local BlurEnabled, LastMessageTime, LastJobIdTime, MESSAGE_COOLDOWN, JOBID_COOLDOWN = true, 0, 0, 10, 60

    local BlurEffect = Instance.new("BlurEffect", Core.Services.Lighting)
    BlurEffect.Name, BlurEffect.Size, BlurEffect.Enabled = "SyllinseLoaderBlur", 24, BlurEnabled

    local ScreenGui = Instance.new("ScreenGui", Core.Services.CoreGuiService)
    ScreenGui.Name, ScreenGui.IgnoreGuiInset, ScreenGui.ResetOnSpawn, ScreenGui.ZIndexBehavior, ScreenGui.DisplayOrder =
        "SyllinseLoader", true, false, Enum.ZIndexBehavior.Sibling, 2147483647

    ScreenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        BlurEffect.Enabled = ScreenGui.Enabled and BlurEnabled
    end)

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Size, MainFrame.Position, MainFrame.BackgroundColor3, MainFrame.BackgroundTransparency, MainFrame.BorderSizePixel =
        UDim2.new(0, 650, 0, 550), UDim2.new(0.5, -325, 0.5, -275), Color3.fromRGB(10, 10, 15), 0.1, 0
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local UIGradient = Instance.new("UIGradient", MainFrame)
    UIGradient.Color, UIGradient.Rotation = ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value), 45

    local TopBar = Instance.new("Frame", MainFrame)
    TopBar.Size, TopBar.BackgroundColor3, TopBar.BackgroundTransparency, TopBar.BorderSizePixel =
        UDim2.new(1, 0, 0, 50), Color3.fromRGB(15, 15, 20), 0.2, 0

    local TopBarGradient = Instance.new("UIGradient", TopBar)
    TopBarGradient.Color, TopBarGradient.Rotation = ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value), 45

    local TitleLabel = Instance.new("TextLabel", TopBar)
    TitleLabel.Size, TitleLabel.Position, TitleLabel.BackgroundTransparency, TitleLabel.Text, TitleLabel.TextColor3,
    TitleLabel.TextSize, TitleLabel.Font, TitleLabel.TextXAlignment =
        UDim2.new(0, 150, 0, 30), UDim2.new(0, 15, 0.5, -15), 1, "Syllinse", Color3.fromRGB(255, 255, 255),
        20, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local TabsContainer = Instance.new("Frame", TopBar)
    TabsContainer.Size, TabsContainer.Position, TabsContainer.BackgroundTransparency =
        UDim2.new(0, 200, 0, 30), UDim2.new(1, -210, 0.5, -15), 1

    local TabsList = Instance.new("UIListLayout", TabsContainer)
    TabsList.FillDirection, TabsList.HorizontalAlignment, TabsList.Padding =
        Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right, UDim.new(0, 10)

    local LoaderTab = Instance.new("TextButton", TabsContainer)
    LoaderTab.Size, LoaderTab.BackgroundColor3, LoaderTab.BackgroundTransparency, LoaderTab.Text, LoaderTab.TextColor3,
    LoaderTab.TextSize, LoaderTab.Font, LoaderTab.BorderSizePixel =
        UDim2.new(0, 80, 0, 30), Color3.fromRGB(25, 25, 30), 0.3, "Loader", Color3.fromRGB(255, 255, 255),
        14, Enum.Font.Montserrat, 0
    Instance.new("UICorner", LoaderTab).CornerRadius = UDim.new(0, 6)

    local LoaderTabGradient = Instance.new("UIGradient", LoaderTab)
    LoaderTabGradient.Color, LoaderTabGradient.Rotation, LoaderTabGradient.Enabled =
        ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value), 45, true

    local ChatTab = Instance.new("TextButton", TabsContainer)
    ChatTab.Size, ChatTab.BackgroundColor3, ChatTab.BackgroundTransparency, ChatTab.Text, ChatTab.TextColor3,
    ChatTab.TextSize, ChatTab.Font, ChatTab.BorderSizePixel =
        UDim2.new(0, 80, 0, 30), Color3.fromRGB(25, 25, 30), 0.3, "Chat", Color3.fromRGB(255, 255, 255),
        14, Enum.Font.Montserrat, 0
    Instance.new("UICorner", ChatTab).CornerRadius = UDim.new(0, 6)

    local ChatTabGradient = Instance.new("UIGradient", ChatTab)
    ChatTabGradient.Color, ChatTabGradient.Rotation, ChatTabGradient.Enabled =
        ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value), 45, false

    local Sidebar = Instance.new("Frame", MainFrame)
    Sidebar.Size, Sidebar.Position, Sidebar.BackgroundColor3, Sidebar.BackgroundTransparency, Sidebar.BorderSizePixel =
        UDim2.new(0, 150, 1, -50), UDim2.new(0, 0, 0, 50), Color3.fromRGB(15, 15, 20), 0.2, 0

    local SidebarGradient = Instance.new("UIGradient", Sidebar)
    SidebarGradient.Color, SidebarGradient.Rotation = ColorSequence.new(Core.GradientColors.Color1.Value, Core.GradientColors.Color2.Value), 45

    local SidebarList = Instance.new("UIListLayout", Sidebar)
    SidebarList.Padding, SidebarList.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder

    local Sections = {
        {Name = "Main", Icon = "rbxassetid://11982164035"},
        {Name = "Autofarm", Icon = "rbxassetid://74133076168703"},
        {Name = "Settings", Icon = "rbxassetid://14134158045"},
        {Name = "Logs & Debug", Icon = "rbxassetid://116108099038795"}
    }

    local SectionFrames = {}
    local DebugList

    for i, section in ipairs(Sections) do
        local SectionButton = Instance.new("TextButton", Sidebar)
        SectionButton.Size, SectionButton.Position, SectionButton.BackgroundColor3, SectionButton.BackgroundTransparency,
        SectionButton.Text, SectionButton.LayoutOrder =
            UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 0), CurrentSection == section.Name and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(20, 20, 25),
            0.3, "", i
        Instance.new("UICorner", SectionButton).CornerRadius = UDim.new(0, 6)

        local Icon = Instance.new("ImageLabel", SectionButton)
        Icon.Size, Icon.Position, Icon.BackgroundTransparency, Icon.Image =
            UDim2.new(0, 20, 0, 20), UDim2.new(0, 10, 0, 10), 1, section.Icon

        local Label = Instance.new("TextLabel", SectionButton)
        Label.Size, Label.Position, Label.BackgroundTransparency, Label.Text, Label.TextColor3, Label.TextSize,
        Label.Font, Label.TextXAlignment, Label.Name =
            UDim2.new(1, -40, 1, 0), UDim2.new(0, 40, 0, 0), 1, section.Name, Color3.fromRGB(255, 255, 255),
            16, Enum.Font.Montserrat, Enum.TextXAlignment.Left, "TextLabel"

        SectionButton.MouseButton1Click:Connect(function()
            if CurrentTab == "Chat" then return end
            CurrentSection, CurrentTab = section.Name, "Loader"
            for _, btn in ipairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = btn.TextLabel.Text == section.Name and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(20, 20, 25)
                end
            end
            for secName, frame in pairs(SectionFrames) do
                if frame then
                    frame.BackgroundTransparency, frame.Visible = secName == section.Name and 0 or 0.3, secName == section.Name
                    if frame.Visible then
                        Core.Services.TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
                    end
                end
            end
            LoaderTabGradient.Enabled, ChatTabGradient.Enabled = true, false
            if ChatSection then ChatSection.Visible = false end
            if OutputSection then
                OutputSection.Position, OutputSection.Size, OutputSection.Visible =
                    UDim2.new(0, 150, 1, -100), UDim2.new(1, -150, 0, 100), ChatLocation ~= "AsOutput"
            end
            if Sidebar then Sidebar.Visible = true end
            if ChatSection and ChatSection.Parent then
                ChatSection.Position = UDim2.new(0, 150, 0, 50)
                ChatSection.Size = UDim2.new(1, -150, 0, 400)
            end
        end)

        SectionButton.MouseEnter:Connect(function()
            Core.Services.TweenService:Create(SectionButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        end)
        SectionButton.MouseLeave:Connect(function()
            Core.Services.TweenService:Create(SectionButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)
    end

    local SectionContainer = Instance.new("Frame", MainFrame)
    SectionContainer.Size, SectionContainer.Position, SectionContainer.BackgroundTransparency =
        UDim2.new(1, -150, 0, 400), UDim2.new(0, 150, 0, 50), 1

    local MainSection = Instance.new("Frame", SectionContainer)
    MainSection.Size, MainSection.BackgroundTransparency, MainSection.BackgroundColor3, MainSection.Visible =
        UDim2.new(1, 0, 1, 0), 0, Color3.fromRGB(30, 30, 40), true
    SectionFrames["Main"] = MainSection

    local MainLabel = Instance.new("TextLabel", MainSection)
    MainLabel.Size, MainLabel.Position, MainLabel.BackgroundTransparency, MainLabel.Text, MainLabel.TextColor3,
    MainLabel.TextSize, MainLabel.Font, MainLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), 1, "Main", Color3.fromRGB(255, 255, 255),
        16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local MainDivider = Instance.new("Frame", MainSection)
    MainDivider.Size, MainDivider.Position, MainDivider.BackgroundColor3, MainDivider.BorderSizePixel =
        UDim2.new(1, -20, 0, 2), UDim2.new(0, 10, 0, 40), Color3.fromRGB(50, 50, 50), 0

    local ModuleList = Instance.new("ScrollingFrame", MainSection)
    ModuleList.Size, ModuleList.Position, ModuleList.BackgroundTransparency, ModuleList.BorderSizePixel,
    ModuleList.CanvasSize, ModuleList.ScrollBarThickness =
        UDim2.new(1, -20, 1, -100), UDim2.new(0, 10, 0, 55), 1, 0, UDim2.new(0, 0, 0, #Core.Modules * 50), 6

    local ModuleListLayout = Instance.new("UIListLayout", ModuleList)
    ModuleListLayout.Padding, ModuleListLayout.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder

    local LoadButton = Instance.new("TextButton", MainSection)
    LoadButton.Size, LoadButton.Position, LoadButton.BackgroundColor3, LoadButton.BackgroundTransparency,
    LoadButton.Text, LoadButton.TextColor3, LoadButton.TextSize, LoadButton.Font =
        UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 1, -50), Color3.fromRGB(40, 40, 50), 0.3,
        "Load Selected Modules", Color3.fromRGB(255, 255, 255), 16, Enum.Font.Montserrat
    Instance.new("UICorner", LoadButton).CornerRadius = UDim.new(0, 8)

    LoadButton.MouseEnter:Connect(function()
        Core.Services.TweenService:Create(LoadButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)
    LoadButton.MouseLeave:Connect(function()
        Core.Services.TweenService:Create(LoadButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
    LoadButton.MouseButton1Down:Connect(function()
        Core.Services.TweenService:Create(LoadButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 38)}):Play()
    end)
    LoadButton.MouseButton1Up:Connect(function()
        Core.Services.TweenService:Create(LoadButton, TweenInfo.new(0.1), {Size = UDim2.new(1, -20, 0, 40)}):Play()
    end)
    LoadButton.MouseButton1Click:Connect(function()
        if Core.UI and Core.UI.loadModules then
            Core.UI.loadModules()
        end
    end)

    local AutofarmSection = Instance.new("Frame", SectionContainer)
    AutofarmSection.Size, AutofarmSection.BackgroundTransparency, AutofarmSection.BackgroundColor3, AutofarmSection.Visible =
        UDim2.new(1, 0, 1, 0), 0.3, Color3.fromRGB(30, 30, 40), false
    SectionFrames["Autofarm"] = AutofarmSection

    local AutofarmLabel = Instance.new("TextLabel", AutofarmSection)
    AutofarmLabel.Size, AutofarmLabel.Position, AutofarmLabel.BackgroundTransparency, AutofarmLabel.Text,
    AutofarmLabel.TextColor3, AutofarmLabel.TextSize, AutofarmLabel.Font, AutofarmLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), 1, "Autofarm", Color3.fromRGB(255, 255, 255),
        14, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local AutofarmDivider = Instance.new("Frame", AutofarmSection)
    AutofarmDivider.Size, AutofarmDivider.Position, AutofarmDivider.BackgroundColor3, AutofarmDivider.BorderSizePixel =
        UDim2.new(1, -20, 0, 2), UDim2.new(0, 10, 0, 40), Color3.fromRGB(50, 50, 50), 0

    local AutofarmPlaceholder = Instance.new("TextLabel", AutofarmSection)
    AutofarmPlaceholder.Size, AutofarmPlaceholder.Position, AutofarmPlaceholder.BackgroundTransparency,
    AutofarmPlaceholder.Text, AutofarmPlaceholder.TextColor3, AutofarmPlaceholder.TextSize, AutofarmPlaceholder.Font,
    AutofarmPlaceholder.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 55), 1, "Coming Soon...", Color3.fromRGB(150, 150, 150),
        14, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local SettingsSection = Instance.new("Frame", SectionContainer)
    SettingsSection.Size, SettingsSection.BackgroundTransparency, SettingsSection.BackgroundColor3, SettingsSection.Visible =
        UDim2.new(1, 0, 1, 0), 0.3, Color3.fromRGB(30, 30, 40), false
    SectionFrames["Settings"] = SettingsSection

    local SettingsLabel = Instance.new("TextLabel", SettingsSection)
    SettingsLabel.Size, SettingsLabel.Position, SettingsLabel.BackgroundTransparency, SettingsLabel.Text,
    SettingsLabel.TextColor3, SettingsLabel.TextSize, SettingsLabel.Font, SettingsLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), 1, "Settings", Color3.fromRGB(255, 255, 255),
        16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local SettingsDivider = Instance.new("Frame", SettingsSection)
    SettingsDivider.Size, SettingsDivider.Position, SettingsDivider.BackgroundColor3, SettingsDivider.BorderSizePixel =
        UDim2.new(1, -20, 0, 2), UDim2.new(0, 10, 0, 40), Color3.fromRGB(50, 50, 50), 0

    local ChatLocationContainer = Instance.new("Frame", SettingsSection)
    ChatLocationContainer.Size, ChatLocationContainer.Position, ChatLocationContainer.BackgroundColor3,
    ChatLocationContainer.BackgroundTransparency, ChatLocationContainer.BorderSizePixel =
        UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 55), Color3.fromRGB(40, 40, 50), 0.3, 0
    Instance.new("UICorner", ChatLocationContainer).CornerRadius = UDim.new(0, 6)

    local ChatLocationLabel = Instance.new("TextLabel", ChatLocationContainer)
    ChatLocationLabel.Size, ChatLocationLabel.Position, ChatLocationLabel.BackgroundTransparency,
    ChatLocationLabel.Text, ChatLocationLabel.TextColor3, ChatLocationLabel.TextSize, ChatLocationLabel.Font,
    ChatLocationLabel.TextXAlignment =
        UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 5), 1, "Chat Location", Color3.fromRGB(255, 255, 255),
        14, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local ChatLocationFrame = Instance.new("Frame", ChatLocationContainer)
    ChatLocationFrame.Size, ChatLocationFrame.Position, ChatLocationFrame.BackgroundColor3 =
        UDim2.new(0, 80, 0, 20), UDim2.new(0, 5, 0, 30), Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", ChatLocationFrame).CornerRadius = UDim.new(1, 0)

    local ChatLocationIndicator = Instance.new("Frame", ChatLocationFrame)
    ChatLocationIndicator.Size, ChatLocationIndicator.Position, ChatLocationIndicator.BackgroundColor3 =
        UDim2.new(0, 40, 0, 20), UDim2.new(0, 0, 0, 0), Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", ChatLocationIndicator).CornerRadius = UDim.new(1, 0)

    local ChatLocationText = Instance.new("TextLabel", ChatLocationFrame)
    ChatLocationText.Size, ChatLocationText.BackgroundTransparency, ChatLocationText.Text,
    ChatLocationText.TextColor3, ChatLocationText.TextSize, ChatLocationText.Font, ChatLocationText.TextXAlignment =
        UDim2.new(1, 0, 1, 0), 1, "In Menu", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat, Enum.TextXAlignment.Center

    local BlurContainer = Instance.new("Frame", SettingsSection)
    BlurContainer.Size, BlurContainer.Position, BlurContainer.BackgroundColor3, BlurContainer.BackgroundTransparency,
    BlurContainer.BorderSizePixel =
        UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 125), Color3.fromRGB(40, 40, 50), 0.3, 0
    Instance.new("UICorner", BlurContainer).CornerRadius = UDim.new(0, 6)

    local BlurLabel = Instance.new("TextLabel", BlurContainer)
    BlurLabel.Size, BlurLabel.Position, BlurLabel.BackgroundTransparency, BlurLabel.Text,
    BlurLabel.TextColor3, BlurLabel.TextSize, BlurLabel.Font, BlurLabel.TextXAlignment =
        UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 5), 1, "Blur Background", Color3.fromRGB(255, 255, 255),
        14, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local BlurFrame = Instance.new("Frame", BlurContainer)
    BlurFrame.Size, BlurFrame.Position, BlurFrame.BackgroundColor3 =
        UDim2.new(0, 80, 0, 20), UDim2.new(0, 5, 0, 30), Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", BlurFrame).CornerRadius = UDim.new(1, 0)

    local BlurEntry = Instance.new("Frame", BlurFrame)
    BlurEntry.Size, BlurEntry.Position, BlurEntry.BackgroundColor3 =
        UDim2.new(0, 40, 0, 20), UDim2.new(1, -40, 0, 0), Color3.fromRGB(70, 130, 255)
    Instance.new("UICorner", BlurEntry).CornerRadius = UDim.new(1, 0)

    local BlurText = Instance.new("TextLabel", BlurFrame)
    BlurText.Size, BlurText.BackgroundTransparency, BlurText.Text, BlurText.TextColor3,
    BlurText.TextSize, BlurText.Font, BlurText.TextXAlignment =
        UDim2.new(1, 0, 1, 0), 1, "Enabled", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat, Enum.TextXAlignment.Center

    local DebugSection = Instance.new("Frame", SectionContainer)
    DebugSection.Size, DebugSection.BackgroundTransparency, DebugSection.BackgroundColor3, DebugSection.Visible =
        UDim2.new(1, 0, 1, 0), 0.3, Color3.fromRGB(30, 30, 40), false
    SectionFrames["Logs & Debug"] = DebugSection

    local DebugLabel = Instance.new("TextLabel", DebugSection)
    DebugLabel.Size, DebugLabel.Position, DebugLabel.BackgroundTransparency, DebugLabel.Text,
    DebugLabel.TextColor3, DebugLabel.TextSize, DebugLabel.Font, DebugLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), 1, "Logs & Debug", Color3.fromRGB(255, 255, 255),
        16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local DebugDivider = Instance.new("Frame", DebugSection)
    DebugDivider.Size, DebugDivider.Position, DebugDivider.BackgroundColor3, DebugDivider.BorderSizePixel =
        UDim2.new(1, -20, 0, 2), UDim2.new(0, 10, 0, 40), Color3.fromRGB(50, 50, 50), 0

    local DebugFilterFrame = Instance.new("Frame", DebugSection)
    DebugFilterFrame.Size, DebugFilterFrame.Position, DebugFilterFrame.BackgroundColor3, DebugFilterFrame.BackgroundTransparency =
        UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 55), Color3.fromRGB(40, 40, 50), 0.3
    Instance.new("UICorner", DebugFilterFrame).CornerRadius = UDim.new(0, 6)

    local DebugFilterLabel = Instance.new("TextLabel", DebugFilterFrame)
    DebugFilterLabel.Size, DebugFilterLabel.Position, DebugFilterLabel.BackgroundTransparency,
    DebugFilterLabel.Text, DebugFilterLabel.TextColor3, DebugFilterLabel.TextSize, DebugFilterLabel.Font =
        UDim2.new(0, 100, 0, 20), UDim2.new(0, -5, 0, 10), 1, "Filter:", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat

    local DebugFilterToggle = Instance.new("Frame", DebugFilterFrame)
    DebugFilterToggle.Size, DebugFilterToggle.Position, DebugFilterToggle.BackgroundColor3 =
        UDim2.new(0, 80, 0, 20), UDim2.new(0, 70, 0, 10), Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", DebugFilterToggle).CornerRadius = UDim.new(1, 0)

    local DebugFilterIndicator = Instance.new("Frame", DebugFilterToggle)
    DebugFilterIndicator.Size, DebugFilterIndicator.Position, DebugFilterIndicator.BackgroundColor3 =
        UDim2.new(0, 40, 0, 20), UDim2.new(0, 0, 0, 0), Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", DebugFilterIndicator).CornerRadius = UDim.new(1, 0)

    local DebugFilterText = Instance.new("TextLabel", DebugFilterToggle)
    DebugFilterText.Size, DebugFilterText.BackgroundTransparency, DebugFilterText.Text,
    DebugFilterText.TextColor3, DebugFilterText.TextSize, DebugFilterText.Font, DebugFilterText.TextXAlignment =
        UDim2.new(1, 0, 1, 0), 1, "All", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat, Enum.TextXAlignment.Center

    local DebugClearButton = Instance.new("TextButton", DebugFilterFrame)
    DebugClearButton.Size, DebugClearButton.Position, DebugClearButton.BackgroundColor3,
    DebugClearButton.Text, DebugClearButton.TextColor3, DebugClearButton.TextSize, DebugClearButton.Font =
        UDim2.new(0, 100, 0, 30), UDim2.new(1, -110, 0, 5), Color3.fromRGB(50, 50, 60),
        "Clear Logs", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat
    Instance.new("UICorner", DebugClearButton).CornerRadius = UDim.new(0, 6)

    local ChatSection = Instance.new("Frame", MainFrame)
    ChatSection.Size, ChatSection.Position, ChatSection.BackgroundTransparency, ChatSection.Visible =
        UDim2.new(1, -150, 0, 400), UDim2.new(0, 150, 0, 50), 1, false

    local ChatLabel = Instance.new("TextLabel", ChatSection)
    ChatLabel.Size, ChatLabel.Position, ChatLabel.BackgroundTransparency, ChatLabel.Text,
    ChatLabel.TextColor3, ChatLabel.TextSize, ChatLabel.Font, ChatLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), 1, "Chat", Color3.fromRGB(255, 255, 255),
        16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local ChatDivider = Instance.new("Frame", ChatSection)
    ChatDivider.Size, ChatDivider.Position, ChatDivider.BackgroundColor3, ChatDivider.BorderSizePixel, ChatDivider.ZIndex =
        UDim2.new(1, -20, 0, 2), UDim2.new(0, 10, 0, 40), Color3.fromRGB(50, 50, 50), 0, 2

    local ChatFrame = Instance.new("Frame", ChatSection)
    ChatFrame.Size, ChatFrame.Position, ChatFrame.BackgroundColor3, ChatFrame.BackgroundTransparency,
    ChatFrame.BorderSizePixel, ChatFrame.BorderColor3, ChatFrame.ZIndex =
        UDim2.new(1, -20, 1, -50), UDim2.new(0, 10, 0, 40), Color3.fromRGB(20, 20, 25), 0.3, 1, Color3.fromRGB(60, 60, 60), 1
    Instance.new("UICorner", ChatFrame).CornerRadius = UDim.new(0, 12)

    local ChatPadding = Instance.new("UIPadding", ChatFrame)
    ChatPadding.PaddingLeft, ChatPadding.PaddingRight, ChatPadding.PaddingTop, ChatPadding.PaddingBottom =
        UDim.new(0, 5), UDim.new(0, 5), UDim.new(0, 5), UDim.new(0, 5)

    local ChatList = Instance.new("ScrollingFrame", ChatFrame)
    ChatList.Size, ChatList.Position, ChatList.BackgroundTransparency, ChatList.BorderSizePixel,
    ChatList.CanvasSize, ChatList.ScrollBarThickness =
        UDim2.new(1, 0, 1, -50), UDim2.new(0, 0, 0, 0), 1, 0, UDim2.new(0, 0, 0, 0), 4

    local ChatListLayout = Instance.new("UIListLayout", ChatList)
    ChatListLayout.Padding, ChatListLayout.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder

    local PMInstructionLabel = Instance.new("TextLabel", ChatFrame)
    PMInstructionLabel.Size, PMInstructionLabel.Position, PMInstructionLabel.BackgroundTransparency,
    PMInstructionLabel.Text, PMInstructionLabel.TextColor3, PMInstructionLabel.TextSize, PMInstructionLabel.Font,
    PMInstructionLabel.TextXAlignment =
        UDim2.new(1, -10, 0, 15), UDim2.new(0, 5, 1, -50), 1,
        "Use /pm <userId> <message> or /pmjobid <userId> to send private messages",
        Color3.fromRGB(150, 150, 150), 12, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local ChatInput = Instance.new("TextBox", ChatFrame)
    ChatInput.Size, ChatInput.Position, ChatInput.BackgroundColor3, ChatInput.Text, ChatInput.PlaceholderText,
    ChatInput.TextColor3, ChatInput.TextSize, ChatInput.Font, ChatInput.TextXAlignment, ChatInput.PlaceholderColor3 =
        UDim2.new(1, -110, 0, 30), UDim2.new(0, 5, 1, -35), Color3.fromRGB(40, 40, 40), "", "Type your message...",
        Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat, Enum.TextXAlignment.Left, Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", ChatInput).CornerRadius = UDim.new(0, 5)

    local ShareJobIdButton = Instance.new("TextButton", ChatFrame)
    ShareJobIdButton.Size, ShareJobIdButton.Position, ShareJobIdButton.BackgroundColor3,
    ShareJobIdButton.Text, ShareJobIdButton.TextColor3, ShareJobIdButton.TextSize, ShareJobIdButton.Font =
        UDim2.new(0, 100, 0, 30), UDim2.new(1, -105, 1, -35), Color3.fromRGB(80, 80, 80),
        "Share JobId", Color3.fromRGB(255, 255, 255), 14, Enum.Font.Montserrat
    Instance.new("UICorner", ShareJobIdButton).CornerRadius = UDim.new(0, 5)

    local OutputSection = Instance.new("Frame", MainFrame)
    OutputSection.Size, OutputSection.Position, OutputSection.BackgroundColor3 =
        UDim2.new(1, -150, 0, 100), UDim2.new(0, 150, 1, -100), Color3.fromRGB(18, 18, 18)

    local OutputLabel = Instance.new("TextLabel", OutputSection)
    OutputLabel.Size, OutputLabel.Position, OutputLabel.BackgroundTransparency, OutputLabel.Text,
    OutputLabel.TextColor3, OutputLabel.TextSize, OutputLabel.Font, OutputLabel.TextXAlignment =
        UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 0), 1, "Output", Color3.fromRGB(255, 255, 255),
        16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

    local OutputList = Instance.new("ScrollingFrame", OutputSection)
    OutputList.Size, OutputList.Position, OutputList.BackgroundTransparency, OutputList.BorderSizePixel,
    OutputList.CanvasSize, OutputList.ScrollBarThickness =
        UDim2.new(1, -20, 1, -30), UDim2.new(0, 10, 0, 20), 1, 0, UDim2.new(0, 0, 0, 0), 6

    local OutputListLayout = Instance.new("UIListLayout", OutputList)
    OutputListLayout.Padding, OutputListLayout.SortOrder = UDim.new(0, 5), Enum.SortOrder.LayoutOrder

    for i, module in ipairs(Core.Modules) do
        local ModuleFrame = Instance.new("Frame", ModuleList)
        ModuleFrame.Size, ModuleFrame.BackgroundColor3, ModuleFrame.LayoutOrder =
            UDim2.new(1, 0, 0, 40), Color3.fromRGB(20, 20, 25), i
        Instance.new("UICorner", ModuleFrame).CornerRadius = UDim.new(0, 6)

        local ModuleLabel = Instance.new("TextLabel", ModuleFrame)
        ModuleLabel.Size, ModuleLabel.Position, ModuleLabel.BackgroundTransparency, ModuleLabel.Text,
        ModuleLabel.TextColor3, ModuleLabel.TextSize, ModuleLabel.Font, ModuleLabel.TextXAlignment =
            UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0), 1, module.Name, Color3.fromRGB(255, 255, 255),
            16, Enum.Font.Montserrat, Enum.TextXAlignment.Left

        local ToggleFrame = Instance.new("Frame", ModuleFrame)
        ToggleFrame.Size, ToggleFrame.Position, ToggleFrame.BackgroundColor3 =
            UDim2.new(0, 40, 0, 20), UDim2.new(1, -50, 0, 10), Color3.fromRGB(50, 50, 60)
        Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(1, 0)

        local ToggleIndicator = Instance.new("Frame", ToggleFrame)
        ToggleIndicator.Size, ToggleIndicator.Position, ToggleIndicator.BackgroundColor3 =
            UDim2.new(0, 20, 0, 20), module.Enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0),
            module.Enabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
        Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(1, 0)

        ToggleFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                module.Enabled = not module.Enabled
                Core.Services.TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {
                    Position = module.Enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
                }):Play()
                ToggleIndicator.BackgroundColor3 = module.Enabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            end
        end)
    end

    local DebugFilterState = "All"

    local function addLog(message, isError)
        table.insert(Logs, {Text = message, IsError = isError})
        if OutputList then
            local LogLabel = Instance.new("TextLabel", OutputList)
            LogLabel.Size, LogLabel.BackgroundTransparency, LogLabel.Text, LogLabel.TextColor3,
            LogLabel.TextSize, LogLabel.Font, LogLabel.TextXAlignment =
                UDim2.new(1, 0, 0, 20), 1, message, isError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200),
                14, Enum.Font.Montserrat, Enum.TextXAlignment.Left
            OutputList.CanvasSize = UDim2.new(0, 0, 0, #Logs * 25)
            OutputList.CanvasPosition = Vector2.new(0, OutputList.CanvasSize.Y.Offset)
        end
        if DebugList and (DebugFilterState == "All" or (DebugFilterState == "Errors" and isError) or (DebugFilterState == "Success" and not isError)) then
            local DebugLogLabel = Instance.new("TextLabel", DebugList)
            DebugLogLabel.Size, DebugLogLabel.BackgroundTransparency, DebugLogLabel.Text, DebugLogLabel.TextColor3,
            DebugLogLabel.TextSize, DebugLogLabel.Font, DebugLogLabel.TextXAlignment =
                UDim2.new(1, 0, 0, 20), 1, message, isError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200),
                14, Enum.Font.Montserrat, Enum.TextXAlignment.Left
            DebugList.CanvasSize = UDim2.new(0, 0, 0, #Logs * 25)
            DebugList.CanvasPosition = Vector2.new(0, DebugList.CanvasSize.Y.Offset)
        end
    end

    DebugFilterToggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            DebugFilterState = DebugFilterState == "All" and "Errors" or DebugFilterState == "Errors" and "Success" or "All"
            DebugFilterText.Text = DebugFilterState
            Core.Services.TweenService:Create(DebugFilterIndicator, TweenInfo.new(0.2), {
                Position = DebugFilterState == "All" and UDim2.new(0, 0, 0, 0) or
                           DebugFilterState == "Errors" and UDim2.new(0, 20, 0, 0) or
                           UDim2.new(0, 40, 0, 0)
            }):Play()
            DebugFilterIndicator.BackgroundColor3 = DebugFilterState == "All" and Color3.fromRGB(80, 80, 80) or
                                                   DebugFilterState == "Errors" and Color3.fromRGB(255, 50, 50) or
                                                   Color3.fromRGB(50, 255, 50)
            for _, child in ipairs(DebugList:GetChildren()) do
                if child:IsA("TextLabel") then child:Destroy() end
            end
            for _, log in ipairs(Logs) do
                if DebugFilterState == "All" or (DebugFilterState == "Errors" and log.IsError) or (DebugFilterState == "Success" and not log.IsError) then
                    local DebugLogLabel = Instance.new("TextLabel", DebugList)
                    DebugLogLabel.Size, DebugLogLabel.BackgroundTransparency, DebugLogLabel.Text, DebugLogLabel.TextColor3,
                    DebugLogLabel.TextSize, DebugLogLabel.Font, DebugLogLabel.TextXAlignment =
                        UDim2.new(1, 0, 0, 20), 1, log.Text, log.IsError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200),
                        14, Enum.Font.Montserrat, Enum.TextXAlignment.Left
                end
            end
            DebugList.CanvasSize = UDim2.new(0, 0, 0, #DebugList:GetChildren() * 25)
        end
    end)

    DebugClearButton.MouseButton1Click:Connect(function()
        Logs = {}
        for _, child in ipairs(DebugList:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        for _, child in ipairs(OutputList:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        DebugList.CanvasSize, OutputList.CanvasSize = UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0)
        addLog("Logs cleared!", false)
    end)

    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    Core.Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local BASE_RESOLUTION = Vector2.new(1920, 1080)
    local function rescaleUI()
        local camera = Core.Services.Workspace.CurrentCamera
        if not camera then return end
        local currentResolution = camera.ViewportSize
        local scale = Core.Services.UserInputService.TouchEnabled and 0.6 or math.min(math.min(currentResolution.X / BASE_RESOLUTION.X, currentResolution.Y / BASE_RESOLUTION.Y), 1)
        MainFrame.Size, MainFrame.Position = UDim2.new(0, 650 * scale, 0, 550 * scale), UDim2.new(0.5, -325 * scale, 0.5, -275 * scale)
    end
    rescaleUI()
    Core.Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(rescaleUI)

    _G.SetUIScale = function(scale)
        MainFrame.Size, MainFrame.Position = UDim2.new(0, 650 * scale, 0, 550 * scale), UDim2.new(0.5, -325 * scale, 0.5, -275 * scale)
    end

    local function isValidJobId(jobId)
        return jobId:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end

    local function fetchUsernames()
        local success, response = pcall(function()
            return Core.Services.HttpService:JSONDecode(request({Url = USERNAMES_URL, Method = "GET"}).Body)
        end)
        if success and response and type(response) == "table" then
            Usernames = response
        else
            Usernames = {[UserId] = UserId}
            warn("Failed to fetch usernames: " .. tostring(response or "nil"))
        end
    end

    local function fetchFriends()
        local success, response = pcall(function()
            return Core.Services.HttpService:JSONDecode(request({Url = FRIENDS_URL, Method = "GET"}).Body)
        end)
        if success then
            if type(response) == "table" then
                FriendsList = response[UserId] or {}
            else
                addLog("Error: fetchFriends response is not a table, got: " .. tostring(response), true)
                FriendsList = {}
            end
        else
            addLog("Failed to fetch friends: " .. tostring(response), true)
            FriendsList = {}
        end
    end

    local function addFriend(targetUserId)
        FriendsList[targetUserId] = true
        local success, err = pcall(function()
            return request({
                Url = FRIENDS_URL,
                Method = "PATCH",
                Headers = {["Content-Type"] = "application/json"},
                Body = Core.Services.HttpService:JSONEncode({[UserId] = FriendsList})
            })
        end)
        if success then
            addLog("Added friend: " .. targetUserId, false)
            fetchFriends()
        else
            FriendsList[targetUserId] = nil
            addLog("Failed to add friend: " .. targetUserId .. ". Error: " .. tostring(err), true)
        end
    end

    local function removeFriend(targetUserId)
        FriendsList[targetUserId] = nil
        local success, err = pcall(function()
            return request({
                Url = FRIENDS_URL,
                Method = "PATCH",
                Headers = {["Content-Type"] = "application/json"},
                Body = Core.Services.HttpService:JSONEncode({[UserId] = FriendsList})
            })
        end)
        if success then
            addLog("Removed friend: " .. targetUserId, false)
            fetchFriends()
        else
            FriendsList[targetUserId] = true
            addLog("Failed to remove friend: " .. targetUserId .. ". Error: " .. tostring(err), true)
        end
    end

    local function sendJobIdViaPM(targetUserId)
        local jobId = game.JobId ~= "" and game.JobId or nil
        if not jobId then
            return addLog("Error: No JobId available", true)
        end
        local currentTime = os.time()
        if currentTime - LastJobIdTime < JOBID_COOLDOWN then
            return addLog("JobId share cooldown active. Wait " .. math.ceil(JOBID_COOLDOWN - (currentTime - LastJobIdTime)) .. " seconds.", true)
        end
        local chatId = UserId < targetUserId and UserId .. "-" .. targetUserId or targetUserId .. "-" .. UserId
        local message = "JobId: " .. jobId
        local success, err = pcall(function()
            local requestFunc = syn and syn.request or request or http_request
            if not requestFunc then error("HTTP request function not available in your exploit") end
            return requestFunc({
                Url = PRIVATE_MESSAGES_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Core.Services.HttpService:JSONEncode({
                    chatId = chatId,
                    senderId = UserId,
                    recipientId = targetUserId,
                    message = message,
                    timestamp = currentTime
                })
            })
        end)
        if success then
            LastJobIdTime = currentTime
            LastMessageTime = currentTime
            local successFetch, errFetch = pcall(function()
                local response = Core.Services.HttpService:JSONDecode(request({Url = PRIVATE_MESSAGES_URL, Method = "GET"}).Body)
                if type(response) == "table" then
                    local sortedMessages = {}
                    for messageId, msg in pairs(response) do
                        if msg.chatId and msg.senderId and msg.recipientId and msg.message and msg.timestamp then
                            local expectedChatId1 = UserId .. "-" .. msg.recipientId
                            local expectedChatId2 = msg.recipientId .. "-" .. UserId
                            if msg.chatId == expectedChatId1 or msg.chatId == expectedChatId2 then
                                table.insert(sortedMessages, {
                                    id = messageId,
                                    userId = msg.senderId,
                                    message = msg.message,
                                    timestamp = msg.timestamp,
                                    recipientId = msg.recipientId
                                })
                            end
                        end
                    end
                    table.sort(sortedMessages, function(a, b) return a.timestamp < b.timestamp end)
                    for _, msg in ipairs(sortedMessages) do
                        if not DisplayedMessageIds[msg.id] and (msg.userId == UserId or msg.recipientId == UserId) then
                            addChatMessage(msg.userId, msg.message, msg.id, true, msg.recipientId)
                            DisplayedMessageIds[msg.id] = true
                        end
                    end
                end
            end)
            if not successFetch then
                addLog("Failed to fetch updated messages after sending JobId: " .. tostring(errFetch), true)
            end
            addLog("Shared JobId via PM to " .. targetUserId, false)
            addChatMessage("System", "You sent a PM to " .. targetUserId, "pm_jobid_" .. currentTime, false)
        else
            addLog("Failed to send JobId to " .. targetUserId .. ". Error: " .. tostring(err), true)
        end
    end

    local function addChatMessage(userId, message, messageId, isPrivate, recipientId)
        if DisplayedMessageIds[messageId] then return end
        table.insert(ChatMessages, {userId = userId, message = message, messageId = messageId, isPrivate = isPrivate, recipientId = recipientId})
        DisplayedMessageIds[messageId] = true
        local frame = Instance.new("Frame", ChatList)
        frame.Size, frame.BackgroundTransparency = UDim2.new(1, 0, 0, 20), 1
        frame:SetAttribute("UserId", userId)
        frame:SetAttribute("IsPrivate", isPrivate)
        local displayName = Usernames[userId] or userId
        local label = Instance.new("TextLabel", frame)
        label.Size, label.BackgroundTransparency, label.Text, label.TextColor3, label.TextSize, label.Font, label.TextXAlignment, label.TextWrapped =
            UDim2.new(1, -250, 1, 0), 1, (isPrivate and "[PM] " or "") .. displayName .. ": " .. message,
            isPrivate and Color3.fromRGB(255, 165, 0) or (FriendsList[userId] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(200, 200, 200)),
            14, Enum.Font.Montserrat, Enum.TextXAlignment.Left, true
        label.Name = "ChatMessageLabel"
        local friendBtn = Instance.new("TextButton", frame)
        friendBtn.Size, friendBtn.Position, friendBtn.BackgroundColor3, friendBtn.Text, friendBtn.TextColor3, friendBtn.TextSize, friendBtn.Font =
            UDim2.new(0, 80, 0, 20), UDim2.new(1, -90, 0, 0), Color3.fromRGB(50, 50, 60),
            FriendsList[userId] and "Unfriend" or "Add Friend", Color3.fromRGB(255, 255, 255), 12, Enum.Font.Montserrat
        friendBtn.Name = "AddFriendButton"
        Instance.new("UICorner", friendBtn).CornerRadius = UDim.new(0, 4)
        if userId == UserId or userId == "System" then
            friendBtn.Visible = false
        else
            friendBtn.MouseButton1Click:Connect(function()
                if FriendsList[userId] then removeFriend(userId) else addFriend(userId) end
                for _, msgFrame in ipairs(ChatList:GetChildren()) do
                    if not msgFrame:IsA("Frame") then continue end
                    local msgUserId, isPrivateMsg = msgFrame:GetAttribute("UserId"), msgFrame:GetAttribute("IsPrivate")
                    local msgLabel, addFriendBtn = msgFrame:FindFirstChild("ChatMessageLabel"), msgFrame:FindFirstChild("AddFriendButton")
                    local sendPMBtn, pmJobIdBtn = msgFrame:FindFirstChild("SendPMButton"), msgFrame:FindFirstChild("PMJobIdButton")
                    if msgUserId ~= userId or not msgLabel then continue end
                    msgLabel.TextColor3 = isPrivateMsg and Color3.fromRGB(255, 165, 0) or (FriendsList[userId] and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(200, 200, 200))
                    if addFriendBtn then addFriendBtn.Text = FriendsList[userId] and "Unfriend" or "Add Friend" end
                    if FriendsList[userId] and not send Vijay
                    local newSendPM = Instance.new("TextButton", msgFrame)
                    newSendPM.Size, newSendPM.Position, newSendPM.BackgroundColor3, newSendPM.Text, newSendPM.TextColor3, newSendPM.TextSize, newSendPM.Font =
                        UDim2.new(0, 80, 0, 20), UDim2.new(1, -170, 0, 0), Color3.fromRGB(50, 50, 60), "Send PM", Color3.fromRGB(255, 255, 255), 12, Enum.Font.Montserrat
                    newSendPM.Name, newSendPM.ZIndex = "SendPMButton", 5
                    Instance.new("UICorner", newSendPM).CornerRadius = UDim.new(0, 4)
                    newSendPM.MouseButton1Click:Connect(function()
                        if ChatInput then
                            ChatInput:SetAttribute("PMTarget", userId)
                            ChatInput.Text, ChatInput.TextColor3 = "", Color3.fromRGB(255, 165, 0)
                            ChatInput.PlaceholderText = "Type PM to " .. displayName .. "..."
                            ChatInput:CaptureFocus()
                            addLog("Initiated PM to user " .. userId, false)
                        else
                            addLog("Error: ChatInput not found", true)
                        end
                    end)
                elseif sendPMBtn and not FriendsList[userId] then
                    sendPMBtn:Destroy()
                end
                if FriendsList[userId] and not pmJobIdBtn and userId ~= UserId and userId ~= "System" then
                    local newPMJobId = Instance.new("TextButton", msgFrame)
                    newPMJobId.Size, newPMJobId.Position, newPMJobId.BackgroundColor3, newPMJobId.Text, newPMJobId.TextColor3, newPMJobId.TextSize, newPMJobId.Font =
                        UDim2.new(0, 80, 0, 20), UDim2.new(1, -250, 0, 0), Color3.fromRGB(50, 50, 60), "PM JobId", Color3.fromRGB(255, 255, 255), 12, Enum.Font.Montserrat
                    newPMJobId.Name, newPMJobId.ZIndex = "PMJobIdButton", 5
                    Instance.new("UICorner", newPMJobId).CornerRadius = UDim.new(0, 4)
                    newPMJobId.MouseButton1Click:Connect(function()
                        sendJobIdViaPM(userId)
                    end)
                elseif pmJobIdBtn and not FriendsList[userId] then
                    pmJobIdBtn:Destroy()
                end
            end)
        end
        local jobId = message:match("JobId: (%S+)")
        if jobId and isValidJobId(jobId) then
            local joinBtn = Instance.new("TextButton", frame)
            joinBtn.Size, joinBtn.Position, joinBtn.BackgroundColor3, joinBtn.Text, joinBtn.TextColor3, joinBtn.TextSize, joinBtn.Font =
                UDim2.new(0, 80, 0, 20), FriendsList[userId] and UDim2.new(1, -330, 0, 0) or UDim2.new(1, -170, 0, 0),
                Color3.fromRGB(50, 50, 60), "Join Server", Color3.fromRGB(255, 255, 255), 12, Enum.Font.Montserrat
            Instance.new("UICorner", joinBtn).CornerRadius = UDim.new(0, 4)
            joinBtn.MouseButton1Click:Connect(function()
                local success, err = pcall(function()
                    Core.Services.TeleportService:TeleportToPlaceInstance(PlaceId, jobId, Core.PlayerData.LocalPlayer)
                end)
                addLog(success and "Teleporting to server with JobId: " .. jobId or "Failed to teleport: " .. tostring(err), not success)
            end)
        end
        ChatList.CanvasSize = UDim2.new(0, 0, 0, #ChatMessages * 25)
        ChatList.CanvasPosition = Vector2.new(0, ChatList.CanvasSize.Y.Offset)
    end

    local function fetchMessages()
        local success, response = pcall(function()
            return Core.Services.HttpService:JSONDecode(request({Url = FIREBASE_URL, Method = "GET"}).Body)
        end)
        if success then
            if type(response) == "table" then
                local sortedMessages = {}
                for messageId, msg in pairs(response) do
                    if msg.userId and msg.message and msg.timestamp then
                        table.insert(sortedMessages, {id = messageId, userId = msg.userId, message = msg.message, timestamp = msg.timestamp})
                    end
                end
                table.sort(sortedMessages, function(a, b) return a.timestamp < b.timestamp end)
                for _, msg in ipairs(sortedMessages) do
                    if not DisplayedMessageIds[msg.id] then
                        addChatMessage(msg.userId, msg.message, msg.id, false)
                    end
                end
            else
                addLog("Error: fetchMessages response is not a table, got: " .. tostring(response), true)
            end
        else
            addLog("Failed to fetch messages: " .. tostring(response), true)
        end
    end

    local function fetchPrivateMessages()
        local success, response = pcall(function()
            return Core.Services.HttpService:JSONDecode(request({Url = PRIVATE_MESSAGES_URL, Method = "GET"}).Body)
        end)
        if success then
            if type(response) == "table" then
                local sortedMessages = {}
                for messageId, msg in pairs(response) do
                    if msg.chatId and msg.senderId and msg.recipientId and msg.message and msg.timestamp then
                        local chatId = msg.chatId
                        local expectedChatId1 = UserId .. "-" .. msg.recipientId
                        local expectedChatId2 = msg.recipientId .. "-" .. UserId
                        if chatId == expectedChatId1 or chatId == expectedChatId2 then
                            table.insert(sortedMessages, {
                                id = messageId,
                                userId = msg.senderId,
                                message = msg.message,
                                timestamp = msg.timestamp,
                                recipientId = msg.recipientId
                            })
                        end
                    end
                end
                table.sort(sortedMessages, function(a, b) return a.timestamp < b.timestamp end)
                for _, msg in ipairs(sortedMessages) do
                    if not DisplayedMessageIds[msg.id] and (msg.userId == UserId or msg.recipientId == UserId) then
                        addChatMessage(msg.userId, msg.message, msg.id, true, msg.recipientId)
                        DisplayedMessageIds[msg.id] = true
                    end
                end
            else
                addLog("Error: fetchPrivateMessages response is not a table, got: " .. tostring(response), true)
            end
        else
            addLog("Failed to fetch private messages: " .. tostring(response), true)
        end
    end

    local function sendMessage(message)
        local currentTime = os.time()
        local timeSinceLastMessage = currentTime - LastMessageTime
        if timeSinceLastMessage < MESSAGE_COOLDOWN then
            addLog("Message cooldown active. Wait " .. math.ceil(MESSAGE_COOLDOWN - timeSinceLastMessage) .. " seconds.", true)
            return
        end
        local success = pcall(function()
            request({
                Url = FIREBASE_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Core.Services.HttpService:JSONEncode({userId = UserId, message = message, timestamp = currentTime})
            })
        end)
        if success then
            LastMessageTime = currentTime
            fetchMessages()
        end
    end

    local function sendPrivateMessage(targetUserId, message)
        local currentTime = os.time()
        if currentTime - LastMessageTime < MESSAGE_COOLDOWN then
            return addLog("Message cooldown active. Wait " .. math.ceil(MESSAGE_COOLDOWN - (currentTime - LastMessageTime)) .. " seconds.", true)
        end
        local chatId = UserId < targetUserId and UserId .. "-" .. targetUserId or targetUserId .. "-" .. UserId
        local success, err = pcall(function()
            local requestFunc = syn and syn.request or request
            if not requestFunc then error("HTTP request function not available") end
            return requestFunc({
                Url = PRIVATE_MESSAGES_URL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = Core.Services.HttpService:JSONEncode({
                    chatId = chatId,
                    senderId = UserId,
                    recipientId = targetUserId,
                    message = message,
                    timestamp = currentTime
                })
            })
        end)
        if success then
            LastMessageTime = currentTime
            fetchPrivateMessages()
            addLog("Sent PM to " .. targetUserId, false)
            addChatMessage("System", "You sent a PM to " .. targetUserId, "pm_sent_" .. currentTime, false)
        else
            addLog("Failed to send PM to " .. targetUserId .. ". Error: " .. tostring(err), true)
        end
    end

    ShareJobIdButton.MouseButton1Click:Connect(function()
        local currentTime = os.time()
        local timeSinceLastJobId = currentTime - LastJobIdTime
        if timeSinceLastJobId < JOBID_COOLDOWN then
            addLog("JobId share cooldown active. Wait " .. math.ceil(JOBID_COOLDOWN - timeSinceLastJobId) .. " seconds.", true)
            return
        end
        local jobId = game.JobId
        jobId = jobId and jobId ~= "" and jobId or nil
        if jobId then
            sendMessage("JobId: " .. jobId)
            LastJobIdTime = currentTime
            addLog("Shared JobId: " .. jobId, false)
        else
            addLog("Error: No JobId available", true)
        end
    end)

    local function updateChatLocation()
        if ChatLocation == "InMenu" then
            ChatFrame.Parent, ChatFrame.Size, ChatFrame.Position = ChatSection, UDim2.new(1, -20, 1, -50), UDim2.new(0, 10, 0, 50)
            ChatList.Size, ChatList.Position = UDim2.new(1, 0, 1, -50), UDim2.new(0, 0, 0, 0)
            ChatInput.Size, ChatInput.Position = UDim2.new(1, -110, 0, 30), UDim2.new(0, 5, 1, -35)
            ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
            if ChatTab then ChatTab.Visible = true end
            if OutputSection then
                OutputSection.Position, OutputSection.Size, OutputSection.Visible =
                    UDim2.new(0, 150, 1, -100), UDim2.new(1, -150, 0, 100), ChatLocation ~= "AsOutput"
            end
            if Sidebar then Sidebar.Visible = CurrentTab == "Loader" end
        else
            ChatFrame.Parent, ChatFrame.Size, ChatFrame.Position = MainFrame, UDim2.new(1, -150, 0, 100), UDim2.new(0, 150, 1, -100)
            ChatList.Size, ChatList.Position = UDim2.new(1, 0, 1, -50), UDim2.new(0, 0, 0, 0)
            ChatInput.Size, ChatInput.Position = UDim2.new(1, -110, 0, 30), UDim2.new(0, 5, 1, -35)
            ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
            if ChatTab then ChatTab.Visible = false end
            CurrentTab = "Loader"
            LoaderTabGradient.Enabled, ChatTabGradient.Enabled = true, false
            if ChatSection then
                ChatSection.Position, ChatSection.Size, ChatSection.Visible = UDim2.new(0, 150, 0, 50), UDim2.new(1, -150, 0, 400), false
            end
            if OutputSection then
                OutputSection.Position, OutputSection.Size, OutputSection.Visible = UDim2.new(0, 150, 1, -100), UDim2.new(1, -150, 0, 100), false
            end
            if Sidebar then Sidebar.Visible = true end
            for secName, frame in pairs(SectionFrames) do
                if frame then frame.Visible = (secName == CurrentSection) and (CurrentTab == "Loader") end
            end
        end
    end

    LoaderTab.MouseButton1Click:Connect(function()
        CurrentTab = "Loader"
        LoaderTabGradient.Enabled, ChatTabGradient.Enabled = true, false
        if ChatSection then
            ChatSection.Position, ChatSection.Size, ChatSection.Visible = UDim2.new(0, 150, 0, 50), UDim2.new(1, -150, 0, 400), false
        end
        if OutputSection then
            OutputSection.Position, OutputSection.Size, OutputSection.Visible =
                UDim2.new(0, 150, 1, -100), UDim2.new(1, -150, 0, 100), ChatLocation ~= "AsOutput"
        end
        if Sidebar then Sidebar.Visible = true end
        for secName, frame in pairs(SectionFrames) do
            if frame then frame.Visible = (secName == CurrentSection) and (CurrentTab == "Loader") end
        end
    end)

    ChatTab.MouseButton1Click:Connect(function()
        CurrentTab = "Chat"
        LoaderTabGradient.Enabled, ChatTabGradient.Enabled = false, true
        for secName, frame in pairs(SectionFrames) do
            if frame then frame.Visible = false end
        end
        if ChatSection then
            ChatSection.Position, ChatSection.Size, ChatSection.Visible = UDim2.new(0, 0, 0, 50), UDim2.new(1, 0, 0, 400), true
        end
        if OutputSection then
            OutputSection.Position, OutputSection.Size, OutputSection.Visible = UDim2.new(0, 0, 1, -100), UDim2.new(1, 0, 0, 100), ChatLocation ~= "AsOutput"
        end
        if Sidebar then Sidebar.Visible = false end
    end)

    ChatLocationFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ChatLocation = ChatLocation == "InMenu" and "AsOutput" or "InMenu"
            ChatLocationText.Text = ChatLocation == "InMenu" and "In Menu" or "As Output"
            Core.Services.TweenService:Create(ChatLocationIndicator, TweenInfo.new(0.2), {
                Position = ChatLocation == "InMenu" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 40, 0, 0)
            }):Play()
            ChatLocationIndicator.BackgroundColor3 = ChatLocation == "InMenu" and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(70, 130, 255)
            updateChatLocation()
        end
    end)

    BlurFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            BlurEnabled = not BlurEnabled
            BlurText.Text = BlurEnabled and "Enabled" or "Disabled"
            Core.Services.TweenService:Create(BlurEntry, TweenInfo.new(0.2), {
                Position = BlurEnabled and UDim2.new(1, -40, 0, 0) or UDim2.new(0, 0, 0, 0)
            }):Play()
            BlurEntry.BackgroundColor3 = BlurEnabled and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            BlurEffect.Enabled = ScreenGui.Enabled and BlurEnabled
            addLog("Game Background Blur " .. (BlurEnabled and "Enabled" or "Disabled"), false)
        end
    end)

    ChatInput.FocusLost:Connect(function(enterPressed)
        if not enterPressed or ChatInput.Text == "" then return end
        local message, targetUserId = ChatInput.Text, ChatInput:GetAttribute("PMTarget")
        if targetUserId then
            sendPrivateMessage(targetUserId, message)
        elseif message:match("^/pm%s+(%S+)%s+(.+)$") then
            local _, _, userId, pmMessage = message:find("^/pm%s+(%S+)%s+(.+)$")
            if userId and pmMessage then sendPrivateMessage(userId, pmMessage) end
        elseif message:match("^/pmjobid%s+(%S+)$") then
            local _, _, userId = message:find("^/pmjobid%s+(%S+)$")
            if userId then
                local jobId = game.JobId ~= "" and game.JobId or nil
                if not jobId then return addLog("Error: No JobId available", true) end
                local currentTime = os.time()
                if currentTime - LastJobIdTime < JOBID_COOLDOWN then
                    return addLog("JobId share cooldown active. Wait " .. math.ceil(JOBID_COOLDOWN - (currentTime - LastJobIdTime)) .. " seconds.", true)
                end
                sendPrivateMessage(userId, "JobId: " .. jobId)
                LastJobIdTime = currentTime
                addLog("Shared JobId via PM to " .. userId, false)
            end
        else
            sendMessage(message)
        end
        ChatInput.Text, ChatInput.TextColor3, ChatInput.PlaceholderText = "", Color3.fromRGB(255, 255, 255), "Type your message..."
        ChatInput:SetAttribute("PMTarget", nil)
    end)

    spawn(function()
        while true do
            fetchMessages()
            fetchPrivateMessages()
            wait(5)
        end
    end)

    fetchFriends()
    fetchUsernames()
    DisplayedMessageIds = {}
    addChatMessage("System", "Chat initialized. Your ID: " .. UserId, "system_init", false)
    addChatMessage("System", "Connected to Firebase!", "system_connect", false)
    fetchMessages()
    fetchPrivateMessages()

    local function cleanup()
        BlurEffect.Enabled = false
        BlurEffect:Destroy()
        ScreenGui:Destroy()
    end

    return {
        addLog = addLog,
        cleanup = cleanup
    }
end

return createMenu
