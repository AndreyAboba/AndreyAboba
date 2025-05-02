-- AutoV2.lua
local AutoV2 = {}

-- Конфигурация модуля
AutoV2.Config = {
    MinDistance = 20, -- Радиус подбора по умолчанию
    Enabled = false -- Флаг включения/выключения
}

-- Инициализация модуля
function AutoV2.Init(UI, Core, notify)
    local Players = Core.Services.Players
    local Workspace = Core.Services.Workspace
    local ReplicatedStorage = Core.Services.ReplicatedStorage
    local LocalPlayer = Core.PlayerData.LocalPlayer
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local Get = Remotes:WaitForChild("Get")

    -- Кэшируем v_u_4 для func
    local v_u_4
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and not getmetatable(obj) and obj.event and obj.func and type(obj.event) == "number" and type(obj.func) == "number" then
            v_u_4 = obj
            break
        end
    end

    if not v_u_4 then
        return
    end

    -- Кэшируем DroppedItems
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then
        return
    end

    -- Функция для получения текущего rootPart
    local function getRootPart()
        local character = LocalPlayer.Character
        if not character then
            character = LocalPlayer.CharacterAdded:Wait()
        end
        return character:WaitForChild("HumanoidRootPart")
    end

    local rootPart = getRootPart()
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        rootPart = newCharacter:WaitForChild("HumanoidRootPart")
    end)

    -- Функция для получения списка названий предметов из ReplicatedStorage.Items
    local function getItemNames()
        local itemsFolder = ReplicatedStorage:FindFirstChild("Items")
        if not itemsFolder then
            return {}
        end

        local itemNames = {}
        local categories = {"ammo", "gun", "melee", "money"}
        for _, categoryName in ipairs(categories) do
            local category = itemsFolder:FindFirstChild(categoryName)
            if category then
                for _, item in ipairs(category:GetChildren()) do
                    if item:IsA("StringValue") or item:IsA("ObjectValue") then
                        itemNames[item.Value or item.Name] = true
                    else
                        itemNames[item.Name] = true
                    end
                end
            end
        end
        return itemNames
    end

    -- Кэшируем имена предметов
    local itemNames = getItemNames()
    if next(itemNames) == nil then
        return
    end

    -- Функция для поиска ближайшего предмета
    local function findNearestDroppedItem()
        local currentRootPart = getRootPart() -- Динамическая проверка rootPart
        if not currentRootPart then return nil end

        local nearestItem = nil
        local minDistance = AutoV2.Config.MinDistance
        local rootPosition = currentRootPart.Position

        for _, item in ipairs(droppedItems:GetChildren()) do
            if item.ClassName == "Model" and itemNames[item.Name] then
                local primaryPart = item:FindFirstChild("PrimaryPart") or item:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local distance = (rootPosition - primaryPart.Position).Magnitude
                    if distance <= minDistance then
                        nearestItem = item
                        minDistance = distance
                    end
                end
            end
        end
        return nearestItem
    end

    -- Функция для отправки запроса на подбор предмета
    local function pickupDroppedItem(item)
        v_u_4.func = v_u_4.func + 1
        local args = {
            [1] = v_u_4.func,
            [2] = "pickup_dropped_item",
            [3] = item
        }

        pcall(function()
            Get:InvokeServer(unpack(args))
        end)
    end

    -- Функция автоматического подбора
    local running = false
    local function startAutoPickup()
        if running then return end
        running = true
        spawn(function()
            while running do
                local nearestItem = findNearestDroppedItem()
                if nearestItem then
                    pickupDroppedItem(nearestItem)
                end
                task.wait(0.03)
            end
        end)
    end

    local function stopAutoPickup()
        running = false
    end

    -- Настройка UI
    if UI and UI.Sections.AutoInteract then
        UI.Sections.AutoInteract:Toggle({
            Name = "Auto Pickup",
            Default = AutoV2.Config.Enabled,
            Callback = function(value)
                AutoV2.Config.Enabled = value
                if value then
                    startAutoPickup()
                    notify("Auto Pickup", "Включён автоматический подбор предметов!", false)
                else
                    stopAutoPickup()
                    notify("Auto Pickup", "Выключён автоматический подбор предметов!", false)
                end
            end
        })

        UI.Sections.AutoInteract:Slider({
            Name = "Pickup Radius",
            Default = AutoV2.Config.MinDistance,
            Minimum = 5,
            Maximum = 50,
            Callback = function(value)
                AutoV2.Config.MinDistance = value
                notify("Auto Pickup", "Радиус подбора установлен на " .. value .. " метров!", false)
            end
        })
    end
end

return AutoV2
