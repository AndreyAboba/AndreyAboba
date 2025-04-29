local module = {}

function module.Init(UI, Core, notify)
    -- Получение сервисов через Core
    local Players = Core.Services.Players
    local UserInputService = Core.Services.UserInputService
    local RunService = Core.Services.RunService
    local TweenService = Core.Services.TweenService
    local LocalPlayer = Core.PlayerData.LocalPlayer

    -- Создание секции Radar
    if not UI.Sections.Radar then
        UI.Sections.Radar = UI.Tabs.Visuals:Section({ Name = "Radar", Side = "Right" })
    end

    -- Объект радара
    local Radar = {
        State = {
            Enabled = false,
            Dragging = false,
            DragStart = nil,
            StartPos = nil,
            Scale = 0.1,
            ShowDebugLabels = true,
            Position = UDim2.new(0, 10, 0, 10),
        },
        Config = {
            Size = 150,
            BackgroundColor = Color3.fromRGB(20, 30, 50),
            BackgroundTransparency = 0.3,
            DotColor = Color3.fromRGB(255, 0, 0),
            FriendColor = Color3.fromRGB(0, 0, 255),
            DotSize = 5,
            UpdateInterval = 0.02,
            LocalPlayerColor = Color3.fromRGB(0, 255, 0),
            LocalPlayerSize = 8,
            CrosshairColor = Color3.fromRGB(255, 255, 255),
            CrosshairTransparency = 0.5,
            BorderTransparency = 0.5,
            GradientSpeed = 30,
            GradientEnabled = true,
            RadarColor = Color3.fromRGB(255, 255, 255),
        },
        Elements = {
            Gui = nil,
            Container = nil,
            Dots = {},
            LocalPlayerIndicator = nil,
            CrosshairVertical = nil,
            CrosshairHorizontal = nil,
            Border = nil,
            Gradient = nil,
            NorthLabel = nil,
            SouthLabel = nil,
            EastLabel = nil,
            WestLabel = nil,
        },
        FriendCache = {
            IsFriend = {},
        }
    }

    -- Локальные ссылки для ускорения доступа
    local Dots = Radar.Elements.Dots
    local FriendCache = Radar.FriendCache.IsFriend
    local Config = Radar.Config
    local State = Radar.State
    local Elements = Radar.Elements

    -- Кэширование часто используемых значений
    local function updateCachedValues()
        State.MaxOffset = Config.Size / 2 - Config.DotSize / 2
        State.LocalPlayerIndicatorPos = UDim2.new(0.5, -Config.LocalPlayerSize / 2, 0.5, -Config.LocalPlayerSize / 2)
    end
    updateCachedValues()

    -- Создание точки для игрока
    local function createPlayerDot(player)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, Config.DotSize, 0, Config.DotSize)
        local playerNameLower = player.Name:lower()
        local isFriend = Core.Services.FriendsList and Core.Services.FriendsList[playerNameLower] or false
        FriendCache[playerNameLower] = isFriend
        dot.BackgroundColor3 = isFriend and Config.FriendColor or Config.DotColor
        dot.BackgroundTransparency = 0
        dot.BorderSizePixel = 0
        dot.Parent = Elements.Container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = dot

        Dots[player] = dot
    end

    -- Создание GUI радара
    local function createRadarGui()
        if Elements.Gui then
            Elements.Gui:Destroy()
        end
        table.clear(Dots)

        local gui = Instance.new("ScreenGui")
        gui.Name = "SyllinseRadarGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Enabled = State.Enabled
        gui.Parent = Core.Services.CoreGuiService
        Elements.Gui = gui

        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, Config.Size, 0, Config.Size)
        container.Position = State.Position
        container.BackgroundColor3 = Config.BackgroundColor
        container.BackgroundTransparency = Config.BackgroundTransparency
        container.BorderSizePixel = 0
        container.Parent = gui
        Elements.Container = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = container

        local border = Instance.new("Frame")
        border.Size = UDim2.new(1, 4, 1, 4)
        border.Position = UDim2.new(0, -2, 0, -2)
        border.BackgroundTransparency = Config.BorderTransparency
        border.BackgroundColor3 = Config.RadarColor
        border.BorderSizePixel = 0
        border.Parent = container
        Elements.Border = border

        local borderCorner = Instance.new("UICorner")
        borderCorner.CornerRadius = UDim.new(0, 7)
        borderCorner.Parent = border

        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
            ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 2"])
        })
        gradient.Rotation = 45
        gradient.Enabled = Config.GradientEnabled
        gradient.Parent = border
        Elements.Gradient = gradient

        RunService.Heartbeat:Connect(function(deltaTime)
            if Elements.Border then
                if Config.GradientEnabled then
                    gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
                        ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 2"])
                    })
                    gradient.Rotation = (gradient.Rotation + deltaTime * Config.GradientSpeed) % 360
                    gradient.Enabled = true
                    Elements.Border.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                else
                    gradient.Enabled = false
                    Elements.Border.BackgroundColor3 = Config.RadarColor
                end
            end
        end)

        local crosshairVertical = Instance.new("Frame")
        crosshairVertical.Size = UDim2.new(0, 1, 1, 0)
        crosshairVertical.Position = UDim2.new(0.5, 0, 0, 0)
        crosshairVertical.BackgroundColor3 = Config.CrosshairColor
        crosshairVertical.BackgroundTransparency = Config.CrosshairTransparency
        crosshairVertical.BorderSizePixel = 0
        crosshairVertical.Parent = container
        Elements.CrosshairVertical = crosshairVertical

        local crosshairHorizontal = Instance.new("Frame")
        crosshairHorizontal.Size = UDim2.new(1, 0, 0, 1)
        crosshairHorizontal.Position = UDim2.new(0, 0, 0.5, 0)
        crosshairHorizontal.BackgroundColor3 = Config.CrosshairColor
        crosshairHorizontal.BackgroundTransparency = Config.CrosshairTransparency
        crosshairHorizontal.BorderSizePixel = 0
        crosshairHorizontal.Parent = container
        Elements.CrosshairHorizontal = crosshairHorizontal

        local function createDebugLabels()
            if Elements.NorthLabel then Elements.NorthLabel:Destroy() end
            if Elements.SouthLabel then Elements.SouthLabel:Destroy() end
            if Elements.EastLabel then Elements.EastLabel:Destroy() end
            if Elements.WestLabel then Elements.WestLabel:Destroy() end

            if not State.ShowDebugLabels then return end

            local northLabel = Instance.new("TextLabel")
            northLabel.Size = UDim2.new(0, 20, 0, 20)
            northLabel.Position = UDim2.new(0.5, -10, 0, -10)
            northLabel.BackgroundTransparency = 1
            northLabel.Text = "N"
            northLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            northLabel.TextSize = 14
            northLabel.Parent = container
            Elements.NorthLabel = northLabel

            local southLabel = Instance.new("TextLabel")
            southLabel.Size = UDim2.new(0, 20, 0, 20)
            southLabel.Position = UDim2.new(0.5, -10, 1, -10)
            southLabel.BackgroundTransparency = 1
            southLabel.Text = "S"
            southLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            southLabel.TextSize = 14
            southLabel.Parent = container
            Elements.SouthLabel = southLabel

            local eastLabel = Instance.new("TextLabel")
            eastLabel.Size = UDim2.new(0, 20, 0, 20)
            eastLabel.Position = UDim2.new(1, -10, 0.5, -10)
            eastLabel.BackgroundTransparency = 1
            eastLabel.Text = "E"
            eastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            eastLabel.TextSize = 14
            eastLabel.Parent = container
            Elements.EastLabel = eastLabel

            local westLabel = Instance.new("TextLabel")
            westLabel.Size = UDim2.new(0, 20, 0, 20)
            westLabel.Position = UDim2.new(0, -10, 0.5, -10)
            westLabel.BackgroundTransparency = 1
            westLabel.Text = "W"
            westLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            westLabel.TextSize = 14
            westLabel.Parent = container
            Elements.WestLabel = westLabel
        end
        createDebugLabels()

        local localPlayerIndicator = Instance.new("ImageLabel")
        localPlayerIndicator.Size = UDim2.new(0, Config.LocalPlayerSize, 0, Config.LocalPlayerSize)
        localPlayerIndicator.Position = State.LocalPlayerIndicatorPos
        localPlayerIndicator.BackgroundTransparency = 1
        localPlayerIndicator.Image = "rbxassetid://4292970642"
        localPlayerIndicator.ImageColor3 = Config.LocalPlayerColor
        localPlayerIndicator.Parent = container
        Elements.LocalPlayerIndicator = localPlayerIndicator

        RunService.Heartbeat:Connect(function()
            if State.Enabled and Elements.LocalPlayerIndicator then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local lookDirection = root.CFrame.LookVector
                    Elements.LocalPlayerIndicator.Rotation = math.deg(math.atan2(lookDirection.Z, lookDirection.X)) + 90
                end
            end
        end)

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createPlayerDot(player)
            end
        end
    end

    -- Удаление точки игрока
    local function removePlayerDot(player)
        local dot = Dots[player]
        if dot then
            dot:Destroy()
            Dots[player] = nil
            FriendCache[player.Name:lower()] = nil
        end
    end

    -- Обновление позиций точек
    local lastUpdate = 0
    local function updateRadar()
        if not State.Enabled or not Elements.Container then return end

        local currentTime = tick()
        if currentTime - lastUpdate < Config.UpdateInterval then return end
        lastUpdate = currentTime

        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not localRoot then return end

        local localPos = localRoot.Position
        local scale = State.Scale
        local maxOffset = State.MaxOffset

        for player, dot in pairs(Dots) do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local relativePos = root.Position - localPos
                local radarX = math.clamp(relativePos.X * scale, -maxOffset, maxOffset)
                local radarZ = math.clamp(relativePos.Z * scale, -maxOffset, maxOffset)
                dot.Position = UDim2.new(0.5, radarX, 0.5, radarZ)
                dot.Visible = true

                local playerNameLower = player.Name:lower()
                local isFriend = FriendCache[playerNameLower]
                if Core.Services.FriendsList and isFriend ~= Core.Services.FriendsList[playerNameLower] then
                    isFriend = Core.Services.FriendsList[playerNameLower] or false
                    FriendCache[playerNameLower] = isFriend
                    dot.BackgroundColor3 = isFriend and Config.FriendColor or Config.DotColor
                end
            else
                dot.Visible = false
            end
        end
    end

    -- Обработка перетаскивания радара
    local function handleInput(input)
        if not State.Enabled then return end

        local mousePos
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mousePos = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
            if input.UserInputState == Enum.UserInputState.Begin then
                if mousePos and Elements.Container then
                    local container = Elements.Container
                    local posX, posY = container.Position.X.Offset, container.Position.Y.Offset
                    local sizeX, sizeY = container.Size.X.Offset, container.Size.Y.Offset
                    if mousePos.X >= posX and mousePos.X <= posX + sizeX and
                       mousePos.Y >= posY and mousePos.Y <= posY + sizeY then
                        State.Dragging = true
                        State.DragStart = mousePos
                        State.StartPos = container.Position
                    end
                end
            elseif input.UserInputState == Enum.UserInputState.End then
                State.Dragging = false
                if Elements.Container then
                    State.Position = Elements.Container.Position
                end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if State.Dragging then
                mousePos = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
                local delta = mousePos - State.DragStart
                Elements.Container.Position = UDim2.new(0, State.StartPos.X.Offset + delta.X, 0, State.StartPos.Y.Offset + delta.Y)
            end
        end
    end

    -- Инициализация радара
    createRadarGui()

    -- Подключение событий
    UserInputService.InputBegan:Connect(handleInput)
    UserInputService.InputChanged:Connect(handleInput)
    UserInputService.InputEnded:Connect(handleInput)

    Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer then
            createPlayerDot(player)
        end
    end)

    Players.PlayerRemoving:Connect(removePlayerDot)
    RunService.RenderStepped:Connect(updateRadar)

    LocalPlayer.CharacterAdded:Connect(createRadarGui)

    -- Добавление UI элементов
    if UI.Sections.Radar then
        UI.Sections.Radar:Header({ Name = "Radar" })

        UI.Sections.Radar:Toggle({
            Name = "Enabled",
            Default = false,
            Callback = function(value)
                State.Enabled = value
                if Elements.Gui then
                    Elements.Gui.Enabled = value
                    if Elements.Container then
                        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                        local targetScale = value and 1 or 0
                        if value then
                            Elements.Container.Size = UDim2.new(0, 0, 0, 0)
                        end
                        TweenService:Create(Elements.Container, tweenInfo, {Size = UDim2.new(0, Config.Size * targetScale, 0, Config.Size * targetScale)}):Play()
                    end
                end
                notify(" Radar", value and " Enabled" or " Disabled", true)
            end
        }, 'RDEnabled')

        UI.Sections.Radar:Slider({
            Name = "Scale",
            Minimum = 0.05,
            Maximum = 0.5,
            Precision = 3,
            Default = 0.1,
            Callback = function(value)
                State.Scale = value
                notify("Radar Scale", "Set to: " .. tostring(value), false)
            end
        }, 'RDScale')

        UI.Sections.Radar:Slider({
            Name = "Radar Size",
            Minimum = 100,
            Maximum = 300,
            Precision = 0,
            Default = 150,
            Callback = function(value)
                Config.Size = value
                updateCachedValues()
                if Elements.Container then
                    Elements.Container.Size = UDim2.new(0, value, 0, value)
                    Elements.LocalPlayerIndicator.Position = State.LocalPlayerIndicatorPos
                    updateRadar()
                end
                notify("Radar Size", "Set to: " .. tostring(value), false)
            end
        }, 'RDSize')

        UI.Sections.Radar:Slider({
            Name = "Dot Size",
            Minimum = 3,
            Maximum = 10,
            Precision = 0,
            Default = 5,
            Callback = function(value)
                Config.DotSize = value
                updateCachedValues()
                for _, dot in pairs(Dots) do
                    dot.Size = UDim2.new(0, value, 0, value)
                end
                updateRadar()
                notify("Dot Size", "Set to: " .. tostring(value), false)
            end
        }, 'DTSize')

        UI.Sections.Radar:Slider({
            Name = "Background Transparency",
            Minimum = 0,
            Maximum = 1,
            Precision = 2,
            Default = 0.3,
            Callback = function(value)
                Config.BackgroundTransparency = value
                if Elements.Container then
                    Elements.Container.BackgroundTransparency = value
                end
                notify("Background Transparency", "Set to: " .. tostring(value), false)
            end
        }, 'BackgroundTransperencyRD')

        UI.Sections.Radar:Toggle({
            Name = "Show Debug Labels",
            Default = true,
            Callback = function(value)
                State.ShowDebugLabels = value
                if Elements.Container then
                    if value then
                        createRadarGui()
                    else
                        if Elements.NorthLabel then Elements.NorthLabel:Destroy() end
                        if Elements.SouthLabel then Elements.SouthLabel:Destroy() end
                        if Elements.EastLabel then Elements.EastLabel:Destroy() end
                        if Elements.WestLabel then Elements.WestLabel:Destroy() end
                    end
                end
                notify("Debug Labels", value and "Enabled" or "Disabled", true)
            end
        }, 'ShowDebugLabelsRD')

        UI.Sections.Radar:Toggle({
            Name = "Gradient Enabled",
            Default = Config.GradientEnabled,
            Callback = function(value)
                Config.GradientEnabled = value
                if Elements.Gradient then
                    Elements.Gradient.Enabled = value
                    if not value then
                        Elements.Border.BackgroundColor3 = Config.RadarColor
                    end
                end
                notify("Gradient", value and "Enabled" or "Disabled", true)
            end
        }, "GradientEnabledRadar")

        UI.Sections.Radar:Slider({
            Name = "Gradient Speed",
            Minimum = 10,
            Maximum = 100,
            Precision = 0,
            Default = Config.GradientSpeed,
            Callback = function(value)
                Config.GradientSpeed = value
                notify("Gradient Speed", "Set to: " .. tostring(value), false)
            end
        }, "GradientSpeedRadar")

        UI.Sections.Radar:Colorpicker({
            Name = "Radar Color",
            Default = Config.RadarColor,
            Callback = function(value)
                Config.RadarColor = value
                if Elements.Border and not Config.GradientEnabled then
                    Elements.Border.BackgroundColor3 = value
                end
                notify("Radar Color", "Updated", true)
            end
        }, "RadarColor")

        UI.Sections.Radar:Colorpicker({
            Name = "Enemy Color",
            Default = Config.DotColor,
            Callback = function(value)
                Config.DotColor = value
                for player, dot in pairs(Dots) do
                    local playerNameLower = player.Name:lower()
                    if not FriendCache[playerNameLower] then
                        dot.BackgroundColor3 = value
                    end
                end
                notify("Enemy Color", "Updated", true)
            end
        }, "EnemyColor")

        UI.Sections.Radar:Colorpicker({
            Name = "Friend Color",
            Default = Config.FriendColor,
            Callback = function(value)
                Config.FriendColor = value
                for player, dot in pairs(Dots) do
                    local playerNameLower = player.Name:lower()
                    if FriendCache[playerNameLower] then
                        dot.BackgroundColor3 = value
                    end
                end
                notify("Friend Color", "Updated", true)
            end
        }, "FriendColor")

        UI.Sections.Radar:Colorpicker({
            Name = "Local Player Color",
            Default = Config.LocalPlayerColor,
            Callback = function(value)
                Config.LocalPlayerColor = value
                if Elements.LocalPlayerIndicator then
                    Elements.LocalPlayerIndicator.ImageColor3 = value
                end
                notify("Local Player Color", "Updated", true)
            end
        }, "LocalPlayerColor")

        UI.Sections.Radar:Colorpicker({
            Name = "Crosshair Color",
            Default = Config.CrosshairColor,
            Callback = function(value)
                Config.CrosshairColor = value
                if Elements.CrosshairVertical then
                    Elements.CrosshairVertical.BackgroundColor3 = value
                end
                if Elements.CrosshairHorizontal then
                    Elements.CrosshairHorizontal.BackgroundColor3 = value
                end
                notify("Crosshair Color", "Updated", true)
            end
        }, "CrosshairColor")
    end
end

return module
