-- AutoV2.lua
local AutoV2 = {}

-- Module configuration
AutoV2.Config = {
    -- AutoPickup settings
    PickupMinDistance = 20, -- Default pickup radius
    PickupEnabled = false,  -- Toggle for enabling/disabling AutoPickup

    -- AutoDrop settings
    DropEnabled = false,    -- Toggle for enabling/disabling AutoDrop
    UseKeybind = false,     -- Toggle for using keybind for AutoDrop
    DropKeybind = Enum.KeyCode.F, -- Default keybind for AutoDrop
    ItemsToDrop = {         -- Default items to drop (lowercase)
        ["shiesty"] = true,
        ["hacktoolbasic"] = true,
        ["bottle"] = true,
        ["spray can"] = true,
        ["jar"] = true,
        ["bowling pin"] = true
    },

    -- AutoReload settings
    ReloadEnabled = false   -- Toggle for enabling/disabling AutoReload
}

-- Module initialization
function AutoV2.Init(MacLib, Core, notify)
    local Players = Core.Services.Players
    local Workspace = Core.Services.Workspace
    local ReplicatedStorage = Core.Services.ReplicatedStorage
    local UserInputService = Core.Services.UserInputService
    local LocalPlayer = Core.PlayerData.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local Remotes = ReplicatedStorage:WaitForChild("Remotes")
    local Get = Remotes:WaitForChild("Get")
    local Send = Remotes:WaitForChild("Send")

    -- Load GameUI for AutoReload (separate from MacLib)
    local GameUI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Core"):WaitForChild("UI"))

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

    -- Cache DroppedItems for AutoPickup
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then
        warn("[AutoV2] DroppedItems not found in Workspace")
        return
    end

    -- Function to get the current rootPart
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

    -- Function to retrieve item names from ReplicatedStorage.Items (for AutoPickup)
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

    -- Cache item names for AutoPickup
    local itemNames = getItemNames()
    if next(itemNames) == nil then
        warn("[AutoV2] No item names found in ReplicatedStorage.Items")
        return
    end

    -- AutoReload functions
    local currentWeapon = nil
    local character = nil

    local function updateCurrentWeapon()
        if not character then return end
        local maxAttempts = 3
        local attempt = 1
        while attempt <= maxAttempts do
            currentWeapon = nil
            for _, child in ipairs(character:GetChildren()) do
                if child.ClassName == "Tool" then
                    currentWeapon = child
                    print("[AutoReload] Updated weapon:", child.Name)
                    return
                end
            end
            if not currentWeapon and attempt < maxAttempts then
                print("[AutoReload] Weapon not found, retrying... (Attempt", attempt, "of", maxAttempts, ")")
                task.wait(0.2)
                attempt = attempt + 1
            else
                break
            end
        end
        if not currentWeapon then
            warn("[AutoReload] Failed to find weapon after", maxAttempts, "attempts")
        end
    end

    local function isFirearm(weapon)
        if not weapon then return false end
        local gunItems = ReplicatedStorage:WaitForChild("Items"):WaitForChild("gun")
        return gunItems:FindFirstChild(weapon.Name) ~= nil
    end

    local function getCurrentAmmoFromUI()
        local bulletsLabel = GameUI.get("Bullets")
        if bulletsLabel then
            local text = bulletsLabel.Text
            local current = tonumber(text:match("^(%d+)/"))
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
        local args = {
            [1] = v_u_4.func,
            [2] = "reload_gun",
            [3] = weapon
        }
        print("[AutoReload] Sending reload event for", weapon.Name, "with event_id:", v_u_4.func)
        local success, newAmmo = pcall(function()
            return Get:InvokeServer(unpack(args))
        end)
        if success and newAmmo then
            print("[AutoReload] Reload successful, new ammo count:", newAmmo)
            local bulletsLabel = GameUI.get("Bullets")
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

                -- Attempt to sync client-side weapon state
                if weapon then
                    -- Update local attributes if they exist
                    if weapon:GetAttribute("Ammo") then
                        weapon:SetAttribute("Ammo", newAmmo)
                    end
                    -- Look for a local script or module that might manage ammo
                    local weaponScripts = weapon:GetDescendants()
                    for _, script in ipairs(weaponScripts) do
                        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
                            local module = script:IsA("ModuleScript") and require(script) or nil
                            if module and type(module) == "table" then
                                if module.ammo then
                                    module.ammo = newAmmo
                                    print("[AutoReload] Updated local module ammo to:", newAmmo)
                                elseif module.currentAmmo then
                                    module.currentAmmo = newAmmo
                                    print("[AutoReload] Updated local module currentAmmo to:", newAmmo)
                                end
                            end
                        end
                    end
                end
            else
                warn("[AutoReload] Bullets UI element not found")
            end
        else
            warn("[AutoReload] Failed to reload or get new ammo count")
        end
    end

    local function startAutoReload()
        spawn(function()
            while AutoV2.Config.ReloadEnabled do
                if currentWeapon and isFirearm(currentWeapon) then
                    local currentAmmo = getCurrentAmmoFromUI()
                    if currentAmmo and currentAmmo <= 0 then
                        sendReloadEvent(currentWeapon)
                    end
                else
                    updateCurrentWeapon()
                end
                task.wait(0.5)
            end
        end)
    end

    local function stopAutoReload()
        AutoV2.Config.ReloadEnabled = false
    end

    -- AutoPickup functions
    local pickupRunning = false
    local function findNearestDroppedItem()
        local currentRootPart = getRootPart()
        if not currentRootPart then return nil end
        local nearestItem = nil
        local minDistance = AutoV2.Config.PickupMinDistance
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

    local function startAutoPickup()
        if pickupRunning then return end
        pickupRunning = true
        spawn(function()
            while pickupRunning do
                local nearestItem = findNearestDroppedItem()
                if nearestItem then
                    pickupDroppedItem(nearestItem)
                end
                task.wait(0.03)
            end
        end)
    end

    local function stopAutoPickup()
        pickupRunning = false
    end

    -- AutoDrop functions
    local dropRunning = false
    local function findInventory()
        local itemsFrame = PlayerGui:FindFirstChild("Items")
        if not itemsFrame then return nil end
        local itemsHolder = itemsFrame:FindFirstChild("ItemsHolder")
        if not itemsHolder then return nil end
        local itemsScrollingFrame = itemsHolder:FindFirstChild("ItemsScrollingFrame")
        if not itemsScrollingFrame then return nil end
        return itemsScrollingFrame
    end

    local function parseInventoryData()
        local inventory = findInventory()
        if not inventory then return nil, nil end
        local guids = {}
        local itemsToDrop = {}
        for _, item in ipairs(inventory:GetChildren()) do
            local itemNameObj = item:FindFirstChild("ItemName")
            if not itemNameObj then continue end
            local itemName = itemNameObj:IsA("TextLabel") and (itemNameObj.Text or "Unknown") or "Unknown"
            itemName = string.lower(itemName)
            local guid = item.Name
            local itemCountObj = item:FindFirstChild("ItemCount")
            local itemCount = 1
            if itemCountObj and itemCountObj:IsA("TextLabel") then
                itemCount = tonumber(itemCountObj.Text:match("%d+")) or 1
            end
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
        return guids, itemsToDrop
    end

    local function dropItems(itemsToDrop)
        if not itemsToDrop or #itemsToDrop == 0 then return false end
        for _, itemData in ipairs(itemsToDrop) do
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
        if not guids or not itemsToDrop then return end
        local success = dropItems(itemsToDrop)
        if success then
            notify("Auto Drop", "Items dropped successfully!", true)
        end
    end

    local function startAutoDrop()
        if dropRunning then return end
        dropRunning = true
        spawn(function()
            while dropRunning do
                if not AutoV2.Config.UseKeybind then
                    executeDrop()
                end
                task.wait(1)
            end
        end)
    end

    local function stopAutoDrop()
        dropRunning = false
    end

    -- Keybind handler for AutoDrop
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if input.KeyCode == AutoV2.Config.DropKeybind and not gameProcessedEvent and AutoV2.Config.UseKeybind and AutoV2.Config.DropEnabled then
            task.spawn(executeDrop)
        end
    end)

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

    -- UI setup with MacLib
    if MacLib and MacLib.Tabs and MacLib.Tabs.Auto then
        local autoPickupSection = MacLib.Tabs.Auto:Section({ Name = "AutoPickup", Side = "Right" })
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
            Precision = 0, -- Ensure integer values
            Callback = function(value)
                AutoV2.Config.PickupMinDistance = value
                notify("Auto Pickup", "Pickup radius set to " .. value .. " meters!", true)
            end
        })

        local autoDropSection = MacLib.Tabs.Auto:Section({ Name = "AutoDrop", Side = "Left" })
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
            Options = {
                "shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin",
                "bike lock", "bronze mop", "chair leg", "metal pipe", "mop", "pool cue",
                "rolling pin", "shank", "silver mop", "taser", "wooden board", "bandage",
                "bull energy", "lockpick", "dice", "brick", "cinder block", "dumbbel plate",
                "glass", "milkshake", "rock", "soda can"
            },
            Default = { "shiesty", "hacktoolbasic", "bottle", "spray can", "jar", "bowling pin" },
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

        local autoReloadSection = MacLib.Tabs.Auto:Section({ Name = "AutoReload", Side = "Right" })
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
