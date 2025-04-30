local HSCR = {}

-- Настройки CustomCrosshair
local CustomCrosshair = {
    Enabled = false,
    Settings = {
        Style = { Value = "Default", Default = "Default" }, -- Dot, Default
        Size = { Value = 18, Default = 18 },
        Gap = { Value = 5, Default = 5 },
        Length = { Value = 8, Default = 8 },
        DotSize = { Value = 8, Default = 8 },
        DotInnerSize = { Value = 4, Default = 4 },
        DotOutlineThickness = { Value = 2, Default = 2 },
        GradientSpeed = { Value = 2, Default = 2 },
        ExpandDistance = { Value = 0.5, Default = 0.5 },
        ExpandDuration = { Value = 0.15, Default = 0.15 },
        ShrinkDuration = { Value = 0.1, Default = 0.1 },
    },
    OriginalElements = {},
    LastGradientUpdate = 0,
    GradientTime = 0,
}

-- Настройки HeadshotSound
local HeadshotSound = {
    Enabled = false,
    Settings = {
        SelectedSound = { Value = "Default", Default = "Default" },
    },
    SoundOptions = {
        "Default", "KillSound", "Bubble2", "KillSound2", "KillSound3",
        "OUH", "Fart", "PUI", "minecraftEXP", "Minecraft2",
        "TF2 HS", "CriminalityHS", "neverlose", "bameware", "fatality",
        "csgoHS", "PopHS", "BubblePop", "NiggaHS", "IdkHS"
    },
    SoundIds = {},
    OriginalSounds = {},
}

-- Инициализация модуля
function HSCR.Init(UI, Core, notify)
    local Services = Core.Services
    local RunService = Services.RunService
    local SoundService = game:GetService("SoundService")

    -- Получение элементов прицела
    local u5 = require(game.ReplicatedStorage.Modules.Core.UI)
    local crosshairScreenGui = u5.get("CrosshairScreenGui")
    local crosshairFrame = u5.get("CrosshairFrame")
    local bulletsLabel = u5.get("Bullets")
    local frame1 = crosshairFrame.Frame1.ImageLabel
    local frame2 = crosshairFrame.Frame2.ImageLabel

    -- Создание объектов звука
    local headshotSound = Instance.new("Sound")
    headshotSound.SoundId = ""
    headshotSound.Volume = 2.5
    headshotSound.Parent = SoundService

    local headshotNormalSound = Instance.new("Sound")
    headshotNormalSound.SoundId = ""
    headshotNormalSound.Volume = 1
    headshotNormalSound.Parent = SoundService

    local hitSound = Instance.new("Sound")
    hitSound.SoundId = ""
    hitSound.Volume = 1
    hitSound.Parent = SoundService

    -- Функция для обновления дизайна прицела
    local function updateCrosshairDesign()
        if not CustomCrosshair.Enabled then
            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child.Name ~= "Frame1" and child.Name ~= "Frame2" then
                    child:Destroy()
                end
            end
            frame1.Visible = CustomCrosshair.OriginalElements.Frame1Visible or true
            frame2.Visible = CustomCrosshair.OriginalElements.Frame2Visible or true
            crosshairFrame.Size = CustomCrosshair.OriginalElements.Size or UDim2.fromOffset(18, 18)
            return
        end

        for _, child in pairs(crosshairFrame:GetChildren()) do
            if child.Name ~= "Frame1" and child.Name ~= "Frame2" then
                child:Destroy()
            end
        end

        crosshairFrame.Size = UDim2.fromOffset(CustomCrosshair.Settings.Size.Value, CustomCrosshair.Settings.Size.Value)
        crosshairFrame.BackgroundTransparency = 1

        frame1.Visible = false
        frame2.Visible = false

        if CustomCrosshair.Settings.Style.Value == "Dot" then
            local dot = Instance.new("Frame")
            dot.Name = "Dot"
            dot.Size = UDim2.new(0, CustomCrosshair.Settings.DotSize.Value, 0, CustomCrosshair.Settings.DotSize.Value)
            dot.Position = UDim2.new(0.5, -CustomCrosshair.Settings.DotSize.Value / 2, 0.5, -CustomCrosshair.Settings.DotSize.Value / 2)
            dot.BackgroundTransparency = 1
            dot.BorderSizePixel = 0
            dot.Parent = crosshairFrame

            local stroke = Instance.new("UIStroke")
            stroke.Thickness = CustomCrosshair.Settings.DotOutlineThickness.Value
            stroke.Color = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            stroke.Parent = dot

            local gradient = Instance.new("UIGradient")
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
                ColorSequenceKeypoint.new(0.5, Core.GlobalConfigs.GradientColors["Gradient Color 2"]),
                ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
            })
            gradient.Parent = stroke

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = dot

            local innerDot = Instance.new("Frame")
            innerDot.Name = "InnerDot"
            innerDot.Size = UDim2.new(0, CustomCrosshair.Settings.DotInnerSize.Value, 0, CustomCrosshair.Settings.DotInnerSize.Value)
            innerDot.Position = UDim2.new(0.5, -CustomCrosshair.Settings.DotInnerSize.Value / 2, 0.5, -CustomCrosshair.Settings.DotInnerSize.Value / 2)
            innerDot.BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 2"]
            innerDot.BorderSizePixel = 0
            innerDot.Parent = dot

            local innerCorner = Instance.new("UICorner")
            innerCorner.CornerRadius = UDim.new(1, 0)
            innerCorner.Parent = innerDot

            RunService.Heartbeat:Connect(function(deltaTime)
                if not CustomCrosshair.Enabled then return end
                CustomCrosshair.LastGradientUpdate = CustomCrosshair.LastGradientUpdate + deltaTime
                if CustomCrosshair.LastGradientUpdate < 0.1 then return end
                CustomCrosshair.GradientTime = CustomCrosshair.GradientTime + CustomCrosshair.LastGradientUpdate
                CustomCrosshair.LastGradientUpdate = 0
                gradient.Offset = Vector2.new(math.sin(CustomCrosshair.GradientTime * CustomCrosshair.Settings.GradientSpeed.Value) * 0.5, 0)
            end)
        elseif CustomCrosshair.Settings.Style.Value == "Default" then
            local gap = CustomCrosshair.Settings.Gap.Value
            local length = CustomCrosshair.Settings.Length.Value
            local thickness = 2

            local top = Instance.new("Frame")
            top.Name = "Top"
            top.Size = UDim2.new(0, thickness, 0, length)
            top.Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length)
            top.BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            top.BorderSizePixel = 0
            top.Parent = crosshairFrame

            local topGradient = Instance.new("UIGradient")
            topGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
                ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 2"]),
            })
            topGradient.Rotation = 90
            topGradient.Parent = top

            local right = Instance.new("Frame")
            right.Name = "Right"
            right.Size = UDim2.new(0, length, 0, thickness)
            right.Position = UDim2.new(0.5, gap, 0.5, -thickness / 2)
            right.BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            right.BorderSizePixel = 0
            right.Parent = crosshairFrame

            local rightGradient = Instance.new("UIGradient")
            rightGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 2"]),
                ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
            })
            rightGradient.Rotation = 0
            rightGradient.Parent = right

            local bottom = Instance.new("Frame")
            bottom.Name = "Bottom"
            bottom.Size = UDim2.new(0, thickness, 0, length)
            bottom.Position = UDim2.new(0.5, -thickness / 2, 0.5, gap)
            bottom.BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            bottom.BorderSizePixel = 0
            bottom.Parent = crosshairFrame

            local bottomGradient = Instance.new("UIGradient")
            bottomGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 2"]),
                ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
            })
            bottomGradient.Rotation = 90
            bottomGradient.Parent = bottom

            local left = Instance.new("Frame")
            left.Name = "Left"
            left.Size = UDim2.new(0, length, 0, thickness)
            left.Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2)
            left.BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            left.BorderSizePixel = 0
            left.Parent = crosshairFrame

            local leftGradient = Instance.new("UIGradient")
            leftGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Core.GlobalConfigs.GradientColors["Gradient Color 1"]),
                ColorSequenceKeypoint.new(1, Core.GlobalConfigs.GradientColors["Gradient Color 2"]),
            })
            leftGradient.Rotation = 0
            leftGradient.Parent = left

            RunService.Heartbeat:Connect(function(deltaTime)
                if not CustomCrosshair.Enabled then return end
                CustomCrosshair.LastGradientUpdate = CustomCrosshair.LastGradientUpdate + deltaTime
                if CustomCrosshair.LastGradientUpdate < 0.1 then return end
                CustomCrosshair.GradientTime = CustomCrosshair.GradientTime + CustomCrosshair.LastGradientUpdate
                CustomCrosshair.LastGradientUpdate = 0
                local gradientOffset = math.sin(CustomCrosshair.GradientTime * CustomCrosshair.Settings.GradientSpeed.Value) * 0.5
                topGradient.Offset = Vector2.new(0, gradientOffset)
                bottomGradient.Offset = Vector2.new(0, -gradientOffset)
                rightGradient.Offset = Vector2.new(-gradientOffset, 0)
                leftGradient.Offset = Vector2.new(gradientOffset, 0)
            end)
        end
    end

    -- Функция для анимации прицела (pulse)
    local function pulse(scale)
        if not CustomCrosshair.Enabled then return end

        local u4 = require(game.ReplicatedStorage.Modules.Core.Util)
        if CustomCrosshair.Settings.Style.Value == "Dot" then
            local newDotSize = CustomCrosshair.Settings.DotSize.Value * (1 + scale)
            local newInnerDotSize = CustomCrosshair.Settings.DotInnerSize.Value * (1 + scale)
            u4.tween(crosshairFrame.Dot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(newDotSize, newDotSize),
                Position = UDim2.new(0.5, -newDotSize / 2, 0.5, -newDotSize / 2),
            })
            u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(newInnerDotSize, newInnerDotSize),
                Position = UDim2.new(0.5, -newInnerDotSize / 2, 0.5, -newInnerDotSize / 2),
            }).Completed:Wait()
            u4.tween(crosshairFrame.Dot, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CustomCrosshair.Settings.DotSize.Value, CustomCrosshair.Settings.DotSize.Value),
                Position = UDim2.new(0.5, -CustomCrosshair.Settings.DotSize.Value / 2, 0.5, -CustomCrosshair.Settings.DotSize.Value / 2),
            })
            u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CustomCrosshair.Settings.DotInnerSize.Value, CustomCrosshair.Settings.DotInnerSize.Value),
                Position = UDim2.new(0.5, -CustomCrosshair.Settings.DotInnerSize.Value / 2, 0.5, -CustomCrosshair.Settings.DotInnerSize.Value / 2),
            })
        elseif CustomCrosshair.Settings.Style.Value == "Default" then
            local gap = CustomCrosshair.Settings.Gap.Value
            local length = CustomCrosshair.Settings.Length.Value
            local thickness = 2
            local newGap = gap * (1 + scale)
            
            u4.tween(crosshairFrame, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CustomCrosshair.Settings.Size.Value * (1 + scale), CustomCrosshair.Settings.Size.Value * (1 + scale)),
            }).Completed:Wait()
            
            u4.tween(crosshairFrame.Top, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -thickness / 2, 0.5, -newGap - length),
            })
            u4.tween(crosshairFrame.Right, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, newGap, 0.5, -thickness / 2),
            })
            u4.tween(crosshairFrame.Bottom, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -thickness / 2, 0.5, newGap),
            })
            u4.tween(crosshairFrame.Left, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -newGap - length, 0.5, -thickness / 2),
            })

            u4.tween(crosshairFrame, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Size = UDim2.fromOffset(CustomCrosshair.Settings.Size.Value, CustomCrosshair.Settings.Size.Value),
            }).Completed:Wait()
            
            u4.tween(crosshairFrame.Top, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -thickness / 2, 0.5, -gap - length),
            })
            u4.tween(crosshairFrame.Right, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, gap, 0.5, -thickness / 2),
            })
            u4.tween(crosshairFrame.Bottom, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -thickness / 2, 0.5, gap),
            })
            u4.tween(crosshairFrame.Left, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Position = UDim2.new(0.5, -gap - length, 0.5, -thickness / 2),
            })
        end
    end

    -- Функция для изменения цвета прицела (pulse_red)
    local function pulseRed()
        if not CustomCrosshair.Enabled then return end

        local u4 = require(game.ReplicatedStorage.Modules.Core.Util)
        if CustomCrosshair.Settings.Style.Value == "Dot" then
            u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                Color = Core.GlobalConfigs.GradientColors["Gradient Color 2"]
            })
            u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            })
        elseif CustomCrosshair.Settings.Style.Value == "Default" then
            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" then
                    u4.tween(child, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 2"]
                    })
                end
            end
        end

        u4.tween(bulletsLabel, TweenInfo.new(0.08, Enum.EasingStyle.Quad), {
            TextColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 2"]
        }).Completed:Wait()

        if CustomCrosshair.Settings.Style.Value == "Dot" then
            u4.tween(crosshairFrame.Dot.UIStroke, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                Color = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
            })
            u4.tween(crosshairFrame.Dot.InnerDot, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 2"]
            })
        elseif CustomCrosshair.Settings.Style.Value == "Default" then
            for _, child in pairs(crosshairFrame:GetChildren()) do
                if child:IsA("Frame") and child.Name ~= "Frame1" and child.Name ~= "Frame2" then
                    u4.tween(child, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
                        BackgroundColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
                    })
                end
            end
        end

        u4.tween(bulletsLabel, TweenInfo.new(0.05, Enum.EasingStyle.Quad), {
            TextColor3 = Core.GlobalConfigs.GradientColors["Gradient Color 1"]
        })
    end

    -- Инициализация CustomCrosshair
    local function initiateCustomCrosshair()
        CustomCrosshair.OriginalElements.Size = crosshairFrame.Size
        CustomCrosshair.OriginalElements.Frame1Visible = frame1.Visible
        CustomCrosshair.OriginalElements.Frame2Visible = frame2.Visible

        updateCrosshairDesign()

        local u27 = {
            pulse = pulse,
            pulse_red = pulseRed,
            is_reloading = require(game.ReplicatedStorage.Modules.Core.State).new(false),
            reloading_length = require(game.ReplicatedStorage.Modules.Core.State).new(0),
        }

        local u7 = require(game.ReplicatedStorage.Modules.Game.UI.RadialModule)
        local radial = u7.new(crosshairFrame)
        radial:Init()
        radial:SetProgress(100)
        radial:SetProgressColor(Core.GlobalConfigs.GradientColors["Gradient Color 1"])

        u27.is_reloading.hook(function(isReloading)
            if not CustomCrosshair.Enabled then return end
            if isReloading then
                local length = u27.reloading_length.get()
                radial:SetProgress(0)
                radial:TweenProgress(100, length)
            else
                radial:StopAnimating(true)
            end
        end)

        return u27
    end

    -- Инициализация HeadshotSound
    local function initiateHeadshotSound(u27)
        HeadshotSound.OriginalSounds.headshotSound = "rbxassetid://115982072912004"
        HeadshotSound.OriginalSounds.headshotNormalSound = "rbxassetid://135358980250767"
        HeadshotSound.OriginalSounds.hitSound = "rbxassetid://100758444127105"

        local lastHitTime
        u27.hitmarker = function(isHeadshot, isKill)
            print("Hitmarker called - isHeadshot:", isHeadshot, "isKill:", isKill)
            task.defer(function()
                print("Inside task.defer for hitmarker")
                local u7 = require(game.ReplicatedStorage.Modules.Game.UI.RadialModule)
                local radial = u7.new(crosshairFrame)
                print("Radial created")
                radial:SetProgressColor(Core.GlobalConfigs.GradientColors["Gradient Color 2"])
                print("Progress color set")

                if isKill then
                    headshotSound.SoundId = HeadshotSound.Enabled and HeadshotSound.SoundIds[HeadshotSound.Settings.SelectedSound.Value] or HeadshotSound.OriginalSounds.headshotSound
                    print("Playing headshotSound:", headshotSound.SoundId)
                    headshotSound:Play()
                elseif isHeadshot then
                    headshotNormalSound.SoundId = HeadshotSound.Enabled and HeadshotSound.SoundIds[HeadshotSound.Settings.SelectedSound.Value] or HeadshotSound.OriginalSounds.headshotNormalSound
                    print("Playing headshotNormalSound:", headshotNormalSound.SoundId)
                    headshotNormalSound:Play()
                else
                    hitSound.SoundId = HeadshotSound.OriginalSounds.hitSound
                    print("Playing hitSound:", hitSound.SoundId)
                    hitSound:Play()
                end

                local hitTime = os.clock()
                lastHitTime = hitTime
                task.delay(0.2, function()
                    if lastHitTime == hitTime then
                        print("Resetting radial color")
                        radial:SetProgressColor(Core.GlobalConfigs.GradientColors["Gradient Color 1"])
                    end
                end)
            end)
        end

        local u6 = require(game.ReplicatedStorage.Modules.Core.Net)
        u6.hook("hit_confirmed", function(isHeadshot, isKill)
            print("hit_confirmed event fired")
            task.defer(function()
                print("Calling hitmarker in task.defer")
                u27.hitmarker(isHeadshot, isKill)
            end)
        end)
    end

    -- Инициализация
    local u27 = initiateCustomCrosshair()
    initiateHeadshotSound(u27)

    -- Создание UI
    local section = UI.Tabs.Visuals:Section({ Name = "Headshot & Crosshair", Side = "Right" })
    section:Header({ Name = "Custom Crosshair Settings" })
    section:Toggle({
        Name = "Enabled",
        Default = CustomCrosshair.Enabled,
        Callback = function(value)
            CustomCrosshair.Enabled = value
            updateCrosshairDesign()
            print("Notifying Custom Crosshair toggle:", value)
            notify("Custom Crosshair", value and "Enabled" or "Disabled")
        end
    }, "CustomCrosshairEnabled")
    section:Dropdown({
        Name = "Style",
        Options = {"Dot", "Default"},
        Default = CustomCrosshair.Settings.Style.Default,
        Callback = function(value)
            CustomCrosshair.Settings.Style.Value = value
            updateCrosshairDesign()
            print("Notifying Style change:", value)
            notify("Custom Crosshair", "Style set to: " .. value)
        end
    }, "CrosshairStyle")
    section:Slider({
        Name = "Size",
        Minimum = 10,
        Maximum = 30,
        Default = CustomCrosshair.Settings.Size.Default,
        Precision = 0,
        Callback = function(value)
            CustomCrosshair.Settings.Size.Value = value
            updateCrosshairDesign()
            print("Notifying Size change:", value)
            notify("Custom Crosshair", "Size set to: " .. value)
        end
    }, "CrosshairSize")
    section:Slider({
        Name = "Gap (Default Style)",
        Minimum = 2,
        Maximum = 10,
        Default = CustomCrosshair.Settings.Gap.Default,
        Precision = 0,
        Callback = function(value)
            CustomCrosshair.Settings.Gap.Value = value
            updateCrosshairDesign()
            print("Notifying Gap change:", value)
            notify("Custom Crosshair", "Gap set to: " .. value)
        end
    }, "CrosshairGap")
    section:Slider({
        Name = "Length (Default Style)",
        Minimum = 4,
        Maximum = 12,
        Default = CustomCrosshair.Settings.Length.Default,
        Precision = 0,
        Callback = function(value)
            CustomCrosshair.Settings.Length.Value = value
            updateCrosshairDesign()
            print("Notifying Length change:", value)
            notify("Custom Crosshair", "Length set to: " .. value)
        end
    }, "CrosshairLength")
    section:Slider({
        Name = "Gradient Speed",
        Minimum = 0.5,
        Maximum = 5,
        Default = CustomCrosshair.Settings.GradientSpeed.Default,
        Precision = 1,
        Callback = function(value)
            CustomCrosshair.Settings.GradientSpeed.Value = value
            print("Notifying Gradient Speed change:", value)
            notify("Custom Crosshair", "Gradient Speed set to: " .. value)
        end
    }, "CrosshairGradientSpeed")

    section:Header({ Name = "Headshot Hitsound Settings" })
    section:Toggle({
        Name = "Enabled",
        Default = HeadshotSound.Enabled,
        Callback = function(value)
            HeadshotSound.Enabled = value
            print("Notifying Headshot Sound toggle:", value)
            notify("Headshot Sound", value and "Enabled" or "Disabled")
        end
    }, "HeadshotSoundEnabled")
    section:Dropdown({
        Name = "Sound",
        Options = HeadshotSound.SoundOptions,
        Default = HeadshotSound.Settings.SelectedSound.Default,
        Values = {
            "rbxassetid://10476301420", "rbxassetid://132390332380260", "rbxassetid://9086370184",
            "rbxassetid://121311089745141", "rbxassetid://104467173440576", "rbxassetid://7246809481",
            "rbxassetid://5622443597", "rbxassetid://105190141089785", "rbxassetid://1053296915",
            "rbxassetid://135478009117226", "rbxassetid://90342360691837", "rbxassetid://83773429281082",
            "rbxassetid://97643101798871", "rbxassetid://92614567965693", "rbxassetid://115982072912004",
            "rbxassetid://6937353691", "rbxassetid://105543133746827", "rbxassetid://119697580657161",
            "rbxassetid://4868633804", "rbxassetid://102911066745395"
        },
        Callback = function(value, selectedIndex)
            HeadshotSound.Settings.SelectedSound.Value = value
            HeadshotSound.SoundIds[value] = HeadshotSound.SoundOptions[selectedIndex]
            print("Notifying Sound change:", value)
            notify("Headshot Sound", "Selected: " .. value)
        end
    }, "HeadshotSound")
end

return HSCR
