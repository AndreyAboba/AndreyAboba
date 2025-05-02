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
    ItemsToDrop = {         -- Default items to drop
        ["Shiesty"] = true,
        ["HackToolBasic"] = true,
        ["Bottle"] = true,
        ["Spray Can"] = true,
        ["Jar"] = true,
        ["Bowling pin"] = true
    }
}

-- Module initialization
function AutoV2.Init(UI, Core, notify)
    local Players = Core.Services.Players
    local Workspace = Core.Services.Workspace
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
        return
    end

    -- Cache DroppedItems for AutoPickup
    local droppedItems = Workspace:FindFirstChild("DroppedItems")
    if not droppedItems then
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
        return
    end

    -- Function to find the nearest dropped item (for AutoPickup)
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

    -- Function to send pickup request (for AutoPickup)
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

    -- Auto-pickup function
    local pickupRunning = false
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

    -- Function to find the inventory (for AutoDrop)
    local function findInventory()
        local itemsFrame = PlayerGui:FindFirstChild("Items")
        if not itemsFrame then return nil end

        local itemsHolder = itemsFrame:FindFirstChild("ItemsHolder")
        if not itemsHolder then return nil end

        local itemsScrollingFrame = itemsHolder:FindFirstChild("ItemsScrollingFrame")
        if not itemsScrollingFrame then return nil end

        return itemsScrollingFrame
    end

    -- Function to parse inventory data (for AutoDrop)
    local function parseInventoryData()
        local inventory = findInventory()
        if not inventory then return nil, nil end

        local guids = {}
        local itemsToDrop = {}

        for _, item in ipairs(inventory:GetChildren()) do
            local itemNameObj = item:FindFirstChild("ItemName")
            if not itemNameObj then continue end

            local itemName = itemNameObj:IsA("TextLabel") and (itemNameObj.Text or "Unknown") or "Unknown"
            local guid = item.Name

            -- Extract item count
            local itemCountObj = item:FindFirstChild("ItemCount")
            local itemCount = 1
            if itemCountObj and itemCountObj:IsA("TextLabel") then
                itemCount = tonumber(itemCountObj.Text:match("%d+")) or 1
            end

            if guid and AutoV2.Config.ItemsToDrop[itemName] then
                table.insert(guids, guid)
                table.insert(itemsToDrop, {GUID = guid, Item = item, Name = itemName, Count = itemCount})
                -- Reset properties to prevent highlighting
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

    -- Function to drop items via RemoteEvent (for AutoDrop)
    local function dropItems(itemsToDrop)
        if not itemsToDrop or #itemsToDrop == 0 then
            return false
        end

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

    -- Function to execute dropping items (for AutoDrop)
    local function executeDrop()
        local guids, itemsToDrop = parseInventoryData()
        if not guids or not itemsToDrop then return end
        local success = dropItems(itemsToDrop)
        if success then
            notify("Auto Drop", "Items dropped successfully!", true)
        end
    end

    -- Auto-drop function (runs continuously if not using keybind)
    local dropRunning = false
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

    -- UI setup
    if UI and UI.Tabs.Auto then
        -- Section for AutoPickup
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
            Callback = function(value)
                AutoV2.Config.PickupMinDistance = value
                notify("Auto Pickup", "Pickup radius set to " .. value .. " meters!", true)
            end
        })

        -- Section for AutoDrop
        local autoDropSection = UI.Tabs.Auto:Section({ Name = "AutoDrop", Side = "Right" })
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
                notify("Auto Drop", "Drop keybind set to " .. tostring(value) .. "!", true)
            end
        })

        autoDropSection:Dropdown({
            Name = "Items to Drop",
            Multi = true,
            Options = {
                "Shiesty", "HackToolBasic", "Bottle", "Spray Can", "Jar", "Bowling pin",
                "Bike lock", "Bronze Mop", "Chair leg", "Metal Pipe", "Mop", "Pool Cue",
                "Rolling Pin", "Shank", "Silver Mop", "Taser", "Wooden Board", "Bandage",
                "Bull Energy", "Lockpick", "Dice", "Brick", "Cinder Block", "Dumbbel Plate",
                "Glass", "Milkshake", "Rock", "Soda Can"
            },
            Default = { "Shiesty", "HackToolBasic", "Bottle", "Spray Can", "Jar", "Bowling pin" },
            Callback = function(value)
                -- Clear current selection
                for key in pairs(AutoV2.Config.ItemsToDrop) do
                    AutoV2.Config.ItemsToDrop[key] = nil
                end
                -- Update with selected items (value is a table of {item = true})
                for item, enabled in pairs(value) do
                    if enabled then
                        AutoV2.Config.ItemsToDrop[item] = true
                    end
                end
                notify("Auto Drop", "Items to drop updated!", true)
            end
        })
    end
end

return AutoV2
