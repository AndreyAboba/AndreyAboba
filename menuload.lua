local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local GunSilent = {
    Settings = {
        Enabled = { Value = false, Default = false },
        RangePlus = { Value = 50, Default = 50 },
        Rage = { Value = false, Default = false },
        HitPart = { Value = "Head", Default = "Head" },
        PredictBullet = { Value = 2500, Default = 2500 },
        FakeDistance = { Value = 3, Default = 3 },
        UseFOV = { Value = true, Default = true },
        FOV = { Value = 120, Default = 120 },
        ShowCircle = { Value = true, Default = true },
        CircleMethod = { Value = "Cursor", Default = "Cursor" },
        SortMethod = { Value = "Mouse&Distance", Default = "Mouse&Distance" },
        TargetVisual = { Value = true, Default = true },
        HitboxVisual = { Value = true, Default = true },
        PredictVisual = { Value = true, Default = true },
        ShowDirection = { Value = true, Default = true },
        HitChance = { Value = 100, Default = 100 },
        GradientCircle = { Value = false, Default = false },
        GradientSpeed = { Value = 2, Default = 2 },
        AdvancedEnabled = { Value = false, Default = false },
        AdvancedVehicleYCorrection = { Value = 0, Default = 0 },
        AdvancedTeleportThreshold = { Value = 600, Default = 600 },
        AdvancedMaxSpeed = { Value = 500, Default = 500 },
        AdvancedSmoothingFactor = { Value = 0.1, Default = 0.1 },
        SmoothingVisualFactor = { Value = 0.3, Default = 0.3 },
        AdvancedPositionHistorySize = { Value = 20, Default = 20 },
        LatencyCompensation = { Value = 0.05, Default = 0.05 }, -- Уменьшено
        PingEstimate = { Value = 0.03, Default = 0.03 }, -- Уменьшено
        ShowTrajectoryBeam = { Value = true, Default = true },
        ShowFullTrajectory = { Value = true, Default = true },
        ShotgunSupport = { Value = false, Default = false },
        GenBullet = { Value = 4, Default = 4 },
        TestGenBullet = { Value = false, Default = false },
        DoubleTap = { Value = false, Default = false }
    },
    FixedPredictionValues = {
        PositionHistorySize = 20,
        SmoothingFactor = 0.1,
        SmoothingVisualFactor = 0.3,
        TeleportThreshold = 600,
        MaxSpeed = 500,
        PredictBullet = 600
    },
    State = {
        LastEventId = 0,
        LastTool = nil,
        TargetVisualPart = nil,
        HitboxVisualPart = nil,
        PredictVisualPart = nil,
        DirectionVisualPart = nil,
        RealDirectionVisualPart = nil,
        FovCircle = nil,
        V_U_4 = nil,
        Connection = nil,
        OldFireServer = nil,
        GradientTime = 0,
        PositionHistory = {},
        LastVisualUpdateTime = 0,
        IsTeleporting = false,
        LastTargetPosition = {},
        TrajectoryBeam = nil,
        FullTrajectoryParts = nil,
        LastFriendsList = nil,
        LastTargetUpdate = 0,
        TargetUpdateInterval = 0.5,
        LocalCharacter = nil,
        LocalRoot = nil,
        LastTargetPos = nil,
        LastPredictionPos = nil,
        SmoothedVisualPositions = {},
        LastPredictedPos = nil -- Добавлено для сглаживания
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

local function isShotgun(tool)
    if not tool then return false end
    local ammoType = tool:GetAttribute("AmmoType")
    return ammoType and ammoType:lower() == "shotgun"
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

local function updateFovCircle(deltaTime)
    if not GunSilent.Settings.ShowCircle.Value then
        if GunSilent.State.FovCircle then
            GunSilent.State.FovCircle.Visible = false
        end
        return
    end

    -- Обновляем камеру
    GunSilent.Core.PlayerData.Camera = Workspace.CurrentCamera
    local camera = GunSilent.Core.PlayerData.Camera
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
    local circlePos
    if GunSilent.Settings.CircleMethod.Value == "Middle" then
        circlePos = camera.ViewportSize / 2
    else
        circlePos = GunSilent.Core.Services.UserInputService:GetMouseLocation()
    end

    if fovCircle.Radius ~= newRadius or fovCircle.Position ~= circlePos then
        fovCircle.Radius = newRadius
        fovCircle.Position = circlePos
    end
    fovCircle.Visible = true

    if GunSilent.Settings.GradientCircle.Value then
        GunSilent.State.GradientTime = (GunSilent.State.GradientTime or 0) + deltaTime
        local t = (math.sin(GunSilent.State.GradientTime / GunSilent.Settings.GradientSpeed.Value * 2 * math.pi) + 1) / 2
        fovCircle.Color = GunSilent.Core.GradientColors.Color1.Value:Lerp(GunSilent.Core.GradientColors.Color2.Value, t)
    end
end

local function isInFov(targetPos, camera)
    if not GunSilent.Settings.UseFOV.Value then return true end
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if not onScreen then return false end
    local referencePos = GunSilent.Settings.CircleMethod.Value == "Middle" and camera.ViewportSize / 2 or GunSilent.Core.Services.UserInputService:GetMouseLocation()
    local distanceFromReference = (Vector2.new(screenPos.X, screenPos.Y) - referencePos).Magnitude
    return distanceFromReference <= math.tan(math.rad(GunSilent.Settings.FOV.Value) / 2) * camera.ViewportSize.X / 2
end

local function getNearestPlayerGun(gunRange)
    local currentTime = tick()
    local friendsList = GunSilent.Core.Services.FriendsList or {}
    local friendsHash = {}
    for k in pairs(friendsList) do
        friendsHash[k:lower()] = true
    end

    local target = GunSilent.Core.GunSilentTarget.CurrentTarget
    if currentTime - GunSilent.State.LastTargetUpdate < GunSilent.State.TargetUpdateInterval and
       target and target.Character and target.Character.Humanoid and target.Character.Humanoid.Health > 0 and
       not friendsHash[target.Name:lower()] then
        return target
    end
    GunSilent.State.LastTargetUpdate = currentTime

    local localRoot = GunSilent.State.LocalRoot
    if not localRoot then return nil end
    local rootPos = localRoot.Position
    local camera = GunSilent.Core.PlayerData.Camera
    local nearestPlayer, shortestDistance, closestToCursor, bestScore = nil, gunRange, math.huge, math.huge
    local sortMethod = GunSilent.Settings.SortMethod.Value

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= GunSilent.Core.PlayerData.LocalPlayer and not friendsHash[player.Name:lower()] then
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
                                local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - GunSilent.Core.Services.UserInputService:GetMouseLocation()).Magnitude
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
                                local cursorDistance = (Vector2.new(screenPos.X, screenPos.Y) - GunSilent.Core.Services.UserInputService:GetMouseLocation()).Magnitude
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
    GunSilent.State.LastFriendsList = friendsList
    return nearestPlayer
end

local function predictTargetPositionGun(target, applyFakeDistance)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then
        return { position = nil, direction = nil, realDirection = nil, fakePosition = nil, timeToTarget = 0 }
    end

    local targetChar = target.Character
    local myPos = localRoot.Position
    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value == "Random" and (math.random() > 0.5 and "Head" or "UpperTorso") or GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart or not targetRoot then
        return { position = nil, direction = nil, realDirection = nil, fakePosition = nil, timeToTarget = 0 }
    end

    local currentTime = tick()
    local ping = GunSilent.Settings.PingEstimate.Value
    local bulletSpeed = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.PredictBullet.Value or GunSilent.FixedPredictionValues.PredictBullet

    local positionHistory = GunSilent.State.PositionHistory[target] or {}
    GunSilent.State.PositionHistory[target] = positionHistory
    table.insert(positionHistory, { time = currentTime, position = hitPart.Position, velocity = targetRoot.Velocity })
    local historySize = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedPositionHistorySize.Value or GunSilent.FixedPredictionValues.PositionHistorySize
    while #positionHistory > historySize do
        table.remove(positionHistory, 1)
    end

    local targetId = tostring(target.UserId)
    local targetPos = hitPart.Position
    GunSilent.State.IsTeleporting = GunSilent.State.LastTargetPosition[targetId] and (targetPos - GunSilent.State.LastTargetPosition[targetId]).Magnitude > 50
    GunSilent.State.LastTargetPosition[targetId] = targetPos

    local targetTime = currentTime - ping
    local pastPos, pastVel
    if #positionHistory < 2 or GunSilent.State.IsTeleporting then
        pastPos = targetPos
        pastVel = targetRoot.Velocity
    else
        for i = 1, #positionHistory - 1 do
            if positionHistory[i].time <= targetTime and positionHistory[i + 1].time >= targetTime then
                local t = (targetTime - positionHistory[i].time) / (positionHistory[i + 1].time - positionHistory[i].time)
                pastPos = positionHistory[i].position:Lerp(positionHistory[i + 1].position, t)
                pastVel = positionHistory[i].velocity:Lerp(positionHistory[i + 1].velocity, t)
                break
            end
        end
        if not pastPos then
            pastPos = positionHistory[#positionHistory].position
            pastVel = positionHistory[#positionHistory].velocity
        end
    end

    local maxSpeed = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedMaxSpeed.Value or GunSilent.FixedPredictionValues.MaxSpeed
    if pastVel.Magnitude > maxSpeed then
        pastVel = pastVel.Unit * maxSpeed
    end

    local fakePos = applyFakeDistance and GunSilent.Settings.FakeDistance.Value > 0 and (pastPos - (pastPos - myPos).Unit * math.max(1, (pastPos - myPos).Magnitude - GunSilent.Settings.FakeDistance.Value)) or myPos
    local distance = (pastPos - fakePos).Magnitude
    local realDistance = (pastPos - myPos).Magnitude
    local timeToTarget = distance / bulletSpeed
    local realTimeToTarget = realDistance / bulletSpeed

    local predictedPos = pastPos + pastVel * (timeToTarget + GunSilent.Settings.LatencyCompensation.Value)
    local realPredictedPos = pastPos + pastVel * (realTimeToTarget + GunSilent.Settings.LatencyCompensation.Value)

    -- Добавляем сглаживание
    local lastPredictedPos = GunSilent.State.LastPredictedPos or predictedPos
    predictedPos = lastPredictedPos:Lerp(predictedPos, 0.5)
    realPredictedPos = lastPredictedPos:Lerp(realPredictedPos, 0.5)
    GunSilent.State.LastPredictedPos = predictedPos

    local humanoid = targetChar:FindFirstChild("Humanoid")
    local isInVehicle = humanoid and humanoid.SeatPart ~= nil
    if isInVehicle then
        local yCorrection = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedVehicleYCorrection.Value or 0
        predictedPos = predictedPos + Vector3.new(0, yCorrection, 0)
        realPredictedPos = realPredictedPos + Vector3.new(0, yCorrection, 0)
    end

    return {
        position = realPredictedPos,
        direction = (predictedPos - fakePos).Unit,
        realDirection = (realPredictedPos - myPos).Unit,
        fakePosition = fakePos,
        timeToTarget = timeToTarget
    }
end

local function getAimCFrameGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.realDirection then return nil end
    return CFrame.new(localRoot.Position, localRoot.Position + prediction.realDirection)
end

local function createHitDataGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local targetChar = target.Character
    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.realDirection or not prediction.fakePosition then return nil end

    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value == "Random" and (math.random() > 0.5 and "Head" or "UpperTorso") or GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart then return nil end

    -- Отладочный вывод
    print("Bullet direction:", prediction.realDirection, "Target position:", prediction.position)

    local equippedTool = getEquippedGunTool(GunSilent.State.LocalCharacter)
    local isShotgunWeapon = GunSilent.Settings.ShotgunSupport.Value and equippedTool and isShotgun(equippedTool)
    local useMultiBullets = isShotgunWeapon or GunSilent.Settings.TestGenBullet.Value
    local numBullets = useMultiBullets and (isShotgunWeapon and GunSilent.Settings.GenBullet.Value or 4) or 1
    local hitData = {}

    if useMultiBullets then
        for i = 1, numBullets do
            hitData[i] = {{Normal = prediction.realDirection, Instance = hitPart, Position = prediction.position}}
        end
    else
        hitData[1] = {{Normal = prediction.realDirection, Instance = hitPart, Position = prediction.position}}
    end
    return hitData
end

local function updateVisualsGun(target, hasWeapon, deltaTime)
    local localRoot = GunSilent.State.LocalRoot
    if not GunSilent.Settings.Enabled.Value or not hasWeapon or not target or not target.Character or not localRoot then
        if GunSilent.State.TargetVisualPart then GunSilent.State.TargetVisualPart.Transparency = 1 end
        if GunSilent.State.HitboxVisualPart then GunSilent.State.HitboxVisualPart.Transparency = 1 end
        if GunSilent.State.PredictVisualPart then GunSilent.State.PredictVisualPart.Transparency = 1 end
        if GunSilent.State.DirectionVisualPart then GunSilent.State.DirectionVisualPart.Transparency = 1 end
        if GunSilent.State.RealDirectionVisualPart then GunSilent.State.RealDirectionVisualPart.Transparency = 1 end
        if GunSilent.State.TrajectoryBeam then GunSilent.State.TrajectoryBeam.Enabled = false end
        if GunSilent.State.FullTrajectoryParts then
            for _, part in pairs(GunSilent.State.FullTrajectoryParts) do part.Transparency = 1 end
        end
        GunSilent.State.LastTargetPos = nil
        GunSilent.State.LastPredictionPos = nil
        GunSilent.State.SmoothedVisualPositions = {}
        return
    end

    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.direction or not prediction.realDirection then return end

    local targetChar = target.Character
    local targetHead = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value == "Random" and (math.random() > 0.5 and "Head" or "UpperTorso") or GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHead or not hitPart then return end

    local targetPos, predictionPos = targetHead.Position, prediction.position
    local shouldUpdate = not GunSilent.State.LastTargetPos or not GunSilent.State.LastPredictionPos or
        (targetPos - GunSilent.State.LastTargetPos).Magnitude > 0.1 or (predictionPos - GunSilent.State.LastPredictionPos).Magnitude > 0.1
    GunSilent.State.LastTargetPos, GunSilent.State.LastPredictionPos = targetPos, predictionPos

    local localHead = GunSilent.State.LocalCharacter and GunSilent.State.LocalCharacter:FindFirstChild("Head")
    local startPos = localHead and localHead.Position or localRoot.Position
    local smoothingFactor = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.SmoothingVisualFactor.Value or GunSilent.FixedPredictionValues.SmoothingVisualFactor
    GunSilent.State.SmoothedVisualPositions = GunSilent.State.SmoothedVisualPositions or {}

    if GunSilent.Settings.TargetVisual.Value and shouldUpdate then
        local targetVisualPart = GunSilent.State.TargetVisualPart
        if not targetVisualPart then
            targetVisualPart = Instance.new("Part")
            targetVisualPart.Size = Vector3.new(1, 1, 1)
            targetVisualPart.Shape = Enum.PartType.Ball
            targetVisualPart.Anchored = true
            targetVisualPart.CanCollide = false
            targetVisualPart.Color = Color3.fromRGB(255, 0, 0)
            targetVisualPart.Parent = Workspace
            GunSilent.State.TargetVisualPart = targetVisualPart
        end
        local currentPos = GunSilent.State.SmoothedVisualPositions.TargetVisual or targetHead.Position
        local targetVisualPos = targetHead.Position
        GunSilent.State.SmoothedVisualPositions.TargetVisual = currentPos:Lerp(targetVisualPos, smoothingFactor)
        targetVisualPart.Position = GunSilent.State.SmoothedVisualPositions.TargetVisual
        targetVisualPart.Transparency = 0.4
    elseif GunSilent.State.TargetVisualPart then
        GunSilent.State.TargetVisualPart.Transparency = 1
    end

    if GunSilent.Settings.HitboxVisual.Value and shouldUpdate then
        local hitboxVisualPart = GunSilent.State.HitboxVisualPart
        if not hitboxVisualPart then
            hitboxVisualPart = Instance.new("Part")
            hitboxVisualPart.Anchored = true
            hitboxVisualPart.CanCollide = false
            hitboxVisualPart.Color = Color3.fromRGB(0, 255, 0)
            hitboxVisualPart.Parent = Workspace
            GunSilent.State.HitboxVisualPart = hitboxVisualPart
        end
        local currentCFrame = GunSilent.State.SmoothedVisualPositions.HitboxVisual or hitPart.CFrame
        local targetCFrame = hitPart.CFrame
        GunSilent.State.SmoothedVisualPositions.HitboxVisual = currentCFrame:Lerp(targetCFrame, smoothingFactor)
        hitboxVisualPart.Size = hitPart.Size + Vector3.new(0.2, 0.2, 0.2)
        hitboxVisualPart.CFrame = GunSilent.State.SmoothedVisualPositions.HitboxVisual
        hitboxVisualPart.Transparency = 0.6
    elseif GunSilent.State.HitboxVisualPart then
        GunSilent.State.HitboxVisualPart.Transparency = 1
    end

    if GunSilent.Settings.PredictVisual.Value and shouldUpdate then
        local predictVisualPart = GunSilent.State.PredictVisualPart
        if not predictVisualPart then
            predictVisualPart = Instance.new("Part")
            predictVisualPart.Size = Vector3.new(0.7, 0.7, 0.7)
            predictVisualPart.Shape = Enum.PartType.Ball
            predictVisualPart.Anchored = true
            predictVisualPart.CanCollide = false
            predictVisualPart.Parent = Workspace
            GunSilent.State.PredictVisualPart = predictVisualPart
        end
        local currentPos = GunSilent.State.SmoothedVisualPositions.PredictVisual or prediction.position
        GunSilent.State.SmoothedVisualPositions.PredictVisual = currentPos:Lerp(prediction.position, smoothingFactor)
        predictVisualPart.Position = GunSilent.State.SmoothedVisualPositions.PredictVisual
        predictVisualPart.Color = GunSilent.State.IsTeleporting and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255)
        predictVisualPart.Transparency = 0.2
    elseif GunSilent.State.PredictVisualPart then
        GunSilent.State.PredictVisualPart.Transparency = 1
    end

    if GunSilent.Settings.ShowDirection.Value and shouldUpdate then
        local directionVisualPart = GunSilent.State.DirectionVisualPart
        if not directionVisualPart then
            directionVisualPart = Instance.new("Part")
            directionVisualPart.Size = Vector3.new(0.2, 0.2, 5)
            directionVisualPart.Anchored = true
            directionVisualPart.CanCollide = false
            directionVisualPart.Color = Color3.fromRGB(255, 215, 0)
            directionVisualPart.Parent = Workspace
            GunSilent.State.DirectionVisualPart = directionVisualPart
        end
        local realDirectionVisualPart = GunSilent.State.RealDirectionVisualPart
        if not realDirectionVisualPart then
            realDirectionVisualPart = Instance.new("Part")
            realDirectionVisualPart.Size = Vector3.new(0.3, 0.3, 6)
            realDirectionVisualPart.Anchored = true
            realDirectionVisualPart.CanCollide = false
            realDirectionVisualPart.Color = Color3.fromRGB(0, 255, 0)
            realDirectionVisualPart.Parent = Workspace
            GunSilent.State.RealDirectionVisualPart = realDirectionVisualPart
        end
        local currentDirectionCFrame = GunSilent.State.SmoothedVisualPositions.DirectionVisual or CFrame.new(startPos, startPos + prediction.direction)
        local targetDirectionCFrame = CFrame.lookAt(startPos, startPos + (prediction.direction * 5))
        GunSilent.State.SmoothedVisualPositions.DirectionVisual = currentDirectionCFrame:Lerp(targetDirectionCFrame, smoothingFactor)
        directionVisualPart.CFrame = GunSilent.State.SmoothedVisualPositions.DirectionVisual
        directionVisualPart.Position = startPos + (prediction.direction * 2.5)
        directionVisualPart.Transparency = 0.4

        local currentRealDirectionCFrame = GunSilent.State.SmoothedVisualPositions.RealDirectionVisual or CFrame.new(startPos, startPos + prediction.realDirection)
        local targetRealDirectionCFrame = CFrame.lookAt(startPos, startPos + (prediction.realDirection * 5))
        GunSilent.State.SmoothedVisualPositions.RealDirectionVisual = currentRealDirectionCFrame:Lerp(targetRealDirectionCFrame, smoothingFactor)
        realDirectionVisualPart.CFrame = GunSilent.State.SmoothedVisualPositions.RealDirectionVisual
        realDirectionVisualPart.Position = startPos + (prediction.realDirection * 3)
        realDirectionVisualPart.Transparency = 0.3
    elseif GunSilent.State.DirectionVisualPart then
        GunSilent.State.DirectionVisualPart.Transparency = 1
        GunSilent.State.RealDirectionVisualPart.Transparency = 1
    end

    if GunSilent.Settings.PredictVisual.Value and GunSilent.Settings.ShowTrajectoryBeam and shouldUpdate then
        local trajectoryBeam = GunSilent.State.TrajectoryBeam
        if not trajectoryBeam then
            trajectoryBeam = Instance.new("Beam")
            trajectoryBeam.FaceCamera = true
            trajectoryBeam.Width0 = 0.3
            trajectoryBeam.Width1 = 0.3
            trajectoryBeam.Transparency = NumberSequence.new(0.4)
            trajectoryBeam.Color = ColorSequence.new(Color3.fromRGB(147, 112, 219))
            trajectoryBeam.Parent = Workspace
            local attachment0 = Instance.new("Attachment")
            local attachment1 = Instance.new("Attachment")
            trajectoryBeam.Attachment0 = attachment0
            trajectoryBeam.Attachment1 = attachment1
            GunSilent.State.TrajectoryBeam = trajectoryBeam
        end
        local currentAttachment0Pos = GunSilent.State.SmoothedVisualPositions.TrajectoryBeam0 or startPos
        local currentAttachment1Pos = GunSilent.State.SmoothedVisualPositions.TrajectoryBeam1 or prediction.position
        GunSilent.State.SmoothedVisualPositions.TrajectoryBeam0 = currentAttachment0Pos:Lerp(startPos, smoothingFactor)
        GunSilent.State.SmoothedVisualPositions.TrajectoryBeam1 = currentAttachment1Pos:Lerp(prediction.position, smoothingFactor)
        trajectoryBeam.Attachment0.WorldPosition = GunSilent.State.SmoothedVisualPositions.TrajectoryBeam0
        trajectoryBeam.Attachment1.WorldPosition = GunSilent.State.SmoothedVisualPositions.TrajectoryBeam1
        trajectoryBeam.Attachment0.Parent = localHead or localRoot
        if GunSilent.State.PredictVisualPart then
            trajectoryBeam.Attachment1.Parent = GunSilent.State.PredictVisualPart
        else
            local tempPart = Instance.new("Part")
            tempPart.Size = Vector3.new(0.1, 0.1, 0.1)
            tempPart.Position = prediction.position
            tempPart.Anchored = true
            tempPart.CanCollide = false
            tempPart.Transparency = 1
            tempPart.Parent = Workspace
            trajectoryBeam.Attachment1.Parent = tempPart
            RunService.Heartbeat:Once(function()
                tempPart:Destroy()
            end)
        end
        trajectoryBeam.Enabled = true
    elseif GunSilent.State.TrajectoryBeam then
        GunSilent.State.TrajectoryBeam.Enabled = false
    end

    if GunSilent.Settings.PredictVisual.Value and GunSilent.Settings.ShowFullTrajectory and shouldUpdate then
        local fullTrajectoryParts = GunSilent.State.FullTrajectoryParts
        if not fullTrajectoryParts then
            fullTrajectoryParts = {}
            for i = 1, 5 do
                local trajectoryPart = Instance.new("Part")
                trajectoryPart.Size = Vector3.new(0.3, 0.3, 0.3)
                trajectoryPart.Shape = Enum.PartType.Ball
                trajectoryPart.Anchored = true
                trajectoryPart.CanCollide = false
                trajectoryPart.Color = Color3.fromRGB(255, 165, 0)
                trajectoryPart.Parent = Workspace
                table.insert(fullTrajectoryParts, trajectoryPart)
            end
            GunSilent.State.FullTrajectoryParts = fullTrajectoryParts
        end
        local bulletSpeed = GunSilent.Settings.PredictBullet.Value
        local distance = (prediction.position - startPos).Magnitude
        local steps = 5
        local stepTime = prediction.timeToTarget / steps

        for i = 0, steps - 1 do
            local t = stepTime * i
            local pos = startPos + (prediction.realDirection * bulletSpeed * t)
            local currentPos = GunSilent.State.SmoothedVisualPositions["FullTrajectory" .. i] or pos
            GunSilent.State.SmoothedVisualPositions["FullTrajectory" .. i] = currentPos:Lerp(pos, smoothingFactor)
            fullTrajectoryParts[i + 1].Position = GunSilent.State.SmoothedVisualPositions["FullTrajectory" .. i]
            fullTrajectoryParts[i + 1].Transparency = 0.4
        end
    elseif GunSilent.State.FullTrajectoryParts then
        for _, part in pairs(GunSilent.State.FullTrajectoryParts) do
            part.Transparency = 1
        end
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
                            if GunSilent.State.LocalCharacter then
                                local localHead = GunSilent.State.LocalCharacter:FindFirstChild("Head")
                                if localHead then
                                    aimCFrame = CFrame.new(localHead.Position, localHead.Position + (aimCFrame.Position - localHead.Position).Unit)
                                end
                            end
                            modifiedArgs = {args[1], args[2], equippedTool, aimCFrame, hitData}
                        end
                    end
                end
            end

            local result = GunSilent.State.OldFireServer(self, unpack(modifiedArgs))
            if GunSilent.Settings.DoubleTap.Value and GunSilent.State.V_U_4 and #modifiedArgs >= 2 and modifiedArgs[2] == "shoot_gun" then
                local equippedTool, aimCFrame, hitData = modifiedArgs[3], modifiedArgs[4], modifiedArgs[5]
                if equippedTool and aimCFrame and hitData then
                    GunSilent.State.V_U_4.event = GunSilent.State.V_U_4.event + 1
                    game:GetService("ReplicatedStorage").Remotes.Send:FireServer(GunSilent.State.V_U_4.event, "shoot_gun", equippedTool, aimCFrame, hitData)
                end
            end
            return result
        end)
    end

    GunSilent.State.Connection = RunService.Heartbeat:Connect(function(deltaTime)
        if not GunSilent.Settings.Enabled.Value then
            if GunSilent.State.FovCircle then GunSilent.State.FovCircle.Visible = false end
            GunSilent.Core.GunSilentTarget.CurrentTarget = nil
            updateVisualsGun(nil, false, deltaTime)
            return
        end

        local character = GunSilent.State.LocalCharacter
        local currentTool = getEquippedGunTool(character)
        if currentTool ~= GunSilent.State.LastTool then
            if currentTool and not GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Equipped: " .. currentTool.Name .. " (Total Range: " .. getGunRange(currentTool) .. ")", true)
            elseif GunSilent.State.LastTool and not currentTool then
                GunSilent.notify("GunSilent", "Unequipped: " .. GunSilent.State.LastTool.Name, true)
            elseif currentTool and GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Switched to " .. currentTool.Name .. " (Range: " .. getGunRange(currentTool) .. ")", true)
            end
            GunSilent.State.LastTool = currentTool
        end

        updateFovCircle(deltaTime)
        if not currentTool then
            GunSilent.Core.GunSilentTarget.CurrentTarget = nil
            updateVisualsGun(nil, false, deltaTime)
            return
        end

        local gunRange = getGunRange(currentTool)
        local nearestPlayer = getNearestPlayerGun(gunRange)
        updateVisualsGun(nearestPlayer, true, deltaTime)
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
                    Maximum = 200,
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
                        initializeGunSilent()
                        notify("GunSilent", "Rage " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'Rage'),
                callback = function(value)
                    GunSilent.Settings.Rage.Value = value
                    initializeGunSilent()
                    notify("GunSilent", "Rage " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.RageKeybind = {
                element = UI.Sections.GunSilent:Keybind({
                    Name = "Rage Keybind",
                    Default = nil,
                    Callback = function()
                        GunSilent.Settings.Rage.Value = not GunSilent.Settings.Rage.Value
                        initializeGunSilent()
                        notify("GunSilent", "Rage " .. (GunSilent.Settings.Rage.Value and "Enabled" or "Disabled"), true)
                    end
                }, 'RageKeybind'),
                callback = function()
                    GunSilent.Settings.Rage.Value = not GunSilent.Settings.Rage.Value
                    initializeGunSilent()
                    notify("GunSilent", "Rage " .. (GunSilent.Settings.Rage.Value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.DoubleTap = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "DoubleTap",
                    Default = GunSilent.Settings.DoubleTap.Value,
                    Callback = function(value)
                        GunSilent.Settings.DoubleTap.Value = value
                        notify("GunSilent", "DoubleTap " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'DoubleTap'),
                callback = function(value)
                    GunSilent.Settings.DoubleTap.Value = value
                    notify("GunSilent", "DoubleTap " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.DoubleTapKeybind = {
                element = UI.Sections.GunSilent:Keybind({
                    Name = "DoubleTap Keybind",
                    Default = nil,
                    Callback = function()
                        GunSilent.Settings.DoubleTap.Value = not GunSilent.Settings.DoubleTap.Value
                        notify("GunSilent", "DoubleTap " .. (GunSilent.Settings.DoubleTap.Value and "Enabled" or "Disabled"), true)
                    end
                }, 'DoubleTapKeybind'),
                callback = function()
                    GunSilent.Settings.DoubleTap.Value = not GunSilent.Settings.DoubleTap.Value
                    notify("GunSilent", "DoubleTap " .. (GunSilent.Settings.DoubleTap.Value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.HitPart = {
                element = UI.Sections.GunSilent:Dropdown({
                    Name = "Hit Part",
                    Default = GunSilent.Settings.HitPart.Value,
                    Options = {"Head", "UpperTorso", "HumanoidRootPart", "Random"},
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
            uiElements.FakeDistance = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Fake Distance",
                    Default = GunSilent.Settings.FakeDistance.Value,
                    Minimum = 0,
                    Maximum = 15,
                    DisplayMethod = "Value",
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.FakeDistance.Value = value
                        notify("GunSilent", "Fake Distance set to: " .. value)
                    end
                }, 'FakeDistance'),
                callback = function(value)
                    GunSilent.Settings.FakeDistance.Value = value
                    notify("GunSilent", "Fake Distance set to: " .. value)
                end
            }
            uiElements.ShotgunSupport = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Shotgun Support",
                    Default = GunSilent.Settings.ShotgunSupport.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShotgunSupport.Value = value
                        notify("GunSilent", "Shotgun Support " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'ShotgunSupport'),
                callback = function(value)
                    GunSilent.Settings.ShotgunSupport.Value = value
                    notify("GunSilent", "Shotgun Support " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.GenerateBullets = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Generate Bullets",
                    Default = GunSilent.Settings.GenBullet.Value,
                    Minimum = 1,
                    Maximum = 10,
                    DisplayMethod = "Value",
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.GenBullet.Value = value
                        notify("GunSilent", "Number of Bullets set to: " .. value)
                    end
                }, 'GenerateBullets'),
                callback = function(value)
                    GunSilent.Settings.GenBullet.Value = value
                    notify("GunSilent", "Number of Bullets set to: " .. value)
                end
            }
            uiElements.TestGenerateBullets = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Test Generate Bullets",
                    Default = GunSilent.Settings.TestGenBullet.Value,
                    Callback = function(value)
                        GunSilent.Settings.TestGenBullet.Value = value
                        notify("GunSilent", "Test Generate Bullets " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'TestGenerateBullets'),
                callback = function(value)
                    GunSilent.Settings.TestGenBullet.Value = value
                    notify("GunSilent", "Test Generate Bullets " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.GSUSEFOV = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Use FOV",
                    Default = GunSilent.Settings.UseFOV.Value,
                    Callback = function(value)
                        GunSilent.Settings.UseFOV.Value = value
                        notify("GunSilent", "Use FOV " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'GSUSEFOV'),
                callback = function(value)
                    GunSilent.Settings.UseFOV.Value = value
                    notify("GunSilent", "Use FOV " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.GSFOV = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "FOV",
                    Default = GunSilent.Settings.FOV.Value,
                    Minimum = 0,
                    Maximum = 120,
                    DisplayMethod = "Value",
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.FOV.Value = value
                        notify("GunSilent", "FOV set to: " .. value)
                    end
                }, 'GSFOV'),
                callback = function(value)
                    GunSilent.Settings.FOV.Value = value
                    notify("GunSilent", "FOV set to: " .. value)
                end
            }
            uiElements.GSShowCircle = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Show Circle",
                    Default = GunSilent.Settings.ShowCircle.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShowCircle.Value = value
                        notify("GunSilent", "Show Circle " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'GSShowCircle'),
                callback = function(value)
                    GunSilent.Settings.ShowCircle.Value = value
                    notify("GunSilent", "Show Circle " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.GSCircleMethod = {
                element = UI.Sections.GunSilent:Dropdown({
                    Name = "Circle Method",
                    Default = GunSilent.Settings.CircleMethod.Value,
                    Options = {"Cursor", "Middle"},
                    Callback = function(value)
                        GunSilent.Settings.CircleMethod.Value = value
                        notify("GunSilent", "Circle Method set to: " .. value, true)
                    end
                }, 'GSCircleMethod'),
                callback = function(value)
                    GunSilent.Settings.CircleMethod.Value = value
                    notify("GunSilent", "Circle Method set to: " .. value, true)
                end
            }
            uiElements.GSGradientCircle = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Gradient Circle",
                    Default = GunSilent.Settings.GradientCircle.Value,
                    Callback = function(value)
                        GunSilent.Settings.GradientCircle.Value = value
                        notify("GunSilent", "Gradient Circle " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'GSGradientCircle'),
                callback = function(value)
                    GunSilent.Settings.GradientCircle.Value = value
                    notify("GunSilent", "Gradient Circle " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.GSGradientSpeed = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Gradient Speed",
                    Default = GunSilent.Settings.GradientSpeed.Value,
                    Minimum = 0.1,
                    Maximum = 3.5,
                    DisplayMethod = "Value",
                    Precision = 1,
                    Callback = function(value)
                        GunSilent.Settings.GradientSpeed.Value = value
                        notify("GunSilent", "Gradient Speed set to: " .. value)
                    end
                }, 'GSGradientSpeed'),
                callback = function(value)
                    GunSilent.Settings.GradientSpeed.Value = value
                    notify("GunSilent", "Gradient Speed set to: " .. value)
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
            uiElements.TargetVisual = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Target Visual",
                    Default = GunSilent.Settings.TargetVisual.Value,
                    Callback = function(value)
                        GunSilent.Settings.TargetVisual.Value = value
                        notify("GunSilent", "Target Visual " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'TargetVisual'),
                callback = function(value)
                    GunSilent.Settings.TargetVisual.Value = value
                    notify("GunSilent", "Target Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.HitboxVisual = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Hitbox Visual",
                    Default = GunSilent.Settings.HitboxVisual.Value,
                    Callback = function(value)
                        GunSilent.Settings.HitboxVisual.Value = value
                        notify("GunSilent", "Hitbox Visual " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'HitboxVisual'),
                callback = function(value)
                    GunSilent.Settings.HitboxVisual.Value = value
                    notify("GunSilent", "Hitbox Visual " .. (value and "Enabled" or "Disabled"), true)
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
                    notify("GunSilent", "Predict Visualconomic
                    notify("GunSilent", "Predict Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.ShowDirection = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Show Direction",
                    Default = GunSilent.Settings.ShowDirection.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShowDirection.Value = value
                        notify("GunSilent", "Show Direction " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'ShowDirection'),
                callback = function(value)
                    GunSilent.Settings.ShowDirection.Value = value
                    notify("GunSilent", "Show Direction " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.ShowTrajectory = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Show Trajectory",
                    Default = GunSilent.Settings.ShowTrajectoryBeam.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShowTrajectoryBeam = value
                        notify("GunSilent", "Trajectory Beam " .. (value and "enabled" or "disabled"), true)
                    end
                }, 'ShowTrajectory'),
                callback = function(value)
                    GunSilent.Settings.ShowTrajectoryBeam = value
                    notify("GunSilent", "Trajectory Beam " .. (value and "enabled" or "disabled"), true)
                end
            }
            uiElements.ShowFullTrajectory = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Show Full Trajectory",
                    Default = GunSilent.Settings.ShowFullTrajectory.Value,
                    Callback = function(value)
                        GunSilent.Settings.ShowFullTrajectory = value
                        notify("GunSilent", "Full Trajectory " .. (value and "enabled" or "disabled"), true)
                    end
                }, 'ShowFullTrajectory'),
                callback = function(value)
                    GunSilent.Settings.ShowFullTrajectory = value
                    notify("GunSilent", "Full Trajectory " .. (value and "enabled" or "disabled"), true)
                end
            }
            uiElements.HitChance = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Hit Chance",
                    Default = GunSilent.Settings.HitChance.Value,
                    Minimum = 0,
                    Maximum = 100,
                    DisplayMethod = "Percent",
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.HitChance.Value = value
                        notify("GunSilent", "Hit Chance set to: " .. value .. "%")
                    end
                }, 'HitChance'),
                callback = function(value)
                    GunSilent.Settings.HitChance.Value = value
                    notify("GunSilent", "Hit Chance set to: " .. value .. "%")
                end
            }
            uiElements.LatencyCompensation = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Latency Compensation",
                    Minimum = 0.0,
                    Maximum = 0.5,
                    Default = GunSilent.Settings.LatencyCompensation.Value,
                    Precision = 3,
                    Callback = function(value)
                        GunSilent.Settings.LatencyCompensation.Value = value
                        notify("GunSilent", "Latency Compensation set to: " .. value .. "s", false)
                    end
                }, 'LatencyCompensation'),
                callback = function(value)
                    GunSilent.Settings.LatencyCompensation.Value = value
                    notify("GunSilent", "Latency Compensation set to: " .. value .. "s", false)
                end
            }
            uiElements.PingEstimate = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Ping Estimate",
                    Minimum = 0.0,
                    Maximum = 0.5,
                    Default = GunSilent.Settings.PingEstimate.Value,
                    Precision = 3,
                    Callback = function(value)
                        GunSilent.Settings.PingEstimate.Value = value
                        notify("GunSilent", "Ping Estimate set to: " .. value .. "s", false)
                    end
                }, 'PingEstimate'),
                callback = function(value)
                    GunSilent.Settings.PingEstimate.Value = value
                    notify("GunSilent", "Ping Estimate set to: " .. value .. "s", false)
                end
            }
            UI.Sections.GunSilent:Header({ Name = "Prediction Settings" })
            uiElements.AdvancedPrediction = {
                element = UI.Sections.GunSilent:Toggle({
                    Name = "Advanced Prediction",
                    Default = GunSilent.Settings.AdvancedEnabled.Value,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedEnabled.Value = value
                        notify("GunSilent", "Advanced Prediction " .. (value and "Enabled" or "Disabled"), true)
                    end
                }, 'AdvancedPrediction'),
                callback = function(value)
                    GunSilent.Settings.AdvancedEnabled.Value = value
                    notify("GunSilent", "Advanced Prediction " .. (value and "Enabled" or "Disabled"), true)
                end
            }
            uiElements.VehicleYCorrection = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Vehicle Y Correction",
                    Minimum = 0,
                    Maximum = 5,
                    Default = GunSilent.Settings.AdvancedVehicleYCorrection.Value,
                    Precision = 2,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedVehicleYCorrection.Value = value
                        notify("GunSilent", "Vehicle Y Correction set to: " .. value, false)
                    end
                }, 'VehicleYCorrection'),
                callback = function(value)
                    GunSilent.Settings.AdvancedVehicleYCorrection.Value = value
                    notify("GunSilent", "Vehicle Y Correction set to: " .. value, false)
                end
            }
            uiElements.PositionHistory = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Position History",
                    Minimum = 2,
                    Maximum = 20,
                    Default = GunSilent.Settings.AdvancedPositionHistorySize.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedPositionHistorySize.Value = value
                        notify("GunSilent", "Position History Size set to: " .. value, false)
                    end
                }, 'PositionHistory'),
                callback = function(value)
                    GunSilent.Settings.AdvancedPositionHistorySize.Value = value
                    notify("GunSilent", "Position History Size set to: " .. value, false)
                end
            }
            uiElements.SmoothingFactor = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Smoothing Factor",
                    Minimum = 0.1,
                    Maximum = 0.9,
                    Default = GunSilent.Settings.AdvancedSmoothingFactor.Value,
                    Precision = 1,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedSmoothingFactor.Value = value
                        notify("GunSilent", "Smoothing Factor set to: " .. value, false)
                    end
                }, 'SmoothingFactor'),
                callback = function(value)
                    GunSilent.Settings.AdvancedSmoothingFactor.Value = value
                    notify("GunSilent", "Smoothing Factor set to: " .. value, false)
                end
            }
            uiElements.SmoothingVisualFactor = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Visual Smoothing Factor",
                    Minimum = 0.1,
                    Maximum = 0.9,
                    Default = GunSilent.Settings.SmoothingVisualFactor.Value,
                    Precision = 1,
                    Callback = function(value)
                        GunSilent.Settings.SmoothingVisualFactor.Value = value
                        notify("GunSilent", "Visual Smoothing Factor set to: " .. value, false)
                    end
                }, 'SmoothingVisualFactor'),
                callback = function(value)
                    GunSilent.Settings.SmoothingVisualFactor.Value = value
                    notify("GunSilent", "Visual Smoothing Factor set to: " .. value, false)
                end
            }
            uiElements.TeleportSpeed = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Teleport Speed",
                    Minimum = 300,
                    Maximum = 1000,
                    Default = GunSilent.Settings.AdvancedTeleportThreshold.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedTeleportThreshold.Value = value
                        notify("GunSilent", "Teleport Threshold set to: " .. value, false)
                    end
                }, 'TeleportSpeed'),
                callback = function(value)
                    GunSilent.Settings.AdvancedTeleportThreshold.Value = value
                    notify("GunSilent", "Teleport Threshold set to: " .. value, false)
                end
            }
            uiElements.TPLimit = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "TP Limit",
                    Minimum = 100,
                    Maximum = 500,
                    Default = GunSilent.Settings.AdvancedMaxSpeed.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.AdvancedMaxSpeed.Value = value
                        notify("GunSilent", "Max Speed Limit set to: " .. value, false)
                    end
                }, 'TPLimit'),
                callback = function(value)
                    GunSilent.Settings.AdvancedMaxSpeed.Value = value
                    notify("GunSilent", "Max Speed Limit set to: " .. value, false)
                end
            }
            uiElements.BulletSpeed = {
                element = UI.Sections.GunSilent:Slider({
                    Name = "Bullet Speed",
                    Minimum = 500,
                    Maximum = 5000,
                    Default = GunSilent.Settings.PredictBullet.Value,
                    Precision = 0,
                    Callback = function(value)
                        GunSilent.Settings.PredictBullet.Value = value
                        notify("GunSilent", "Bullet Speed set to: " .. value, false)
                    end
                }, 'BulletSpeed'),
                callback = function(value)
                    GunSilent.Settings.PredictBullet.Value = value
                    notify("GunSilent", "Bullet Speed set to: " .. value, false)
                end
            }

            UI.Sections.GunSilent:Button({
                Name = "Sync Settings",
                Callback = function()
                    uiElements.GSEnabled.callback(uiElements.GSEnabled.element:GetState())
                    uiElements.RangePlus.callback(uiElements.RangePlus.element:GetValue())
                    uiElements.Rage.callback(uiElements.Rage.element:GetState())
                    uiElements.DoubleTap.callback(uiElements.DoubleTap.element:GetState())
                    local hitPartOptions = uiElements.HitPart.element:GetOptions()
                    for option, selected in pairs(hitPartOptions) do
                        if selected then
                            uiElements.HitPart.callback(option)
                            break
                        end
                    end
                    uiElements.FakeDistance.callback(uiElements.FakeDistance.element:GetValue())
                    uiElements.ShotgunSupport.callback(uiElements.ShotgunSupport.element:GetState())
                    uiElements.GenerateBullets.callback(uiElements.GenerateBullets.element:GetValue())
                    uiElements.TestGenerateBullets.callback(uiElements.TestGenerateBullets.element:GetState())
                    uiElements.GSUSEFOV.callback(uiElements.GSUSEFOV.element:GetState())
                    uiElements.GSFOV.callback(uiElements.GSFOV.element:GetValue())
                    uiElements.GSShowCircle.callback(uiElements.GSShowCircle.element:GetState())
                    local circleMethodOptions = uiElements.GSCircleMethod.element:GetOptions()
                    for option, selected in pairs(circleMethodOptions) do
                        if selected then
                            uiElements.GSCircleMethod.callback(option)
                            break
                        end
                    end
                    uiElements.GSGradientCircle.callback(uiElements.GSGradientCircle.element:GetState())
                    uiElements.GSGradientSpeed.callback(uiElements.GSGradientSpeed.element:GetValue())
                    local sortMethodOptions = uiElements.SortMethod.element:GetOptions()
                    for option, selected in pairs(sortMethodOptions) do
                        if selected then
                            uiElements.SortMethod.callback(option)
                            break
                        end
                    end
                    uiElements.TargetVisual.callback(uiElements.TargetVisual.element:GetState())
                    uiElements.HitboxVisual.callback(uiElements.HitboxVisual.element:GetState())
                    uiElements.PredictVisual.callback(uiElements.PredictVisual.element:GetState())
                    uiElements.ShowDirection.callback(uiElements.ShowDirection.element:GetState())
                    uiElements.ShowTrajectory.callback(uiElements.ShowTrajectory.element:GetState())
                    uiElements.ShowFullTrajectory.callback(uiElements.ShowFullTrajectory.element:GetState())
                    uiElements.HitChance.callback(uiElements.HitChance.element:GetValue())
                    uiElements.LatencyCompensation.callback(uiElements.LatencyCompensation.element:GetValue())
                    uiElements.PingEstimate.callback(uiElements.PingEstimate.element:GetValue())
                    uiElements.AdvancedPrediction.callback(uiElements.AdvancedPrediction.element:GetState())
                    uiElements.VehicleYCorrection.callback(uiElements.VehicleYCorrection.element:GetValue())
                    uiElements.PositionHistory.callback(uiElements.PositionHistory.element:GetValue())
                    uiElements.SmoothingFactor.callback(uiElements.SmoothingFactor.element:GetValue())
                    uiElements.SmoothingVisualFactor.callback(uiElements.SmoothingVisualFactor.element:GetValue())
                    uiElements.TeleportSpeed.callback(uiElements.TeleportSpeed.element:GetValue())
                    uiElements.TPLimit.callback(uiElements.TPLimit.element:GetValue())
                    uiElements.BulletSpeed.callback(uiElements.BulletSpeed.element:GetValue())

                    notify("GunSilent", "Settings synchronized with UI!", true)
                end
            }, 'SyncSettings')
        end
    end

    initializeGunSilent()
end

return { Init = Init }
