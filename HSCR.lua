local HSCR = {}

local CrosshairSettings = {
    Enabled = false,
    Style = { Value = "Dot", Default = "Dot" },
    Size = { Value = 18, Default = 18 },
    Gap = { Value = 5, Default = 5 },
    Length = { Value = 8, Default = 8 },
    DotSize = { Value = 20, Default = 20 },
    DotInnerSize = { Value = 4, Default = 4 },
    DotOutlineThickness = { Value = 2, Default = 2 },
    GradientColors = {
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0)
    },
    ExpandDistance = { Value = 0.8, Default = 0.8 },
    ExpandDuration = { Value = 0.3, Default = 0.3 },
    ShrinkDuration = { Value = 0.2, Default = 0.2 },
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

function HSCR.Init(UI, Core, notify)
    local TweenService = game:GetService("TweenService")
    local SoundService = game:GetService("SoundService")
    local RunService = game:GetService("RunService")
    local ContentProvider = game:GetService("ContentProvider")

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

    crosshairFrame.AnchorPoint = Vector2.new(0.5, 0.5)

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

    local soundsToPreload = {
        headshotSound.SoundId,
        headshotNormalSound.SoundId,
        hitSound.SoundId
    }
    for _, soundData in ipairs(CrosshairSettings.SoundData) do
        table.insert(soundsToPreload, soundData.SoundId)
    end
    ContentProvider:PreloadAsync(soundsToPreload)

    local AnimationFunctions = {
        pulse = nil,
        pulseRed = nil,
        updateCrosshairDesign = nil
    }

    local gradientConnections = {}

    local hitQueue = {}
    local radial = u7.new(crosshairFrame)
    local lastHitTime
    local isAnimating = false

    local function processHitQueue()
        if #hitQueue == 0 then return end
        if isAnimating then return end

        local hit = table.remove(hitQueue, 1)

        if not crosshairFrame or not crosshairFrame.Parent then
            crosshairFrame = u5.get("CrosshairFrame")
            if not crosshairFrame then return end
            frame1 = crosshairFrame.Frame1.ImageLabel
            frame2 = crosshairFrame.Frame2.ImageLabel
            radial = u7.new(crosshairFrame)
        end

        if CrosshairSettings.Enabled then
            local needsUpdate = false
            if CrosshairSettings.Style.Value == "Dot" then
                if not crosshairFrame:FindFirstChild("Dot") or not crosshairFrame.Dot:FindFirstChild("InnerDot") then
                    needsUpdate = true
                end
            elseif CrosshairSettings.Style.Value == "Default" then
                if not crosshairFrame:FindFirstChild("Top") or not crosshairFrame:FindFirstChild("Right") or
                   not crosshairFrame:FindFirstChild("Bottom") or not crosshairFrame:FindFirstChild("Left") then
                    needsUpdate = true
                end
            end

            if needsUpdate then
                AnimationFunctions.updateCrosshairDesign()
            end

            isAnimating = true
            AnimationFunctions.pulse(CrosshairSettings.ExpandDistance.Value)
            task.delay(CrosshairSettings.ExpandDuration.Value + CrosshairSettings.ShrinkDuration.Value, function()
                isAnimating = false
            end)

            AnimationFunctions.pulseRed()
            radial:SetProgressColor(CrosshairSettings.GradientColors[2])
        end

        local hitTime = os.clock()
        lastHitTime = hitTime
        wait(0.2)
        if lastHitTime == hitTime then
            radial:SetProgressColor(CrosshairSettings.GradientColors[1])
        end
    end

    RunService:BindToRenderStep("ProcessHitQueue", Enum.RenderPriority.Input.Value, processHitQueue)

    local function lerpColor(color1, color2, t)
        return Color3.new(
            color1.R + (color2.R - color1.R) * t,
            color1.G + (color2.G - color1.G) * t,
            color1.B + (color2.B - color1.B) * t
        )
    end

    local function animateColor(element, property, color1, color2, speed, reverse)
        local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        local tween = TweenService:Create(element, tweenInfo, { [property] = reverse and color1 or color2 })
        tween:Play()
        table.insert(gradientConnections, tween)
    end

    local function updateCrosshairDesign()
        for _, connection in pairs(gradientConnections) do
            if typeof(connection) == "Instance" and connection:IsA("Tween") then
                connection:Cancel()
            end
        end
        gradientConnections = {}

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
            stroke.Color = CrosshairSettings.GradientColors[1]
            stroke.Parent = dot

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot

            local innerDot = Instance.new("Frame")
            innerDot.Name = "InnerDot"
            innerDot.Size = UDim2.new(0, CrosshairSettings.DotInnerSize.Value, 0, CrosshairSettings.DotInnerSize.Value)
            innerDot.Position = UDim2.new(0.5, -CrosshairSettings.DotInnerSize.Value / 2, 0.5, -CrosshairSettings.DotInnerSize.Value / 2)
            innerDot.BackgroundColor3 = CrosshairSettings.GradientColors[2]
            innerDot.BorderSizePixel = 0
            innerDot.Parent = dot

            local innerCorner = Instance.new("UICorner")
            innerCorner.CornerRadius = UDim.new(1, 0)
            innerCorner.Parent = innerDot

            animateColor(stroke, "Color", CrosshairSettings.GradientColors[1], CrosshairSettings.GradientColors[2], 1 / CrosshairSettings.GradientSpeed.Value, false)
        elseif CrosshairSettings.Style.Value == "Default" then
            local gap = CrosshairSettings.Gap.Value
            local length = CrosshairSettings.Length.Value
            local thickness = 2

            local top = Instance.new("Frame")
            top.Name = "Top"
            top.Size = UDim2.new(0, thickness, 0, length)
            top.Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length)
            top.BackgroundColor3 = CrosshairSettings.GradientColors[1]
            top.BorderSizePixel = 0
            top.Parent = crosshairFrame

            local right = Instance.new("Frame")
            right.Name = "Right"
            right.Size = UDim2.new(0, length, 0, thickness)
            right.Position = UDim2.new(0.5, gap, 0.5, -thickness / 2)
            right.BackgroundColor3 = CrosshairSettings.GradientColors[1]
            right.BorderSizePixel = 0
            right.Parent = crosshairFrame

            local bottom = Instance.new("Frame")
            bottom.Name = "Bottom"
            bottom.Size = UDim2.new(0, thickness, 0, length)
            bottom.Position = UDim2.new(0.5, -thickness / 2, 0.5, gap)
            bottom.BackgroundColor3 = CrosshairSettings.GradientColors[1]
            bottom.BorderSizePixel = 0
            bottom.Parent = crosshairFrame

            local left = Instance.new("Frame")
            left.Name = "Left"
            left.Size = UDim2.new(0, length, 0, thickness)
            left.Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2)
            left.BackgroundColor3 = CrosshairSettings.GradientColors[1]
            left.BorderSizePixel = 0
            left.Parent = crosshairFrame

            animateColor(top, "BackgroundColor3", CrosshairSettings.GradientColors[1], CrosshairSettings.GradientColors[2], 1 / CrosshairSettings.GradientSpeed.Value, false)
            animateColor(right, "BackgroundColor3", CrosshairSettings.GradientColors[1], CrosshairSettings.GradientColors[2], 1 / CrosshairSettings.GradientSpeed.Value, false)
            animateColor(bottom, "BackgroundColor3", CrosshairSettings.GradientColors[1], CrosshairSettings.GradientColors[2], 1 / CrosshairSettings.GradientSpeed.Value, true)
            animateColor(left, "BackgroundColor3", CrosshairSettings.GradientColors[1], CrosshairSettings.GradientColors[2], 1 / CrosshairSettings.GradientSpeed.Value, true)
        end
    end

    local function pulse(scale)
        if not CrosshairSettings.Enabled then return end
        if not crosshairFrame or not crosshairFrame.Parent then return end

        u4.tween(crosshairFrame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {
            Rotation = crosshairFrame.Rotation + 360
        })

        if CrosshairSettings.Style.Value == "Dot" then
            if not crosshairFrame:FindFirstChild("Dot") or not crosshairFrame.Dot:FindFirstChild("InnerDot") then return end

            local newDotSize = CrosshairSettings.DotSize.Value * (1 + scale)
            local newInnerDotSize = CrosshairSettings.DotInnerSize.Value * (1 + scale)

            if crosshairFrame.Dot and crosshairFrame.Dot.Parent then
                u4.tween(crosshairFrame.Dot, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(newDotSize, newDotSize),
                    Position = UDim2.new(0.5, -newDotSize / 2, 0.5, -newDotSize / 2),
                })
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Size = UDim2.fromOffset(newInnerDotSize, newInnerDotSize),
                    Position = UDim2.new(0.5, -newInnerDotSize / 2, 0.5, -newInnerDotSize / 2),
                })
            end

            task.delay(CrosshairSettings.ExpandDuration.Value, function()
                if crosshairFrame and crosshairFrame.Parent and crosshairFrame.Dot and crosshairFrame.Dot.Parent then
                    u4.tween(crosshairFrame.Dot, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Size = UDim2.fromOffset(CrosshairSettings.DotSize.Value, CrosshairSettings.DotSize.Value),
                        Position = UDim2.new(0.5, -CrosshairSettings.DotSize.Value / 2, 0.5, -CrosshairSettings.DotSize.Value / 2),
                    })
                end
                if crosshairFrame and crosshairFrame.Parent and crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                    u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Size = UDim2.fromOffset(CrosshairSettings.DotInnerSize.Value, CrosshairSettings.DotInnerSize.Value),
                        Position = UDim2.new(0.5, -CrosshairSettings.DotInnerSize.Value / 2, 0.5, -CrosshairSettings.DotInnerSize.Value / 2),
                    })
                end
            end)
        elseif CrosshairSettings.Style.Value == "Default" then
            if not crosshairFrame:FindFirstChild("Top") or not crosshairFrame:FindFirstChild("Right") or
               not crosshairFrame:FindFirstChild("Bottom") or not crosshairFrame:FindFirstChild("Left") then return end

            local gap = CrosshairSettings.Gap.Value
            local length = CrosshairSettings.Length.Value
            local thickness = 2
            local newGap = gap * (1 + scale)

            u4.tween(crosshairFrame, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = UDim2.fromOffset(CrosshairSettings.Size.Value * (1 + scale), CrosshairSettings.Size.Value * (1 + scale)),
            })

            if crosshairFrame.Top and crosshairFrame.Top.Parent then
                u4.tween(crosshairFrame.Top, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, -newGap - length),
                })
            end
            if crosshairFrame.Right and crosshairFrame.Right.Parent then
                u4.tween(crosshairFrame.Right, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, newGap, 0.5, -thickness / 2),
                })
            end
            if crosshairFrame.Bottom and crosshairFrame.Bottom.Parent then
                u4.tween(crosshairFrame.Bottom, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -thickness / 2, 0.5, newGap),
                })
            end
            if crosshairFrame.Left and crosshairFrame.Left.Parent then
                u4.tween(crosshairFrame.Left, TweenInfo.new(CrosshairSettings.ExpandDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0.5, -newGap - length, 0.5, -thickness / 2),
                })
            end

            task.delay(CrosshairSettings.ExpandDuration.Value, function()
                if not crosshairFrame or not crosshairFrame.Parent then return end

                u4.tween(crosshairFrame, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                    Size = UDim2.fromOffset(CrosshairSettings.Size.Value, CrosshairSettings.Size.Value),
                })

                if crosshairFrame.Top and crosshairFrame.Top.Parent then ?\n                    u4.tween(crosshairFrame.Top, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length),
                    })
                end
                if crosshairFrame.Right and crosshairFrame.Right.Parent then
                    u4.tween(crosshairFrame.Right, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, gap, 0.5, -thickness / 2),
                    })
                end
                if crosshairFrame.Bottom and crosshairFrame.Bottom.Parent then
                    u4.tween(crosshairFrame.Bottom, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -thickness / 2, 0.5, gap),
                    })
                end
                if crosshairFrame.Left and crosshairFrame.Left.Parent then
                    u4.tween(crosshairFrame.Left, TweenInfo.new(CrosshairSettings.ShrinkDuration.Value, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2),
                    })
                end
            end)
        end
    end

    local function pulseRed()
        if not CrosshairSettings.Enabled then return end
        if not crosshairFrame or not crosshairFrame.Parent then return end

        if CrosshairSettings.Style.Value == "Dot" then
            if not crosshairFrame:FindFirstChild("Dot") or not crosshairFrame.Dot:FindFirstChild("UIStroke") or
               not crosshairFrame.Dot:FindFirstChild("InnerDot") then return end

            if crosshairFrame.Dot and crosshairFrame.Dot.UIStroke and crosshairFrame.Dot.UIStroke.Parent then
                u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                    Color = CrosshairSettings.GradientColors[2]
                })
            end
            if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = CrosshairSettings.GradientColors[1]
                })
            end
        elseif CrosshairSettings.Style.Value == "Default" then
            if not crosshairFrame:FindFirstChild("Top") or not crosshairFrame:FindFirstChild("Right") or
               not crosshairFrame:FindFirstChild("Bottom") or not crosshairFrame:FindFirstChild("Left") then return end

            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" and child.Parent then
                    u4.tween(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = CrosshairSettings.GradientColors[2]
                    })
                end
            end
        end

        if not bulletsLabel or not bulletsLabel.Parent then return end
        u4.tween(bulletsLabel, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            TextColor3 = CrosshairSettings.GradientColors[2]
        })

        task.delay(0.08, function()
            if not crosshairFrame or not crosshairFrame.Parent then return end

            if CrosshairSettings.Style.Value == "Dot" then
                if crosshairFrame.Dot and crosshairFrame.Dot.UIStroke and crosshairFrame.Dot.UIStroke.Parent then
                    u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        Color = CrosshairSettings.GradientColors[1]
                    })
                end
                if crosshairFrame.Dot and crosshairFrame.Dot.InnerDot and crosshairFrame.Dot.InnerDot.Parent then
                    u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = CrosshairSettings.GradientColors[2]
                    })
                end
            elseif CrosshairSettings.Style.Value == "Default" then
                for _, child in pairs(crosshairFrame:GetChildren()) do
                    if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" and child.Parent then
                        u4.tween(child, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                            BackgroundColor3 = CrosshairSettings.GradientColors[1]
                        })
                    end
                end
            end

            if bulletsLabel and bulletsLabel.Parent then
                u4.tween(bulletsLabel, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                    TextColor3 = CrosshairSettings.GradientColors[1]
                })
            end
        end)
    end

    AnimationFunctions.updateCrosshairDesign = updateCrosshairDesign
    AnimationFunctions.pulse = pulse
    AnimationFunctions.pulseRed = pulseRed

    local function initiate()
        CrosshairSettings.OriginalElements.Size = crosshairFrame.Size
        CrosshairSettings.OriginalElements.Frame1Visible = frame1 and frame1.Visible
        CrosshairSettings.OriginalElements.Frame2Visible = frame2 and frame2.Visible

        AnimationFunctions.updateCrosshairDesign()

        local u27 = {
            pulse = AnimationFunctions.pulse,
            pulse_red = AnimationFunctions.pulseRed,
            is_reloading = v3.new(false),
            reloading_length = v3.new(0),
        }

        if radial and radial.Init then
            radial:Init()
            radial:SetProgress(100)
            radial:SetProgressColor(CrosshairSettings.GradientColors[1])
        end

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
            if isKill then
                local selectedSoundId = CrosshairSettings.SoundIds[CrosshairSettings.SelectedSound.Value] or CrosshairSettings.OriginalSounds.headshotSound
                headshotSound.SoundId = CrosshairSettings.HeadshotSoundEnabled and selectedSoundId or CrosshairSettings.OriginalSounds.headshotSound
                headshotSound:Play()
            elseif isHeadshot then
                headshotNormalSound.SoundId = CrosshairSettings.OriginalSounds.headshotNormalSound
                headshotNormalSound:Play()
            else
                hitSound.SoundId = CrosshairSettings.OriginalSounds.hitSound
                hitSound:Play()
            end

            table.insert(hitQueue, { isHeadshot = isHeadshot, isKill = isKill })
        end

        u6.hook("hit_confirmed", function(isHeadshot, isKill)
            u27.hitmarker(isHeadshot, isKill)
        end)
    end

    initiate()

    task.defer(function()
        local section = UI.Tabs.Visuals:Section({ Name = "Custom Crosshair & Hitsound", Side = "Right" })
        section:Header({ Name = "Crosshair Settings" })
        section:Toggle({
            Name = "Enabled",
            Default = CrosshairSettings.Enabled,
            Callback = function(value)
                CrosshairSettings.Enabled = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CustomCrosshairEnabled")

        section:Dropdown({
            Name = "Style",
            Options = {"Dot", "Default"},
            Default = CrosshairSettings.Style.Default,
            Callback = function(value)
                CrosshairSettings.Style.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairStyle")

        section:Slider({
            Name = "Size",
            Minimum = 10,
            Maximum = 30,
            Default = CrosshairSettings.Size.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Size.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairSize")

        section:Slider({
            Name = "Gap (Default Style)",
            Minimum = 2,
            Maximum = 10,
            Default = CrosshairSettings.Gap.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Gap.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairGap")

        section:Slider({
            Name = "Length (Default Style)",
            Minimum = 4,
            Maximum = 12,
            Default = CrosshairSettings.Length.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.Length.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairLength")

        section:Slider({
            Name = "Dot Size (Dot Style)",
            Minimum = 10,
            Maximum = 30,
            Default = CrosshairSettings.DotSize.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotSize.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairDotSize")

        section:Slider({
            Name = "Dot Inner Size (Dot Style)",
            Minimum = 2,
            Maximum = 10,
            Default = CrosshairSettings.DotInnerSize.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotInnerSize.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairDotInnerSize")

        section:Slider({
            Name = "Dot Outline Thickness (Dot Style)",
            Minimum = 1,
            Maximum = 5,
            Default = CrosshairSettings.DotOutlineThickness.Default,
            Precision = 0,
            Callback = function(value)
                CrosshairSettings.DotOutlineThickness.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairDotOutlineThickness")

        section:Slider({
            Name = "Gradient Speed",
            Minimum = 0.5,
            Maximum = 5,
            Default = CrosshairSettings.GradientSpeed.Default,
            Precision = 1,
            Callback = function(value)
                CrosshairSettings.GradientSpeed.Value = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "CrosshairGradientSpeed")

        section:Slider({
            Name = "Expand Distance",
            Minimum = 0.1,
            Maximum = 1,
            Default = CrosshairSettings.ExpandDuration.Value,
            Precision = 1,
            Callback = function(value)
                CrosshairSettings.ExpandDistance.Value = value
            end
        }, "CrosshairExpandDistance")

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

        section:Colorpicker({
            Name = "Gradient Color 1",
            Default = CrosshairSettings.GradientColors[1],
            Callback = function(value)
                CrosshairSettings.GradientColors[1] = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "GradientColor1")

        section:Colorpicker({
            Name = "Gradient Color 2",
            Default = CrosshairSettings.GradientColors[2],
            Callback = function(value)
                CrosshairSettings.GradientColors[2] = value
                AnimationFunctions.updateCrosshairDesign()
            end
        }, "GradientColor2")

        section:Header({ Name = "Hitsound Settings" })

        section:Toggle({
            Name = "Enable Hitsound",
            Default = CrosshairSettings.HeadshotSoundEnabled,
            Callback = function(value)
                CrosshairSettings.HeadshotSoundEnabled = value
            end
        }, "HeadshotSoundEnabled")

        local soundOptions = {}
        for _, sound in ipairs(CrosshairSettings.SoundData) do
            table.insert(soundOptions, sound.Label)
        end

        section:Dropdown({
            Name = "Sound",
            Options = soundOptions,
            Default = CrosshairSettings.SelectedSound.Default,
            Callback = function(value)
                if value and type(value) == "string" then
                    for _, sound in ipairs(CrosshairSettings.SoundData) do
                        if sound.Label == value then
                            CrosshairSettings.SelectedSound.Value = value
                            CrosshairSettings.SoundIds[value] = sound.SoundId
                            break
                        end
                    end
                end
            end
        }, "HeadshotSound")
    end)
end

return HSCR
