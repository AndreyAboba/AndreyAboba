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
            Enabled = false, -- Начальное состояние: выключен
            Dragging = false,
            DragStart = nil,
            StartPos = nil,
            Scale = 0.1,
        },
        Config = {
            Size = 150,
            BackgroundColor = Color3.fromRGB(20, 30, 50),
            BackgroundTransparency = 0.3,
            DotColor = Color3.fromRGB(255, 0, 0), -- Красный для врагов
            FriendColor = Color3.fromRGB(0, 0, 255), -- Синий для друзей
            DotSize = 5,
            UpdateInterval = 0.02,
            LocalPlayerColor = Color3.fromRGB(0, 255, 0),
            LocalPlayerSize = 8,
            CrosshairColor = Color3.fromRGB(255, 255, 255),
            CrosshairTransparency = 0.5,
            BorderTransparency = 0.5,
        },
        Elements = {
            Gui = nil,
            Container = nil,
            Dots = {},
            LocalPlayerIndicator = nil,
            CrosshairVertical = nil,
            CrosshairHorizontal = nil,
            Border = nil,
            NorthLabel = nil,
            SouthLabel = nil,
            EastLabel = nil,
            WestLabel = nil,
        }
    }

    -- Создание точки для игрока
    local function createPlayerDot(player)
        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, Radar.Config.DotSize, 0, Radar.Config.DotSize)
        -- Проверяем, является ли игрок другом
        local isFriend = table.find(Core.Services.FriendsList, player.Name) ~= nil
        dot.BackgroundColor3 = isFriend and Radar.Config.FriendColor or Radar.Config.DotColor
        dot.BackgroundTransparency = 0
        dot.BorderSizePixel = 0
        dot.Parent = Radar.Elements.Container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = dot

        Radar.Elements.Dots[player] = dot
    end

    -- Создание GUI радара
    local function createRadarGui()
        if Radar.Elements.Gui then Radar.Elements.Gui:Destroy() end
        Radar.Elements.Dots = {}

        local gui = Instance.new("ScreenGui")
        gui.Name = "SyllinseRadarGui"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.Enabled = Radar.State.Enabled
        gui.Parent = Core.Services.CoreGuiService
        Radar.Elements.Gui = gui

        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, Radar.Config.Size, 0, Radar.Config.Size)
        container.Position = UDim2.new(0, 10, 0, 10)
        container.BackgroundColor3 = Radar.Config.BackgroundColor
        container.BackgroundTransparency = Radar.Config.BackgroundTransparency
        container.BorderSizePixel = 0
        container.Parent = gui
        Radar.Elements.Container = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = container

        -- Градиентный бордер
        local border = Instance.new("Frame")
        border.Size = UDim2.new(1, 4, 1, 4)
        border.Position = UDim2.new(0, -2, 0, -2)
        border.BackgroundTransparency = Radar.Config.BorderTransparency
        border.BorderSizePixel = 0
        border.Parent = container
        Radar.Elements.Border = border

        local borderCorner = Instance.new("UICorner")
        borderCorner.CornerRadius = UDim.new(0, 7)
        borderCorner.Parent = border

        local gradient = Instance.new("UIGradient")
        -- Используем GradientColor1 и GradientColor2 из Core
        gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
            ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 2"])
        })
        gradient.Rotation = 45
        gradient.Parent = border

        -- Анимация градиента
        RunService.Heartbeat:Connect(function(deltaTime)
            if Radar.Elements.Border then
                gradient.Rotation = (gradient.Rotation + deltaTime * 30) % 360
            end
        end)

        -- Перекрестие: вертикальная линия
        local crosshairVertical = Instance.new("Frame")
        crosshairVertical.Size = UDim2.new(0, 1, 1, 0)
        crosshairVertical.Position = UDim2.new(0.5, 0, 0, 0)
        crosshairVertical.BackgroundColor3 = Radar.Config.CrosshairColor
        crosshairVertical.BackgroundTransparency = Radar.Config.CrosshairTransparency
        crosshairVertical.BorderSizePixel = 0
        crosshairVertical.Parent = container
        Radar.Elements.CrosshairVertical = crosshairVertical

        -- Перекрестие: горизонтальная линия
        local crosshairHorizontal = Instance.new("Frame")
        crosshairHorizontal.Size = UDim2.new(1, 0, 0, 1)
        crosshairHorizontal.Position = UDim2.new(0, 0, 0.5, 0)
        crosshairHorizontal.BackgroundColor3 = Radar.Config.CrosshairColor
        crosshairHorizontal.BackgroundTransparency = Radar.Config.CrosshairTransparency
        crosshairHorizontal.BorderSizePixel = 0
        crosshairHorizontal.Parent = container
        Radar.Elements.CrosshairHorizontal = crosshairHorizontal

        -- Отладочные метки (N, S, E, W)
        local northLabel = Instance.new("TextLabel")
        northLabel.Size = UDim2.new(0, 20, 0, 20)
        northLabel.Position = UDim2.new(0.5, -10, 0, -10)
        northLabel.BackgroundTransparency = 1
        northLabel.Text = "N"
        northLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        northLabel.TextSize = 14
        northLabel.Parent = container
        Radar.Elements.NorthLabel = northLabel

        local southLabel = Instance.new("TextLabel")
        southLabel.Size = UDim2.new(0, 20, 0, 20)
        southLabel.Position = UDim2.new(0.5, -10, 1, -10)
        southLabel.BackgroundTransparency = 1
        southLabel.Text = "S"
        southLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        southLabel.TextSize = 14
        southLabel.Parent = container
        Radar.Elements.SouthLabel = southLabel

        local eastLabel = Instance.new("TextLabel")
        eastLabel.Size = UDim2.new(0, 20, 0, 20)
        eastLabel.Position = UDim2.new(1, -10, 0.5, -10)
        eastLabel.BackgroundTransparency = 1
        eastLabel.Text = "E"
        eastLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        eastLabel.TextSize = 14
        eastLabel.Parent = container
        Radar.Elements.EastLabel = eastLabel

        local westLabel = Instance.new("TextLabel")
        westLabel.Size = UDim2.new(0, 20, 0, 20)
        westLabel.Position = UDim2.new(0, -10, 0.5, -10)
        westLabel.BackgroundTransparency = 1
        westLabel.Text = "W"
        westLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        westLabel.TextSize = 14
        westLabel.Parent = container
        Radar.Elements.WestLabel = westLabel

        -- Треугольник локального игрока
        local localPlayerIndicator = Instance.new("ImageLabel")
        localPlayerIndicator.Size = UDim2.new(0, Radar.Config.LocalPlayerSize, 0, Radar.Config.LocalPlayerSize)
        localPlayerIndicator.Position = UDim2.new(0.5, -Radar.Config.LocalPlayerSize / 2, 0.5, -Radar.Config.LocalPlayerSize / 2)
        localPlayerIndicator.BackgroundTransparency = 1
        localPlayerIndicator.Image = "rbxassetid://4292970642"
        localPlayerIndicator.ImageColor3 = Radar.Config.LocalPlayerColor
        localPlayerIndicator.Parent = container
        Radar.Elements.LocalPlayerIndicator = localPlayerIndicator

        -- Обновление поворота треугольника
        RunService.Heartbeat:Connect(function()
            if Radar.State.Enabled and Radar.Elements.LocalPlayerIndicator then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local lookDirection = root.CFrame.LookVector
                    local angle = math.deg(math.atan2(lookDirection.Z, lookDirection.X)) + 90
                    Radar.Elements.LocalPlayerIndicator.Rotation = angle
                end
            end
        end)

        -- Создание точек для других игроков
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createPlayerDot(player)
            end
        end
    end

    -- Удаление точки игрока
    local function removePlayerDot(player)
        if Radar.Elements.Dots[player] then
            Radar.Elements.Dots[player]:Destroy()
            Radar.Elements.Dots[player] = nil
        end
    end

    -- Обновление позиций точек
    local lastUpdate = 0
    local function updateRadar()
        if not Radar.State.Enabled or not Radar.Elements.Container then return end

        local currentTime = tick()
        if currentTime - lastUpdate < Radar.Config.UpdateInterval then return end
        lastUpdate = currentTime

        local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        for player, dot in pairs(Radar.Elements.Dots) do
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if localRoot and root then
                local relativePos = root.Position - localRoot.Position
                local radarX = relativePos.X * Radar.State.Scale
                local radarZ = relativePos.Z * Radar.State.Scale

                local maxOffset = Radar.Config.Size / 2 - Radar.Config.DotSize / 2
                radarX = math.clamp(radarX, -maxOffset, maxOffset)
                radarZ = math.clamp(radarZ, -maxOffset, maxOffset)

                dot.Position = UDim2.new(0.5, radarX, 0.5, radarZ)
                dot.Visible = true

                -- Обновляем цвет точки, если статус друга изменился
                local isFriend = table.find(Core.Services.FriendsList, player.Name) ~= nil
                dot.BackgroundColor3 = isFriend and Radar.Config.FriendColor or Radar.Config.DotColor
            else
                dot.Visible = false
            end
        end
    end

    -- Обработка перетаскивания радара
    local function handleInput(input)
        if not Radar.State.Enabled then return end

        local mousePos
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            mousePos = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
            if input.UserInputState == Enum.UserInputState.Begin then
                if mousePos and Radar.Elements.Container then
                    local container = Radar.Elements.Container
                    if mousePos.X >= container.Position.X.Offset and mousePos.X <= container.Position.X.Offset + container.Size.X.Offset and
                       mousePos.Y >= container.Position.Y.Offset and mousePos.Y <= container.Position.Y.Offset + container.Size.Y.Offset then
                        Radar.State.Dragging = true
                        Radar.State.DragStart = mousePos
                        Radar.State.StartPos = container.Position
                    end
                end
            elseif input.UserInputState == Enum.UserInputState.End then
                Radar.State.Dragging = false
            end
        elseif input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if Radar.State.Dragging then
                mousePos = input.UserInputType == Enum.UserInputType.Touch and input.Position or UserInputService:GetMouseLocation()
                local delta = mousePos - Radar.State.DragStart
                Radar.Elements.Container.Position = UDim2.new(0, Radar.State.StartPos.X.Offset + delta.X, 0, Radar.State.StartPos.Y.Offset + delta.Y)
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

    -- Добавление переключателя в UI (вкладка Visuals, секция Radar)
    if UI.Sections.Radar then
        UI.Sections.Radar:Toggle({
            Name = "Radar",
            Default = false,
            Callback = function(value)
                Radar.State.Enabled = value
                if Radar.Elements.Gui then
                    Radar.Elements.Gui.Enabled = value
                    if Radar.Elements.Container then
                        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
                        local targetScale = value and 1 or 0
                        local tween = TweenService:Create(Radar.Elements.Container, tweenInfo, {Size = UDim2.new(0, Radar.Config.Size * targetScale, 0, Radar.Config.Size * targetScale)})
                        tween:Play()
                    end
                end
                notify("Radar", "Radar " .. (value and "Enabled" or "Disabled"))
            end
        })
    end

    -- Добавление регулировки масштаба через UI
    if UI.Sections.Radar then
        UI.Sections.Radar:Slider({
            Name = "Radar Scale",
            Minimum = 0.05,
            Maximum = 0.5,
            Precision = 3,
            Default = 0.1,
            Callback = function(value)
                Radar.State.Scale = value
                notify("Radar Scale", "Set to: " .. tostring(value))
            end
        })
    end
end

return module
