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
        YCorrection = { Value = 0.01, Default = 0.01 },
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
        AdvancedVehicleFactor = { Value = 0.9, Default = 0.9 },
        AdvancedPedestrianFactor = { Value = 0.55, Default = 0.55 },
        AdvancedTeleportThreshold = { Value = 600, Default = 600 },
        AdvancedMaxSpeed = { Value = 500, Default = 500 },
        AdvancedVehicleYCorrection = { Value = 0, Default = 0 },
        AdvancedPredictionAggressiveness = { Value = 1.2, Default = 1.2 },
        AdvancedSmoothingFactor = { Value = 0.1, Default = 0.1 },
        AdvancedSmallDistanceSpeedFactorMultiplier = { Value = 1.7, Default = 1.7 },
        AdvancedSlowVehiclePredictionFactor = { Value = 1.95, Default = 1.95 },
        AdvancedFastVehiclePredictionLimit = { Value = 2.2, Default = 2.2 },
        VisualUpdateFrequency = { Value = 0.1, Default = 0.1 },
        AdvancedPositionHistorySize = { Value = 20, Default = 20 },
        LatencyCompensation = { Value = 0.2, Default = 0.2 },
        ShowTrajectoryBeam = { Value = true, Default = true },
        ShowFullTrajectory = { Value = true, Default = true },
        ShotgunSupport = { Value = false, Default = false },
        GenBullet = { Value = 4, Default = 4 },
        TestGenBullet = { Value = false, Default = false },
        DoubleTap = { Value = false, Default = false },
        TrackTarget = { Value = true, Default = true },
        ChamsColor = { Value = Color3.fromRGB(255, 0, 255), Default = Color3.fromRGB(255, 0, 255) },
    },
    FixedPredictionValues = {
        VehicleFactor = 0.9,
        PedestrianFactor = 0.55,
        PredictionAggressiveness = 1.2,
        SmallDistanceSpeedFactorMultiplier = 1.7,
        SlowVehiclePredictionFactor = 1.95,
        FastVehiclePredictionLimit = 2.2,
        PositionHistorySize = 20,
        SmoothingFactor = 0.1,
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
        TrackTargetHitboxes = nil,
        ChamsFolder = nil,
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

    local targetPos = hitPart.Position
    local targetId = tostring(target.UserId)
    GunSilent.State.IsTeleporting = GunSilent.State.LastTargetPosition[targetId] and (targetPos - GunSilent.State.LastTargetPosition[targetId]).Magnitude > 50
    GunSilent.State.LastTargetPosition[targetId] = targetPos

    local fakePos = applyFakeDistance and GunSilent.Settings.FakeDistance.Value > 0 and (targetPos - (targetPos - myPos).Unit * math.max(1, (targetPos - myPos).Magnitude - GunSilent.Settings.FakeDistance.Value)) or myPos
    local distance, realDistance = (targetPos - fakePos).Magnitude, (targetPos - myPos).Magnitude
    local bulletSpeed = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.PredictBullet.Value or GunSilent.FixedPredictionValues.PredictBullet
    local timeToTarget, realTimeToTarget = distance / bulletSpeed, realDistance / bulletSpeed

    local positionHistory = GunSilent.State.PositionHistory[target] or {}
    GunSilent.State.PositionHistory[target] = positionHistory
    local currentTime = tick()
    positionHistory[#positionHistory + 1] = { pos = targetPos, time = currentTime }
    local historySize = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedPositionHistorySize.Value or GunSilent.FixedPredictionValues.PositionHistorySize
    while #positionHistory > historySize do
        table.remove(positionHistory, 1)
    end

    local effectiveVelocity = targetRoot.Velocity
    local effectiveSpeed = effectiveVelocity.Magnitude
    local teleportThreshold = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedTeleportThreshold.Value or GunSilent.FixedPredictionValues.TeleportThreshold
    local maxSpeedLimit = GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedMaxSpeed.Value or GunSilent.FixedPredictionValues.MaxSpeed
    if effectiveSpeed > teleportThreshold then
        effectiveVelocity = Vector3.new(0, 0, 0)
        effectiveSpeed = 0
        GunSilent.State.IsTeleporting = true
    elseif effectiveSpeed > maxSpeedLimit then
        effectiveVelocity = effectiveVelocity.Unit * maxSpeedLimit
    end

    local humanoid = targetChar:FindFirstChild("Humanoid")
    local isInVehicle = humanoid and humanoid.SeatPart ~= nil
    local adjustedTimeToTarget = timeToTarget + GunSilent.Settings.LatencyCompensation.Value
    local adjustedRealTimeToTarget = realTimeToTarget + GunSilent.Settings.LatencyCompensation.Value

    local predictedPos, realPredictedPos = targetPos, targetPos
    if not GunSilent.State.IsTeleporting then
        local speedFactor = math.clamp(effectiveSpeed / (isInVehicle and 50 or 20), 0.5, isInVehicle and 2.5 or 1)
        local predictionFactor = speedFactor * (isInVehicle and
            (GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedVehicleFactor.Value or GunSilent.FixedPredictionValues.VehicleFactor) or
            (GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedPedestrianFactor.Value or GunSilent.FixedPredictionValues.PedestrianFactor)) *
            (GunSilent.Settings.AdvancedEnabled.Value and GunSilent.Settings.AdvancedPredictionAggressiveness.Value or GunSilent.FixedPredictionValues.PredictionAggressiveness)

        predictedPos = targetPos + effectiveVelocity * adjustedTimeToTarget * predictionFactor
        realPredictedPos = targetPos + effectiveVelocity * adjustedRealTimeToTarget * predictionFactor
    end

    return {
        position = predictedPos,
        direction = (predictedPos - (fakePos + Vector3.new(0, 1.5, 0))).Unit,
        realDirection = (realPredictedPos - (myPos + Vector3.new(0, 1.5, 0))).Unit,
        fakePosition = fakePos,
        timeToTarget = timeToTarget
    }
end

local function getAimCFrameGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.direction then return nil end
    return CFrame.new(localRoot.Position, localRoot.Position + prediction.direction)
end

local function createHitDataGun(target)
    local localRoot = GunSilent.State.LocalRoot
    if not target or not target.Character or not localRoot then return nil end
    local targetChar = target.Character
    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.direction or not prediction.fakePosition then return nil end

    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value == "Random" and (math.random() > 0.5 and "Head" or "UpperTorso") or GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    if not hitPart then return nil end

    local equippedTool = getEquippedGunTool(GunSilent.State.LocalCharacter)
    local isShotgunWeapon = GunSilent.Settings.ShotgunSupport.Value and equippedTool and isShotgun(equippedTool)
    local useMultiBullets = isShotgunWeapon or GunSilent.Settings.TestGenBullet.Value
    local numBullets = useMultiBullets and (isShotgunWeapon and GunSilent.Settings.GenBullet.Value or 4) or 1
    local hitData = {}

    if useMultiBullets then
        for i = 1, numBullets do
            hitData[i] = {{Normal = prediction.direction, Instance = hitPart, Position = prediction.position}}
        end
    else
        hitData[1] = {{Normal = prediction.direction, Instance = hitPart, Position = prediction.position}}
    end
    return hitData
end

local function ClearTrackTargetHitboxes()
    if GunSilent.State.TrackTargetHitboxes then
        for _, hitboxData in pairs(GunSilent.State.TrackTargetHitboxes.Hitboxes or {}) do
            if hitboxData.Highlight then
                hitboxData.Highlight:Destroy()
            end
        end
        GunSilent.State.TrackTargetHitboxes = nil
    end
    if GunSilent.State.ChamsFolder then
        GunSilent.State.ChamsFolder:Destroy()
        GunSilent.State.ChamsFolder = nil
    end
end

local function SetupTrackTargetHitboxes(character, targetRoot)
    if not character or not targetRoot then
        return nil
    end

    ClearTrackTargetHitboxes()

    local chamsFolder = Instance.new("Folder")
    chamsFolder.Name = "ChamsFolder"
    chamsFolder.Parent = Workspace
    GunSilent.State.ChamsFolder = chamsFolder

    local bodyParts = {
        "Head",
        "UpperTorso",
        "LowerTorso",
        "Torso",
        "LeftUpperLeg",
        "LeftLowerLeg",
        "RightUpperLeg",
        "RightLowerLeg",
        "LeftLeg",
        "RightLeg",
        "LeftUpperArm",
        "LeftLowerArm",
        "RightUpperArm",
        "RightLowerArm",
        "LeftArm",
        "RightArm"
    }

    local hitboxes = {}
    for _, partName in ipairs(bodyParts) do
        local bodyPart = character:FindFirstChild(partName)
        if bodyPart and bodyPart:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = GunSilent.Settings.ChamsColor.Value
            highlight.OutlineColor = GunSilent.Settings.ChamsColor.Value
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0
            highlight.Adornee = bodyPart
            highlight.Parent = chamsFolder

            hitboxes[partName] = {
                Highlight = highlight,
                BodyPart = bodyPart
            }
        end
    end

    return hitboxes
end

local function updateVisualsGun(target, hasWeapon, deltaTime)
    local currentTime = tick()
    if currentTime - GunSilent.State.LastVisualUpdateTime < GunSilent.Settings.VisualUpdateFrequency.Value then
        if not GunSilent.Settings.TrackTarget.Value or not GunSilent.State.TrackTargetHitboxes then
            return
        end
    else
        GunSilent.State.LastVisualUpdateTime = currentTime
    end

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
        ClearTrackTargetHitboxes()
        GunSilent.State.LastTargetPos = nil
        GunSilent.State.LastPredictionPos = nil
        return
    end

    local prediction = predictTargetPositionGun(target, true)
    if not prediction.position or not prediction.direction then
        ClearTrackTargetHitboxes()
        return
    end

    local targetChar = target.Character
    local targetHead = targetChar:FindFirstChild("Head") or targetChar:FindFirstChild("HumanoidRootPart")
    local hitPart = targetChar:FindFirstChild(GunSilent.Settings.HitPart.Value == "Random" and (math.random() > 0.5 and "Head" or "UpperTorso") or GunSilent.Settings.HitPart.Value) or targetChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHead or not hitPart or not targetRoot then
        ClearTrackTargetHitboxes()
        return
    end

    local targetPos, predictedPos = targetHead.Position, prediction.position
    local shouldUpdate = not GunSilent.State.LastTargetPos or not GunSilent.State.LastPredictionPos or
        (targetPos - GunSilent.State.LastTargetPos).Magnitude > 0.1 or (predictedPos - GunSilent.State.LastPredictionPos).Magnitude > 0.1
    GunSilent.State.LastTargetPos, GunSilent.State.LastPredictionPos = targetPos, predictedPos

    local startPos = localRoot.Position + Vector3.new(0, 1.5, 0)
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
        targetVisualPart.Position = targetHead.Position + Vector3.new(0, 3, 0)
        targetVisualPart.Transparency = 0.5
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
        hitboxVisualPart.Size = hitPart.Size + Vector3.new(0.2, 0.2, 0.2)
        hitboxVisualPart.CFrame = hitPart.CFrame
        hitboxVisualPart.Transparency = 0.7
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
        predictVisualPart.Position = predictedPos
        predictVisualPart.Color = GunSilent.State.IsTeleporting and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255)
        predictVisualPart.Transparency = 0.3
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
            realDirectionVisualPart.Size = Vector3.new(0.2, 0.2, 5)
            realDirectionVisualPart.Anchored = true
            realDirectionVisualPart.CanCollide = false
            realDirectionVisualPart.Color = Color3.fromRGB(255, 255, 255)
            realDirectionVisualPart.Parent = Workspace
            GunSilent.State.RealDirectionVisualPart = realDirectionVisualPart
        end
        directionVisualPart.CFrame = CFrame.lookAt(startPos, startPos + (prediction.direction * 5))
        directionVisualPart.Position = startPos + (prediction.direction * 2.5)
        directionVisualPart.Transparency = 0.5
        realDirectionVisualPart.CFrame = CFrame.lookAt(startPos, startPos + (prediction.realDirection * 5))
        realDirectionVisualPart.Position = startPos + (prediction.realDirection * 2.5)
        realDirectionVisualPart.Transparency = 0.5
    elseif GunSilent.State.DirectionVisualPart then
        GunSilent.State.DirectionVisualPart.Transparency = 1
        GunSilent.State.RealDirectionVisualPart.Transparency = 1
    end

    if GunSilent.Settings.PredictVisual.Value and GunSilent.Settings.ShowTrajectoryBeam.Value and shouldUpdate then
        local trajectoryBeam = GunSilent.State.TrajectoryBeam
        if not trajectoryBeam then
            trajectoryBeam = Instance.new("Beam")
            trajectoryBeam.FaceCamera = true
            trajectoryBeam.Width0 = 0.2
            trajectoryBeam.Width1 = 0.2
            trajectoryBeam.Transparency = NumberSequence.new(0.5)
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
    elseif GunSilent.State.TrajectoryBeam then
        GunSilent.State.TrajectoryBeam.Enabled = false
    end

    if GunSilent.Settings.PredictVisual.Value and GunSilent.Settings.ShowFullTrajectory.Value and shouldUpdate then
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
        local bulletSpeed = 2500
        local gravity = Vector3.new(0, -Workspace.Gravity, 0)
        local distance = (predictedPos - startPos).Magnitude
        local steps = 5
        local stepTime = prediction.timeToTarget / steps

        for i = 0, steps - 1 do
            local t = stepTime * i
            local pos = startPos + (prediction.direction * bulletSpeed * t) + (0.5 * gravity * t * t * math.clamp(distance / 100, 0.5, 2))
            fullTrajectoryParts[i + 1].Position = pos
            fullTrajectoryParts[i + 1].Transparency = 0.5
        end
    elseif GunSilent.State.FullTrajectoryParts then
        for _, part in pairs(GunSilent.State.FullTrajectoryParts) do
            part.Transparency = 1
        end
    end

    if GunSilent.Settings.TrackTarget.Value then
        if not GunSilent.State.TrackTargetHitboxes or GunSilent.State.TrackTargetHitboxes.Target != target then
            ClearTrackTargetHitboxes()
            local hitboxes = SetupTrackTargetHitboxes(targetChar, targetRoot)
            if hitboxes then
                GunSilent.State.TrackTargetHitboxes = {
                    Target = target,
                    Hitboxes = hitboxes
                }
            end
        end

        if GunSilent.State.TrackTargetHitboxes and GunSilent.State.TrackTargetHitboxes.Hitboxes then
            for _, hitboxData in pairs(GunSilent.State.TrackTargetHitboxes.Hitboxes) do
                local highlight = hitboxData.Highlight
                if highlight then
                    highlight.FillColor = GunSilent.Settings.ChamsColor.Value
                    highlight.OutlineColor = GunSilent.Settings.ChamsColor.Value
                end
            end
        end
    else
        ClearTrackTargetHitboxes()
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
            return
        end

        local character = GunSilent.State.LocalCharacter
        local currentTool = getEquippedGunTool(character)
        if currentTool ~= GunSilent.State.LastTool then
            if currentTool and not GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Equipped: " .. (currentTool.Name or "Unknown") .. " (Total Range: " .. getGunRange(currentTool) .. ")", true)
            elseif GunSilent.State.LastTool and not currentTool then
                GunSilent.notify("GunSilent", "Unequipped: " .. (GunSilent.State.LastTool.Name or "Unknown"), true)
            elseif currentTool and GunSilent.State.LastTool then
                GunSilent.notify("GunSilent", "Switched to " .. (currentTool.Name or "Unknown") .. " (Range: " .. getGunRange(currentTool) .. ")", true)
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
            uiElements.GSEnabled = UI.Sections.GunSilent:Toggle({
                Name = "Enabled",
                Default = GunSilent.Settings.Enabled.Default,
                Callback = function(value)
                    GunSilent.Settings.Enabled.Value = value
                    initializeGunSilent()
                    notify("GunSilent", "GunSilent " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'GSEnabled')

            uiElements.RangePlus = UI.Sections.GunSilent:Slider({
                Name = "Range Plus",
                Minimum = 0,
                Maximum = 200,
                Default = GunSilent.Settings.RangePlus.Default,
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.RangePlus.Value = value
                    notify("GunSilent", "Range Plus set to: " .. value, false)
                end
            }, 'RangePlus')

            uiElements.Rage = UI.Sections.GunSilent:Toggle({
                Name = "Rage",
                Default = GunSilent.Settings.Rage.Default,
                Callback = function(value)
                    GunSilent.Settings.Rage.Value = value
                    initializeGunSilent()
                    notify("GunSilent", "Rage " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'Rage')

            uiElements.RageKeybind = UI.Sections.GunSilent:Keybind({
                Name = "Rage Keybind",
                Default = nil,
                Callback = function()
                    GunSilent.Settings.Rage.Value = not GunSilent.Settings.Rage.Value
                    initializeGunSilent()
                    notify("GunSilent", "Rage " .. (GunSilent.Settings.Rage.Value and "Enabled" or "Disabled"), true)
                end
            }, 'RageKeybind')

            uiElements.DoubleTap = UI.Sections.GunSilent:Toggle({
                Name = "DoubleTap",
                Default = GunSilent.Settings.DoubleTap.Default,
                Callback = function(value)
                    GunSilent.Settings.DoubleTap.Value = value
                    notify("GunSilent", "DoubleTap " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'DoubleTap')

            uiElements.DoubleTapKeybind = UI.Sections.GunSilent:Keybind({
                Name = "DoubleTap Keybind",
                Default = nil,
                Callback = function()
                    GunSilent.Settings.DoubleTap.Value = not GunSilent.Settings.DoubleTap.Value
                    notify("GunSilent", "DoubleTap " .. (GunSilent.Settings.DoubleTap.Value and "Enabled" or "Disabled"), true)
                end
            }, 'DoubleTapKeybind')

            uiElements.HitPart = UI.Sections.GunSilent:Dropdown({
                Name = "Hit Part",
                Default = GunSilent.Settings.HitPart.Default,
                Options = {"Head", "UpperTorso", "HumanoidRootPart", "Random"},
                Callback = function(value)
                    GunSilent.Settings.HitPart.Value = value
                    notify("GunSilent", "Hit Part set to: " .. value, true)
                end
            }, 'HitPart')

            uiElements.FakeDistance = UI.Sections.GunSilent:Slider({
                Name = "Fake Distance",
                Default = GunSilent.Settings.FakeDistance.Default,
                Minimum = 0,
                Maximum = 15,
                DisplayMethod = "Value",
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.FakeDistance.Value = value
                    notify("GunSilent", "Fake Distance set to: " .. value)
                end
            }, 'FakeDistance')

            uiElements.ShotgunSupport = UI.Sections.GunSilent:Toggle({
                Name = "Shotgun Support",
                Default = GunSilent.Settings.ShotgunSupport.Default,
                Callback = function(value)
                    GunSilent.Settings.ShotgunSupport.Value = value
                    notify("GunSilent", "Shotgun Support " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'ShotgunSupport')

            uiElements.GenerateBullets = UI.Sections.GunSilent:Slider({
                Name = "Generate Bullets",
                Default = GunSilent.Settings.GenBullet.Default,
                Minimum = 1,
                Maximum = 10,
                DisplayMethod = "Value",
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.GenBullet.Value = value
                    notify("GunSilent", "Number of Bullets set to: " .. value)
                end
            }, 'GenerateBullets')

            uiElements.TestGenerateBullets = UI.Sections.GunSilent:Toggle({
                Name = "Test Generate Bullets",
                Default = GunSilent.Settings.TestGenBullet.Default,
                Callback = function(value)
                    GunSilent.Settings.TestGenBullet.Value = value
                    notify("GunSilent", "Test Generate Bullets " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'TestGenerateBullets')

            uiElements.GSUSEFOV = UI.Sections.GunSilent:Toggle({
                Name = "Use FOV",
                Default = GunSilent.Settings.UseFOV.Default,
                Callback = function(value)
                    GunSilent.Settings.UseFOV.Value = value
                    notify("GunSilent", "Use FOV " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'GSUSEFOV')

            uiElements.GSFOV = UI.Sections.GunSilent:Slider({
                Name = "FOV",
                Default = GunSilent.Settings.FOV.Default,
                Minimum = 0,
                Maximum = 120,
                DisplayMethod = "Value",
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.FOV.Value = value
                    notify("GunSilent", "FOV set to: " .. value)
                end
            }, 'GSFOV')

            uiElements.GSShowCircle = UI.Sections.GunSilent:Toggle({
                Name = "Show Circle",
                Default = GunSilent.Settings.ShowCircle.Default,
                Callback = function(value)
                    GunSilent.Settings.ShowCircle.Value = value
                    notify("GunSilent", "Show Circle " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'GSShowCircle')

            uiElements.GSCircleMethod = UI.Sections.GunSilent:Dropdown({
                Name = "Circle Method",
                Default = GunSilent.Settings.CircleMethod.Default,
                Options = {"Cursor", "Middle"},
                Callback = function(value)
                    GunSilent.Settings.CircleMethod.Value = value
                    notify("GunSilent", "Circle Method set to: " .. value, true)
                end
            }, 'GSCircleMethod')

            uiElements.GSGradientCircle = UI.Sections.GunSilent:Toggle({
                Name = "Gradient Circle",
                Default = GunSilent.Settings.GradientCircle.Default,
                Callback = function(value)
                    GunSilent.Settings.GradientCircle.Value = value
                    notify("GunSilent", "Gradient Circle " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'GSGradientCircle')

            uiElements.GSGradientSpeed = UI.Sections.GunSilent:Slider({
                Name = "Gradient Speed",
                Default = GunSilent.Settings.GradientSpeed.Default,
                Minimum = 0.1,
                Maximum = 3.5,
                DisplayMethod = "Value",
                Precision = 1,
                Callback = function(value)
                    GunSilent.Settings.GradientSpeed.Value = value
                    notify("GunSilent", "Gradient Speed set to: " .. value)
                end
            }, 'GSGradientSpeed')

            uiElements.SortMethod = UI.Sections.GunSilent:Dropdown({
                Name = "Sort Method",
                Default = GunSilent.Settings.SortMethod.Default,
                Options = {"Mouse", "Distance", "Mouse&Distance"},
                Callback = function(value)
                    GunSilent.Settings.SortMethod.Value = value
                    notify("GunSilent", "Sort Method set to: " .. value, true)
                end
            }, 'SortMethod')

            uiElements.TargetVisual = UI.Sections.GunSilent:Toggle({
                Name = "Target Visual",
                Default = GunSilent.Settings.TargetVisual.Default,
                Callback = function(value)
                    GunSilent.Settings.TargetVisual.Value = value
                    notify("GunSilent", "Target Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'TargetVisual')

            uiElements.HitboxVisual = UI.Sections.GunSilent:Toggle({
                Name = "Hitbox Visual",
                Default = GunSilent.Settings.HitboxVisual.Default,
                Callback = function(value)
                    GunSilent.Settings.HitboxVisual.Value = value
                    notify("GunSilent", "Hitbox Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'HitboxVisual')

            uiElements.PredictVisual = UI.Sections.GunSilent:Toggle({
                Name = "Predict Visual",
                Default = GunSilent.Settings.PredictVisual.Default,
                Callback = function(value)
                    GunSilent.Settings.PredictVisual.Value = value
                    notify("GunSilent", "Predict Visual " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'PredictVisual')

            uiElements.ShowDirection = UI.Sections.GunSilent:Toggle({
                Name = "Show Direction",
                Default = GunSilent.Settings.ShowDirection.Default,
                Callback = function(value)
                    GunSilent.Settings.ShowDirection.Value = value
                    notify("GunSilent", "Show Direction " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'ShowDirection')

            uiElements.ShowTrajectory = UI.Sections.GunSilent:Toggle({
                Name = "Show Trajectory",
                Default = GunSilent.Settings.ShowTrajectoryBeam.Default,
                Callback = function(value)
                    GunSilent.Settings.ShowTrajectoryBeam.Value = value
                    notify("GunSilent", "Trajectory Beam " .. (value and "enabled" or "disabled"), true)
                end
            }, 'ShowTrajectory')

            uiElements.ShowFullTrajectory = UI.Sections.GunSilent:Toggle({
                Name = "Show Full Trajectory",
                Default = GunSilent.Settings.ShowFullTrajectory.Default,
                Callback = function(value)
                    GunSilent.Settings.ShowFullTrajectory.Value = value
                    notify("GunSilent", "Full Trajectory " .. (value and "enabled" or "disabled"), true)
                end
            }, 'ShowFullTrajectory')

            uiElements.TrackTarget = UI.Sections.GunSilent:Toggle({
                Name = "Track Target",
                Default = GunSilent.Settings.TrackTarget.Default,
                Callback = function(value)
                    GunSilent.Settings.TrackTarget.Value = value
                    notify("GunSilent", "Track Target " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'TrackTarget')

            uiElements.ChamsColor = UI.Sections.GunSilent:Colorpicker({
                Name = "Chams Color",
                Default = GunSilent.Settings.ChamsColor.Default,
                Callback = function(value)
                    GunSilent.Settings.ChamsColor.Value = value
                    notify("GunSilent", "Chams Color updated", true)
                end
            }, 'ChamsColor')

            uiElements.HitChance = UI.Sections.GunSilent:Slider({
                Name = "Hit Chance",
                Default = GunSilent.Settings.HitChance.Default,
                Minimum = 0,
                Maximum = 100,
                DisplayMethod = "Percent",
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.HitChance.Value = value
                    notify("GunSilent", "Hit Chance set to: " .. value .. "%")
                end
            }, 'HitChance')

            uiElements.LatencyCompensation = UI.Sections.GunSilent:Slider({
                Name = "Latency Compensation",
                Minimum = 0.0,
                Maximum = 0.5,
                Default = GunSilent.Settings.LatencyCompensation.Default,
                Precision = 3,
                Callback = function(value)
                    GunSilent.Settings.LatencyCompensation.Value = value
                    notify("GunSilent", "Latency Compensation set to: " .. value .. "s", false)
                end
            }, 'LatencyCompensation')

            UI.Sections.GunSilent:Header({ Name = "Prediction Settings" })

            uiElements.AdvancedPrediction = UI.Sections.GunSilent:Toggle({
                Name = "Advanced Prediction",
                Default = GunSilent.Settings.AdvancedEnabled.Default,
                Callback = function(value)
                    GunSilent.Settings.AdvancedEnabled.Value = value
                    notify("GunSilent", "Advanced Prediction " .. (value and "Enabled" or "Disabled"), true)
                end
            }, 'AdvancedPrediction')

            uiElements.VehicleFactor = UI.Sections.GunSilent:Slider({
                Name = "Vehicle Factor",
                Minimum = 0.1,
                Maximum = 2.0,
                Default = GunSilent.Settings.AdvancedVehicleFactor.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedVehicleFactor.Value = value
                    notify("GunSilent", "Vehicle Prediction Factor set to: " .. value, false)
                end
            }, 'VehicleFactor')

            uiElements.PlayerFactor = UI.Sections.GunSilent:Slider({
                Name = "Player Factor",
                Minimum = 0.1,
                Maximum = 2.0,
                Default = GunSilent.Settings.AdvancedPedestrianFactor.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedPedestrianFactor.Value = value
                    notify("GunSilent", "Pedestrian Prediction Factor set to: " .. value, false)
                end
            }, 'PlayerFactor')

            uiElements.Agressivness = UI.Sections.GunSilent:Slider({
                Name = "Agressivness",
                Minimum = 0.4,
                Maximum = 2.1,
                Default = GunSilent.Settings.AdvancedPredictionAggressiveness.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedPredictionAggressiveness.Value = value
                    notify("GunSilent", "Prediction Aggressiveness set to: " .. value, false)
                end
            }, 'Agressivness')

            uiElements.LowDistanceMulti = UI.Sections.GunSilent:Slider({
                Name = "LowDistanceMulti",
                Minimum = 0.4,
                Maximum = 2.1,
                Default = GunSilent.Settings.AdvancedSmallDistanceSpeedFactorMultiplier.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedSmallDistanceSpeedFactorMultiplier.Value = value
                    notify("GunSilent", "Small Distance Speed Multiplier set to: " .. value, false)
                end
            }, 'LowDistanceMulti')

            uiElements.SlowVehicleMulti = UI.Sections.GunSilent:Slider({
                Name = "SlowVehicleMulti",
                Minimum = 0.5,
                Maximum = 3.0,
                Default = GunSilent.Settings.AdvancedSlowVehiclePredictionFactor.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedSlowVehiclePredictionFactor.Value = value
                    notify("GunSilent", "Slow Vehicle Prediction Factor set to: " .. value, false)
                end
            }, 'SlowVehicleMulti')

            uiElements.FastPredictionLimit = UI.Sections.GunSilent:Slider({
                Name = "FastPredictionLimit",
                Minimum = 1.0,
                Maximum = 5.0,
                Default = GunSilent.Settings.AdvancedFastVehiclePredictionLimit.Default,
                Precision = 1,
                Callback = function(value)
                    GunSilent.Settings.AdvancedFastVehiclePredictionLimit.Value = value
                    notify("GunSilent", "Fast Vehicle Prediction Limit set to: " .. value, false)
                end
            }, 'FastPredictionLimit')

            uiElements.PositionHistory = UI.Sections.GunSilent:Slider({
                Name = "Position History",
                Minimum = 2,
                Maximum = 20,
                Default = GunSilent.Settings.AdvancedPositionHistorySize.Default,
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.AdvancedPositionHistorySize.Value = value
                    notify("GunSilent", "Position History Size set to: " .. value, false)
                end
            }, 'PositionHistory')

            uiElements.SmoothingFactor = UI.Sections.GunSilent:Slider({
                Name = "Smoothing Factor",
                Minimum = 0.1,
                Maximum = 0.9,
                Default = GunSilent.Settings.AdvancedSmoothingFactor.Default,
                Precision = 1,
                Callback = function(value)
                    GunSilent.Settings.AdvancedSmoothingFactor.Value = value
                    notify("GunSilent", "Smoothing Factor set to: " .. value, false)
                end
            }, 'SmoothingFactor')

            uiElements.VehicleYCorrection = UI.Sections.GunSilent:Slider({
                Name = "Vehicle Y Correction",
                Minimum = 0,
                Maximum = 5,
                Default = GunSilent.Settings.AdvancedVehicleYCorrection.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.AdvancedVehicleYCorrection.Value = value
                    notify("GunSilent", "Vehicle Y Correction set to: " .. value, false)
                end
            }, 'VehicleYCorrection')

            uiElements.VisualUpdate = UI.Sections.GunSilent:Slider({
                Name = "Visual Update Frequency",
                Minimum = 0.01,
                Maximum = 0.2,
                Default = GunSilent.Settings.VisualUpdateFrequency.Default,
                Precision = 2,
                Callback = function(value)
                    GunSilent.Settings.VisualUpdateFrequency.Value = value
                    notify("GunSilent", "Visual Update Frequency set to: " .. value .. " seconds", false)
                end
            }, 'VisualUpdate')

            uiElements.TeleportSpeed = UI.Sections.GunSilent:Slider({
                Name = "Teleport Speed",
                Minimum = 300,
                Maximum = 1000,
                Default = GunSilent.Settings.AdvancedTeleportThreshold.Default,
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.AdvancedTeleportThreshold.Value = value
                    notify("GunSilent", "Teleport Threshold set to: " .. value, false)
                end
            }, 'TeleportSpeed')

            uiElements.TPLimit = UI.Sections.GunSilent:Slider({
                Name = "TP Limit",
                Minimum = 100,
                Maximum = 500,
                Default = GunSilent.Settings.AdvancedMaxSpeed.Default,
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.AdvancedMaxSpeed.Value = value
                    notify("GunSilent", "Max Speed Limit set to: " .. value, false)
                end
            }, 'TPLimit')

            uiElements.BulletSpeed = UI.Sections.GunSilent:Slider({
                Name = "Bullet Speed",
                Minimum = 500,
                Maximum = 5000,
                Default = GunSilent.Settings.PredictBullet.Default,
                Precision = 0,
                Callback = function(value)
                    GunSilent.Settings.PredictBullet.Value = value
                    notify("GunSilent", "Bullet Speed set to: " .. value, false)
                end
            }, 'BulletSpeed')

            UI.Sections.GunSilent:Button({
                Name = "Sync Settings",
                Callback = function()
                    uiElements.GSEnabled.Callback(uiElements.GSEnabled:GetState())
                    uiElements.RangePlus.Callback(uiElements.RangePlus:GetValue())
                    uiElements.Rage.Callback(uiElements.Rage:GetState())
                    uiElements.DoubleTap.Callback(uiElements.DoubleTap:GetState())
                    local hitPartOptions = uiElements.HitPart:GetOptions()
                    for option, selected in pairs(hitPartOptions) do
                        if selected then
                            uiElements.HitPart.Callback(option)
                            break
                        end
                    end
                    uiElements.FakeDistance.Callback(uiElements.FakeDistance:GetValue())
                    uiElements.ShotgunSupport.Callback(uiElements.ShotgunSupport:GetState())
                    uiElements.GenerateBullets.Callback(uiElements.GenerateBullets:GetValue())
                    uiElements.TestGenerateBullets.Callback(uiElements.TestGenerateBullets:GetState())
                    uiElements.GSUSEFOV.Callback(uiElements.GSUSEFOV:GetState())
                    uiElements.GSFOV.Callback(uiElements.GSFOV:GetValue())
                    uiElements.GSShowCircle.Callback(uiElements.GSShowCircle:GetState())
                    local circleMethodOptions = uiElements.GSCircleMethod:GetOptions()
                    for option, selected in pairs(circleMethodOptions) do
                        if selected then
                            uiElements.GSCircleMethod.Callback(option)
                            break
                        end
                    end
                    uiElements.GSGradientCircle.Callback(uiElements.GSGradientCircle:GetState())
                    uiElements.GSGradientSpeed.Callback(uiElements.GSGradientSpeed:GetValue())
                    local sortMethodOptions = uiElements.SortMethod:GetOptions()
                    for option, selected in pairs(sortMethodOptions) do
                        if selected then
                            uiElements.SortMethod.Callback(option)
                            break
                        end
                    end
                    uiElements.TargetVisual.Callback(uiElements.TargetVisual:GetState())
                    uiElements.HitboxVisual.Callback(uiElements.HitboxVisual:GetState())
                    uiElements.PredictVisual.Callback(uiElements.PredictVisual:GetState())
                    uiElements.ShowDirection.Callback(uiElements.ShowDirection:GetState())
                    uiElements.ShowTrajectory.Callback(uiElements.ShowTrajectory:GetState())
                    uiElements.ShowFullTrajectory.Callback(uiElements.ShowFullTrajectory:GetState())
                    uiElements.TrackTarget.Callback(uiElements.TrackTarget:GetState())
                    uiElements.ChamsColor.Callback(uiElements.ChamsColor:GetValue())
                    uiElements.HitChance.Callback(uiElements.HitChance:GetValue())
                    uiElements.LatencyCompensation.Callback(uiElements.LatencyCompensation:GetValue())
                    uiElements.AdvancedPrediction.Callback(uiElements.AdvancedPrediction:GetState())
                    uiElements.VehicleFactor.Callback(uiElements.VehicleFactor:GetValue())
                    uiElements.PlayerFactor.Callback(uiElements.PlayerFactor:GetValue())
                    uiElements.Agressivness.Callback(uiElements.Agressivness:GetValue())
                    uiElements.LowDistanceMulti.Callback(uiElements.LowDistanceMulti:GetValue())
                    uiElements.SlowVehicleMulti.Callback(uiElements.SlowVehicleMulti:GetValue())
                    uiElements.FastPredictionLimit.Callback(uiElements.FastPredictionLimit:GetValue())
                    uiElements.PositionHistory.Callback(uiElements.PositionHistory:GetValue())
                    uiElements.SmoothingFactor.Callback(uiElements.SmoothingFactor:GetValue())
                    uiElements.VehicleYCorrection.Callback(uiElements.VehicleYCorrection:GetValue())
                    uiElements.VisualUpdate.Callback(uiElements.VisualUpdate:GetValue())
                    uiElements.TeleportSpeed.Callback(uiElements.TeleportSpeed:GetValue())
                    uiElements.TPLimit.Callback(uiElements.TPLimit:GetValue())
                    uiElements.BulletSpeed.Callback(uiElements.BulletSpeed:GetValue())
                    notify("GunSilent", "Settings synchronized with UI!", true)
                end
            }, 'SyncSettings')
        end
    end

    initializeGunSilent()
end

return { Init = Init }
