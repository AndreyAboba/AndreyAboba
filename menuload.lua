local TweenService = game:GetService("TweenService")

local function InitMenu(MainFrame, Core, CurrentTab, ChatSection, OutputSection, ChatLocation)
    local Sidebar = Instance.new("Frame", MainFrame); Sidebar.Size, Sidebar.Position, Sidebar.BackgroundColor3, Sidebar.BorderSizePixel = UDim2.new(0,150,1,-40), UDim2.new(0,0,0,40), Color3.fromRGB(20,20,20), 0
    local SidebarCorner = Instance.new("UICorner", Sidebar); SidebarCorner.CornerRadius = UDim.new(0,8)
    local SidebarDivider = Instance.new("Frame", Sidebar); SidebarDivider.Size, SidebarDivider.Position, SidebarDivider.BackgroundColor3, SidebarDivider.BorderSizePixel = UDim2.new(0,2,1,-10), UDim2.new(1,-2,0,5), Color3.fromRGB(50,50,50), 0
    local SidebarList = Instance.new("ScrollingFrame", Sidebar); SidebarList.Size, SidebarList.Position, SidebarList.BackgroundTransparency, SidebarList.BorderSizePixel, SidebarList.CanvasSize, SidebarList.ScrollBarThickness = UDim2.new(1,-10,1,-60), UDim2.new(0,5,0,55), 1, 0, UDim2.new(0,0,0,0), 4
    local SidebarListLayout = Instance.new("UIListLayout", SidebarList); SidebarListLayout.Padding, SidebarListLayout.SortOrder = UDim.new(0,5), Enum.SortOrder.LayoutOrder
    local SidebarLabel = Instance.new("TextLabel", Sidebar); SidebarLabel.Size, SidebarLabel.Position, SidebarLabel.BackgroundTransparency, SidebarLabel.Text, SidebarLabel.TextColor3, SidebarLabel.TextSize, SidebarLabel.Font, SidebarLabel.TextXAlignment = UDim2.new(1,-20,0,30), UDim2.new(0,10,0,10), 1, "Syllinse", Color3.fromRGB(255,255,255), 16, Enum.Font.SourceSansBold, Enum.TextXAlignment.Left

    local TopBar = Instance.new("Frame", MainFrame); TopBar.Size, TopBar.Position, TopBar.BackgroundColor3, TopBar.BorderSizePixel = UDim2.new(1,0,0,40), UDim2.new(0,0,0,0), Color3.fromRGB(20,20,20), 0
    local TopBarCorner = Instance.new("UICorner", TopBar); TopBarCorner.CornerRadius = UDim.new(0,8)
    local TopBarLabel = Instance.new("TextLabel", TopBar); TopBarLabel.Size, TopBarLabel.Position, TopBarLabel.BackgroundTransparency, TopBarLabel.Text, TopBarLabel.TextColor3, TopBarLabel.TextSize, TopBarLabel.Font, TopBarLabel.TextXAlignment = UDim2.new(1,-20,0,30), UDim2.new(0,10,0,5), 1, "Syllinse Loader", Color3.fromRGB(255,255,255), 16, Enum.Font.SourceSansBold, Enum.TextXAlignment.Left

    local SectionFrames = Instance.new("Frame", MainFrame); SectionFrames.Size, SectionFrames.Position, SectionFrames.BackgroundTransparency = UDim2.new(1,-150,1,-40), UDim2.new(0,150,0,40), 1

    local LoaderSection = Instance.new("Frame", SectionFrames); LoaderSection.Size, LoaderSection.Position, LoaderSection.BackgroundTransparency, LoaderSection.Visible = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 1, true
    local LoaderLabel = Instance.new("TextLabel", LoaderSection); LoaderLabel.Size, LoaderLabel.Position, LoaderLabel.BackgroundTransparency, LoaderLabel.Text, LoaderLabel.TextColor3, LoaderLabel.TextSize, LoaderLabel.Font, LoaderLabel.TextXAlignment = UDim2.new(1,-20,0,30), UDim2.new(0,10,0,10), 1, "Loader", Color3.fromRGB(255,255,255), 16, Enum.Font.SourceSansBold, Enum.TextXAlignment.Left
    local LoaderDivider = Instance.new("Frame", LoaderSection); LoaderDivider.Size, LoaderDivider.Position, LoaderDivider.BackgroundColor3, LoaderDivider.BorderSizePixel = UDim2.new(1,-20,0,2), UDim2.new(0,10,0,40), Color3.fromRGB(50,50,50), 0
    local ModulesFrame = Instance.new("Frame", LoaderSection); ModulesFrame.Size, ModulesFrame.Position, ModulesFrame.BackgroundColor3, ModulesFrame.BorderSizePixel, ModulesFrame.BorderColor3 = UDim2.new(1,-20,0,150), UDim2.new(0,10,0,40), Color3.fromRGB(20,20,20), 1, Color3.fromRGB(60,60,60)
    local ModulesCorner = Instance.new("UICorner", ModulesFrame); ModulesCorner.CornerRadius = UDim.new(0,12)
    local ModulesPadding = Instance.new("UIPadding", ModulesFrame); ModulesPadding.PaddingLeft, ModulesPadding.PaddingRight, ModulesPadding.PaddingTop, ModulesPadding.PaddingBottom = UDim.new(0,5), UDim.new(0,5), UDim.new(0,5), UDim.new(0,5)
    local ModulesList = Instance.new("ScrollingFrame", ModulesFrame); ModulesList.Size, ModulesList.Position, ModulesList.BackgroundTransparency, ModulesList.BorderSizePixel, ModulesList.CanvasSize, ModulesList.ScrollBarThickness = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 1, 0, UDim2.new(0,0,0,0), 4
    local ModulesListLayout = Instance.new("UIListLayout", ModulesList); ModulesListLayout.Padding, ModulesListLayout.SortOrder = UDim.new(0,5), Enum.SortOrder.LayoutOrder

    local LoadButton = Instance.new("TextButton", LoaderSection); LoadButton.Size, LoadButton.Position, LoadButton.BackgroundColor3, LoadButton.Text, LoadButton.TextColor3, LoadButton.TextSize, LoadButton.Font = UDim2.new(0,100,0,30), UDim2.new(0,10,1,-40), Color3.fromRGB(80,80,80), "Load", Color3.fromRGB(255,255,255), 14, Enum.Font.SourceSans
    local LoadButtonCorner = Instance.new("UICorner", LoadButton); LoadButtonCorner.CornerRadius = UDim.new(0,5)

    local ChatLocationFrame = Instance.new("Frame", LoaderSection); ChatLocationFrame.Size, ChatLocationFrame.Position, ChatLocationFrame.BackgroundColor3, ChatLocationFrame.BorderSizePixel = UDim2.new(0,80,0,20), UDim2.new(1,-90,1,-35), Color3.fromRGB(40,40,40), 0
    local ChatLocationCorner = Instance.new("UICorner", ChatLocationFrame); ChatLocationCorner.CornerRadius = UDim.new(0,10)
    local ChatLocationIndicator = Instance.new("Frame", ChatLocationFrame); ChatLocationIndicator.Size, ChatLocationIndicator.Position, ChatLocationIndicator.BackgroundColor3, ChatLocationIndicator.BorderSizePixel = UDim2.new(0,40,1,-4), UDim2.new(0,2,0,2), Color3.fromRGB(80,80,80), 0
    local ChatLocationIndicatorCorner = Instance.new("UICorner", ChatLocationIndicator); ChatLocationIndicatorCorner.CornerRadius = UDim.new(0,8)
    local ChatLocationText = Instance.new("TextLabel", ChatLocationFrame); ChatLocationText.Size, ChatLocationText.Position, ChatLocationText.BackgroundTransparency, ChatLocationText.Text, ChatLocationText.TextColor3, ChatLocationText.TextSize, ChatLocationText.Font, ChatLocationText.TextXAlignment = UDim2.new(1,0,1,0), UDim2.new(0,0,0,0), 1, "In Menu", Color3.fromRGB(255,255,255), 12, Enum.Font.SourceSans, Enum.TextXAlignment.Center

    local function createModuleToggle(moduleData)
        local ModuleFrame = Instance.new("Frame", ModulesList); ModuleFrame.Size, ModuleFrame.BackgroundTransparency = UDim2.new(1,0,0,30), 1
        local ModuleLabel = Instance.new("TextLabel", ModuleFrame); ModuleLabel.Size, ModuleLabel.Position, ModuleLabel.BackgroundTransparency, ModuleLabel.Text, ModuleLabel.TextColor3, ModuleLabel.TextSize, ModuleLabel.Font, ModuleLabel.TextXAlignment = UDim2.new(1,-50,1,0), UDim2.new(0,5,0,0), 1, moduleData.Name, Color3.fromRGB(255,255,255), 14, Enum.Font.SourceSans, Enum.TextXAlignment.Left
        local ToggleButton = Instance.new("TextButton", ModuleFrame); ToggleButton.Size, ToggleButton.Position, ToggleButton.BackgroundColor3, ToggleButton.Text, ToggleButton.TextColor3, ToggleButton.TextSize, ToggleButton.Font = UDim2.new(0,40,0,20), UDim2.new(1,-45,0,5), moduleData.Enabled and Color3.fromRGB(80,80,80) or Color3.fromRGB(40,40,40), moduleData.Enabled and "On" or "Off", Color3.fromRGB(255,255,255), 12, Enum.Font.SourceSans
        local ToggleButtonCorner = Instance.new("UICorner", ToggleButton); ToggleButtonCorner.CornerRadius = UDim.new(0,5)
        ToggleButton.MouseButton1Click:Connect(function()
            moduleData.Enabled = not moduleData.Enabled
            ToggleButton.BackgroundColor3 = moduleData.Enabled and Color3.fromRGB(80,80,80) or Color3.fromRGB(40,40,40)
            ToggleButton.Text = moduleData.Enabled and "On" or "Off"
        end)
        ModulesList.CanvasSize = UDim2.new(0,0,0,#Core.Modules*35)
    end

    for _, module in ipairs(Core.Modules) do
        createModuleToggle(module)
    end

    local tabs = {
        {Name="Loader",Section=LoaderSection},
        {Name="Chat",Section=ChatSection},
        {Name="Output",Section=OutputSection}
    }

    for _, tab in ipairs(tabs) do
        local TabButton = Instance.new("TextButton", SidebarList); TabButton.Size, TabButton.BackgroundTransparency, TabButton.Text, TabButton.TextColor3, TabButton.TextSize, TabButton.Font = UDim2.new(1,0,0,30), 1, tab.Name, Color3.fromRGB(255,255,255), 14, Enum.Font.SourceSans
        TabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(tabs) do
                t.Section.Visible = t.Name == tab.Name
                if t.Name == "Chat" then
                    t.Section.Size = UDim2.new(1,-150,1,-40)
                    t.Section.Position = UDim2.new(0,150,0,40)
                elseif t.Name == "Output" then
                    t.Section.Size = UDim2.new(1,-150,0,150)
                    t.Section.Position = UDim2.new(0,150,1,-150)
                elseif t.Name == "Loader" then
                    t.Section.Size = UDim2.new(1,0,1,0)
                    t.Section.Position = UDim2.new(0,0,0,0)
                end
            end
            CurrentTab.Value = tab.Name
        end)
        SidebarList.CanvasSize = UDim2.new(0,0,0,#tabs*35)
    end

    return {
        Sidebar = Sidebar,
        SectionFrames = SectionFrames,
        CurrentSection = LoaderSection,
        LoadButton = LoadButton,
        ChatLocationFrame = ChatLocationFrame,
        ChatLocationIndicator = ChatLocationIndicator,
        ChatLocationText = ChatLocationText,
        TopBar = TopBar,
        ChatTab = ChatSection,
        OutputTab = OutputSection
    }
end

return {
    InitMenu = InitMenu
}
