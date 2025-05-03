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
        if type(obj) == "table" and not getmetatable(obj) and obj.event and obj.func then
            v_u_4 = obj
            break
        end
    end
    if not v_u_4 then return end

    -- Cache gun items and item names
    local gunItems = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")
    local itemNames = {}
    for _, category in pairs({"ammo", "gun", "melee", "money"}) do
        local categoryFolder = ReplicatedStorage:WaitForChild("Items"):FindFirstChild(category)
        if categoryFolder then
            for _, item in pairs(categoryFolder:GetChildren()) do
                itemNames[item.Name] = true
            end
        end
    end
    if not next(itemNames) then return end

    -- Variables
    local currentWeapon, character = nil, nil
    local pickupRunning, dropRunning, reloadRunning = false, false, false

    -- Utility functions
    local function getRootPart()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        return char:WaitForChild("HumanoidRootPart")
    end

    local function updateCurrentWeapon()
        if not character then return end
        for _ = 1, 3 do
            currentWeapon = nil
            for _, child in pairs(character:GetChildren()) do
                if child.ClassName == "Tool" then
                    currentWeapon = child
                    print("[AutoReload] Updated weapon:", child.Name)
                    return
                end
            end
            if not currentWeapon then task.wait(0.2) end
        end
        warn("[AutoReload] Failed to find weapon after 3 attempts")
    end

    local function isFirearm(weapon)
        return weapon and gunItems:FindFirstChild(weapon.Name) ~= nil
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
        warn("[AutoReload] Failed to get current ammo from UI")
        return nil
    end

    local function sendReloadEvent(weapon)
        v_u_4.func = v_u_4.func + 1
        local args = {v_u_4.func, "reload_gun", weapon}
        local success, newAmmo = pcall(function() return Get:InvokeServer(unpack(args)) end)
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
                if itemInfo then itemInfo.ammo_amount = newAmmo end
            else
                warn("[AutoReload] Bullets UI element not found")
            end
        else
            warn("[AutoReload] Failed to reload or get new ammo count")
        end
    end

    local function findNearestDroppedItem()
        local rootPart = getRootPart()
        local nearestItem, minDistance = nil, AutoV2.Config.PickupMinDistance
        for _, item in pairs(Workspace:WaitForChild("DroppedItems"):GetChildren()) do
            if item.ClassName == "Model" and itemNames[item.Name] then
                local primaryPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if primaryPart then
                    local distance = (rootPart.Position - primaryPart.Position).Magnitude
                    if distance <= minDistance then
                        nearestItem, minDistance = item, distance
                    end
                end
            end
        end
        return nearestItem
    end

    local function pickupDroppedItem(item)
        v_u_4.func = v_u_4.func + 1
        pcall(function() Get:InvokeServer(v_u_4.func, "pickup_dropped_item", item) end)
    end

    local function findInventory()
        local itemsFrame = PlayerGui:FindFirstChild("Items")
        if not itemsFrame then return end
        local itemsHolder = itemsFrame:FindFirstChild("ItemsHolder")
        if not itemsHolder then return end
        return itemsHolder:FindFirstChild("ItemsScrollingFrame")
    end

    local function parseInventoryData()
        local inventory = findInventory()
        if not inventory then return nil, nil end
        local guids, itemsToDrop = {}, {}
        for _, item in pairs(inventory:GetChildren()) do
            local itemNameObj = item:FindFirstChild("ItemName")
            if not itemNameObj or not itemNameObj:IsA("TextLabel") then continue end
            local itemName = string.lower(itemNameObj.Text or "Unknown")
            local guid = item.Name
            local itemCount = tonumber(item:FindFirstChild("ItemCount") and item.ItemCount.Text:match("%d+") or 1)
            if guid and AutoV2.Config.ItemsToDrop[itemName] then
                table.insert(guids, guid)
                table.insert(itemsToDrop, {GUID = guid, Item = item, Name = itemName, Count = itemCount})
                if item:IsA("GuiObject") then
                    item.BackgroundTransparency = 1
                    item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
            end
        end
        return guids, itemsToDrop
    end

    local function dropItems(itemsToDrop)
        if not itemsToDrop or #itemsToDrop == 0 then return false end
        for _, itemData in pairs(itemsToDrop) do
            v_u_4.event = v_u_4.event + 1
            pcall(function() Send:FireServer(v_u_4.event, "drop_item", itemData.GUID, itemData.Count) end)
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
                local item = findNearestDroppedItem()
                if item then pickupDroppedItem(item) end
                task.wait(0.03)
            end
        end)
    end

    local function stopAutoPickup() pickupRunning = false end

    local function startAutoDrop()
        if dropRunning then return end
        dropRunning = true
        spawn(function()
            while dropRunning do
                if not AutoV2.Config.UseKeybind then executeDrop() end
                task.wait(1)
            end
        end)
    end

    local function stopAutoDrop() dropRunning = false end

    local function startAutoReload()
        if reloadRunning then return end
        reloadRunning = true
        spawn(function()
            while reloadRunning do
                if currentWeapon and isFirearm(currentWeapon) then
                    local ammo = getCurrentAmmoFromUI()
                    if ammo and ammo <= 0 then sendReloadEvent(currentWeapon) end
                else updateCurrentWeapon() end
                task.wait(0.5)
            end
        end)
    end

    local function stopAutoReload() reloadRunning = false end

    -- Event handlers
    LocalPlayer.CharacterAdded:Connect(function(char)
        character = char
        updateCurrentWeapon()
        if AutoV2.Config.ReloadEnabled then startAutoReload() end
    end)

    if LocalPlayer.Character then
        character = LocalPlayer.Character
        updateCurrentWeapon()
        if AutoV2.Config.ReloadEnabled then startAutoReload() end
    end

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == AutoV2.Config.DropKeybind and not gameProcessed and AutoV2.Config.UseKeybind and AutoV2.Config.DropEnabled then
            executeDrop()
        end
    end)

    -- UI setup
    if UI and UI.Tabs.Auto then
        local autoPickupSection = UI.Tabs.Auto:Section({ Name = "AutoPickup", Side = "Right" })
        autoPickupSection:Header({ Name = "AutoPickup" })
        autoPickupSection:Toggle({
            Name = "Enabled", Default = AutoV2.Config.PickupEnabled,
            Callback = function(v) AutoV2.Config.PickupEnabled = v; v and startAutoPickup() or stopAutoPickup(); notify("Auto Pickup", "Auto-pickup " .. (v and "enabled" or "disabled") .. "!", true) end
        })
        autoPickupSection:Slider({
            Name = "Pickup Radius", Default = AutoV2.Config.PickupMinDistance,
            Minimum = 5, Maximum = 50, Precision = 1,
            Callback = function(v) AutoV2.Config.PickupMinDistance = v; notify("Auto Pickup", "Pickup radius set to " .. v .. " meters!", true) end
        })

        local autoDropSection = UI.Tabs.Auto:Section({ Name = "AutoDrop", Side = "Left" })
        autoDropSection:Header({ Name = "AutoDrop" })
        autoDropSection:Toggle({
            Name = "Enabled", Default = AutoV2.Config.DropEnabled,
            Callback = function(v) AutoV2.Config.DropEnabled = v; v and startAutoDrop() or stopAutoDrop(); notify("Auto Drop", "Auto-drop " .. (v and "enabled" or "disabled") .. "!", true) end
        })
        autoDropSection:Toggle({
            Name = "Use Keybind", Default = AutoV2.Config.UseKeybind,
            Callback = function(v) AutoV2.Config.UseKeybind = v; notify("Auto Drop", "Keybind mode " .. (v and "enabled" or "disabled") .. "!", true) end
        })
        autoDropSection:Keybind({
            Name = "Drop Keybind", Default = AutoV2.Config.DropKeybind,
            Callback = function(v) AutoV2.Config.DropKeybind = v end
        })
        autoDropSection:Dropdown({
            Name = "Items to Drop", Multi = true,
            Options = {"shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin", "bike lock", "bronze mop", "chair leg", "metal pipe", "mop", "pool cue", "rolling pin", "shank", "silver mop", "taser", "wooden board", "bandage", "bull energy", "lockpick", "dice", "brick", "cinder block", "dumbbel plate", "glass", "milkshake", "rock", "soda can"},
            Default = {"shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin"},
            Callback = function(v)
                for k in pairs(AutoV2.Config.ItemsToDrop) do AutoV2.Config.ItemsToDrop[k] = nil end
                for item, selected in pairs(v) do if selected then AutoV2.Config.ItemsToDrop[item] = true end end
                notify("Auto Drop", "Items to drop updated!", true)
            end
        })

        local autoReloadSection = UI.Tabs.Auto:Section({ Name = "AutoReload", Side = "Right" })
        autoReloadSection:Header({ Name = "AutoReload" })
        autoReloadSection:Toggle({
            Name = "Enabled", Default = AutoV2.Config.ReloadEnabled,
            Callback = function(v) AutoV2.Config.ReloadEnabled = v; v and startAutoReload() or stopAutoReload(); notify("Auto Reload", "Auto-reload " .. (v and "enabled" or "disabled") .. "!", true) end
        })
    end
end

return AutoV2
