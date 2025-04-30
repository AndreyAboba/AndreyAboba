local HSCR = {}

-- Настройки для кастомного прицела и хитсаунда
local CrosshairSettings = {
    Enabled = false,
    Style = { Value = "Dot", Default = "Dot" }, -- Dot, Default
    Size = { Value = 18, Default = 18 },
    Gap = { Value = 5, Default = 5 },
    Length = { Value = 8, Default = 8 },
    DotSize = { Value = 20, Default = 20 },
    DotInnerSize = { Value = 4, Default = 4 },
    DotOutlineThickness = { Value = 2, Default = 2 },
    BaseColor = { Value = Color3.fromRGB(255, 255, 255), Default = Color3.fromRGB(255, 255, 255) },
    HitColor = { Value = Color3.fromRGB(255, 0, 0), Default = Color3.fromRGB(255, 0, 0) },
    ExpandDistance = { Value = 0.5, Default = 0.5 },
    ExpandDuration = { Value = 0.15, Default = 0.15 },
    ShrinkDuration = { Value = 0.1, Default = 0.1 },
    GradientSpeed = { Value = 2, Default = 2 },
    HeadshotSoundEnabled = false,
    SelectedSound = { Value = "Default", Default = "Default" },
    SoundData = {
        { Label = "Default", SoundId = "rbxassetid://10476301420" },
        { Label = "KillSound", SoundId = "rbxassetid://132390332380260" },
        { Label = "Bubble2", SoundId = "rbxassetid://9086370184" },
        { Label = "KillSound2", SoundId = "rbxassetid://121311089745141" },
        { Label = "KillSound3", SoundId = "rbxassetid://104467173440576" },
        { Label = "OUH", SoundId = "rbxassetid://7246809481" },
        { Label = "Fart", SoundId = "rbxassetid://5622443597" },
        { Label = "PUI", SoundId = "rbxassetid://105190141089785" },
        { Label = "minecraftEXP", SoundId = "rbxassetid://1053296915" },
        { Label = "Minecraft2", SoundId = "rbxassetid://135478009117226" },
        { Label = "TF2 HS", SoundId = "rbxassetid://90342360691837" },
        { Label = "CriminalityHS", SoundId = "rbxassetid://83773429281082" },
        { Label = "neverlose", SoundId = "rbxassetid://97643101798871" },
        { Label = "bameware", SoundId = "rbxassetid://92614567965693" },
        { Label = "fatality", SoundId = "rbxassetid://115982072912004" },
        { Label = "csgoHS", SoundId = "rbxassetid://6937353691" },
        { Label = "PopHS", SoundId = "rbxassetid://105543133746827" },
        { Label = "BubblePop", SoundId = "rbxassetid://119697580657161" },
        { Label = "NiggaHS", SoundId = "rbxassetid://4868633804" },
        { Label = "IdkHS", SoundId = "rbxassetid://102911066745395" },
    },
    SoundIds = {},
    OriginalSounds = {
        headshotSound = "rbxassetid://115982072912004",
        headshotNormalSound = "rbxassetid://135358980250767",
        hitSound = "rbxassetid://100758444127105"
    },
    OriginalElements = {}
}

-- Инициализация модуля
function HSCR.Init(UI, Core, notify)
    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")
    local RunService = game:GetService("RunService")

    -- Получение элементов прицела
    local u5 = require(game.ReplicatedStorage.Modules.Core.UI)
    local u4 = require(game.ReplicatedStorage.Modules.Core.Util)
    local u6 = require(game.ReplicatedStorage.Modules.Core.Net)
    local u7 = require(game.ReplicatedStorage.Modules.Game.UI.RadialModule)
    local v3 = require(game.ReplicatedStorage.Modules.Core.State)

    local crosshairScreenGui = u5.get("CrosshairScreenGui")
    local crosshairFrame = u5.get("CrosshairFrame")
    local bulletsLabel = u5.get("Bullets")
    local frame1 = crosshairFrame and crosshairFrame.Frame1 and crosshairFrame.Frame1.ImageLabel
    local frame2 = crosshairFrame and crosshairFrame.Frame2 and crosshairFrame.Frame2.ImageLabel

    -- Проверка на существование crosshairFrame
    if not crosshairFrame then
        warn("CrosshairFrame not found, attempting to wait for it")
        local attempts = 0
        while not crosshairFrame and attempts < 10 do
            wait(1)
            crosshairFrame = u5.get("CrosshairFrame")
            attempts = attempts + 1
        end
        if not crosshairFrame then
            error("Failed to initialize: CrosshairFrame not found after 10 seconds")
            return
        end
        frame1 = crosshairFrame.Frame1.ImageLabel
        frame2 = crosshairFrame.Frame2.ImageLabel
    end

    -- Создание объектов звука
    local headshotSound = Instance.new("Sound")
    headshotSound.SoundId = CrosshairSettings.OriginalSounds.headshotSound
    headshotSound.Volume = 2.5
    headshotSound.Parent = SoundService

    local headshotNormalSound = Instance.new("Sound")
    headshotNormalSound.SoundId = CrosshairSettings.OriginalSounds.headshotNormalSound
    headshotNormalSound.Volume = 1
    headshotNormalSound.Parent = SoundService

    local hitSound = Instance.new("Sound")
    hitSound.SoundId = CrosshairSettings.OriginalSounds.hitSound
    hitSound.Volume = 1
    hitSound.Parent = SoundService

    -- Очередь для обработки hitmarker в главном потоке
    local hitQueue = {}
    local radial = u7.new(crosshairFrame)
    local lastHitTime

    local function processHitQueue()
        if #hitQueue == 0 then return end
        local hit = table.remove(hitQueue, 1)
        local isHeadshot, isKill = hit.isHeadshot, hit.isKill

        print("Processing hitmarker in main thread - isHeadshot:", isHeadshot, "isKill:", isKill)

        -- Проверка на существование crosshairFrame
        if not crosshairFrame or not crosshairFrame.Parent then
            warn("CrosshairFrame is nil or destroyed, attempting to reinitialize")
            crosshairFrame = u5.get("CrosshairFrame")
            if not crosshairFrame then
                warn("Failed to reinitialize CrosshairFrame")
                return
            end
            frame1 = crosshairFrame.Frame1.ImageLabel
            frame2 = crosshairFrame.Frame2.ImageLabel
            radial = u7.new(crosshairFrame)
        end

        -- Вызов анимаций
        if CrosshairSettings.Enabled then
            print("CrosshairFrame exists:", crosshairFrame ~= nil)
            print("Attempting to call updateCrosshairDesign before animations")
            updateCrosshairDesign() -- Гарантируем, что элементы прицела созданы
            print("Attempting to call pulse and pulseRed")
            pulse(CrosshairSettings.ExpandDistance.Value)
            pulseRed()
            if radial and radial.SetProgressColor then
                print("Setting radial progress color")
                radial:SetProgressColor(CrosshairSettings.HitColor.Value)
            else
                warn("Radial is nil or SetProgressColor is not a function")
            end
        end

        -- Воспроизведение звука
        if isKill then
            local selectedSoundId = CrosshairSettings.SoundIds[CrosshairSettings.SelectedSound.Value] or CrosshairSettings.OriginalSounds.headshotSound
            headshotSound.SoundId = CrosshairSettings.HeadshotSoundEnabled and selectedSoundId or CrosshairSettings.OriginalSounds.headshotSound
            print("Playing headshotSound (Kill):", headshotSound.SoundId)
            headshotSound:Play()
        elseif isHeadshot then
            headshotNormalSound.SoundId = CrosshairSettings.OriginalSounds.headshotNormalSound
            print("Playing headshotNormalSound:", headshotNormalSound.SoundId)
            headshotNormalSound:Play()
        else
            hitSound.SoundId = CrosshairSettings.OriginalSounds.hitSound
            print("Playing hitSound:", hitSound.SoundId)
            hitSound:Play()
        end

        local hitTime = os.clock()
        lastHitTime = hitTime
        wait(0.2)
        if lastHitTime == hitTime then
            print("Resetting radial color")
            if radial and radial.SetProgressColor then
                radial:SetProgressColor(CrosshairSettings.BaseColor.Value)
            else
                warn("Radial is nil or SetProgressColor is not a function during reset")
            end
        end
    end

    -- Привязка к главному потоку через BindToRenderStep
    RunService:BindToRenderStep("ProcessHitQueue", Enum.RenderPriority.Last.Value, processHitQueue)

    -- Функция для обновления дизайна прицела
    local function updateCrosshairDesign()
        print("Updating crosshair design - Enabled:", CrosshairSettings.Enabled)
        print("CrosshairFrame exists:", crosshairFrame ~= nil)
        if not crosshairFrame or not crosshairFrame.Parent then
            warn("CrosshairFrame is nil or destroyed during updateCrosshairDesign")
            return
        end
        for _, child in pairs(crosshairFrame:GetChildren()) do
            if child.Name ~= "Frame1" and child.Name ~= "Frame2" then
                child:Destroy()
            end
        end

        if not CrosshairSettings.Enabled then
            if frame1 then frame1.Visible = CrosshairSettings.OriginalElements.Frame1Visible or true end
            if frame2 then frame2.Visible = CrosshairSettings.OriginalElements.Frame2Visible or true end
            crosshairFrame.Size = CrosshairSettings.OriginalElements.Size or UDim2.fromOffset(18, 18)
            return
        end

        crosshairFrame.Size = UDim2.fromOffset(CrosshairSettings.Size.Value, CrosshairSettings.Size.Value)
        crosshairFrame.BackgroundTransparency = 1

        if frame1 then frame1.Visible = false end
        if frame2 then frame2.Visible = false end

        if CrosshairSettings.Style.Value == "Dot" then
            local dot = Instance.new("Frame")
            dot.Name = "Dot"
            dot.Size = UDim2.new(0, CrosshairSettings.DotSize.Value, 0, CrosshairSettings.DotSize.Value)
            dot.Position = UDim2.new(0.5, -CrosshairSettings.DotSize.Value / 2, 0.5, -CrosshairSettings.DotSize.Value / 2)
            dot.BackgroundTransparency = 1
            dot.BorderSizePixel = 0
            dot.Parent = crosshairFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = CrosshairSettings.DotOutlineThickness.Value
            stroke.Color = CrosshairSettings.BaseColor.Value
            stroke.Parent = dot

            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CrosshairSettings.BaseColor.Value),
                ColorSequenceKeypoint.new(0.5, CrosshairSettings.HitColor.Value),
                ColorSequenceKeypoint.new(1, CrosshairSettings.BaseColor.Value),
            })
            gradient.Parent = stroke

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot

            local innerDot = Instance.new("Frame")
            innerDot.Name = "InnerDot"
            innerDot.Size = UDim2.new(0, CrosshairSettings.DotInnerSize.Value, 0, CrosshairSettings.DotInnerSize.Value)
            innerDot.Position = UDim2.new(0.5, -CrosshairSettings.DotInnerSize.Value / 2, 0.5, -CrosshairSettings.DotInnerSize.Value / 2)
            innerDot.BackgroundColor3 = CrosshairSettings.HitColor.Value
            innerDot.BorderSizePixel = 0
            innerDot.Parent = dot

            local innerCorner = Instance.new("UICorner")
            innerCorner.CornerRadius = UDim.new(1, 0)
            innerCorner.Parent = innerDot

            local tweenInfo = TweenInfo.new(
                CrosshairSettings.GradientSpeed.Value,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true
            )
            local tween = TweenService:Create(gradient, tweenInfo, { Offset = Vector2.new(0.5, 0) })
            tween:Play()

            print("Dot created:", dot ~= nil, "InnerDot created:", innerDot ~= nil)
        elseif CrosshairSettings.Style.Value == "Default" then
            local gap = CrosshairSettings.Gap.Value
            local length = CrosshairSettings.Length.Value
            local thickness = 2

            local top = Instance.new("Frame")
            top.Name = "Top"
            top.Size = UDim2.new(0, thickness, 0, length)
            top.Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length)
            top.BackgroundColor3 = CrosshairSettings.BaseColor.Value
            top.BorderSizePixel = 0
            top.Parent = crosshairFrame

            local topGradient = Instance.new("UIGradient")
            topGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CrosshairSettings.BaseColor.Value),
                ColorSequenceKeypoint.new(1, CrosshairSettings.HitColor.Value),
            })
            topGradient.Rotation = 90
            topGradient.Parent = top

            local right = Instance.new("Frame")
            right.Name = "Right"
            right.Size = UDim2.new(0, length, 0, thickness)
            right.Position = UDim2.new(0.5, gap, 0.5, -thickness / 2)
            right.BackgroundColor3 = CrosshairSettings.BaseColor.Value
            top.BorderSizePixel = 0
            right.Parent = crosshairFrame

            local rightGradient = Instance.new("UIGradient")
            rightGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CrosshairSettings.HitColor.Value),
                ColorSequenceKeypoint.new(1, CrosshairSettings.BaseColor.Value),
            })
            rightGradient.Rotation = 0
            rightGradient.Parent = right

            local bottom = Instance.new("Frame")
            bottom.Name = "Bottom"
            bottom.Size = UDim2.new(0, thickness, 0, length)
            bottom.Position = UDim2.new(0.5, -thickness / 2, 0.5, gap)
            bottom.BackgroundColor3 = CrosshairSettings.BaseColor.Value
            bottom.BorderSizePixel = 0
            bottom.Parent = crosshairFrame

            local bottomGradient = Instance.new("UIGradient")
            bottomGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CrosshairSettings.HitColor.Value),
                ColorSequenceKeypoint.new(1, CrosshairSettings.BaseColor.Value),
            })
            bottomGradient.Rotation = 90
            bottomGradient.Parent = bottom

            local left = Instance.new("Frame")
            left.Name = "Left"
            left.Size = UDim2.new(0, length, 0, thickness)
            left.Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2)
            left.BackgroundColor3 = CrosshairSettings.BaseColor.Value
            left.BorderSizePixel = 0
            left.Parent = crosshairFrame

            local leftGradient = Instance.new("UIGradient")
            leftGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, CrosshairSettings.BaseColor.Value),
                ColorSequenceKeypoint.new(1, CrosshairSettings.HitColor.Value),
            })
            leftGradient.Rotation = 0
            leftGradient.Parent = left

            local tweenInfo = TweenInfo.new(
                CrosshairSettings.GradientSpeed.Value,
                Enum.EasingStyle.Sine,
                Enum.EasingDirection.InOut,
                -1,
                true
            )
            local topTween = TweenService:Create(topGradient, tweenInfo, { Offset = Vector2.new(0, 0.5) })
            local bottomTween = TweenService:Create(bottomGradient, tweenInfo, { Offset = Vector2.new(0, -0.5) })
            local rightTween = TweenService:Create(rightGradient, tweenInfo, { Offset = Vector2.new(-0.5, 0) })
            local leftTween = TweenService:Create(leftGradient, tweenInfo, { Offset = Vector2.new(0.5, 0) })
            topTween:Play()
            bottomTween:Play()
            rightTween:Play()
            leftTween:Play()

            print("Default style elements created - Top:", top ~= nil, "Right:", right ~= nil, "Bottom:", bottom ~= nil, "Left:", left ~= nil)
        end
    end

    -- Функция для анимации прицела (pulse)
    local function pulse(scale)
        if not CrosshairSettings.Enabled then
            print("Pulse skipped: Crosshair not enabled")
            return
        end

        if not crosshairFrame or not crosshairFrame.Parent then
            print("Pulse failed: CrosshairFrame is nil or destroyed")
            return
        end

        if CrosshairSettings.Style.Value == "Dot" then
            if not crosshairFrame:FindFirstChild("Dot") or not crosshairFrame.Dot:FindFirstChild("InnerDot") then
                print("Pulse failed: Dot or InnerDot not found")
                return
            end
            local newDotSize = CrosshairSettings.DotSize.Value * (1 + scale)
            local newInnerDotSize = CrosshairSettings.DotInnerSize.Value * (1 + scale)
            print("Animating Dot - New size:", newDotSize, "New inner size:", newInnerDotSize)
            if crosshairFrame.Dot and crosshairFrame.Dot.Parent then
                u4.tween(crosshairFrame.Dot, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(newDotSize, newDotSize),
                    Position = UDim2.new(0.5, -newDotSize / 2, 0.5, -newDotSize / 2),
                })
            else
                print("Dot is nil or destroyed during animation")
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(newInnerDotSize, newInnerDotSize),
                    Position = UDim2.new(0.5, -newInnerDotSize / 2, 0.5, -newInnerDotSize / 2),
                }).Completed:Wait()
            else
                print("InnerDot is nil or destroyed during animation")
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.Parent then
                u4.tween(crosshairFrame.Dot, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(CrosshairSettings.DotSize.Value, CrosshairSettings.DotSize.Value),
                    Position = UDim2.new(0.5, -CrosshairSettings.DotSize.Value / 2, 0.5, -CrosshairSettings.DotSize.Value / 2),
                })
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Size = UDim2.fromOffset(CrosshairSettings.DotInnerSize.Value, CrosshairSettings.DotInnerSize.Value),
                    Position = UDim2.new(0.5, -CrosshairSettings.DotInnerSize.Value / 2, 0.5, -CrosshairSettings.DotInnerSize.Value / 2),
                })
            end
        elseif CrosshairSettings.Style.Value == "Default" then
            if not crosshairFrame:FindFirstChild("Top") or not crosshairFrame:FindFirstChild("Right") or
               not crosshairFrame:FindFirstChild("Bottom") or not crosshairFrame:FindFirstChild("Left") then
                print("Pulse failed: Default style elements (Top, Right, Bottom, Left) not found")
                return
            end
            local gap = CrosshairSettings.Gap.Value
            local length = CrosshairSettings.Length.Value
            local thickness = 2
            local newGap = gap * (1 + scale)
            print("Animating Default style - New gap:", newGap)

            u4.tween(crosshairFrame, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CrosshairSettings.Size.Value * (1 + scale), CrosshairSettings.Size.Value * (1 + scale)),
            }).Completed:Wait()

            if crosshairFrame.Top and crosshairFrame.Top.Parent then
                u4.tween(crosshairFrame.Top, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, -newGap - length),
                })
            end
            if crosshairFrame.Right and crosshairFrame.Right.Parent then
                u4.tween(crosshairFrame.Right, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, newGap, 0.5, -thickness / 2),
                })
            end
            if crosshairFrame.Bottom and crosshairFrame.Bottom.Parent then
                u4.tween(crosshairFrame.Bottom, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, newGap),
                })
            end
            if crosshairFrame.Left and crosshairFrame.Left.Parent then
                u4.tween(crosshairFrame.Left, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -newGap - length, 0.5, -thickness / 2),
                })
            end

            u4.tween(crosshairFrame, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CrosshairSettings.Size.Value, CrosshairSettings.Size.Value),
            }).Completed:Wait()

            if crosshairFrame.Top and crosshairFrame.Top.Parent then
                u4.tween(crosshairFrame.Top, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length),
                })
            end
            if crosshairFrame.Right and crosshairFrame.Right.Parent then
                u4.tween(crosshairFrame.Right, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, gap, 0.5, -thickness / 2),
                })
            end
            if crosshairFrame.Bottom and crosshairFrame.Bottom.Parent then
                u4.tween(crosshairFrame.Bottom, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, gap),
                })
            end
            if crosshairFrame.Left and crosshairFrame.Left.Parent then
                u4.tween(crosshairFrame.Left, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Quad), {
                    Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2),
                })
            end
        end
    end

    -- Функция для изменения цвета прицела (pulseRed)
    local function pulseRed()
        if not CrosshairSettings.Enabled then
            print("PulseRed skipped: Crosshair not enabled")
            return
        end

        if not crosshairFrame or not crosshairFrame.Parent then
            print("PulseRed failed: CrosshairFrame is nil or destroyed")
            return
        end

        if CrosshairSettings.Style.Value == "Dot" then
            if not crosshairFrame:FindFirstChild("Dot") or not crosshairFrame.Dot:FindFirstChild("UIStroke") or
               not crosshairFrame.Dot:FindFirstChild("InnerDot") then
                print("PulseRed failed: Dot, UIStroke, or InnerDot not found")
                return
            end
            print("Animating Dot color change")
            if crosshairFrame.Dot and crosshairFrame.Dot.UIStroke and crosshairFrame.Dot.UIStroke.Parent then
                u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                    Color = CrosshairSettings.HitColor.Value
                })
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CrosshairSettings.BaseColor.Value
                })
            end
        elseif CrosshairSettings.Style.Value == "Default" then
            if not crosshairFrame:FindFirstChild("Top") or not crosshairFrame:FindFirstChild("Right") or
               not crosshairFrame:FindFirstChild("Bottom") or not crosshairFrame:FindFirstChild("Left") then
                print("PulseRed failed: Default style elements (Top, Right, Bottom, Left) not found")
                return
            end
            print("Animating Default style color change")
            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" and child.Parent then
                    u4.tween(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = CrosshairSettings.HitColor.Value
                    })
                end
            end
        end

        if not bulletsLabel or not bulletsLabel.Parent then
            print("PulseRed failed: bulletsLabel not found or destroyed")
            return
        end
        print("Animating bulletsLabel color change")
        u4.tween(bulletsLabel, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            TextColor3 = CrosshairSettings.HitColor.Value
        }).Completed:Wait()

        if CrosshairSettings.Style.Value == "Dot" then
            if crosshairFrame.Dot and crosshairFrame.Dot.UIStroke and crosshairFrame.Dot.UIStroke.Parent then
                u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    Color = CrosshairSettings.BaseColor.Value
                })
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CrosshairSettings.HitColor.Value
                })
            end
        elseif CrosshairSettings.Style.Value == "Default" then
            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" and child.Parent then
                    u4.tween(child, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = CrosshairSettings.BaseColor.Value
                    })
                end
            end
        end

        u4.tween(bulletsLabel, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
            TextColor3 = CrosshairSettings.BaseColor.Value
        })
    end

    -- Инициализация прицела и хитсаунда
    local function initiate()
        CrosshairSettings.OriginalElements.Size = crosshairFrame.Size
        CrosshairSettings.OriginalElements.Frame1Visible = frame1 and frame1.Visible
        CrosshairSettings.OriginalElements.Frame2Visible = frame2 and frame2.Visible

        updateCrosshairDesign()

        local u27 = {
            pulse = pulse,
            pulse_red = pulseRed,
            is_reloading = v3.new(false),
            reloading_length = v3.new(0),
        }

        -- Настройка радиального индикатора
        if radial and radial.Init then
            radial:Init()
            radial:SetProgress(100)
            radial:SetProgressColor(CrosshairSettings.BaseColor.Value)
        else
            warn("Radial is nil or Init is not a function")
        end

        -- Хук для перезарядки
        u27.is_reloading.hook(function(isReloading)
            if not CrosshairSettings.Enabled then return end
            if isReloading then
                local length = u27.reloading_length.get()
                if radial and radial.SetProgress and radial.TweenProgress then
                    radial:SetProgress(0)
                    radial:TweenProgress(100, length)
                end
            else
                if radial and radial.StopAnimating then
                    radial:StopAnimating(true)
                end
            end
        end)

        u27.hitmarker = function(isHeadshot, isKill)
            print("Hitmarker called - isHeadshot:", isHeadshot, "isKill:", isKill)
            table.insert(hitQueue, { isHeadshot = isHeadshot, isKill = isKill })
        end

        u6.hook("hit_confirmed", function(isHeadshot, isKill)
            print("hit_confirmed event fired - isHeadshot:", isHeadshot, "isKill:", isKill)
            u27.hitmarker(isHeadshot, isKill)
        end)
    end

    -- Вызов инициализации
    initiate()

    -- Создание UI в главном потоке
    task.defer(function()
        print("Starting UI creation in main thread")
        local section = UI.Tabs.Visuals:Section({ Name = "Custom Crosshair & Hitsound", Side = "Right" })
        section:Header({ Name = "Crosshair Settings" })
        print("Adding Toggle: Enabled")
        section:Toggle({
            Name = "Enabled",
            Default = CrosshairSettings.Enabled,
            Callback = function(value)
                CrosshairSettings.Enabled = value
                updateCrosshairDesign()
            end
        }, "CustomCrosshairEnabled")

        print("Adding Dropdown: Style")
        section:Dropdown({
            Name = "Style",
            Options = {"Dot", "Default"},
            Default = CrosshairSettings.Style.Default,
            Callback = function(value)
                CrosshairSettings.Style.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairStyle")

        print("Adding Slider: Size")
        section:Slider({
            Name = "Size",
            Minimum = 10,
            Maximum = 30,
            Default = CrosshairSettings.Size.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Size.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairSize")

        print("Adding Slider: Gap (Default Style)")
        section:Slider({
            Name = "Gap (Default Style)",
            Minimum = 2,
            Maximum = 10,
            Default = CrosshairSettings.Gap.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Gap.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairGap")

        print("Adding Slider: Length (Default Style)")
        section:Slider({
            Name = "Length (Default Style)",
            Minimum = 4,
            Maximum = 12,
            Default = CrosshairSettings.Length.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Length.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairLength")

        print("Adding Slider: Dot Size (Dot Style)")
        section:Slider({
            Name = "Dot Size (Dot Style)",
            Minimum = 10,
            Maximum = 30,
            Default = CrosshairSettings.DotSize.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotSize.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairDotSize")

        print("Adding Slider: Dot Inner Size (Dot Style)")
        section:Slider({
            Name = "Dot Inner Size (Dot Style)",
            Minimum = 2,
            Maximum = 10,
            Default = CrosshairSettings.DotInnerSize.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotInnerSize.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairDotInnerSize")

        print("Adding Slider: Dot Outline Thickness (Dot Style)")
        section:Slider({
            Name = "Dot Outline Thickness (Dot Style)",
            Minimum = 1,
            Maximum = 5,
            Default = CrosshairSettings.DotOutlineThickness.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotOutlineThickness.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairDotOutlineThickness")

        print("Adding Slider: Gradient Speed")
        section:Slider({
            Name = "Gradient Speed",
            Minimum = 0.5,
            Maximum = 5,
            Default = CrosshairSettings.GradientSpeed.Default,
            Precision = 1,
            Callback = function(value)
                CrosshairSettings.GradientSpeed.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairGradientSpeed")

        print("Adding Slider: Expand Distance")
        section:Slider({
            Name = "Expand Distance",
            Minimum = 0.1,
            Maximum = 1,
            Default = CrosshairSettings.ExpandDistance.Default,
            Precision = 1,
            Callback = function(value)
                CrosshairSettings.ExpandDistance.Value = value
            end
        }, "CrosshairExpandDistance")

        print("Adding Slider: Expand Duration")
        section:Slider({
            Name = "Expand Duration",
            Minimum = 0.05,
            Maximum = 0.5,
            Default = CrosshairSettings.ExpandDuration.Default,
            Precision = 2,
            Callback = function(value)
                CrosshairSettings.ExpandDuration.Value = value
            end
        }, "CrosshairExpandDuration")

        print("Adding Slider: Shrink Duration")
        section:Slider({
            Name = "Shrink Duration",
            Minimum = 0.05,
            Maximum = 0.5,
            Default = CrosshairSettings.ShrinkDuration.Default,
            Precision = 2,
            Callback = function(value)
                CrosshairSettings.ShrinkDuration.Value = value
            end
        }, "CrosshairShrinkDuration")

        print("Adding Colorpicker: Base Color")
        section:Colorpicker({
            Name = "Base Color",
            Default = CrosshairSettings.BaseColor.Default,
            Callback = function(value)
                CrosshairSettings.BaseColor.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairBaseColor")

        print("Adding Colorpicker: Hit Color")
        section:Colorpicker({
            Name = "Hit Color",
            Default = CrosshairSettings.HitColor.Default,
            Callback = function(value)
                CrosshairSettings.HitColor.Value = value
                updateCrosshairDesign()
            end
        }, "CrosshairHitColor")

        print("Adding Header: Hitsound Settings")
        section:Header({ Name = "Hitsound Settings" })

        print("Adding Toggle: Enable Hitsound")
        section:Toggle({
            Name = "Enable Hitsound",
            Default = CrosshairSettings.HeadshotSoundEnabled,
            Callback = function(value)
                CrosshairSettings.HeadshotSoundEnabled = value
            end
        }, "HeadshotSoundEnabled")

        -- Создаём список опций для дропдауна из SoundData
        local soundOptions = {}
        for _, sound in ipairs(CrosshairSettings.SoundData) do
            table.insert(soundOptions, sound.Label)
        end

        print("Adding Dropdown: Sound")
        section:Dropdown({
            Name = "Sound",
            Options = soundOptions,
            Default = CrosshairSettings.SelectedSound.Default,
            Callback = function(value)
                -- Получаем текущие опции через GetOptions
                local options = section:GetOptions()
                print("Dropdown options:", options)

                -- Ищем выбранную опцию (где значение true)
                local selectedSound = nil
                for option, isSelected in pairs(options) do
                    if isSelected then
                        selectedSound = option
                        break
                    end
                end

                if selectedSound then
                    CrosshairSettings.SelectedSound.Value = selectedSound
                    -- Находим соответствующий SoundId
                    for _, sound in ipairs(CrosshairSettings.SoundData) do
                        if sound.Label == selectedSound then
                            CrosshairSettings.SoundIds[selectedSound] = sound.SoundId
                            break
                        end
                    end
                    print("Selected sound:", selectedSound, "SoundId:", CrosshairSettings.SoundIds[selectedSound])
                else
                    warn("No sound selected in dropdown!")
                end
            end
        }, "HeadshotSound")

        print("UI creation completed")
    end)
end

return HSCR
