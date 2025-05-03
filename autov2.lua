-- AutoV2.lua
local AutoV2 = {}

-- Module configuration
AutoV2.Config = {
    PickupMinDistance = 20, -- Default pickup radius
    PickupEnabled = false,
    DropEnabled = false,
    UseKeybind = false,
    DropKeybind = Enum.KeyCode.F,
    ItemsToDrop = {
        ["shiesty"] = true,
        ["hacktoolbasic"] = true,
        ["bottle"] = true,
        ["spray can"] = true,
        ["jar"] = true,
        ["bowling pin"] = true
    },
    ReloadEnabled = false
}

-- Module initialization
function AutoV2.Init(UI, Core, notify)
    local Players = Core.Services.Players
    local ReplicatedStorage = Core.Services.ReplicatedStorage
    local UserInputService = Core.Services.UserInputService
    local LocalPlayer = Core.PlayerData.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local Get = Remotes:WaitForChild("Get")
    local Send = Remotes:WaitForChild("Send")

    -- Cache v_u_4 for function increment
    local v_u_4
    for _, obj in pairs(getgc(true)) do
        if type(obj) == "table" and not getmetatable(obj) and obj.event and obj.func and type(obj.event) == "number" and type(obj.func) == "number" then
            v_u_4 = obj
            break
        end
    end
    if not v_u_4 then
        warn("[AutoV2] Failed to find v_u_4 table for event_id")
        return
    end

    -- Cache gun items and item names
    local gunItems = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")
    local itemNames = {}
    for _, categoryName in pairs({"ammo", "gun", "melee", "money"}) do
        local category = ReplicatedStorage:WaitForChild("Items"):FindFirstChild(categoryName)
        if category then
            for _, item in pairs(category:GetChildren()) do
                itemNames[item.Name] = true
            end
        end
    end
    if not next(itemNames) then
        warn("[AutoV2] No item names found in ReplicatedStorage.Items")
        return
    end

    -- Variables
    local currentWeapon = nil
    local character = nil
    local pickupRunning = false
    local dropRunning = false
    local reloadRunning = false

    -- Utility functions
    local function getRootPart()
        local char = LocalPlayer.Character
        if not char then
            char = LocalPlayer.CharacterAdded:Wait()
        end
        return char:WaitForChild("HumanoidRootPart")
    end

    local function updateCurrentWeapon()
        if not character then return end
        currentWeapon = nil
        for i = 1, 3 do
            for _, child in pairs(character:GetChildren()) do
                if child.ClassName == "Tool" then
                    currentWeapon = child
                    print("[AutoReload] Updated weapon:", child.Name)
                    return
                end
            end
            if not currentWeapon then
                print("[AutoReload] Weapon not found, retrying... (Attempt", i, "of 3)")
                task.wait(0.2)
            end
        end
        warn("[AutoReload] Failed to find weapon after 3 attempts")
    end

    local function isFirearm(weapon)
        if not weapon then return false end
        return gunItems:FindFirstChild(weapon.Name) ~= nil
    end

    local function getCurrentAmmoFromUI()
        if not UI or not UI.get then
            warn("[AutoReload] UI module or get function is unavailable")
            return nil
        end
        local bulletsLabel = UI.get("Bullets")
        if bulletsLabel and bulletsLabel.Text then
            local current = tonumber(bulletsLabel.Text:match("^(%d+)/"))
            if current then
                print("[AutoReload] Current ammo from UI:", current)
                return current
            end
        end
        warn("[AutoReload] Failed to get current ammo from UI (bulletsLabel or Text is nil)")
        return nil
    end

    local function sendReloadEvent(weapon)
        v_u_4.func = v_u_4.func + 1
        local args = {
            [1] = v_u_4.func,
            [2] = "reload_gun",
            [3] = weapon
        }
        local success, newAmmo = pcall(function()
            return Get:InvokeServer(unpack(args))
        end)
        if success and newAmmo then
            print("[AutoReload] Reload successful, new ammo count:", newAmmo)
            local bulletsLabel = UI.get("Bullets")
            if bulletsLabel then
                local magSize = weapon:GetAttribute("MagSize") or 0
                bulletsLabel.Text = string.format("%d/%d", newAmmo, magSize)
                print("[AutoReload] Updated Bullets UI to:", bulletsLabel.Text)
                local ItemUtils = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Game"):WaitForChild("Inventory"):WaitForChild("ItemUtils"))
                local Data = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("Data"))
                local itemInfo = ItemUtils.get_item_info(Data, weapon:GetAttribute("ItemGUID"))
                if itemInfo then
                    itemInfo.ammo_amount = newAmmo
                end
            else
                warn("[AutoReload] Bullets UI element not found")
            end
        else
            warn("[AutoReload] Failed to reload or get new ammo count")
        end
    end

    local function findNearestDroppedItem()
        local rootPart = getRootPart()
        local nearestItem = nil
        local minDistance = AutoV2.Config.PickupMinDistance
        for _, item in pairs(Workspace:WaitForChild("DroppedItems"):GetChildren()) do
            if item.ClassName == "Model" and itemNames[item.Name] then
                local primaryPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local distance = (rootPart.Position - primaryPart.Position).Magnitude
                    if distance <= minDistance then
                        nearestItem = item
                        minDistance = distance
                    end
                end
            end
        end
        return nearestItem
    end

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

    local function findInventory()
        local itemsFrame = PlayerGui:FindFirstChild("Items")
        if not itemsFrame then return nil end
        local itemsHolder = itemsFrame:FindFirstChild("ItemsHolder")
        if not itemsHolder then return nil end
        return itemsHolder:FindFirstChild("ItemsScrollingFrame")
    end

    local function parseInventoryData()
        local inventory = findInventory()
        if not inventory then return nil, nil end
        local guids = {}
        local itemsToDrop = {}
        for _, item in pairs(inventory:GetChildren()) do
            local itemNameObj = item:FindFirstChild("ItemName")
            if not itemNameObj or not itemNameObj:IsA("TextLabel") then
                -- Пропускаем итерацию вместо continue
            else
                local itemName = string.lower(itemNameObj.Text or "Unknown")
                local guid = item.Name
                local itemCountObj = item:FindFirstChild("ItemCount")
                local itemCount = itemCountObj and itemCountObj:IsA("TextLabel") and tonumber(itemCountObj.Text:match("%d+")) or 1
                if guid and AutoV2.Config.ItemsToDrop[itemName] then
                    table.insert(guids, guid)
                    table.insert(itemsToDrop, {GUID = guid, Item = item, Name = itemName, Count = itemCount})
                    if item:IsA("GuiObject") then
                        item.BackgroundTransparency = 1
                        item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        item.BorderSizePixel = 0
                        item.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    end
                end
            end
        end
        return guids, itemsToDrop
    end

    local function dropItems(itemsToDrop)
        if not itemsToDrop or #itemsToDrop == 0 then return false end
        for _, itemData in pairs(itemsToDrop) do
            v_u_4.event = v_u_4.event + 1
            local args = {
                [1] = v_u_4.event,
                [2] = "drop_item",
                [3] = itemData.GUID,
                [4] = itemData.Count
            }
            pcall(function()
                Send:FireServer(unpack(args))
            end)
        end
        return true
    end

    local function executeDrop()
        local guids, itemsToDrop = parseInventoryData()
        if guids and itemsToDrop and dropItems(itemsToDrop) then
            notify("Auto Drop", "Items dropped successfully!", true)
        end
    end

    -- Main functions
    local function startAutoPickup()
        if pickupRunning then return end
        pickupRunning = true
        spawn(function()
            while pickupRunning do
                local nearestItem = findNearestDroppedItem()
                if nearestItem then
                    pickupDroppedItem(nearestItem)
                end
                task.wait(0.1) -- Увеличена задержка для снижения нагрузки
            end
        end)
    end

    local function stopAutoPickup()
        pickupRunning = false
    end

    local function startAutoDrop()
        if dropRunning then return end
        dropRunning = true
        spawn(function()
            while dropRunning do
                if not AutoV2.Config.UseKeybind then
                    executeDrop()
                end
                task.wait(2) -- Увеличена задержка для снижения нагрузки
            end
        end)
    end

    local function stopAutoDrop()
        dropRunning = false
    end

    local function startAutoReload()
        if reloadRunning then return end
        reloadRunning = true
        spawn(function()
            while reloadRunning do
                if currentWeapon and isFirearm(currentWeapon) then
                    local currentAmmo = getCurrentAmmoFromUI()
                    if currentAmmo and currentAmmo <= 0 then
                        sendReloadEvent(currentWeapon)
                    end
                else
                    updateCurrentWeapon()
                end
                task.wait(0.5) -- Оставляем как есть для быстрой реакции
            end
        end)
    end

    local function stopAutoReload()
        reloadRunning = false
    end

    -- Event handlers
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        updateCurrentWeapon()
        if AutoV2.Config.ReloadEnabled then
            startAutoReload()
        end
    end)

    if LocalPlayer.Character then
        character = LocalPlayer.Character
        updateCurrentWeapon()
        if AutoV2.Config.ReloadEnabled then
            startAutoReload()
        end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == AutoV2.Config.DropKeybind and not gameProcessedEvent and AutoV2.Config.UseKeybind and AutoV2.Config.DropEnabled then
            task.spawn(executeDrop)
        end
    end)

    -- UI setup
    if UI and UI.Tabs.Auto then
        local autoPickupSection = UI.Tabs.Auto:Section({ Name = "AutoPickup", Side = "Right" })
        autoPickupSection:Header({ Name = "AutoPickup" })
        autoPickupSection:Toggle({
            Name = "Enabled",
            Default = AutoV2.Config.PickupEnabled,
            Callback = function(value)
                AutoV2.Config.PickupEnabled = value
                if value then
                    startAutoPickup()
                    notify("Auto Pickup", "Auto-pickup enabled!", true)
                else
                    stopAutoPickup()
                    notify("Auto Pickup", "Auto-pickup disabled!", true)
                end
            end
        })
        autoPickupSection:Slider({
            Name = "Pickup Radius",
            Default = AutoV2.Config.PickupMinDistance,
            Minimum = 5,
            Maximum = 50,
            Precision = 1,
            Callback = function(value)
                AutoV2.Config.PickupMinDistance = value
                notify("Auto Pickup", "Pickup radius set to " .. value .. " meters!", true)
            end
        })

        local autoDropSection = UI.Tabs.Auto:Section({ Name = "AutoDrop", Side = "Left" })
        autoDropSection:Header({ Name = "AutoDrop" })
        autoDropSection:Toggle({
            Name = "Enabled",
            Default = AutoV2.Config.DropEnabled,
            Callback = function(value)
                AutoV2.Config.DropEnabled = value
                if value then
                    startAutoDrop()
                    notify("Auto Drop", "Auto-drop enabled!", true)
                else
                    stopAutoDrop()
                    notify("Auto Drop", "Auto-drop disabled!", true)
                end
            end
        })
        autoDropSection:Toggle({
            Name = "Use Keybind",
            Default = AutoV2.Config.UseKeybind,
            Callback = function(value)
                AutoV2.Config.UseKeybind = value
                if value then
                    notify("Auto Drop", "Keybind mode enabled!", true)
                else
                    notify("Auto Drop", "Keybind mode disabled!", true)
                end
            end
        })
        autoDropSection:Keybind({
            Name = "Drop Keybind",
            Default = AutoV2.Config.DropKeybind,
            Callback = function(value)
                AutoV2.Config.DropKeybind = value
            end
        })
        autoDropSection:Dropdown({
            Name = "Items to Drop",
            Multi = true,
            Options = {"shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin", "bike lock", "bronze mop", "chair leg", "metal pipe", "mop", "pool cue", "rolling pin", "shank", "silver mop", "taser", "wooden board", "bandage", "bull energy", "lockpick", "dice", "brick", "cinder block", "dumbbel plate", "glass", "milkshake", "rock", "soda can"},
            Default = {"shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin"},
            Callback = function(value)
                for key in pairs(AutoV2.Config.ItemsToDrop) do
                    AutoV2.Config.ItemsToDrop[key] = nil
                end
                for item, isSelected in pairs(value) do
                    if isSelected then
                        AutoV2.Config.ItemsToDrop[item] = true
                    end
                end
                notify("Auto Drop", "Items to drop updated!", true)
            end
        })

        local autoReloadSection = UI.Tabs.Auto:Section({ Name = "AutoReload", Side = "Right" })
        autoReloadSection:Header({ Name = "AutoReload" })
        autoReloadSection:Toggle({
            Name = "Enabled",
            Default = AutoV2.Config.ReloadEnabled,
            Callback = function(value)
                AutoV2.Config.ReloadEnabled = value
                if value then
                    startAutoReload()
                    notify("Auto Reload", "Auto-reload enabled!", true)
                else
                    stopAutoReload()
                    notify("Auto Reload", "Auto-reload disabled!", true)
                end
            end
        })
    end
end

return AutoV2
