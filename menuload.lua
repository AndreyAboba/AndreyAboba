local Core = require(script.Parent.Core)
local TweenService = Core.Services.TweenService

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyllinseLoader"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = Core.Services.CoreGuiService

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 650, 0, 550)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
UIGradient.Rotation = 45
UIGradient.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarGradient = Instance.new("UIGradient")
TopBarGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
TopBarGradient.Rotation = 45
TopBarGradient.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0, 150, 0, 30)
TitleLabel.Position = UDim2.new(0, 15, 0.5, -15)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Syllinse"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 20
TitleLabel.Font = Enum.Font.Montserrat
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local TabsContainer = Instance.new("Frame")
TabsContainer.Size = UDim2.new(0, 200, 0, 30)
TabsContainer.Position = UDim2.new(1, -210, 0.5, -15)
TabsContainer.BackgroundTransparency = 1
TabsContainer.Parent = TopBar

local TabsList = Instance.new("UIListLayout")
TabsList.FillDirection = Enum.FillDirection.Horizontal
TabsList.HorizontalAlignment = Enum.HorizontalAlignment.Right
TabsList.Padding = UDim.new(0, 10)
TabsList.Parent = TabsContainer

local LoaderTab = Instance.new("TextButton")
LoaderTab.Size = UDim2.new(0, 80, 0, 30)
LoaderTab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
LoaderTab.BackgroundTransparency = 0.3
LoaderTab.Text = "Loader"
LoaderTab.TextColor3 = Color3.fromRGB(255, 255, 255)
LoaderTab.TextSize = 14
LoaderTab.Font = Enum.Font.Montserrat
LoaderTab.BorderSizePixel = 0
LoaderTab.Parent = TabsContainer

local LoaderTabCorner = Instance.new("UICorner")
LoaderTabCorner.CornerRadius = UDim.new(0, 6)
LoaderTabCorner.Parent = LoaderTab

local LoaderTabGradient = Instance.new("UIGradient")
LoaderTabGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
LoaderTabGradient.Rotation = 45
LoaderTabGradient.Enabled = true
LoaderTabGradient.Parent = LoaderTab

local ChatTab = Instance.new("TextButton")
ChatTab.Size = UDim2.new(0, 80, 0, 30)
ChatTab.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ChatTab.BackgroundTransparency = 0.3
ChatTab.Text = "Chat"
ChatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatTab.TextSize = 14
ChatTab.Font = Enum.Font.Montserrat
ChatTab.BorderSizePixel = 0
ChatTab.Parent = TabsContainer

local ChatTabCorner = Instance.new("UICorner")
ChatTabCorner.CornerRadius = UDim.new(0, 6)
ChatTabCorner.Parent = ChatTab

local ChatTabGradient = Instance.new("UIGradient")
ChatTabGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
ChatTabGradient.Rotation = 45
ChatTabGradient.Enabled = false
ChatTabGradient.Parent = ChatTab

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -50)
Sidebar.Position = UDim2.new(0, 0, 0, 50)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Sidebar.BackgroundTransparency = 0.2
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
SidebarGradient.Rotation = 45
SidebarGradient.Parent = Sidebar

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 5)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local Sections = {
    { Name = "Main", Icon = "rbxassetid://18821914323" },
    { Name = "Autofarm", Icon = "rbxassetid://18821914323" },
    { Name = "Settings", Icon = "rbxassetid://18821914323" }
}
local SectionFrames = {}
local CurrentSection = "Main"
local CurrentTab = "Loader"

for i, section in ipairs(Sections) do
    local SectionButton = Instance.new("TextButton")
    SectionButton.Size = UDim2.new(1, -10, 0, 40)
    SectionButton.Position = UDim2.new(0, 5, 0, 0)
    SectionButton.BackgroundColor3 = CurrentSection == section.Name and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(20, 20, 25)
    SectionButton.BackgroundTransparency = 0.3
    SectionButton.Text = ""
    SectionButton.LayoutOrder = i
    SectionButton.Parent = Sidebar

    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
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
    Label.Font = Enum.Font.Montserrat
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SectionButton

    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
    ButtonGradient.Rotation = 45
    ButtonGradient.Enabled = CurrentSection == section.Name
    ButtonGradient.Parent = SectionButton

    SectionButton.MouseButton1Click:Connect(function()
        if CurrentTab == "Chat" then return end
        CurrentSection = section.Name
        CurrentTab = "Loader"
        for _, btn in ipairs(Sidebar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = btn.TextLabel.Text == section.Name and Color3.fromRGB(25, 25, 30) or Color3.fromRGB(20, 20, 25)
                btn.UIGradient.Enabled = btn.TextLabel.Text == section.Name
            end
        end
        for secName, frame in pairs(SectionFrames) do
            frame.Visible = (secName == section.Name) and (CurrentTab == "Loader")
        end
        LoaderTabGradient.Enabled = true
        ChatTabGradient.Enabled = false
        ChatSection.Position = UDim2.new(0, 150, 0, 50)
        ChatSection.Size = UDim2.new(1, -150, 0, 400)
        OutputSection.Position = UDim2.new(0, 150, 1, -100)
        OutputSection.Size = UDim2.new(1, -150, 0, 100)
        ChatSection.Visible = false
        Sidebar.Visible = true
    end)

    SectionButton.MouseEnter:Connect(function()
        TweenService:Create(SectionButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
    end)

    SectionButton.MouseLeave:Connect(function()
        TweenService:Create(SectionButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
    end)
end

local SectionContainer = Instance.new("Frame")
SectionContainer.Size = UDim2.new(1, -150, 0, 400)
SectionContainer.Position = UDim2.new(0, 150, 0, 50)
SectionContainer.BackgroundTransparency = 1
SectionContainer.Parent = MainFrame

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
LoadButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
LoadButton.BackgroundTransparency = 0.3
LoadButton.Text = "Load Selected Modules"
LoadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadButton.TextSize = 16
LoadButton.Font = Enum.Font.Montserrat
LoadButton.Parent = MainSection

local LoadButtonCorner = Instance.new("UICorner")
LoadButtonCorner.CornerRadius = UDim.new(0, 8)
LoadButtonCorner.Parent = LoadButton

local LoadButtonGradient = Instance.new("UIGradient")
LoadButtonGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
LoadButtonGradient.Rotation = 45
LoadButtonGradient.Parent = LoadButton

LoadButton.MouseEnter:Connect(function()
    TweenService:Create(LoadButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
end)

LoadButton.MouseLeave:Connect(function()
    TweenService:Create(LoadButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
end)

local MainLabel = Instance.new("TextLabel")
MainLabel.Size = UDim2.new(1, -20, 0, 30)
MainLabel.Position = UDim2.new(0, 10, 0, 10)
MainLabel.BackgroundTransparency = 1
MainLabel.Text = "Main"
MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
MainLabel.TextSize = 16
MainLabel.Font = Enum.Font.Montserrat
MainLabel.TextXAlignment = Enum.TextXAlignment.Left
MainLabel.Parent = MainSection

local MainDivider = Instance.new("Frame")
MainDivider.Size = UDim2.new(1, -20, 0, 2)
MainDivider.Position = UDim2.new(0, 10, 0, 40)
MainDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainDivider.BorderSizePixel = 0
MainDivider.Parent = MainSection

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
AutofarmLabel.Font = Enum.Font.Montserrat
AutofarmLabel.TextXAlignment = Enum.TextXAlignment.Left
AutofarmLabel.Parent = AutofarmSection

local AutofarmDivider = Instance.new("Frame")
AutofarmDivider.Size = UDim2.new(1, -20, 0, 2)
AutofarmDivider.Position = UDim2.new(0, 10, 0, 40)
AutofarmDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AutofarmDivider.BorderSizePixel = 0
AutofarmDivider.Parent = AutofarmSection

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
SettingsLabel.Font = Enum.Font.Montserrat
SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
SettingsLabel.Parent = SettingsSection

local SettingsDivider = Instance.new("Frame")
SettingsDivider.Size = UDim2.new(1, -20, 0, 2)
SettingsDivider.Position = UDim2.new(0, 10, 0, 40)
SettingsDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SettingsDivider.BorderSizePixel = 0
SettingsDivider.Parent = SettingsSection

local ChatLocationContainer = Instance.new("Frame")
ChatLocationContainer.Size = UDim2.new(1, -20, 0, 60)
ChatLocationContainer.Position = UDim2.new(0, 10, 0, 50)
ChatLocationContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ChatLocationContainer.BackgroundTransparency = 0.3
ChatLocationContainer.BorderSizePixel = 0
ChatLocationContainer.Parent = SettingsSection

local ChatLocationContainerCorner = Instance.new("UICorner")
ChatLocationContainerCorner.CornerRadius = UDim.new(0, 6)
ChatLocationContainerCorner.Parent = ChatLocationContainer

local ChatLocationLabel = Instance.new("TextLabel")
ChatLocationLabel.Size = UDim2.new(1, -10, 0, 20)
ChatLocationLabel.Position = UDim2.new(0, 5, 0, 5)
ChatLocationLabel.BackgroundTransparency = 1
ChatLocationLabel.Text = "Chat Location"
ChatLocationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatLocationLabel.TextSize = 14
ChatLocationLabel.Font = Enum.Font.Montserrat
ChatLocationLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatLocationLabel.Parent = ChatLocationContainer

local ChatLocationFrame = Instance.new("Frame")
ChatLocationFrame.Size = UDim2.new(0, 80, 0, 20)
ChatLocationFrame.Position = UDim2.new(0, 5, 0, 30)
ChatLocationFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ChatLocationFrame.Parent = ChatLocationContainer

local ChatLocationCorner = Instance.new("UICorner")
ChatLocationCorner.CornerRadius = UDim.new(1, 0)
ChatLocationCorner.Parent = ChatLocationFrame

local ChatLocationIndicator = Instance.new("Frame")
ChatLocationIndicator.Size = UDim2.new(0, 40, 0, 20)
ChatLocationIndicator.Position = UDim2.new(0, 0, 0, 0)
ChatLocationIndicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ChatLocationIndicator.Parent = ChatLocationFrame

local ChatLocationIndicatorCorner = Instance.new("UICorner")
ChatLocationIndicatorCorner.CornerRadius = UDim.new(1, 0)
ChatLocationIndicatorCorner.Parent = ChatLocationIndicator

local ChatLocationText = Instance.new("TextLabel")
ChatLocationText.Size = UDim2.new(1, 0, 1, 0)
ChatLocationText.BackgroundTransparency = 1
ChatLocationText.Text = "In Menu"
ChatLocationText.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatLocationText.TextSize = 14
ChatLocationText.Font = Enum.Font.Montserrat
ChatLocationText.TextXAlignment = Enum.TextXAlignment.Center
ChatLocationText.Parent = ChatLocationFrame

local ChatSection = Instance.new("Frame")
ChatSection.Size = UDim2.new(1, -150, 0, 400)
ChatSection.Position = UDim2.new(0, 150, 0, 50)
ChatSection.BackgroundTransparency = 1
ChatSection.Visible = false
ChatSection.Parent = MainFrame

local ChatLabel = Instance.new("TextLabel")
ChatLabel.Size = UDim2.new(1, -20, 0, 30)
ChatLabel.Position = UDim2.new(0, 10, 0, 10)
ChatLabel.BackgroundTransparency = 1
ChatLabel.Text = "Chat"
ChatLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatLabel.TextSize = 16
ChatLabel.Font = Enum.Font.Montserrat
ChatLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatLabel.Parent = ChatSection

local ChatDivider = Instance.new("Frame")
ChatDivider.Size = UDim2.new(1, -20, 0, 2)
ChatDivider.Position = UDim2.new(0, 10, 0, 40)
ChatDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ChatDivider.BorderSizePixel = 0
ChatDivider.ZIndex = 2
ChatDivider.Parent = ChatSection

local ChatFrame = Instance.new("Frame")
ChatFrame.Size = UDim2.new(1, -20, 1, -50)
ChatFrame.Position = UDim2.new(0, 10, 0, 40)
ChatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ChatFrame.BackgroundTransparency = 0.3
ChatFrame.BorderSizePixel = 1
ChatFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
ChatFrame.ZIndex = 1
ChatFrame.Parent = ChatSection

local ChatCorner = Instance.new("UICorner")
ChatCorner.CornerRadius = UDim.new(0, 12)
ChatCorner.Parent = ChatFrame

local ChatPadding = Instance.new("UIPadding")
ChatPadding.PaddingLeft = UDim.new(0, 5)
ChatPadding.PaddingRight = UDim.new(0, 5)
ChatPadding.PaddingTop = UDim.new(0, 5)
ChatPadding.PaddingBottom = UDim.new(0, 5)
ChatPadding.Parent = ChatFrame

local ChatList = Instance.new("ScrollingFrame")
ChatList.Size = UDim2.new(1, 0, 1, -40)
ChatList.Position = UDim2.new(0, 0, 0, 0)
ChatList.BackgroundTransparency = 1
ChatList.BorderSizePixel = 0
ChatList.CanvasSize = UDim2.new(0, 0, 0, 0)
ChatList.ScrollBarThickness = 4
ChatList.Parent = ChatFrame

local ChatListLayout = Instance.new("UIListLayout")
ChatListLayout.Padding = UDim.new(0, 5)
ChatListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatListLayout.Parent = ChatList

local ChatInput = Instance.new("TextBox")
ChatInput.Size = UDim2.new(1, -110, 0, 30)
ChatInput.Position = UDim2.new(0, 5, 1, -35)
ChatInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ChatInput.BackgroundTransparency = 0.3
ChatInput.Text = ""
ChatInput.PlaceholderText = "Type your message..."
ChatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatInput.TextSize = 14
ChatInput.Font = Enum.Font.Montserrat
ChatInput.TextXAlignment = Enum.TextXAlignment.Left
ChatInput.Parent = ChatFrame

local ChatInputCorner = Instance.new("UICorner")
ChatInputCorner.CornerRadius = UDim.new(0, 6)
ChatInputCorner.Parent = ChatInput

local ChatInputGradient = Instance.new("UIGradient")
ChatInputGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
ChatInputGradient.Rotation = 45
ChatInputGradient.Parent = ChatInput

local ShareJobIdButton = Instance.new("TextButton")
ShareJobIdButton.Size = UDim2.new(0, 100, 0, 30)
ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
ShareJobIdButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ShareJobIdButton.BackgroundTransparency = 0.3
ShareJobIdButton.Text = "Share JobId"
ShareJobIdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShareJobIdButton.TextSize = 14
ShareJobIdButton.Font = Enum.Font.Montserrat
ShareJobIdButton.Parent = ChatFrame

local ShareJobIdCorner = Instance.new("UICorner")
ShareJobIdCorner.CornerRadius = UDim.new(0, 6)
ShareJobIdCorner.Parent = ShareJobIdButton

local ShareJobIdGradient = Instance.new("UIGradient")
ShareJobIdGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
ShareJobIdGradient.Rotation = 45
ShareJobIdGradient.Parent = ShareJobIdButton

ShareJobIdButton.MouseEnter:Connect(function()
    TweenService:Create(ShareJobIdButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
end)

ShareJobIdButton.MouseLeave:Connect(function()
    TweenService:Create(ShareJobIdButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
end)

local OutputSection = Instance.new("Frame")
OutputSection.Size = UDim2.new(1, -150, 0, 100)
OutputSection.Position = UDim2.new(0, 150, 1, -100)
OutputSection.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
OutputSection.BackgroundTransparency = 0.2
OutputSection.Parent = MainFrame

local OutputLabel = Instance.new("TextLabel")
OutputLabel.Size = UDim2.new(1, -20, 0, 20)
OutputLabel.Position = UDim2.new(0, 10, 0, 0)
OutputLabel.BackgroundTransparency = 1
OutputLabel.Text = "Output"
OutputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OutputLabel.TextSize = 16
OutputLabel.Font = Enum.Font.Montserrat
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.Parent = OutputSection

local OutputList = Instance.new("ScrollingFrame")
OutputList.Size = UDim2.new(1, -20, 1, -30)
OutputList.Position = UDim2.new(0, 10, 0, 20)
OutputList.BackgroundTransparency = 1
OutputList.BorderSizePixel = 0
OutputList.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputList.ScrollBarThickness = 6
OutputList.Parent = OutputSection

local OutputListLayout = Instance.new("UIListLayout")
OutputListLayout.Padding = UDim.new(0, 5)
OutputListLayout.SortOrder = Enum.SortOrder.LayoutOrder
OutputListLayout.Parent = OutputList

for i, module in ipairs(Core.Modules) do
    local ModuleFrame = Instance.new("Frame")
    ModuleFrame.Size = UDim2.new(1, 0, 0, 40)
    ModuleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    ModuleFrame.BackgroundTransparency = 0.3
    ModuleFrame.LayoutOrder = i
    ModuleFrame.Parent = ModuleList

    local ModuleCorner = Instance.new("UICorner")
    ModuleCorner.CornerRadius = UDim.new(0, 6)
    ModuleCorner.Parent = ModuleFrame

    local ModuleLabel = Instance.new("TextLabel")
    ModuleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ModuleLabel.Position = UDim2.new(0, 10, 0, 0)
    ModuleLabel.BackgroundTransparency = 1
    ModuleLabel.Text = module.Name
    ModuleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ModuleLabel.TextSize = 16
    ModuleLabel.Font = Enum.Font.Montserrat
    ModuleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ModuleLabel.Parent = ModuleFrame

    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(0, 40, 0, 20)
    ToggleFrame.Position = UDim2.new(1, -50, 0, 10)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ToggleFrame.Parent = ModuleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleFrame

    local ToggleIndicator = Instance.new("Frame")
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = module.Enabled and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
    ToggleIndicator.BackgroundColor3 = module.Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(80, 80, 80)
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
            ToggleIndicator.BackgroundColor3 = module.Enabled and Color3.fromRGB(147, 112, 219) or Color3.fromRGB(80, 80, 80)
        end
    end)
end

LoadButton.MouseButton1Click:Connect(function()
    if not Core.InitializeMacLib() then
        Core.AddLog("Error: Failed to initialize MacLib", true)
        return
    end

    local selectedModules = 0
    for _, module in ipairs(Core.Modules) do
        if module.Enabled then
            selectedModules = selectedModules + 1
        end
    end

    if selectedModules == 0 then
        Core.AddLog("Info: No modules selected. Closing loader.", false)
        ScreenGui:Destroy()
        return
    end

    local loadedModules = 0
    for _, module in ipairs(Core.Modules) do
        if module.Enabled then
            Core.LoadModule(module.Name, module.URL)
            loadedModules = loadedModules + 1
            if loadedModules == selectedModules then
                Core.AddLog("🔰 FastLoad: All selected modules loaded!", false)
                ScreenGui:Destroy()
            end
        end
    end
end)

local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
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
    if not camera then
        warn("Camera not found, cannot rescale UI")
        return
    end

    local currentResolution = camera.ViewportSize
    local scale
    if Core.Services.UserInputService.TouchEnabled then
        scale = 0.6
    else
        local scaleX = currentResolution.X / BASE_RESOLUTION.X
        local scaleY = currentResolution.Y / BASE_RESOLUTION.Y
        scale = math.min(scaleX, scaleY)
        scale = math.min(scale, 1)
    end

    MainFrame.Size = UDim2.new(0, 650 * scale, 0, 550 * scale)
    MainFrame.Position = UDim2.new(0.5, -325 * scale, 0.5, -275 * scale)
end

rescaleUI()

Core.Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    rescaleUI()
end)

_G.SetUIScale = function(scale)
    MainFrame.Size = UDim2.new(0, 650 * scale, 0, 550 * scale)
    MainFrame.Position = UDim2.new(0.5, -325 * scale, 0.5, -275 * scale)
end

_G.UpdateOutput = function(logs)
    OutputList:ClearAllChildren()
    for _, log in ipairs(logs) do
        local LogLabel = Instance.new("TextLabel")
        LogLabel.Size = UDim2.new(1, 0, 0, 20)
        LogLabel.BackgroundTransparency = 1
        LogLabel.Text = log.Text
        LogLabel.TextColor3 = log.IsError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)
        LogLabel.TextSize = 14
        LogLabel.Font = Enum.Font.Montserrat
        LogLabel.TextXAlignment = Enum.TextXAlignment.Left
        LogLabel.Parent = OutputList
    end
    OutputList.CanvasSize = UDim2.new(0, 0, 0, #logs * 25)
    OutputList.CanvasPosition = Vector2.new(0, OutputList.CanvasSize.Y.Offset)
end

local ChatMessages = {}
local DisplayedMessageIds = {}
local UserId = tostring(math.random(1000, 9999))
local FIREBASE_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/messages.json"
local ChatLocation = "InMenu"
local PlaceId = game.PlaceId

local function isValidJobId(jobId)
    return jobId:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
end

local function addChatMessage(userId, message, messageId)
    if DisplayedMessageIds[messageId] then
        return
    end

    table.insert(ChatMessages, { userId = userId, message = message, messageId = messageId })
    DisplayedMessageIds[messageId] = true

    local ChatMessageFrame = Instance.new("Frame")
    ChatMessageFrame.Size = UDim2.new(1, 0, 0, 20)
    ChatMessageFrame.BackgroundTransparency = 1
    ChatMessageFrame.Parent = ChatList

    local ChatMessageLabel = Instance.new("TextLabel")
    ChatMessageLabel.Size = UDim2.new(1, -100, 1, 0)
    ChatMessageLabel.BackgroundTransparency = 1
    ChatMessageLabel.Text = userId .. ": " .. message
    ChatMessageLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    ChatMessageLabel.TextSize = 14
    ChatMessageLabel.Font = Enum.Font.Montserrat
    ChatMessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ChatMessageLabel.TextWrapped = true
    ChatMessageLabel.Parent = ChatMessageFrame

    local jobId = message:match("JobId: (%S+)")
    if jobId and isValidJobId(jobId) then
        local JoinButton = Instance.new("TextButton")
        JoinButton.Size = UDim2.new(0, 80, 0, 20)
        JoinButton.Position = UDim2.new(1, -90, 0, 0)
        JoinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        JoinButton.BackgroundTransparency = 0.3
        JoinButton.Text = "Join Server"
        JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinButton.TextSize = 12
        JoinButton.Font = Enum.Font.Montserrat
        JoinButton.Parent = ChatMessageFrame

        local JoinButtonCorner = Instance.new("UICorner")
        JoinButtonCorner.CornerRadius = UDim.new(0, 4)
        JoinButtonCorner.Parent = JoinButton

        local JoinButtonGradient = Instance.new("UIGradient")
        JoinButtonGradient.Color = ColorSequence.new(Color3.fromRGB(0, 153, 255), Color3.fromRGB(147, 112, 219))
        JoinButtonGradient.Rotation = 45
        JoinButtonGradient.Parent = JoinButton

        JoinButton.MouseEnter:Connect(function()
            TweenService:Create(JoinButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.1}):Play()
        end)

        JoinButton.MouseLeave:Connect(function()
            TweenService:Create(JoinButton, TweenInfo.new(0.2), {BackgroundTransparency = 0.3}):Play()
        end)

        JoinButton.MouseButton1Click:Connect(function()
            local success, err = pcall(function()
                Core.Services.TeleportService:TeleportToPlaceInstance(PlaceId, jobId, Core.PlayerData.LocalPlayer)
            end)
            if success then
                Core.AddLog("Teleporting to server with JobId: " .. jobId, false)
            else
                Core.AddLog("Failed to teleport: " .. tostring(err), true)
            end
        end)
    end

    ChatList.CanvasSize = UDim2.new(0, 0, 0, #ChatMessages * 25)
    ChatList.CanvasPosition = Vector2.new(0, ChatList.CanvasSize.Y.Offset)
end

local function fetchMessages()
    local success, response = pcall(function()
        local response = request({
            Url = FIREBASE_URL,
            Method = "GET"
        })
        if response then
            if response.StatusCode == 200 then
                if response.Body then
                    local decoded = game:GetService("HttpService"):JSONDecode(response.Body)
                    if decoded == nil then
                        return {}
                    end
                    return decoded
                else
                    error("No response body")
                end
            else
                error("Invalid status code: " .. tostring(response.StatusCode))
            end
        else
            error("Response is nil")
        end
    end)

    if success then
        if type(response) == "table" then
            local sortedMessages = {}
            for messageId, msg in pairs(response) do
                if msg.userId and msg.message and msg.timestamp then
                    table.insert(sortedMessages, { id = messageId, userId = msg.userId, message = msg.message, timestamp = msg.timestamp })
                end
            end
            table.sort(sortedMessages, function(a, b) return a.timestamp < b.timestamp end)

            for _, msg in ipairs(sortedMessages) do
                addChatMessage(msg.userId, msg.message, msg.id)
            end
        end
    end
end

local function sendMessage(message)
    local success, err = pcall(function()
        local data = {
            userId = UserId,
            message = message,
            timestamp = os.time()
        }
        local encodedData = game:GetService("HttpService"):JSONEncode(data)
        local response = request({
            Url = FIREBASE_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = encodedData
        })
        if response and response.StatusCode == 200 then
            fetchMessages()
        end
    end)
end

ShareJobIdButton.MouseButton1Click:Connect(function()
    local jobId = game.JobId
    if jobId and jobId ~= "" then
        local message = "JobId: " .. jobId
        sendMessage(message)
        Core.AddLog("Shared JobId: " .. jobId, false)
    else
        Core.AddLog("Error: No JobId available (you might be in Studio or on a local server)", true)
    end
end)

local function updateChatLocation()
    if ChatLocation == "InMenu" then
        ChatFrame.Parent = ChatSection
        ChatFrame.Size = UDim2.new(1, -20, 1, -50)
        ChatFrame.Position = UDim2.new(0, 10, 0, 40)
        ChatList.Size = UDim2.new(1, 0, 1, -40)
        ChatList.Position = UDim2.new(0, 0, 0, 0)
        ChatInput.Size = UDim2.new(1, -110, 0, 30)
        ChatInput.Position = UDim2.new(0, 5, 1, -35)
        ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
        ChatTab.Visible = true
        OutputSection.Position = CurrentTab == "Chat" and UDim2.new(0, 0, 1, -100) or UDim2.new(0, 150, 1, -100)
        OutputSection.Size = CurrentTab == "Chat" and UDim2.new(1, 0, 0, 100) or UDim2.new(1, -150, 0, 100)
        Sidebar.Visible = CurrentTab == "Loader"
    else
        ChatFrame.Parent = MainFrame
        ChatFrame.Size = UDim2.new(1, -150, 0, 100)
        ChatFrame.Position = UDim2.new(0, 150, 1, -100)
        ChatList.Size = UDim2.new(1, 0, 1, -40)
        ChatList.Position = UDim2.new(0, 0, 0, 0)
        ChatInput.Size = UDim2.new(1, -110, 0, 30)
        ChatInput.Position = UDim2.new(0, 5, 1, -35)
        ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
        ChatTab.Visible = false
        CurrentTab = "Loader"
        LoaderTabGradient.Enabled = true
        ChatTabGradient.Enabled = false
        ChatSection.Position = UDim2.new(0, 150, 0, 50)
        ChatSection.Size = UDim2.new(1, -150, 0, 400)
        ChatSection.Visible = false
        OutputSection.Position = UDim2.new(0, 150, 1, -100)
        OutputSection.Size = UDim2.new(1, -150, 0, 100)
        Sidebar.Visible = true
        for secName, frame in pairs(SectionFrames) do
            frame.Visible = (secName == CurrentSection) and (CurrentTab == "Loader")
        end
    end
end

LoaderTab.MouseButton1Click:Connect(function()
    CurrentTab = "Loader"
    LoaderTabGradient.Enabled = true
    ChatTabGradient.Enabled = false
    ChatSection.Position = UDim2.new(0, 150, 0, 50)
    ChatSection.Size = UDim2.new(1, -150, 0, 400)
    ChatSection.Visible = false
    OutputSection.Position = UDim2.new(0, 150, 1, -100)
    OutputSection.Size = UDim2.new(1, -150, 0, 100)
    Sidebar.Visible = true
    for secName, frame in pairs(SectionFrames) do
        frame.Visible = (secName == CurrentSection) and (CurrentTab == "Loader")
    end
end)

ChatTab.MouseButton1Click:Connect(function()
    CurrentTab = "Chat"
    LoaderTabGradient.Enabled = false
    ChatTabGradient.Enabled = true
    for secName, frame in pairs(SectionFrames) do
        frame.Visible = false
    end
    ChatSection.Position = UDim2.new(0, 0, 0, 50)
    ChatSection.Size = UDim2.new(1, 0, 0, 400)
    ChatSection.Visible = true
    OutputSection.Position = UDim2.new(0, 0, 1, -100)
    OutputSection.Size = UDim2.new(1, 0, 0, 100)
    Sidebar.Visible = false
end)

ChatLocationFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        ChatLocation = ChatLocation == "InMenu" and "AsOutput" or "InMenu"
        ChatLocationText.Text = ChatLocation == "InMenu" and "In Menu" or "As Output"
        Core.Services.TweenService:Create(
            ChatLocationIndicator,
            TweenInfo.new(0.2),
            {Position = ChatLocation == "InMenu" and UDim2.new(0, 0, 0, 0) or UDim2.new(0, 40, 0, 0)}
        ):Play()
        ChatLocationIndicator.BackgroundColor3 = ChatLocation == "InMenu" and Color3.fromRGB(80, 80, 80) or Color3.fromRGB(147, 112, 219)
        updateChatLocation()
    end
end)

ChatInput.FocusLost:Connect(function(enterPressed)
    if enterPressed and ChatInput.Text ~= "" then
        sendMessage(ChatInput.Text)
        ChatInput.Text = ""
    end
end)

spawn(function()
    while true do
        fetchMessages()
        wait(5)
    end
end)

MainFrame.BackgroundTransparency = 1
local fadeIn = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 0.1})
fadeIn:Play()

Core.AddLog("🔰 Syllinse Loader: Loader UI initialized!", false)
addChatMessage("System", "Chat initialized. Your ID: " .. UserId, "system_init")
addChatMessage("System", "Connected to Firebase!", "system_connect")
fetchMessages()
