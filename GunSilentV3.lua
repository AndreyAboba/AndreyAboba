local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local GunSilent = {
    Settings = {
        Enabled = { Value = false, Default = false },
        RangePlus = { Value = 50, Default = 50 },
        Rage = { Value = false, Default = false },
        HitPart = { Value = "Head", Default = "Head" },
        BulletSpeed = { Value = 2500, Default = 2500 },
        UseFOV = { Value = true, Default = true },
        FOV = { Value = 90, Default = 90 },
        ShowCircle = { Value = true, Default = true },
        CircleMethod = { Value = "Cursor", Default = "Cursor" },
        SortMethod = { Value = "Mouse&Distance", Default = "Mouse&Distance" },
        PredictVisual = { Value = true, Default = true },
        DirectionVisual = { Value = true, Default = true },
        TrajectoryBeam = { Value = true, Default = true },
        HitChance = { Value = 100, Default = 100 },
        PredictionStrength = { Value = 1.0, Default = 1.0 },
        PingCompensation = { Value = 0.1, Default = 0.1 },
        SmoothingFactor = { Value = 0.1, Default = 0.1 },
        ResolverEnabled = { Value = true, Default = true },
        ResolverThreshold = { Value = 0.3, Default = 0.3 },
        PositionHistorySize = { Value = 50, Default = 50 }
    },
    FixedPredictionValues = {
        MaxPlayerSpeed = 50, -- Максимальная скорость игрока (Da Hood)
        MaxAcceleration = 100,
        TeleportThreshold = 50,
        MinSmoothing = 0.05,
        MaxSmoothing = 0.2
    },
    State = {
        LastEventId = 0,
        LastTool = nil,
        PredictVisualPart = nil,
        DirectionVisualPart = nil,
        TrajectoryBeam = nil,
        FovCircle = nil,
        V_U_4 = nil,
        Connection = nil,
        OldFireServer = nil,
        PositionHistory = {},
        LastVisualUpdateTime = 0,
        LastTargetPosition = {},
        LocalCharacter = nil,
        LocalRoot = nil,
        LastTargetPos = nil,
        LastPredictionPos = nil,
        LastTargetUpdate = 0,
        TargetUpdateInterval = 0.2
    }
}

local function isGunTool(tool)
    local items = game:GetService("ReplicatedStorage"):FindFirstChild("Items")
    if not items then return false end
    local gunFolder = items:FindFirstChild("gun")
    if not gunFolder then return false end
    return gunFolder:FindFirstChild(tool.Name) ~= nil
end

local function getGunRange(tool)
    return (tool and tool:GetAttribute("Range") or 50) + GunSilent.Settings.RangePlus.Value
end

local function getEquippedGunTool(character)
    if not character then return nil end
    for _, child in pairs(character:GetChildren()) do
        if child.ClassName == "Tool" and isGunTool(child) then
            return child
        end
    end
    return nil
end

local function updateFovCircle()
    if not GunSilent.Settings.ShowCircle.Value then
        if GunSilent.State.FovCircle then
            GunSilent.State.FovCircle.Visible = false
        end
        return
    end

    local camera = Workspace.CurrentCamera
    if not camera then return end

    local fovCircle = GunSilent.State.FovCircle
    if not fovCircle then
        fovCircle = Drawing.new("Circle")
        fovCircle.Thickness = 2
        fovCircle.NumSides = 100
        fovCircle.Color = Color3.fromRGB(255, 255, 255)
        fovCircle.Visible = true
        fovCircle.Filled = false
        GunSilent.State.FovCircle = fovCircle
    end

    local newRadius = math.tan(math.rad(GunSilent.Settings.FOV.Value) / 2) * camera.ViewportSize.X / 2
    local circlePos = GunSilent.Settings.CircleMethod.Value == "Middle" and camera.ViewportSize / 2 or UserInputService:GetMouseLocation()

    fovCircle.Radius = newRadius
    fovCircle.Position = circlePos
    fovCircle.Visible = true
end

local function isInFov(targetPos, camera)
    if not GunSilent.Settings.UseFOV.Value then return true end
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if not onScreen then return false end
    local referencePos = GunSilent.Settings.CircleMethod.Value == "Middle" and camera.ViewportSize / 2 or UserInputService:GetMouseLocation()
    local distanceFromReference = (Vector2.new(screenPos.X, screenPos.Y) - referencePos).Magnitude
    return distanceFromReference <= math.tan(math.rad(GunSilent.Settings.FOV.Value) / 2) * camera.ViewportSize.X / 2
end

local function getNearestPlayerGun(gunRange)
    local currentTime = tick()
    if currentTime - GunSilent.State.LastTargetUpdate < GunSilent.State.TargetUpdateInterval then
        local target = GunSilent.Core.GunSilentTarget.CurrentTarget
        if target and target.Character and target.Character.Humanoid and target.Character.Humanoid.Health > 0 then
            return target
        end
    end
    GunSilent.State.LastTargetUpdate = currentTime

    local localRoot = GunSilent.State.LocalRoot
    if not localRoot then return nil end
    local rootPos = localRoot.Position
    local camera = Workspace.CurrentCamera
    local nearestPlayer, shortestDistance, closestToCursor, bestScore = nil, gunRange, math.huge, math.huge
    local sortMethod = GunSilent.Settings.SortMethod.Value

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local targetChar = player.Character
            if targetChar then
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = targetChar:FindFirstChild("Humanoid")
                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                    local distance = (rootPos - targetRoot.Position).Magnitude
                    if distance <= shortestDistance or sortMethod ~= "Distance" then
                        if isInFov(targetRoot.Position, camera) then
                            if sortMethod == "Mouse&Distance" then
                                local screenPos = camera:WorldToViewportPoint(targetRoot.Position)
                                local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                                local score = (distance / (GunSilent.Settings.RangePlus.Value + 50)) + (cursorDistance / camera.ViewportSize.X)
                                if score < bestScore then
                                    bestScore = score
                                    nearestPlayer = player
                                end
                            elseif sortMethod == "Distance" and distance < shortestDistance then
                                shortestDistance = distance
                                nearestPlayer = player
                            elseif sortMethod == "Mouse" then
                                local screenPos = camera:WorldToViewportPoint(targetRoot.Position)
                                local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                                if cursorDistance < closestToCursor then
                                    closestToCursor = cursorDistance
                                    nearestPlayer = player
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    GunSilent.Core.GunSilentTarget.CurrentTarget = nearestPlayer
    return nearestPlayer
end

local function resolveVelocity(target, positionHistory, clientVelocity)
    if not GunSilent.Settings.ResolverEnabled.Value or not positionHistory or #positionHistory < 5 then
        return clientVelocity, false
    end

    local currentTime = tick()
    local totalVelocity = Vector3.new(0, 0, 0)
    local totalWeight = 0
    local validEntries = 0
    local maxSpeedLimit = GunSilent.FixedPredictionValues.MaxPlayerSpeed
    local teleportThreshold = GunSilent.FixedPredictionValues.TeleportThreshold

    -- Фильтрация аномалий
    local filteredHistory = {}
    for i = 1, #positionHistory do
        if i == 1 or (positionHistory[i].pos - positionHistory[i-1].pos).Magnitude < teleportThreshold then
            filteredHistory[#filteredHistory + 1] = positionHistory[i]
        end
    end

    -- Взвешенная средняя скорость из последних 15 позиций
    for i = #filteredHistory - 1, math.max(1, #filteredHistory - 15), -1 do
        local currEntry = filteredHistory[i + 1]
        local prevEntry = filteredHistory[i]
        local timeDelta = currEntry.time - prevEntry.time
        if timeDelta > 0 and timeDelta < 0.2 then
            local velocity = (currEntry.pos - prevEntry.pos) / timeDelta
            if velocity.Magnitude <= maxSpeedLimit * 1.5 then
                local weight = 1 / (1 + (currentTime - currEntry.time) * 5) -- Свежие данные имеют больший вес
                totalVelocity = totalVelocity + velocity * weight
                totalWeight = totalWeight + weight
                validEntries = validEntries + 1
            end
        end
    end

    local calculatedVelocity = validEntries > 0 and totalVelocity / totalWeight or Vector3.new(0, 0, 0)
    local isSpoofed = false

    -- Проверка спуфа
    if validEntries >= 5 then
        local velocityDiff = (clientVelocity - calculatedVelocity).Magnitude
        local threshold = maxSpeedLimit * GunSilent.Settings.ResolverThreshold.Value
        if velocityDiff > threshold or clientVelocity.Magnitude > maxSpeedLimit * 1.5 then
            isSpoofed = true
        else
            -- Проверка углового отклонения
            local lastPositions = {}
            for i = #filteredHistory - 4, #filteredHistory do
                if filteredHistory[i] then
                    lastPositions[#lastPositions + 1] = filteredHistory[i].pos
                end
            end
            if #lastPositions >= 3 then
                local trajectoryDir = (lastPositions[#lastPositions] - lastPositions[1]).Unit
                local velocityDir = clientVelocity.Magnitude > 0 and clientVelocity.Unit or Vector3.new(0, 0, 0)
                local dotProduct = velocityDir.Magnitude > 0 and trajectoryDir:Dot(velocityDir) or 1
                if dotProduct < 0.6 then -- Угол > ~50 градусов
                    isSpoofed = true
                end
            end
        end
    end

    return isSpoofed and calculatedVelocity or clientVelocity, isSpoofed
end

local function predictTargetPositionGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then
        return { position = nil, direction = nil, timeToTarget = 0, clientPosition = nil }
    end

    local targetChar = target.Character
    local myPos = localRoot.Position
    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart or not targetRoot then
        return { position = nil, direction = nil, timeToTarget = 0, clientPosition = nil }
    end

    local targetPos = hitPart.Position
    local targetId = tostring(target.UserId)
    local isTeleporting = GunSilent.State.LastTargetPosition[targetId] and (targetPos - GunSilent.State.LastTargetPosition[targetId]).Magnitude > GunSilent.FixedPredictionValues.TeleportThreshold
    GunSilent.State.LastTargetPosition[targetId] = targetPos

    local distance = (targetPos - myPos).Magnitude
    local bulletSpeed = GunSilent.Settings.BulletSpeed.Value
    local timeToTarget = distance / bulletSpeed

    local positionHistory = GunSilent.State.PositionHistory[target] or {}
    GunSilent.State.PositionHistory[target] = positionHistory
    local currentTime = tick()
    positionHistory[#positionHistory + 1] = { pos = targetPos, time = currentTime, velocity = targetRoot.Velocity }
    while #positionHistory > GunSilent.Settings.PositionHistorySize.Value do
        table.remove(positionHistory, 1)
    end

    local clientPos = targetPos
    local resolvedVelocity, isSpoofed = resolveVelocity(target, positionHistory, targetRoot.Velocity)

    -- Ограничение скорости
    if resolvedVelocity.Magnitude > GunSilent.FixedPredictionValues.MaxPlayerSpeed then
        resolvedVelocity = resolvedVelocity.Unit * GunSilent.FixedPredictionValues.MaxPlayerSpeed
    end

    -- Динамическое масштабирование предикта по скорости
    local targetSpeed = resolvedVelocity.Magnitude
    local speedFactor = 0.7 + (targetSpeed / GunSilent.FixedPredictionValues.MaxPlayerSpeed) * 0.6

    -- Учет пинга
    local ping = GunSilent.Settings.PingCompensation.Value
    local totalPredictionTime = (timeToTarget + ping) * GunSilent.Settings.PredictionStrength.Value * speedFactor

    local predictedPos = clientPos
    if not isTeleporting then
        -- Базовый предикт
        predictedPos = clientPos + resolvedVelocity * totalPredictionTime

        -- Учет ускорения
        if not isSpoofed and #positionHistory >= 5 then
            local prevEntry = positionHistory[#positionHistory - 1]
            local timeDelta = positionHistory[#positionHistory].time - prevEntry.time
            if timeDelta > 0 then
                local acceleration = (positionHistory[#positionHistory].velocity - prevEntry.velocity) / timeDelta
                if acceleration.Magnitude <= GunSilent.FixedPredictionValues.MaxAcceleration then
                    predictedPos = predictedPos + 0.5 * acceleration * totalPredictionTime^2
                end
            end
        end

        -- Компенсация стрейфов
        if #positionHistory >= 10 then
            local trajectoryPoints = {}
            for i = math.max(1, #positionHistory - 10), #positionHistory do
                trajectoryPoints[#trajectoryPoints + 1] = positionHistory[i].pos
            end
            local avgDir = Vector3.new(0, 0, 0)
            local dirCount = 0
            for i = 2, #trajectoryPoints do
                local dir = (trajectoryPoints[i] - trajectoryPoints[i-1]).Unit
                avgDir = avgDir + dir
                dirCount = dirCount + 1
            end
            if dirCount > 0 then
                avgDir = avgDir / dirCount
                local strafeCorrection = avgDir * targetSpeed * totalPredictionTime * 0.4
                predictedPos = predictedPos + strafeCorrection
            end
        end

        -- Сглаживание
        if GunSilent.State.LastPredictionPos then
            predictedPos = GunSilent.State.LastPredictionPos:Lerp(predictedPos, 1 - GunSilent.Settings.SmoothingFactor.Value)
        end
        GunSilent.State.LastPredictionPos = predictedPos
    end

    return {
        position = predictedPos,
        direction = (predictedPos - myPos).Unit,
        timeToTarget = timeToTarget,
        clientPosition = targetPos,
        isSpoofed = isSpoofed,
        isTeleporting = isTeleporting
    }
end

local function getAimCFrameGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local prediction = predictTargetPositionGun(target)
    if not prediction.position or not prediction.direction then return nil end
    return CFrame.new(localRoot.Position, localRoot.Position + prediction.direction)
end

local function createHitDataGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local targetChar = target.Character
    local prediction = predictTargetPositionGun(target)
    if not prediction.position or not prediction.direction then return nil end

    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart then return nil end

    local hitData = {}
    hitData[1] = {{Normal = prediction.direction, Instance = hitPart, Position = prediction.position}}
    return hitData
end

local function updateVisualsGun(target, hasWeapon)
    local currentTime = tick()
    if currentTime - GunSilent.State.LastVisualUpdateTime < 0.016 then return end -- 60 FPS
    GunSilent.State.LastVisualUpdateTime = currentTime

    local localRoot = GunSilent.State.LocalRoot
    if not GunSilent.Settings.Enabled.Value or not hasWeapon or not target or not target.Character or not localRoot then
        if GunSilent.State.PredictVisualPart then GunSilent.State.PredictVisualPart.Transparency = 1 end
        if GunSilent.State.DirectionVisualPart then GunSilent.State.DirectionVisualPart.Transparency = 1 end
        if GunSilent.State.TrajectoryBeam then GunSilent.State.TrajectoryBeam.Enabled = false end
        GunSilent.State.LastTargetPos = nil
        GunSilent.State.LastPredictionPos = nil
        return
    end

    local prediction = predictTargetPositionGun(target)
    if not prediction.position or not prediction.direction then return end

    local targetChar = target.Character
    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart then return end

    local targetPos, predictionPos = prediction.clientPosition, prediction.position
    GunSilent.State.LastTargetPos, GunSilent.State.LastPredictionPos = targetPos, predictionPos

    local startPos = localRoot.Position + Vector3.new(0, 1.5, 0)

    if GunSilent.Settings.PredictVisual.Value then
        local predictVisualPart = GunSilent.State.PredictVisualPart
        if not predictVisualPart then
            predictVisualPart = Instance.new("Part")
            predictVisualPart.Size = Vector3.new(0.5, 0.5, 0.5)
            predictVisualPart.Shape = Enum.PartType.Ball
            predictVisualPart.Anchored = true
            predictVisualPart.CanCollide = false
            predictVisualPart.Parent = Workspace
            GunSilent.State.PredictVisualPart = predictVisualPart
        end
        predictVisualPart.Position = prediction.position
        predictVisualPart.Color = prediction.isSpoofed and Color3.fromRGB(255, 0, 0) or (prediction.isTeleporting and Color3.fromRGB(255, 165, 0) or Color3.fromRGB(0, 255, 255))
        predictVisualPart.Transparency = 0.3
    elseif GunSilent.State.PredictVisualPart then
        GunSilent.State.PredictVisualPart.Transparency = 1
    end

    if GunSilent.Settings.DirectionVisual.Value then
        local directionVisualPart = GunSilent.State.DirectionVisualPart
        if not directionVisualPart then
            directionVisualPart = Instance.new("Part")
            directionVisualPart.Size = Vector3.new(0.2, 0.2, 3)
            directionVisualPart.Anchored = true
            directionVisualPart.CanCollide = false
            directionVisualPart.Color = Color3.fromRGB(255, 215, 0)
            directionVisualPart.Parent = Workspace
            GunSilent.State.DirectionVisualPart = directionVisualPart
        end
        directionVisualPart.CFrame = CFrame.lookAt(startPos, startPos + (prediction.direction * 3))
        directionVisualPart.Position = startPos + (prediction.direction * 1.5)
        directionVisualPart.Transparency = 0.5
    elseif GunSilent.State.DirectionVisualPart then
        GunSilent.State.DirectionVisualPart.Transparency = 1
    end

    if GunSilent.Settings.TrajectoryBeam.Value and GunSilent.Settings.PredictVisual.Value then
        local trajectoryBeam = GunSilent.State.TrajectoryBeam
        if not trajectoryBeam then
            trajectoryBeam = Instance.new("Beam")
            trajectoryBeam.FaceCamera = true
            trajectoryBeam.Width0 = 0.15
            trajectoryBeam.Width1 = 0.15
            trajectoryBeam.Transparency = NumberSequence.new(0.4)
            trajectoryBeam.Color = ColorSequence.new(Color3.fromRGB(147, 112, 219))
            trajectoryBeam.Parent = Workspace
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")
            trajectoryBeam.Attachment0 = attachment0
            trajectoryBeam.Attachment1 = attachment1
            GunSilent.State.TrajectoryBeam = trajectoryBeam
        end
        trajectoryBeam.Attachment0.Parent = localRoot
        trajectoryBeam.Attachment1.Parent = GunSilent.State.PredictVisualPart
        trajectoryBeam.Enabled = true
        -- Индикация пинга через длину луча
        trajectoryBeam.Width0 = 0.15 + GunSilent.Settings.PingCompensation.Value * 0.5
        trajectoryBeam.Width1 = 0.15 + GunSilent.Settings.PingCompensation.Value * 0.5
    elseif GunSilent.State.TrajectoryBeam then
        GunSilent.State.TrajectoryBeam.Enabled = false
    end
end

local function initializeGunSilent()
    if GunSilent.State.Connection then GunSilent.State.Connection:Disconnect() end
    if not GunSilent.State.V_U_4 then
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" and not getmetatable(obj) and obj.event and obj.func then
                GunSilent.State.V_U_4 = obj
                break
            end
        end
    end

    if not GunSilent.State.OldFireServer then
        GunSilent.State.OldFireServer = hookfunction(game:GetService("ReplicatedStorage").Remotes.Send.FireServer, function(self, ...)
            local args = {...}
            local modifiedArgs = args
            if GunSilent.Settings.Enabled.Value and #args >= 2 and typeof(args[1]) == "number" and math.random(100) <= GunSilent.Settings.HitChance.Value then
                GunSilent.State.LastEventId = args[1]
                local equippedTool = getEquippedGunTool(GunSilent.State.LocalCharacter)
                if equippedTool and args[2] == "shoot_gun" then
                    local gunRange = getGunRange(equippedTool)
                    local nearestPlayer = getNearestPlayerGun(gunRange)
                    if nearestPlayer then
                        local aimCFrame = getAimCFrameGun(nearestPlayer)
                        local hitData = createHitDataGun(nearestPlayer)
                        if aimCFrame and hitData then
                            modifiedArgs = {args[1], args[2], equippedTool, aimCFrame, hitData}
                        end
                    end
                end
            end
            return GunSilent.State.OldFireServer(self, unpack(modifiedArgs))
        end)
    end

    GunSilent.State.Connection = RunService.RenderStepped:Connect(function(deltaTime)
        if not GunSilent.Settings.Enabled.Value then
            if GunSilent.State.FovCircle then GunSilent.State.FovCircle.Visible = false end
            GunSilent.Core.GunSilentTarget.CurrentTarget = nil
            return
        end

        local character = GunSilent.State.LocalCharacter
        local currentTool = getEquippedGunTool(character)
        if currentTool ~= GunSilent.State.LastTool then
            if currentTool and not GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Equipped: " .. currentTool.Name .. " (Range: " .. getGunRange(currentTool) .. ")", true)
            elseif GunSilent.State.LastTool and not currentTool then
                GunSilent.notify("GunSilent", "Unequipped: " .. GunSilent.State.LastTool.Name, true)
            elseif currentTool and GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Switched to " .. currentTool.Name .. " (Range: " .. getGunRange(currentTool) .. ")", true)
            end
            GunSilent.State.LastTool = currentTool
        end

        updateFovCircle()
        if not currentTool then
            GunSilent.Core.GunSilentTarget.CurrentTarget = nil
            updateVisualsGun(nil, false)
            return
        end

        local gunRange = getGunRange(currentTool)
        local nearestPlayer = getNearestPlayerGun(gunRange)
        updateVisualsGun(nearestPlayer, true)
        if GunSilent.Settings.Rage.Value and GunSilent.State.V_U_4 and nearestPlayer then
            local aimCFrame = getAimCFrameGun(nearestPlayer)
            local hitData = createHitDataGun(nearestPlayer)
            if aimCFrame and hitData then
                GunSilent.State.V_U_4.event = GunSilent.State.V_U_4.event + 1
                game:GetService("ReplicatedStorage").Remotes.Send:FireServer(GunSilent.State.V_U_4.event, "shoot_gun", currentTool, aimCFrame, hitData)
            end
        end
    end)
end

local function Init(UI, Core, notify)
    GunSilent.Core = Core
    GunSilent.notify = notify

    local LocalPlayer = Core.PlayerData.LocalPlayer
    if LocalPlayer then
        LocalPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("HumanoidRootPart")
            GunSilent.State.LocalCharacter = character
            GunSilent.State.LocalRoot = character.HumanoidRootPart
        end)
        if LocalPlayer.Character then
            GunSilent.State.LocalCharacter = LocalPlayer.Character
            GunSilent.State.LocalRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        end
    end

    if UI.Tabs.Combat then
        UI.Sections.GunSilent = UI.Tabs.Combat:Section({ Side = "Right", Name = "GunSilent" })
        if UI.Sections.GunSilent then
            local uiElements = {}

            UI.Sections.GunSilent:Header({ Name = "GunSilent" })
            uiElements.GSEnabled = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Enabled",
                    Default = GunSilent.Settings.Enabled.Value,
                    Callback = function(value)
                        GunSilent.Settings.Enabled.Value = value
                        initializeGunSilent()
                        notify("GunSilent", "GunSilent " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'GSEnabled'),
                callback = function(value)
                    GunSilent.Settings.Enabled.Value = value
                    initializeGunSilent()
                    notify("GunSilent", "GunSilent " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.RangePlus = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Range Plus",
                    Minimum = 0,
                    Maximum = 100,
                    Default = GunSilent.Settings.RangePlus.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.RangePlus.Value = value
                        notify("GunSilent", "Range Plus set to: " .. value, false)
                    end
                }, 'RangePlus'),
                callback = function(value)
                    GunSilent.Settings.RangePlus.Value = value
                    notify("GunSilent", "Range Plus set to: " .. value, false)
                end
            }
            uiElements.Rage = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Rage",
                    Default = GunSilent.Settings.Rage.Value,
                    Callback = function(value)
                        GunSilent.Settings.Rage.Value = value
                        notify("GunSilent", "Rage " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'Rage'),
                callback = function(value)
                    GunSilent.Settings.Rage.Value = value
                    notify("GunSilent", "Rage " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.HitPart = {
                element = UI.Sections.GunSilent:Dropdown({
                    Name = "Hit Part",
                    Default = GunSilent.Settings.HitPart.Value,
                    Options = {"Head", "UpperTorso", "HumanoidRootPart"},
                    Callback = function(value)
                        GunSilent.Settings.HitPart.Value = value
                        notify("GunSilent", "Hit Part set to: " .. value, true)
                    end
                }, 'HitPart'),
                callback = function(value)
                    GunSilent.Settings.HitPart.Value = value
                    notify("GunSilent", "Hit Part set to: " .. value, true)
                end
            }
            uiElements.UseFOV = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Use FOV",
                    Default = GunSilent.Settings.UseFOV.Value,
                    Callback = function(value)
                        GunSilent.Settings.UseFOV.Value = value
                        notify("GunSilent", "Use FOV " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'UseFOV'),
                callback = function(value)
                    GunSilent.Settings.UseFOV.Value = value
                    notify("GunSilent", "Use FOV " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.FOV = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "FOV",
                    Default = GunSilent.Settings.FOV.Value,
                    Minimum = 30,
                    Maximum = 120,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.FOV.Value = value
                        notify("GunSilent", "FOV set to: " .. value, false)
                    end
                }, 'FOV'),
                callback = function(value)
                    GunSilent.Settings.FOV.Value = value
                    notify("GunSilent", "FOV set to: " .. value, false)
                end
            }
            uiElements.ShowCircle = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Show Circle",
                    Default = GunSilent.Settings.ShowCircle.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShowCircle.Value = value
                        notify("GunSilent", "Show Circle " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'ShowCircle'),
                callback = function(value)
                    GunSilent.Settings.ShowCircle.Value = value
                    notify("GunSilent", "Show Circle " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.CircleMethod = {
                element = UI.Sections.GunSilent:Dropdown({
                    Name = "Circle Method",
                    Default = GunSilent.Settings.CircleMethod.Value,
                    Options = {"Cursor", "Middle"},
                    Callback = function(value)
                        GunSilent.Settings.CircleMethod.Value = value
                        notify("GunSilent", "Circle Method set to: " .. value, true)
                    end
                }, 'CircleMethod'),
                callback = function(value)
                    GunSilent.Settings.CircleMethod.Value = value
                    notify("GunSilent", "Circle Method set to: " .. value, true)
                end
            }
            uiElements.SortMethod = {
                element = UI.Sections.GunSilent:Dropdown({
                    Name = "Sort Method",
                    Default = GunSilent.Settings.SortMethod.Value,
                    Options = {"Mouse", "Distance", "Mouse&Distance"},
                    Callback = function(value)
                        GunSilent.Settings.SortMethod.Value = value
                        notify("GunSilent", "Sort Method set to: " .. value, true)
                    end
                }, 'SortMethod'),
                callback = function(value)
                    GunSilent.Settings.SortMethod.Value = value
                    notify("GunSilent", "Sort Method set to: " .. value, true)
                end
            }
            uiElements.PredictVisual = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Predict Visual",
                    Default = GunSilent.Settings.PredictVisual.Value,
                    Callback = function(value)
                        GunSilent.Settings.PredictVisual.Value = value
                        notify("GunSilent", "Predict Visual " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'PredictVisual'),
                callback = function(value)
                    GunSilent.Settings.PredictVisual.Value = value
                    notify("GunSilent", "Predict Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.DirectionVisual = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Direction Visual",
                    Default = GunSilent.Settings.DirectionVisual.Value,
                    Callback = function(value)
                        GunSilent.Settings.DirectionVisual.Value = value
                        notify("GunSilent", "Direction Visual " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'DirectionVisual'),
                callback = function(value)
                    GunSilent.Settings.DirectionVisual.Value = value
                    notify("GunSilent", "Direction Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.TrajectoryBeam = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Trajectory Beam",
                    Default = GunSilent.Settings.TrajectoryBeam.Value,
                    Callback = function(value)
                        GunSilent.Settings.TrajectoryBeam.Value = value
                        notify("GunSilent", "Trajectory Beam " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'TrajectoryBeam'),
                callback = function(value)
                    GunSilent.Settings.TrajectoryBeam.Value = value
                    notify("GunSilent", "Trajectory Beam " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.HitChance = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Hit Chance",
                    Default = GunSilent.Settings.HitChance.Value,
                    Minimum = 0,
                    Maximum = 100,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.HitChance.Value = value
                        notify("GunSilent", "Hit Chance set to: " .. value .. "%", false)
                    end
                }, 'HitChance'),
                callback = function(value)
                    GunSilent.Settings.HitChance.Value = value
                    notify("GunSilent", "Hit Chance set to: " .. value .. "%", false)
                end
            }
            UI.Sections.GunSilent:Header({ Name = "Prediction Settings" })
            uiElements.PredictionStrength = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Prediction Strength",
                    Minimum = 0.5,
                    Maximum = 1.5,
                    Default = GunSilent.Settings.PredictionStrength.Value,
                    Precision = 2,
                    Callback = function(value)
                        GunSilent.Settings.PredictionStrength.Value = value
                        notify("GunSilent", "Prediction Strength set to: " .. value, false)
                    end
                }, 'PredictionStrength'),
                callback = function(value)
                    GunSilent.Settings.PredictionStrength.Value = value
                    notify("GunSilent", "Prediction Strength set to: " .. value, false)
                end
            }
            uiElements.PingCompensation = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Ping Compensation",
                    Minimum = 0.0,
                    Maximum = 0.3,
                    Default = GunSilent.Settings.PingCompensation.Value,
                    Precision = 3,
                    Callback = function(value)
                        GunSilent.Settings.PingCompensation.Value = value
                        notify("GunSilent", "Ping Compensation set to: " .. value .. "s", false)
                    end
                }, 'PingCompensation'),
                callback = function(value)
                    GunSilent.Settings.PingCompensation.Value = value
                    notify("GunSilent", "Ping Compensation set to: " .. value .. "s", false)
                end
            }
            uiElements.SmoothingFactor = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Smoothing Factor",
                    Minimum = 0.05,
                    Maximum = 0.3,
                    Default = GunSilent.Settings.SmoothingFactor.Value,
                    Precision = 2,
                    Callback = function(value)
                        GunSilent.Settings.SmoothingFactor.Value = value
                        notify("GunSilent", "Smoothing Factor set to: " .. value, false)
                    end
                }, 'SmoothingFactor'),
                callback = function(value)
                    GunSilent.Settings.SmoothingFactor.Value = value
                    notify("GunSilent", "Smoothing Factor set to: " .. value, false)
                end
            }
            uiElements.ResolverEnabled = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Resolver Enabled",
                    Default = GunSilent.Settings.ResolverEnabled.Value,
                    Callback = function(value)
                        GunSilent.Settings.ResolverEnabled.Value = value
                        notify("GunSilent", "Resolver " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'ResolverEnabled'),
                callback = function(value)
                    GunSilent.Settings.ResolverEnabled.Value = value
                    notify("GunSilent", "Resolver " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.ResolverThreshold = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Resolver Threshold",
                    Minimum = 0.2,
                    Maximum = 0.5,
                    Default = GunSilent.Settings.ResolverThreshold.Value,
                    Precision = 2,
                    Callback = function(value)
                        GunSilent.Settings.ResolverThreshold.Value = value
                        notify("GunSilent", "Resolver Threshold set to: " .. value, false)
                    end
                }, 'ResolverThreshold'),
                callback = function(value)
                    GunSilent.Settings.ResolverThreshold.Value = value
                    notify("GunSilent", "Resolver Threshold set to: " .. value, false)
                end
            }
            uiElements.BulletSpeed = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Bullet Speed",
                    Minimum = 1000,
                    Maximum = 5000,
                    Default = GunSilent.Settings.BulletSpeed.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.BulletSpeed.Value = value
                        notify("GunSilent", "Bullet Speed set to: " .. value, false)
                    end
                }, 'BulletSpeed'),
                callback = function(value)
                    GunSilent.Settings.BulletSpeed.Value = value
                    notify("GunSilent", "Bullet Speed set to: " .. value, false)
                end
            }
            local gunconfigSection = UI.Tabs.Config:Section({ Name = "GunSilent Sync", Side = "Right" })
            gunconfigSection:Header({ Name = "GunSilent Settings Sync" })
            gunconfigSection:Button({
                Name = "Sync Settings",
                Callback = function()
                    uiElements.GSEnabled.callback(uiElements.GSEnabled.element:GetState())
                    uiElements.RangePlus.callback(uiElements.RangePlus.element:GetValue())
                    uiElements.Rage.callback(uiElements.Rage.element:GetState())
                    local hitPartOptions = uiElements.HitPart.element:GetOptions()
                    for option, selected in pairs(hitPartOptions) do
                        if selected then
                            uiElements.HitPart.callback(option)
                            break
                        end
                    end
                    uiElements.UseFOV.callback(uiElements.UseFOV.element:GetState())
                    uiElements.FOV.callback(uiElements.FOV.element:GetValue())
                    uiElements.ShowCircle.callback(uiElements.ShowCircle.element:GetState())
                    local circleMethodOptions = uiElements.CircleMethod.element:GetOptions()
                    for option, selected in pairs(circleMethodOptions) do
                        if selected then
                            uiElements.CircleMethod.callback(option)
                            break
                        end
                    end
                    local sortMethodOptions = uiElements.SortMethod.element:GetOptions()
                    for option, selected in pairs(sortMethodOptions) do
                        if selected then
                            uiElements.SortMethod.callback(option)
                            break
                        end
                    end
                    uiElements.PredictVisual.callback(uiElements.PredictVisual.element:GetState())
                    uiElements.DirectionVisual.callback(uiElements.DirectionVisual.element:GetState())
                    uiElements.TrajectoryBeam.callback(uiElements.TrajectoryBeam.element:GetState())
                    uiElements.HitChance.callback(uiElements.HitChance.element:GetValue())
                    uiElements.PredictionStrength.callback(uiElements.PredictionStrength.element:GetValue())
                    uiElements.PingCompensation.callback(uiElements.PingCompensation.element:GetValue())
                    uiElements.SmoothingFactor.callback(uiElements.SmoothingFactor.element:GetValue())
                    uiElements.ResolverEnabled.callback(uiElements.ResolverEnabled.element:GetState())
                    uiElements.ResolverThreshold.callback(uiElements.ResolverThreshold.element:GetValue())
                    uiElements.BulletSpeed.callback(uiElements.BulletSpeed.element:GetValue())
                    notify("GunSilent", "Settings synchronized with UI!", true)
                end
            }, 'SyncSettings')
        end
    end

    initializeGunSilent()
end

return { Init = Init }
