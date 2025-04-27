-- UILib.lua: Библиотека для создания UI-элементов (toggle, dropdown, multi-toggle)

-- Зависимости: требуется TweenService для анимаций
local TweenService = game:GetService("TweenService")

-- Основной объект библиотеки
local UILib = {}

-- Функция для создания Toggle (переключателя)
function UILib:CreateToggle(parent, name, default, callback)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ToggleFrame.BackgroundTransparency = 0.3
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

    local ToggleLabel = Instance.new("TextLabel", ToggleFrame)
    ToggleLabel.Size = UDim2.new(1, -60, 0, 20)
    ToggleLabel.Position = UDim2.new(0, 5, 0, 10)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Enum.Font.Montserrat
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleSwitch = Instance.new("Frame", ToggleFrame)
    ToggleSwitch.Size = UDim2.new(0, 40, 0, 20)
    ToggleSwitch.Position = UDim2.new(1, -45, 0, 10)
    ToggleSwitch.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", ToggleSwitch).CornerRadius = UDim.new(1, 0)

    local ToggleIndicator = Instance.new("Frame", ToggleSwitch)
    ToggleIndicator.Size = UDim2.new(0, 20, 0, 20)
    ToggleIndicator.Position = default and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)
    ToggleIndicator.BackgroundColor3 = default and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
    Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(1, 0)

    ToggleSwitch.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local newValue = not default
            default = newValue
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = newValue and UDim2.new(1, -20, 0, 0) or UDim2.new(0, 0, 0, 0)}):Play()
            ToggleIndicator.BackgroundColor3 = newValue and Color3.fromRGB(70, 130, 255) or Color3.fromRGB(80, 80, 80)
            if callback then callback(newValue) end
        end
    end)

    return ToggleFrame
end

-- Функция для создания Dropdown (выпадающего списка)
function UILib:CreateDropdown(parent, name, options, default, callback)
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(1, -20, 0, 40)
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DropdownFrame.BackgroundTransparency = 0.3
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)

    local DropdownLabel = Instance.new("TextLabel", DropdownFrame)
    DropdownLabel.Size = UDim2.new(1, -60, 0, 20)
    DropdownLabel.Position = UDim2.new(0, 15, 0, 10) -- Сдвигаем правее: с 5 до 15 пикселей
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = name .. " : " -- Добавляем двоеточие и пробел
    DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Enum.Font.Montserrat
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

    local DropdownButton = Instance.new("TextButton", DropdownFrame)
    DropdownButton.Size = UDim2.new(0, 100, 0, 20)
    DropdownButton.Position = UDim2.new(1, -105, 0, 10)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    DropdownButton.Text = default or options[1]
    DropdownButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    DropdownButton.TextSize = 14
    DropdownButton.Font = Enum.Font.Montserrat
    Instance.new("UICorner", DropdownButton).CornerRadius = UDim.new(0, 4)

    local DropdownList = Instance.new("Frame", DropdownFrame)
    DropdownList.Size = UDim2.new(0, 100, 0, 0)
    DropdownList.Position = UDim2.new(1, -105, 0, 30)
    DropdownList.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    DropdownList.BackgroundTransparency = 0.3
    DropdownList.Visible = false
    Instance.new("UICorner", DropdownList).CornerRadius = UDim.new(0, 4)

    local ListLayout = Instance.new("UIListLayout", DropdownList)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)

    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton", DropdownList)
        OptionButton.Size = UDim2.new(1, 0, 0, 20)
        OptionButton.BackgroundTransparency = 1
        OptionButton.Text = option
        OptionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        OptionButton.TextSize = 14
        OptionButton.Font = Enum.Font.Montserrat
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = option
            DropdownList.Visible = false
            DropdownList.Size = UDim2.new(0, 100, 0, 0)
            if callback then callback(option) end
        end)
    end

    DropdownList.Size = UDim2.new(0, 100, 0, #options * 22)

    DropdownButton.MouseButton1Click:Connect(function()
        DropdownList.Visible = not DropdownList.Visible
        DropdownList.Size = DropdownList.Visible and UDim2.new(0, 100, 0, #options * 22) or UDim2.new(0, 100, 0, 0)
    end)

    return DropdownFrame
end

-- Функция для создания Multi-Toggle (переключателя с несколькими опциями)
function UILib:CreateMultiToggle(parent, name, options, default, callback)
    local MultiToggleFrame = Instance.new("Frame", parent)
    MultiToggleFrame.Size = UDim2.new(1, -20, 0, 40)
    MultiToggleFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    MultiToggleFrame.BackgroundTransparency = 0.3
    Instance.new("UICorner", MultiToggleFrame).CornerRadius = UDim.new(0, 6)

    local MultiToggleLabel = Instance.new("TextLabel", MultiToggleFrame)
    MultiToggleLabel.Size = UDim2.new(1, -90, 0, 20)
    MultiToggleLabel.Position = UDim2.new(0, 5, 0, 10)
    MultiToggleLabel.BackgroundTransparency = 1
    MultiToggleLabel.Text = name
    MultiToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MultiToggleLabel.TextSize = 14
    MultiToggleLabel.Font = Enum.Font.Montserrat
    MultiToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ToggleFrame = Instance.new("Frame", MultiToggleFrame)
    ToggleFrame.Size = UDim2.new(0, #options * 40, 0, 20)
    ToggleFrame.Position = UDim2.new(1, -5 - #options * 40, 0, 10)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(1, 0)

    local ToggleIndicator = Instance.new("Frame", ToggleFrame)
    ToggleIndicator.Size = UDim2.new(0, 40, 0, 20)
    local defaultIndex = 1
    for i, option in ipairs(options) do
        if option == default then defaultIndex = i end
    end
    ToggleIndicator.Position = UDim2.new(0, (defaultIndex - 1) * 40, 0, 0)
    ToggleIndicator.BackgroundColor3 = Color3.fromRGB(70, 130, 255)
    Instance.new("UICorner", ToggleIndicator).CornerRadius = UDim.new(1, 0)

    local ToggleText = Instance.new("TextLabel", ToggleFrame)
    ToggleText.Size = UDim2.new(1, 0, 1, 0)
    ToggleText.BackgroundTransparency = 1
    ToggleText.Text = default
    ToggleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleText.TextSize = 14
    ToggleText.Font = Enum.Font.Montserrat
    ToggleText.TextXAlignment = Enum.TextXAlignment.Center

    ToggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = input.Position.X - ToggleFrame.AbsolutePosition.X
            local index = math.floor(mousePos / 40) + 1
            if index < 1 then index = 1 end
            if index > #options then index = #options end
            local newValue = options[index]
            TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {Position = UDim2.new(0, (index - 1) * 40, 0, 0)}):Play()
            ToggleText.Text = newValue
            if callback then callback(newValue) end
        end
    end)

    return MultiToggleFrame
end

-- Возвращаем библиотеку для использования
return UILib
