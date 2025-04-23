local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGuiService = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- Основные сервисы
local Core = {
    Services = {
        Players = Players,
        UserInputService = UserInputService,
        CoreGuiService = CoreGuiService,
        Workspace = game:GetService("Workspace"),
        RunService = game:GetService("RunService"),
        ReplicatedStorage = game:GetService("ReplicatedStorage"),
        TweenService = game:GetService("TweenService"),
        HttpService = HttpService,
        TeleportService = TeleportService,
        FriendsList = {}
    },
    PlayerData = {
        LocalPlayer = Players.LocalPlayer,
        Camera = game.Workspace.CurrentCamera
    },
    GradientColors = {
        Color1 = { Value = Color3.fromRGB(0, 0, 255) },
        Color2 = { Value = Color3.fromRGB(147, 112, 219) }
    },
    GunSilentTarget = {
        CurrentTarget = nil
    },
    GlobalConfigs = {
        GradientColors = {
            ["Gradient Color 1"] = nil,
            ["Gradient Color 2"] = nil
        },
        LocalInfo = {
            AnimateNumbers = true,
            AnimationDuration = 0.5,
            UIStyleMode = "Circle",
            PercentStyle = {
                ShowHand = true,
                ShowSafe = true,
                ProgressBarWidth = 80,
                ProgressBarHeight = 10
            },
            CircleStyle = {
                ShowHand = true,
                ShowSafe = true,
                CircleIconStyle = 2
            },
            GradientSettings = {
                Enabled = true,
                Speed = 1,
                ColorSequence = nil
            },
            Enabled = false
        }
    },
    Modules = {
        { Name = "Visuals", URL = "https://raw.githubusercontent.com/pid123or123as/5555/refs/heads/main/vizuals.lua", Enabled = true },
        { Name = "LocalPlayer", URL = "https://raw.githubusercontent.com/pid123or123as/5555/refs/heads/main/lacalpleer.lua", Enabled = true },
        { Name = "Auto", URL = "https://raw.githubusercontent.com/pid123or123as/5555/refs/heads/main/Avto.lua", Enabled = true },
        { Name = "Vehicles", URL = "https://raw.githubusercontent.com/pid123or123as/5555/refs/heads/main/vehecle.lua", Enabled = true },
        { Name = "Misc", URL = "https://raw.githubusercontent.com/pid123or123as/5555/refs/heads/main/mizc.lua", Enabled = true },
        { Name = "Combat", URL = "https://raw.githubusercontent.com/pid927or927as/5555/refs/heads/main/Cumbat.lua", Enabled = true },
        { Name = "GunSilent", URL = "https://raw.githubusercontent.com/pid927or927as/5555/refs/heads/main/CumSilent.lua", Enabled = true },
        { Name = "TargetInfo", URL = "https://raw.githubusercontent.com/pid927or927as/5555/refs/heads/main/torgetenfo.lua", Enabled = true },
        { Name = "LocalInfo", URL = "https://raw.githubusercontent.com/pid927or927as/5555/refs/heads/main/lacalenfo.lua", Enabled = true }
    }
}

Core.GlobalConfigs.GradientColors["Gradient Color 1"] = Core.GradientColors.Color1.Value
Core.GlobalConfigs.GradientColors["Gradient Color 2"] = Core.GradientColors.Color2.Value

local CoreProxy = setmetatable({}, {
    __index = Core,
    __newindex = function(_, key, value)
        warn("Attempt to modify Core detected")
    end
})

local Logs = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SyllinseLoader"
ScreenGui.IgnoreGuiInset = true
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 2147483647
ScreenGui.Parent = CoreGuiService

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 600, 0, 500)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Секция Chat
local ChatSection = Instance.new("Frame")
ChatSection.Size = UDim2.new(1, -150, 0, 350)
ChatSection.Position = UDim2.new(0, 150, 0, 40)
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
ChatLabel.Font = Enum.Font.SourceSansBold
ChatLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatLabel.Parent = ChatSection

local ChatDivider = Instance.new("Frame")
ChatDivider.Size = UDim2.new(1, -20, 0, 2)
ChatDivider.Position = UDim2.new(0, 10, 0, 40)
ChatDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ChatDivider.BorderSizePixel = 0
ChatDivider.ZIndex = 2
ChatDivider.Parent = ChatSection

-- UI чата
local ChatFrame = Instance.new("Frame")
ChatFrame.Size = UDim2.new(1, -20, 1, -80) -- Увеличена ширина
ChatFrame.Position = UDim2.new(0, 10, 0, 40)
ChatFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
ChatList.Size = UDim2.new(1, -10, 1, -40) -- Увеличена ширина
ChatList.Position = UDim2.new(0, 5, 0, 0)
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
ChatInput.Text = ""
ChatInput.PlaceholderText = "Type your message..."
ChatInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ChatInput.TextSize = 14
ChatInput.Font = Enum.Font.SourceSans
ChatInput.TextXAlignment = Enum.TextXAlignment.Left
ChatInput.Parent = ChatFrame

local ChatInputCorner = Instance.new("UICorner")
ChatInputCorner.CornerRadius = UDim.new(0, 5)
ChatInputCorner.Parent = ChatInput

-- Кнопка Share JobId
local ShareJobIdButton = Instance.new("TextButton")
ShareJobIdButton.Size = UDim2.new(0, 100, 0, 30)
ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
ShareJobIdButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
ShareJobIdButton.Text = "Share JobId"
ShareJobIdButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ShareJobIdButton.TextSize = 14
ShareJobIdButton.Font = Enum.Font.SourceSans
ShareJobIdButton.Parent = ChatFrame

local ShareJobIdCorner = Instance.new("UICorner")
ShareJobIdCorner.CornerRadius = UDim.new(0, 5)
ShareJobIdCorner.Parent = ShareJobIdButton

-- Секция Output (снизу, вне вкладки Output)
local OutputSection = Instance.new("Frame")
OutputSection.Size = UDim2.new(1, -150, 0, 110)
OutputSection.Position = UDim2.new(0, 150, 1, -110)
OutputSection.BackgroundTransparency = 1
OutputSection.Parent = MainFrame

local OutputLabel = Instance.new("TextLabel")
OutputLabel.Size = UDim2.new(1, -20, 0, 30)
OutputLabel.Position = UDim2.new(0, 10, 0, 10)
OutputLabel.BackgroundTransparency = 1
OutputLabel.Text = "Output"
OutputLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
OutputLabel.TextSize = 16
OutputLabel.Font = Enum.Font.SourceSansBold
OutputLabel.TextXAlignment = Enum.TextXAlignment.Left
OutputLabel.Parent = OutputSection

local OutputDivider = Instance.new("Frame")
OutputDivider.Size = UDim2.new(1, -20, 0, 2)
OutputDivider.Position = UDim2.new(0, 10, 0, 40)
OutputDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
OutputDivider.BorderSizePixel = 0
OutputDivider.Parent = OutputSection

local OutputListFrame = Instance.new("Frame")
OutputListFrame.Size = UDim2.new(1, -20, 1, -80)
OutputListFrame.Position = UDim2.new(0, 10, 0, 40)
OutputListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
OutputListFrame.BorderSizePixel = 1
OutputListFrame.BorderColor3 = Color3.fromRGB(60, 60, 60)
OutputListFrame.Parent = OutputSection

local OutputListCorner = Instance.new("UICorner")
OutputListCorner.CornerRadius = UDim.new(0, 12)
OutputListCorner.Parent = OutputListFrame

local OutputListPadding = Instance.new("UIPadding")
OutputListPadding.PaddingLeft = UDim.new(0, 5)
OutputListPadding.PaddingRight = UDim.new(0, 5)
OutputListPadding.PaddingTop = UDim.new(0, 5)
OutputListPadding.PaddingBottom = UDim.new(0, 5)
OutputListPadding.Parent = OutputListFrame

local OutputList = Instance.new("ScrollingFrame")
OutputList.Size = UDim2.new(1, 0, 1, 0)
OutputList.Position = UDim2.new(0, 0, 0, 0)
OutputList.BackgroundTransparency = 1
OutputList.BorderSizePixel = 0
OutputList.CanvasSize = UDim2.new(0, 0, 0, 0)
OutputList.ScrollBarThickness = 6
OutputList.Parent = OutputListFrame

local OutputListLayout = Instance.new("UIListLayout")
OutputListLayout.Padding = UDim.new(0, 5)
OutputListLayout.SortOrder = Enum.SortOrder.LayoutOrder
OutputListLayout.Parent = OutputList

-- Загрузка и инициализация MenuModule
local MenuModule
local success, err = pcall(function()
    MenuModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/ваш_репозиторий/имя_репозитория/main/MenuModule.lua"))()
end)

if not success or not MenuModule then
    warn("Failed to load MenuModule: " .. tostring(err))
    addLog("Failed to load MenuModule: " .. tostring(err), true)
    return
end

-- Переменная для отслеживания текущей вкладки
local CurrentTab = { Value = "Loader" }
local ChatLocation = "InMenu"

-- Инициализация меню через MenuModule
local menuResult = MenuModule.InitMenu(MainFrame, Core, CurrentTab, ChatSection, OutputSection, ChatLocation)
local Sidebar = menuResult.Sidebar
local SectionFrames = menuResult.SectionFrames
local CurrentSection = menuResult.CurrentSection
local LoadButton = menuResult.LoadButton
local ChatLocationFrame = menuResult.ChatLocationFrame
local ChatLocationIndicator = menuResult.ChatLocationIndicator
local ChatLocationText = menuResult.ChatLocationText
local TopBar = menuResult.TopBar
local ChatTab = menuResult.ChatTab
local OutputTab = menuResult.OutputTab

-- Функция добавления логов в секцию Output с автоматической прокруткой
local function addLog(message, isError)
    table.insert(Logs, {Text = message, IsError = isError})
    local LogLabel = Instance.new("TextLabel")
    LogLabel.Size = UDim2.new(1, 0, 0, 20)
    LogLabel.BackgroundTransparency = 1
    LogLabel.Text = message
    LogLabel.TextColor3 = isError and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(200, 200, 200)
    LogLabel.TextSize = 14
    LogLabel.Font = Enum.Font.SourceSans
    LogLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogLabel.Parent = OutputList

    OutputList.CanvasSize = UDim2.new(0, 0, 0, #Logs * 25)
    OutputList.CanvasPosition = Vector2.new(0, OutputList.CanvasSize.Y.Offset)
end

-- Загрузка MacLib и инициализация UI
local UI
local function initializeMacLib()
    local MacLib
    local success, err = pcall(function()
        MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()
    end)
    if not success or not MacLib then
        warn("Ошибка загрузки MacLib: " .. tostring(err))
        addLog("Failed to load MacLib: " .. tostring(err), true)
        return false
    end

    UI = {
        Window = MacLib:Window({
            Title = "Syllinse",
            Subtitle = "Stable",
            Size = UDim2.fromOffset(868, 650),
            DragStyle = 1,
            Keybind = Enum.KeyCode.RightControl,
            AcrylicBlur = true
        })
    }

    if not UI.Window then
        warn("Failed to create UI.Window - MacLib initialization failed")
        addLog("Failed to create UI.Window - MacLib initialization failed", true)
        return false
    end

    UI.TabGroups = { Main = UI.Window:TabGroup() }
    UI.Tabs = {
        Visuals = UI.TabGroups.Main:Tab({ Name = "Visuals", Image = "rbxassetid://18821914323" }),
        LocalPlayer = UI.TabGroups.Main:Tab({ Name = "LocalPlayer", Image = "rbxassetid://18821914323" }),
        Auto = UI.TabGroups.Main:Tab({ Name = "Auto", Image = "rbxassetid://18821914323" }),
        Vehicles = UI.TabGroups.Main:Tab({ Name = "Vehicles", Image = "rbxassetid://18821914323" }),
        Misc = UI.TabGroups.Main:Tab({ Name = "Misc", Image = "rbxassetid://18821914323" }),
        Combat = UI.TabGroups.Main:Tab({ Name = "Combat", Image = "rbxassetid://18821914323" }),
        Config = UI.TabGroups.Main:Tab({ Name = "Config", Image = "rbxassetid://18821914323" })
    }
    UI.Sections = {
        Timer = UI.Tabs.LocalPlayer:Section({ Name = "Timer", Side = "Left" }),
        Disabler = UI.Tabs.LocalPlayer:Section({ Name = "Disabler", Side = "Left" }),
        Speed = UI.Tabs.LocalPlayer:Section({ Name = "Speed", Side = "Left" }),
        HighJump = UI.Tabs.LocalPlayer:Section({ Name = "HighJump", Side = "Right" }),
        NoRagdoll = UI.Tabs.LocalPlayer:Section({ Name = "NoRagdoll", Side = "Right" }),
        AntiStamina = UI.Tabs.LocalPlayer:Section({ Name = "AntiStamina", Side = "Right" }),
        FastAttack = UI.Tabs.LocalPlayer:Section({ Name = "FastAttack", Side = "Right" }),
        AutoInteract = UI.Tabs.Auto:Section({ Name = "AutoInteract", Side = "Left" }),
        VehicleSpeed = UI.Tabs.Vehicles:Section({ Name = "VehicleSpeed", Side = "Left" }),
        VehicleFly = UI.Tabs.Vehicles:Section({ Name = "VehicleFly", Side = "Right" }),
        MenuButton = UI.Tabs.Visuals:Section({ Name = "Menu Button", Side = "Left" }),
        Watermark = UI.Tabs.Visuals:Section({ Name = "Watermark", Side = "Left" }),
        GradientColors = UI.Tabs.Visuals:Section({ Name = "Gradient Colors", Side = "Right" }),
        ESP = UI.Tabs.Visuals:Section({ Name = "ESP", Side = "Right" }),
        FriendList = UI.Tabs.Misc:Section({ Name = "Friend List", Side = "Left" }),
        InventoryCapacity = UI.Tabs.Visuals:Section({ Name = "Inventory Capacity", Side = "Left" })
    }

    MacLib:SetFolder('Syllinse')
    UI.Tabs.Config:InsertConfigSection({ Name = 'Config System', Side = 'Left' })

    if UI.Sections.GradientColors then
        UI.Sections.GradientColors:Header({ Name = "Gradient Colors" })
        UI.Sections.GradientColors:Colorpicker({
            Name = "Gradient Color 1",
            Default = Core.GradientColors.Color1.Value,
            Callback = function(value)
                Core.GradientColors.Color1.Value = value
                Core.GlobalConfigs.GradientColors["Gradient Color 1"] = value
            end
        }, "GradientColor1")
        UI.Sections.GradientColors:Colorpicker({
            Name = "Gradient Color 2",
            Default = Core.GradientColors.Color2.Value,
            Callback = function(value)
                Core.GradientColors.Color2.Value = value
                Core.GlobalConfigs.GradientColors["Gradient Color 2"] = value
            end
        }, "GradientColor2")
    end

    return true
end

-- Функция загрузки модуля
local function loadModule(moduleName, url)
    addLog("🔰 | FastLoad: Start: " .. moduleName, false)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success then
        addLog("💠 | Result for " .. moduleName .. ": " .. type(result) .. " " .. tostring(result), false)
        if result and type(result) == "table" then
            addLog("🔘 | Has Main: " .. tostring(result.Init ~= nil), false)
            addLog("🌐 | Main is func: " .. tostring(type(result.Init) == "function"), false)
            if result.Init and type(result.Init) == "function" then
                addLog("🔍 | Main before init: " .. tostring(Core), false)
                addLog("🔍 | RunService is: " .. tostring(Core.Services.RunService), false)
                local initSuccess, initError = pcall(function()
                    result.Init(UI, CoreProxy)
                end)
                if initSuccess then
                    addLog("🔰 | FastLoad: 🟢 : " .. moduleName .. " loaded successfully", false)
                else
                    addLog("💥Error: Failed to initialize " .. moduleName .. ": " .. tostring(initError), true)
                end
            else
                addLog("⭕ " .. moduleName .. ": 💥 Error: Init function not found", true)
            end
        else
            addLog("⭕ " .. moduleName .. ": 💥 Error: Result is not a table", true)
        end
    else
        addLog("⭕ " .. moduleName .. ": 💥 Error: Syntax Error - " .. tostring(result), true)
    end
end

-- Загрузка выбранных модулей
LoadButton.MouseButton1Click:Connect(function()
    if not initializeMacLib() then
        addLog("Error: Failed to initialize MacLib", true)
        return
    end

    local selectedModules = 0
    for _, module in ipairs(Core.Modules) do
        if module.Enabled then
            selectedModules = selectedModules + 1
        end
    end

    if selectedModules == 0 then
        addLog("Info: No modules selected. Closing loader.", false)
        ScreenGui:Destroy()
        return
    end

    local loadedModules = 0
    for _, module in ipairs(Core.Modules) do
        if module.Enabled then
            loadModule(module.Name, module.URL)
            loadedModules = loadedModules + 1
            if loadedModules == selectedModules then
                addLog("🔰 FastLoad: All selected modules loaded!", false)
                ScreenGui:Destroy()
            end
        end
    end
end)

-- Перетаскивание окна
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

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Масштабирование UI
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
        print("Mobile device detected, applying fixed 0.6 UI scale")
    else
        local scaleX = currentResolution.X / BASE_RESOLUTION.X
        local scaleY = currentResolution.Y / BASE_RESOLUTION.Y
        scale = math.min(scaleX, scaleY)
        scale = math.min(scale, 1)
        print("Desktop device detected, applying dynamic UI scale: " .. tostring(scale))
    end

    MainFrame.Size = UDim2.new(0, 600 * scale, 0, 500 * scale)
    MainFrame.Position = UDim2.new(0.5, -300 * scale, 0.5, -250 * scale)
    print("UI scale set to: " .. tostring(scale))
end

rescaleUI()

Core.Services.Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    rescaleUI()
end)

_G.SetUIScale = function(scale)
    MainFrame.Size = UDim2.new(0, 600 * scale, 0, 500 * scale)
    MainFrame.Position = UDim2.new(0.5, -300 * scale, 0.5, -250 * scale)
    print("UI scale manually set to: " .. tostring(scale))
end

-- Начальное сообщение в логах
addLog("🔰 Syllinse Loader: Loader UI initialized!", false)

-- Логика чата через Firebase
local ChatMessages = {}
local DisplayedMessageIds = {}
local UserId = tostring(math.random(1000, 9999))
local FIREBASE_URL = "https://skibidi-chat-26fa2-default-rtdb.firebaseio.com/messages.json"
local PlaceId = game.PlaceId

local lastMessageTime = 0
local lastJobIdTime = 0
local MESSAGE_COOLDOWN = 5
local JOBID_COOLDOWN = 60

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
    ChatMessageLabel.Font = Enum.Font.SourceSans
    ChatMessageLabel.TextXAlignment = Enum.TextXAlignment.Left
    ChatMessageLabel.TextWrapped = true
    ChatMessageLabel.Parent = ChatMessageFrame

    local jobId = message:match("JobId: (%S+)")
    if jobId and isValidJobId(jobId) then
        local JoinButton = Instance.new("TextButton")
        JoinButton.Size = UDim2.new(0, 80, 0, 20)
        JoinButton.Position = UDim2.new(1, -90, 0, 0)
        JoinButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        JoinButton.Text = "Join Server"
        JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinButton.TextSize = 12
        JoinButton.Font = Enum.Font.SourceSans
        JoinButton.Parent = ChatMessageFrame

        local JoinButtonCorner = Instance.new("UICorner")
        JoinButtonCorner.CornerRadius = UDim.new(0, 4)
        JoinButtonCorner.Parent = JoinButton

        JoinButton.MouseButton1Click:Connect(function()
            local success, err = pcall(function()
                Core.Services.TeleportService:TeleportToPlaceInstance(PlaceId, jobId, Core.PlayerData.LocalPlayer)
            end)
            if success then
                addLog("Teleporting to server with JobId: " .. jobId, false)
            else
                addLog("Failed to teleport: " .. tostring(err), true)
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
    local currentTime = tick()
    local timeSinceLastMessage = currentTime - lastMessageTime

    if timeSinceLastMessage < MESSAGE_COOLDOWN then
        local remainingTime = math.ceil(MESSAGE_COOLDOWN - timeSinceLastMessage)
        addLog("⏳ Please wait " .. remainingTime .. " second(s) before sending another message.", true)
        return
    end

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

    if success then
        lastMessageTime = currentTime
    end
end

ShareJobIdButton.MouseButton1Click:Connect(function()
    local currentTime = tick()
    local timeSinceLastJobId = currentTime - lastJobIdTime

    if timeSinceLastJobId < JOBID_COOLDOWN then
        local remainingTime = math.ceil(JOBID_COOLDOWN - timeSinceLastJobId)
        addLog("⏳ Please wait " .. remainingTime .. " second(s) before sharing another JobId.", true)
        return
    end

    local jobId = game.JobId
    if jobId and jobId ~= "" then
        local message = "JobId: " .. jobId
        sendMessage(message)
        lastJobIdTime = currentTime
        addLog("Shared JobId: " .. jobId, false)
    else
        addLog("Error: No JobId available (you might be in Studio or on a local server)", true)
    end
end)

local function updateChatLocation()
    if ChatLocation == "InMenu" then
        ChatFrame.Parent = ChatSection
        ChatFrame.Size = UDim2.new(1, -20, 1, -80) -- Нормальная ширина для чата
        ChatFrame.Position = UDim2.new(0, 10, 0, 40)
        ChatList.Size = UDim2.new(1, -10, 1, -40)
        ChatList.Position = UDim2.new(0, 5, 0, 0)
        ChatInput.Size = UDim2.new(1, -110, 0, 30)
        ChatInput.Position = UDim2.new(0, 5, 1, -35)
        ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
        ChatTab.Visible = true
        ChatSection.Visible = CurrentTab.Value == "Chat"
        OutputSection.Position = CurrentTab.Value == "Chat" and UDim2.new(0, 0, 1, -110) or UDim2.new(0, 150, 1, -110)
        OutputSection.Size = CurrentTab.Value == "Chat" and UDim2.new(1, 0, 0, 110) or UDim2.new(1, -150, 0, 110)
        Sidebar.Visible = CurrentTab.Value == "Loader"
    else
        ChatFrame.Parent = OutputSection
        ChatFrame.Size = UDim2.new(1, -20, 1, -80) -- Исправлено: чат занимает всё пространство Output
        ChatFrame.Position = UDim2.new(0, 10, 0, 40)
        ChatList.Size = UDim2.new(1, -10, 1, -40)
        ChatList.Position = UDim2.new(0, 5, 0, 0)
        ChatInput.Size = UDim2.new(1, -110, 0, 30)
        ChatInput.Position = UDim2.new(0, 5, 1, -35)
        ShareJobIdButton.Position = UDim2.new(1, -105, 1, -35)
        ChatTab.Visible = false
        ChatSection.Visible = false
        OutputSection.Position = UDim2.new(0, 150, 1, -110) -- Возвращаем позицию
        OutputSection.Size = UDim2.new(1, -150, 0, 110)
        Sidebar.Visible = CurrentTab.Value == "Loader"
    end
end

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

addChatMessage("System", "Chat initialized. Your ID: " .. UserId, "system_init")
addChatMessage("System", "Connected to Firebase!", "system_connect")

fetchMessages()
